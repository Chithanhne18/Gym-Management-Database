-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3 (PHAN CUA THANH)
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: 04_thanh_complex_queries.sql (6 truy van phuc tap: JOIN, Subquery, Aggregation)
-- QUY UOC: SQLStyle.guide / Google SQL Style Guide (snake_case, UPPERCASE keywords)
-- ============================================================================

USE gym_management_db;
GO

/* ============================================================================
   QUERY 1. THONG KE DOANH THU THUC THU VA CONG NO THEO TUNG GOI TAP
   Ky thuat: Multi-table LEFT JOIN + Conditional Aggregation (SUM/CASE) + GROUP BY
   ============================================================================ */
SELECT
    mp.plan_id AS ma_goi,
    mp.name AS ten_goi_tap,
    mp.price AS don_gia_niem_yet,
    COUNT(DISTINCT ms.membership_id) AS so_hop_dong_da_ban,
    COUNT(bl.billing_id) AS tong_hoa_don_phat_sinh,
    COALESCE(SUM(CASE WHEN bl.payment_status = 'SUCCESS' THEN bl.amount ELSE 0 END), 0) AS doanh_thu_thuc_thu,
    COALESCE(SUM(CASE WHEN bl.payment_status = 'PENDING' THEN bl.amount ELSE 0 END), 0) AS tien_dang_cho_an_han,
    COALESCE(SUM(CASE WHEN bl.payment_status = 'FAILED'  THEN bl.amount ELSE 0 END), 0) AS tien_thanh_toan_that_bai
FROM dbo.membership_plan AS mp
LEFT JOIN dbo.membership AS ms
    ON ms.plan_id = mp.plan_id
LEFT JOIN dbo.billing_log AS bl
    ON bl.membership_id = ms.membership_id
GROUP BY
    mp.plan_id,
    mp.name,
    mp.price
ORDER BY
    doanh_thu_thuc_thu DESC,
    so_hop_dong_da_ban DESC;
GO


/* ============================================================================
   QUERY 2. HOI VIEN CO HOP DONG SAP HET HAN TRONG 7 NGAY TOI NHUNG CHUA GIA HAN
   Ky thuat: JOIN + Date Calculation + Correlated Subquery (NOT EXISTS)
   ============================================================================ */
SELECT
    m.member_id AS ma_hoi_vien,
    m.full_name AS ho_ten,
    m.email,
    mp.name AS goi_dang_dung,
    ms.end_date AS ngay_het_han,
    DATEDIFF(DAY, GETDATE(), ms.end_date) AS so_ngay_con_lai
FROM dbo.member AS m
INNER JOIN dbo.membership AS ms
    ON ms.member_id = m.member_id
INNER JOIN dbo.membership_plan AS mp
    ON mp.plan_id = ms.plan_id
WHERE ms.end_date >= GETDATE()
  AND ms.end_date <= DATEADD(DAY, 7, GETDATE())
  AND NOT EXISTS (
      -- Loai tru nhung hoi vien da mua hop dong moi co ngay ket thuc sau hop dong hien tai
      SELECT 1
      FROM dbo.membership AS ms_next
      WHERE ms_next.member_id = m.member_id
        AND ms_next.membership_id <> ms.membership_id
        AND ms_next.end_date > ms.end_date
  )
ORDER BY
    ms.end_date ASC;
GO


/* ============================================================================
   QUERY 3. HOI VIEN CO SO LUOT CHECK-IN CAO HON MUC TRUNG BINH PHONG TAP
   Ky thuat: CTE + GROUP BY + HAVING + Scalar Subquery (AVG)
   ============================================================================ */
;WITH member_visit_counts AS (
    SELECT
        m.member_id,
        m.full_name,
        m.email,
        COUNT(gv.visit_id) AS so_luot_check_in
    FROM dbo.member AS m
    LEFT JOIN dbo.gym_visit AS gv
        ON gv.member_id = m.member_id
    GROUP BY
        m.member_id,
        m.full_name,
        m.email
)
SELECT
    mvc.member_id AS ma_hoi_vien,
    mvc.full_name AS ho_ten,
    mvc.email,
    mvc.so_luot_check_in,
    (
        SELECT CAST(AVG(CAST(cnt AS DECIMAL(10, 2))) AS DECIMAL(10, 2))
        FROM (
            SELECT COUNT(*) AS cnt
            FROM dbo.gym_visit
            GROUP BY member_id
        ) AS sub_avg
    ) AS trung_binh_luot_tap
FROM member_visit_counts AS mvc
WHERE mvc.so_luot_check_in > (
    SELECT AVG(CAST(cnt AS FLOAT))
    FROM (
        SELECT COUNT(*) AS cnt
        FROM dbo.gym_visit
        GROUP BY member_id
    ) AS sub_avg
)
ORDER BY
    mvc.so_luot_check_in DESC,
    mvc.member_id ASC;
GO


/* ============================================================================
   QUERY 4. HOI VIEN KHONG CON HOP DONG HIEU LUC HOAC THE BI KHOA NHUNG VAN CO BOOKING CONFIRMED
   Ky thuat: Multi-table JOIN + NOT EXISTS + Kiem toan vi pham BR_03 / BR_13 / BR_14
   ============================================================================ */
