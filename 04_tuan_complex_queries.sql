USE gym_management_db;
GO

/* ============================================================
   QUERY 1. LICH TRINH CHI TIET TOAN BO PHONG TAP THEO TUAN
   JOIN: session, gym_class, room, trainer.
   @week_start la ngay bat dau tuan; @week_end la moc ket thuc.
   ============================================================ */
DECLARE @week_start DATE = DATEADD(DAY, 1 - DATEPART(WEEKDAY, CAST(GETDATE() AS DATE)),
                                   CAST(GETDATE() AS DATE));
DECLARE @week_end DATE = DATEADD(DAY, 7, @week_start);

SELECT
    s.session_id AS ma_ca,
    COALESCE(gc.class_name, N'PT 1-kèm-1') AS mon_hoc,
    t.trainer_id,
    t.full_name AS ten_hlv,
    r.room_id AS ma_phong,
    r.capacity AS suc_chua,
    s.start_time,
    s.end_time
FROM dbo.[session] AS s
LEFT JOIN dbo.gym_class AS gc
    ON gc.class_id = s.class_id
INNER JOIN dbo.room AS r
    ON r.room_id = s.room_id
INNER JOIN dbo.trainer AS t
    ON t.trainer_id = s.trainer_id
WHERE s.start_time >= @week_start
  AND s.start_time < @week_end
ORDER BY s.start_time, r.room_id, t.full_name;
GO


/* ============================================================
   QUERY 2. CAC CA DAY NHOM CO TY LE LAP DAY >= 80%
   Khong tinh booking da CANCELLED.
   ============================================================ */
SELECT
    s.session_id AS ma_ca,
    gc.class_name AS mon_hoc,
    r.room_id AS ma_phong,
    r.capacity AS suc_chua,
    COUNT(b.booking_id) AS so_nguoi_da_dat,
    CAST(
        100.0 * COUNT(b.booking_id) / NULLIF(r.capacity, 0)
        AS DECIMAL(5, 2)
    ) AS ty_le_lap_day
FROM dbo.[session] AS s
INNER JOIN dbo.gym_class AS gc
    ON gc.class_id = s.class_id
INNER JOIN dbo.room AS r
    ON r.room_id = s.room_id
LEFT JOIN dbo.booking AS b
    ON b.session_id = s.session_id
   AND b.status = 'CONFIRMED'
GROUP BY
    s.session_id,
    gc.class_name,
    r.room_id,
    r.capacity
HAVING COUNT(b.booking_id) * 100.0 / NULLIF(r.capacity, 0) >= 80
ORDER BY ty_le_lap_day DESC, so_nguoi_da_dat DESC;
GO


/* ============================================================
   QUERY 3. TOP HLV THEO TONG GIO DAY VA LUOT DAT CHO TRONG THANG
   Tach hai CTE de tranh nhan SUM(thoi_luong) theo so booking.
   Tinh ca day co start_time nam trong thang duoc chon.
   ============================================================ */
DECLARE @month_start DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @next_month DATE = DATEADD(MONTH, 1, @month_start);

;WITH trainer_hours AS (
    SELECT
        s.trainer_id,
        SUM(DATEDIFF(MINUTE, s.start_time, s.end_time)) / 60.0 AS tong_gio_day,
        COUNT(s.session_id) AS tong_so_ca
    FROM dbo.[session] AS s
    WHERE s.start_time >= @month_start
      AND s.start_time < @next_month
    GROUP BY s.trainer_id
),
trainer_bookings AS (
    SELECT
        s.trainer_id,
        COUNT(b.booking_id) AS tong_luot_dat
    FROM dbo.[session] AS s
    INNER JOIN dbo.booking AS b
        ON b.session_id = s.session_id
       AND b.status = 'CONFIRMED'
    WHERE s.start_time >= @month_start
      AND s.start_time < @next_month
    GROUP BY s.trainer_id
)
SELECT
    t.trainer_id,
    t.full_name AS ten_hlv,
    COALESCE(h.tong_gio_day, 0) AS tong_gio_day,
    COALESCE(h.tong_so_ca, 0) AS tong_so_ca,
    COALESCE(b.tong_luot_dat, 0) AS tong_luot_hoc_vien_dat,
    DENSE_RANK() OVER (
        ORDER BY COALESCE(h.tong_gio_day, 0) DESC,
                 COALESCE(b.tong_luot_dat, 0) DESC
    ) AS xep_hang
