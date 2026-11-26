-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3 (PHAN CUA THANH)
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: 02_thanh_trigger.sql (Triggers nghiep vu Booking & Maintenance)
-- QUY UOC: SQLStyle.guide / Google SQL Style Guide (snake_case, UPPERCASE keywords)
-- ============================================================================

USE gym_management_db;
GO

-- ============================================================================
-- TRIGGER 1: trg_check_booking_eligibility
-- Ap dung tren bang dbo.booking (AFTER INSERT, UPDATE)
-- Rang buoc thuc thi:
--   - BR_03 / BR_14: Chi hoi vien co hop dong membership dang con hieu luc moi duoc dat cho CONFIRMED.
--   - BR_10: Ca tap nhom khong duoc vuot qua suc chua (capacity) cua phong.
--   - BR_11: Ca tap ca nhan PT 1-kem-1 (class_id IS NULL) chi co toi da 1 booking CONFIRMED.
-- ============================================================================
IF OBJECT_ID('dbo.trg_check_booking_eligibility', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_check_booking_eligibility;
GO

CREATE TRIGGER dbo.trg_check_booking_eligibility
ON dbo.booking
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chi kiem tra cac dong dat cho o trang thai CONFIRMED
    IF NOT EXISTS (
        SELECT 1
        FROM inserted
        WHERE status = 'CONFIRMED'
    )
        RETURN;

    -- 1. BR_03 & BR_14: Hoi vien phai co it nhat 1 hop dong membership con hieu luc tai thoi diem hien tai
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        WHERE i.status = 'CONFIRMED'
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.membership AS ms
              WHERE ms.member_id = i.member_id
                AND GETDATE() BETWEEN ms.start_date AND ms.end_date
          )
    )
    BEGIN
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 51003,
              N'BR_03: Hội viên chưa có gói tập hoặc hợp đồng đã hết hạn, không thể đặt chỗ.',
              1;
    END;

    -- 2. BR_11: Ca PT 1-kem-1 (class_id IS NULL) chi cho phep toi da 1 booking CONFIRMED
    IF EXISTS (
        SELECT 1
        FROM dbo.booking AS b
        INNER JOIN dbo.[session] AS s
            ON s.session_id = b.session_id
        WHERE b.status = 'CONFIRMED'
          AND s.class_id IS NULL
          AND b.session_id IN (
              SELECT DISTINCT session_id
              FROM inserted
              WHERE status = 'CONFIRMED'
          )
        GROUP BY b.session_id
        HAVING COUNT(*) > 1
    )
    BEGIN
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 51011,
              N'BR_11: Ca tập PT 1-kèm-1 chỉ được phép có tối đa 1 học viên đặt chỗ.',
              1;
    END;

    -- 3. BR_10: Ca lop nhom (class_id IS NOT NULL) khong duoc vuot qua suc chua phong (room.capacity)
    IF EXISTS (
        SELECT 1
        FROM dbo.booking AS b
        INNER JOIN dbo.[session] AS s
            ON s.session_id = b.session_id
        INNER JOIN dbo.room AS r
            ON r.room_id = s.room_id
        WHERE b.status = 'CONFIRMED'
          AND s.class_id IS NOT NULL
          AND b.session_id IN (
              SELECT DISTINCT session_id
              FROM inserted
              WHERE status = 'CONFIRMED'
          )
        GROUP BY b.session_id, r.capacity
        HAVING COUNT(*) > r.capacity
    )
    BEGIN
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 51010,
              N'BR_10: Ca tập đã đầy chỗ (vượt quá sức chứa tối đa của phòng tập).',
              1;
    END;
END;
GO

-- ============================================================================
-- TRIGGER 2: trg_prevent_duplicate_open_maintenance
-- Ap dung tren bang dbo.maintenance_log (AFTER INSERT, UPDATE)
-- Rang buoc thuc thi:
--   - BR_16: Mot thiet bi khong the co nhieu hon 1 phieu bao tri dang mo (end_date IS NULL) cung luc.
-- ============================================================================
IF OBJECT_ID('dbo.trg_prevent_duplicate_open_maintenance', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_prevent_duplicate_open_maintenance;
GO

CREATE TRIGGER dbo.trg_prevent_duplicate_open_maintenance
ON dbo.maintenance_log
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.maintenance_log AS ml
        WHERE ml.end_date IS NULL
          AND ml.equipment_id IN (
              SELECT DISTINCT equipment_id
              FROM inserted
              WHERE end_date IS NULL
          )
        GROUP BY ml.equipment_id
        HAVING COUNT(*) > 1
    )
    BEGIN
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW 51016,
              N'BR_16: Thiết bị này đang có phiếu bảo trì chưa hoàn tất (end_date IS NULL).',
              1;
    END;
END;
GO
