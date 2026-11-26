USE gym_management_db;
GO

IF OBJECT_ID('dbo.vw_session_availability', 'V') IS NOT NULL
    DROP VIEW dbo.vw_session_availability;
GO

CREATE VIEW dbo.vw_session_availability
AS
SELECT
    s.session_id AS ma_ca,
    COALESCE(gc.class_name, N'PT 1-kèm-1') AS mon_hoc,
    t.full_name AS ten_hlv,
    r.room_id AS ma_phong,
    r.capacity AS suc_chua,
    COUNT(CASE WHEN b.status = 'CONFIRMED' THEN 1 END) AS so_nguoi_da_dat,
    CASE
        WHEN r.capacity - COUNT(CASE WHEN b.status = 'CONFIRMED' THEN 1 END) < 0
            THEN 0
        ELSE r.capacity - COUNT(CASE WHEN b.status = 'CONFIRMED' THEN 1 END)
    END AS so_cho_con_trong,
    s.start_time AS thoi_gian_bat_dau,
    s.end_time AS thoi_gian_ket_thuc
FROM dbo.[session] AS s
LEFT JOIN dbo.gym_class AS gc
    ON gc.class_id = s.class_id
INNER JOIN dbo.trainer AS t
    ON t.trainer_id = s.trainer_id
INNER JOIN dbo.room AS r
    ON r.room_id = s.room_id
LEFT JOIN dbo.booking AS b
    ON b.session_id = s.session_id
GROUP BY
    s.session_id,
    gc.class_name,
    t.full_name,
    r.room_id,
    r.capacity,
    s.start_time,
    s.end_time;
GO

-- Xem lich va so cho trong:
SELECT *
FROM dbo.vw_session_availability
ORDER BY thoi_gian_bat_dau, ma_phong;
GO