FROM dbo.trainer AS t
LEFT JOIN trainer_hours AS h
    ON h.trainer_id = t.trainer_id
LEFT JOIN trainer_bookings AS b
    ON b.trainer_id = t.trainer_id
ORDER BY xep_hang, t.full_name;
GO


/* ============================================================
   QUERY 4A. PHONG TAP KHONG CO CA NAO TRONG KHUNG GIO
   Hai khoang thoi gian giao nhau neu:
   session.start_time < @window_end AND session.end_time > @window_start.
   ============================================================ */
DECLARE @window_start DATETIME = DATEADD(HOUR, 8, DATEADD(DAY, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)));
DECLARE @window_end DATETIME = DATEADD(HOUR, 10, DATEADD(DAY, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)));

SELECT
    r.room_id,
    r.capacity
FROM dbo.room AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.[session] AS s
    WHERE s.room_id = r.room_id
      AND s.start_time < @window_end
      AND s.end_time > @window_start
)
ORDER BY r.room_id;
GO


/* ============================================================
   QUERY 4B. HLV KHONG CO CA NAO TRONG CUNG KHUNG GIO
   ============================================================ */
DECLARE @trainer_window_start DATETIME = DATEADD(HOUR, 8, DATEADD(DAY, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)));
DECLARE @trainer_window_end DATETIME = DATEADD(HOUR, 10, DATEADD(DAY, 1, CAST(CAST(GETDATE() AS DATE) AS DATETIME)));

SELECT
    t.trainer_id,
    t.full_name
FROM dbo.trainer AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.[session] AS s
    WHERE s.trainer_id = t.trainer_id
      AND s.start_time < @trainer_window_end
      AND s.end_time > @trainer_window_start
)
ORDER BY t.trainer_id;
GO


/* ============================================================
   QUERY 5. DOI CHIEU SU DUNG THIET BI / BAO TRI / LICH DAY THEO PHONG
   Tach CTE de tranh nhan so luong do JOIN nhieu bang 1-N.
   ============================================================ */
;WITH equipment_stats AS (
    SELECT
        e.room_id,
        COUNT(DISTINCT e.equipment_id) AS tong_thiet_bi
    FROM dbo.equipment AS e
    GROUP BY e.room_id
),
maintenance_stats AS (
    SELECT
        e.room_id,
        COUNT(ml.log_id) AS tong_luot_bao_tri,
        SUM(CASE WHEN ml.end_date IS NULL THEN 1 ELSE 0 END) AS so_thiet_bi_dang_hong,
        SUM(
            DATEDIFF(
                MINUTE,
                ml.start_date,
                COALESCE(ml.end_date, GETDATE())
            )
        ) / 60.0 AS tong_gio_bao_tri
    FROM dbo.equipment AS e
    LEFT JOIN dbo.maintenance_log AS ml
        ON ml.equipment_id = e.equipment_id
    GROUP BY e.room_id
),
session_stats AS (
    SELECT
        s.room_id,
        COUNT(s.session_id) AS tong_so_ca,
        SUM(DATEDIFF(MINUTE, s.start_time, s.end_time)) / 60.0 AS tong_gio_su_dung_phong
    FROM dbo.[session] AS s
    GROUP BY s.room_id
)
SELECT
    r.room_id,
    r.capacity,
    COALESCE(es.tong_thiet_bi, 0) AS tong_thiet_bi,
    COALESCE(ms.tong_luot_bao_tri, 0) AS tong_luot_bao_tri,
    COALESCE(ms.so_thiet_bi_dang_hong, 0) AS so_thiet_bi_dang_hong,
    COALESCE(ms.tong_gio_bao_tri, 0) AS tong_gio_bao_tri,
    COALESCE(ss.tong_so_ca, 0) AS tong_so_ca,
    COALESCE(ss.tong_gio_su_dung_phong, 0) AS tong_gio_su_dung_phong
FROM dbo.room AS r
LEFT JOIN equipment_stats AS es
    ON es.room_id = r.room_id
LEFT JOIN maintenance_stats AS ms
    ON ms.room_id = r.room_id
LEFT JOIN session_stats AS ss
    ON ss.room_id = r.room_id
ORDER BY so_thiet_bi_dang_hong DESC,
         tong_gio_su_dung_phong DESC,
         r.room_id;
GO