SELECT
    b.booking_id AS ma_dat_cho,
    m.member_id AS ma_hoi_vien,
    m.full_name AS ho_ten,
    COALESCE(mc.status, 'NO_CARD') AS trang_thai_the,
    COALESCE(gc.class_name, N'PT 1-kèm-1') AS mon_hoc,
    s.start_time AS gio_hoc,
    CASE
        WHEN mc.status <> 'ACTIVE' THEN N'Thẻ không ở trạng thái ACTIVE'
        ELSE N'Không có hợp đồng còn hạn'
    END AS ly_do_canh_bao
FROM dbo.booking AS b
INNER JOIN dbo.member AS m
    ON m.member_id = b.member_id
INNER JOIN dbo.[session] AS s
    ON s.session_id = b.session_id
LEFT JOIN dbo.gym_class AS gc
    ON gc.class_id = s.class_id
LEFT JOIN dbo.membership_card AS mc
    ON mc.member_id = m.member_id
WHERE b.status = 'CONFIRMED'
  AND (
      COALESCE(mc.status, 'NO_CARD') <> 'ACTIVE'
      OR NOT EXISTS (
          SELECT 1
          FROM dbo.membership AS ms
          WHERE ms.member_id = m.member_id
            AND GETDATE() BETWEEN ms.start_date AND ms.end_date
      )
  )
ORDER BY
    s.start_time ASC;
GO


/* ============================================================================
   QUERY 5. THIET BI DANG HONG / BAO TRI VA LICH SU BAO TRI TICH LUY
   Ky thuat: JOIN + Correlated Subquery + Aggregation (COUNT, SUM, DATEDIFF)
   ============================================================================ */
SELECT
    e.equipment_id AS ma_thiet_bi,
    e.name AS ten_thiet_bi,
    e.room_id AS ma_phong,
    r.capacity AS suc_chua_phong,
    ml_open.start_date AS ngay_bao_hong_hien_tai,
    DATEDIFF(DAY, ml_open.start_date, GETDATE()) AS so_ngay_dang_ngung_hoat_dong,
    (
        SELECT COUNT(*)
        FROM dbo.maintenance_log AS ml_all
        WHERE ml_all.equipment_id = e.equipment_id
    ) AS tong_so_lan_tung_bao_tri,
    (
        SELECT COALESCE(SUM(DATEDIFF(HOUR, ml_hist.start_date, COALESCE(ml_hist.end_date, GETDATE()))), 0)
        FROM dbo.maintenance_log AS ml_hist
        WHERE ml_hist.equipment_id = e.equipment_id
    ) AS tong_gio_bao_tri_tich_luy
FROM dbo.equipment AS e
INNER JOIN dbo.room AS r
    ON r.room_id = e.room_id
INNER JOIN dbo.maintenance_log AS ml_open
    ON ml_open.equipment_id = e.equipment_id
   AND ml_open.end_date IS NULL
ORDER BY
    so_ngay_dang_ngung_hoat_dong DESC,
    tong_so_lan_tung_bao_tri DESC;
GO


/* ============================================================================
   QUERY 6. BAO CAO TONG HOP 360 DO HOAT DONG CUA TUNG HOI VIEN
   Ky thuat: Multiple CTEs + LEFT JOIN + Multi-metric Aggregation
   ============================================================================ */
;WITH visit_summary AS (
    SELECT
        member_id,
        COUNT(*) AS tong_luot_tap,
        MAX(check_in_time) AS lan_tap_gan_nhat
    FROM dbo.gym_visit
    GROUP BY member_id
),
booking_summary AS (
    SELECT
        member_id,
        COUNT(CASE WHEN status = 'CONFIRMED' THEN 1 END) AS so_ca_da_dat,
        COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) AS so_ca_da_huy
    FROM dbo.booking
    GROUP BY member_id
),
payment_summary AS (
    SELECT
        ms.member_id,
        COUNT(DISTINCT ms.membership_id) AS so_hop_dong_da_ky,
        COALESCE(SUM(CASE WHEN bl.payment_status = 'SUCCESS' THEN bl.amount ELSE 0 END), 0) AS tong_chi_tieu
    FROM dbo.membership AS ms
    LEFT JOIN dbo.billing_log AS bl
        ON bl.membership_id = ms.membership_id
    GROUP BY ms.member_id
)
SELECT
    m.member_id AS ma_hoi_vien,
    m.full_name AS ho_ten,
    COALESCE(ps.so_hop_dong_da_ky, 0) AS so_hop_dong_da_ky,
    COALESCE(ps.tong_chi_tieu, 0) AS tong_chi_tieu_thanh_cong,
    COALESCE(vs.tong_luot_tap, 0) AS tong_luot_check_in,
    vs.lan_tap_gan_nhat,
    COALESCE(bs.so_ca_da_dat, 0) AS so_ca_da_dat,
    COALESCE(bs.so_ca_da_huy, 0) AS so_ca_da_huy
FROM dbo.member AS m
LEFT JOIN payment_summary AS ps
    ON ps.member_id = m.member_id
LEFT JOIN visit_summary AS vs
    ON vs.member_id = m.member_id
LEFT JOIN booking_summary AS bs
    ON bs.member_id = m.member_id
ORDER BY
    tong_chi_tieu_thanh_cong DESC,
    tong_luot_check_in DESC;
GO
