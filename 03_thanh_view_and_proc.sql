-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3 (PHAN CUA THANH)
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: 03_thanh_view_and_proc.sql (Views tong hop & Stored Procedure check-in)
-- QUY UOC: SQLStyle.guide / Google SQL Style Guide (snake_case, UPPERCASE keywords)
-- ============================================================================

USE gym_management_db;
GO

-- ============================================================================
-- VIEW 1: dbo.vw_member_billing_overview
-- Muc dich: Tong hop ho so hoi vien, the quet, hop dong moi nhat, trang thai
--           hieu luc va tong tien thanh toan / cong no.
-- ============================================================================
IF OBJECT_ID('dbo.vw_member_billing_overview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_member_billing_overview;
GO

CREATE VIEW dbo.vw_member_billing_overview
AS
WITH latest_membership AS (
    SELECT
        ms.membership_id,
        ms.member_id,
        ms.plan_id,
        ms.start_date,
        ms.end_date,
        ROW_NUMBER() OVER (
            PARTITION BY ms.member_id
            ORDER BY ms.end_date DESC, ms.membership_id DESC
        ) AS rn
    FROM dbo.membership AS ms
),
member_billing_totals AS (
    SELECT
        ms.member_id,
        SUM(CASE WHEN bl.payment_status = 'SUCCESS' THEN bl.amount ELSE 0 END) AS tong_da_thanh_toan,
        SUM(CASE WHEN bl.payment_status = 'PENDING' THEN bl.amount ELSE 0 END) AS tong_cho_thanh_toan,
        SUM(CASE WHEN bl.payment_status = 'FAILED'  THEN bl.amount ELSE 0 END) AS tong_thanh_toan_loi
    FROM dbo.membership AS ms
    LEFT JOIN dbo.billing_log AS bl
        ON bl.membership_id = ms.membership_id
    GROUP BY ms.member_id
)
SELECT
    m.member_id AS ma_hoi_vien,
    m.full_name AS ho_ten,
    m.email,
    mc.card_id AS ma_the,
    COALESCE(mc.status, 'NO_CARD') AS trang_thai_the,
    mp.name AS goi_tap_gan_nhat,
    lm.start_date AS ngay_bat_dau,
    lm.end_date AS ngay_het_han,
    CASE
        WHEN lm.membership_id IS NULL THEN N'Chưa đăng ký gói'
        WHEN GETDATE() > lm.end_date THEN N'Đã hết hạn'
        WHEN GETDATE() < lm.start_date THEN N'Chưa kích hoạt'
        WHEN DATEDIFF(DAY, GETDATE(), lm.end_date) <= 7 THEN N'Sắp hết hạn (<= 7 ngày)'
        ELSE N'Đang hiệu lực'
    END AS tinh_trang_hop_dong,
    COALESCE(mbt.tong_da_thanh_toan, 0) AS tong_da_thanh_toan,
    COALESCE(mbt.tong_cho_thanh_toan, 0) AS tong_cho_thanh_toan,
    COALESCE(mbt.tong_thanh_toan_loi, 0) AS tong_thanh_toan_loi
FROM dbo.member AS m
LEFT JOIN dbo.membership_card AS mc
    ON mc.member_id = m.member_id
LEFT JOIN latest_membership AS lm
    ON lm.member_id = m.member_id
   AND lm.rn = 1
LEFT JOIN dbo.membership_plan AS mp
    ON mp.plan_id = lm.plan_id
LEFT JOIN member_billing_totals AS mbt
    ON mbt.member_id = m.member_id;
GO

-- ============================================================================
-- VIEW 2: dbo.vw_equipment_maintenance_status
-- Muc dich: Theo doi tinh trang kha dung hien tai cua tung thiet bi (BR_16)
-- ============================================================================
IF OBJECT_ID('dbo.vw_equipment_maintenance_status', 'V') IS NOT NULL
    DROP VIEW dbo.vw_equipment_maintenance_status;
GO

CREATE VIEW dbo.vw_equipment_maintenance_status
AS
SELECT
    e.equipment_id AS ma_thiet_bi,
    e.name AS ten_thiet_bi,
    e.room_id AS ma_phong,
    COUNT(ml.log_id) AS so_lan_bao_tri,
    MAX(ml.start_date) AS lan_bao_tri_gan_nhat,
    CASE
        WHEN SUM(CASE WHEN ml.log_id IS NOT NULL AND ml.end_date IS NULL THEN 1 ELSE 0 END) > 0
            THEN N'ĐANG BẢO TRÌ (CẤM SỬ DỤNG)'
        ELSE N'KHẢ DỤNG'
    END AS trang_thai_kha_dung
FROM dbo.equipment AS e
LEFT JOIN dbo.maintenance_log AS ml
    ON ml.equipment_id = e.equipment_id
GROUP BY
    e.equipment_id,
    e.name,
    e.room_id;
GO

-- ============================================================================
-- STORED PROCEDURE: dbo.sp_check_in_gym
-- Muc dich: Kiem tra the vat ly (BR_13) va hieu luc hop dong (BR_03, BR_14)
--           truoc khi ghi nhan luot check-in vao bang dbo.gym_visit.
-- ============================================================================
IF OBJECT_ID('dbo.sp_check_in_gym', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_check_in_gym;
GO

CREATE PROCEDURE dbo.sp_check_in_gym
    @card_id INT,
    @status_code INT OUTPUT,
    @message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @member_id INT;
    DECLARE @member_name NVARCHAR(100);
    DECLARE @card_status VARCHAR(20);
    DECLARE @active_membership_count INT;

    SELECT
        @member_id = mc.member_id,
        @card_status = mc.status,
        @member_name = m.full_name
    FROM dbo.membership_card AS mc
    INNER JOIN dbo.member AS m
        ON m.member_id = mc.member_id
    WHERE mc.card_id = @card_id;

    IF @member_id IS NULL
    BEGIN
        SET @status_code = 404;
        SET @message = N'Thẻ không tồn tại trên hệ thống.';
        RETURN;
    END;

    IF @card_status <> 'ACTIVE'
    BEGIN
        SET @status_code = 403;
        SET @message = CONCAT(N'BR_13: Thẻ đang ở trạng thái ', @card_status, N', không được phép check-in.');
        RETURN;
    END;

    SELECT @active_membership_count = COUNT(*)
    FROM dbo.membership AS ms
    WHERE ms.member_id = @member_id
      AND GETDATE() BETWEEN ms.start_date AND ms.end_date;

    IF @active_membership_count = 0
    BEGIN
        SET @status_code = 402;
        SET @message = N'BR_14: Hợp đồng gói tập đã hết hạn hoặc chưa kích hoạt.';
        RETURN;
    END;

    INSERT INTO dbo.gym_visit (member_id, check_in_time)
    VALUES (@member_id, GETDATE());

    SET @status_code = 200;
    SET @message = CONCAT(N'Check-in thành công! Xin chào hội viên ', @member_name, N'.');
END;
GO

-- Kiem tra nhanh 2 View vua tao:
SELECT * FROM dbo.vw_member_billing_overview ORDER BY ma_hoi_vien;
SELECT * FROM dbo.vw_equipment_maintenance_status ORDER BY ma_phong, ma_thiet_bi;
GO
