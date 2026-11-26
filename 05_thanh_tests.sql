-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3 (PHAN CUA THANH)
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: 05_thanh_tests.sql (Kiem thu Trigger Booking, Maintenance & SP Check-in)
-- LUU Y: Chay sau khi da chay 01_schema_ddl.sql, seed_data.sql,
--        02_thanh_trigger.sql va 03_thanh_view_and_proc.sql.
-- ============================================================================

USE gym_management_db;
GO

/* ============================================================================
   TEST 1 - BR_03: Hoi vien co hop dong HET HAN (member_id = 5) co tinh dat ca 7
   Ky vong: Trigger trg_check_booking_eligibility chan va bao loi 51003.
   ============================================================================ */
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.booking (session_id, member_id, status)
    VALUES (7, 5, 'CONFIRMED');

    PRINT N'TEST 1 THAT BAI: Trigger khong chan hoi vien het han dat cho.';
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 1 PASS - Da chan dung BR_03: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================================
   TEST 2 - BR_10: Ca nhom da DAY CHO (session_id = 5, room 104 capacity = 2,
            da co 2 booking CONFIRMED). Hoi vien con han (member_id = 3) dat them.
   Ky vong: Trigger trg_check_booking_eligibility chan va bao loi 51010.
   ============================================================================ */
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.booking (session_id, member_id, status)
    VALUES (5, 3, 'CONFIRMED');

    PRINT N'TEST 2 THAT BAI: Trigger khong chan ca nhom vuot suc chua.';
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 2 PASS - Da chan dung BR_10: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================================
   TEST 3 - BR_11: Ca PT 1-kem-1 da co 1 nguoi dat (session_id = 4, class_id IS NULL).
            Hoi vien con han (member_id = 2) co tinh dat them vao ca PT 4.
   Ky vong: Trigger trg_check_booking_eligibility chan va bao loi 51011.
   ============================================================================ */
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.booking (session_id, member_id, status)
    VALUES (4, 2, 'CONFIRMED');

    PRINT N'TEST 3 THAT BAI: Trigger khong chan ca PT 1-kem-1 co > 1 booking.';
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 3 PASS - Da chan dung BR_11: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================================
   TEST 4 - BR_16: Mo them phieu bao tri dang mo (end_date IS NULL) cho thiet bi
            equipment_id = 8 (dang co phieu log_id = 5 chua dong).
   Ky vong: Trigger trg_prevent_duplicate_open_maintenance chan va bao loi 51016.
   ============================================================================ */
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.maintenance_log (equipment_id, start_date, end_date)
    VALUES (8, GETDATE(), NULL);

    PRINT N'TEST 4 THAT BAI: Trigger khong chan bao tri trung khi may dang sua.';
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 4 PASS - Da chan dung BR_16: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================================
   TEST 5 - STORED PROCEDURE sp_check_in_gym (BR_13, BR_14)
   Dung Transaction Rollback de khong lam thay doi du lieu gym_visit goc.
   ============================================================================ */
BEGIN TRANSACTION;
    DECLARE @code INT, @msg NVARCHAR(255);

    -- Case A: The 1001 (Thanh - ACTIVE, hop dong con han) -> 200
    EXEC dbo.sp_check_in_gym @card_id = 1001, @status_code = @code OUTPUT, @message = @msg OUTPUT;
    SELECT @code AS [Code_1001], @msg AS [Msg_1001];

    -- Case B: The 1003 (Toan - BLOCKED) -> 403
    EXEC dbo.sp_check_in_gym @card_id = 1003, @status_code = @code OUTPUT, @message = @msg OUTPUT;
    SELECT @code AS [Code_1003], @msg AS [Msg_1003];

    -- Case C: The 1005 (Huy - ACTIVE nhung hop dong het han) -> 402
    EXEC dbo.sp_check_in_gym @card_id = 1005, @status_code = @code OUTPUT, @message = @msg OUTPUT;
    SELECT @code AS [Code_1005], @msg AS [Msg_1005];
ROLLBACK TRANSACTION;
GO
