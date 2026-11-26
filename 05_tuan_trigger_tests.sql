USE gym_management_db;
GO

/*
   CHAY SAU KHI DA NAP seed_data.sql VA TAO TRIGGER.
   Du lieu mau co session_id = 1:
   - trainer_id = 1, room_id = 101, 08:00-09:00 ngay mai.
   - session_id = 3 cung HLV 1, 09:30-10:30.
   Room 105 va trainer 5 duoc de trong de phuc vu test.
*/


/* ============================================================
   TEST CASE 1 - BR_07
   Cung HLV 1, thoi gian giao voi session 1.
   Dung room 105 de khong phat sinh BR_08.
   ============================================================ */
DECLARE @test1_start DATETIME;
DECLARE @test1_end DATETIME;

SELECT
    @test1_start = DATEADD(MINUTE, 30, start_time),
    @test1_end = DATEADD(MINUTE, 90, start_time)
FROM dbo.[session]
WHERE session_id = 1;

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.[session] (
        class_id, room_id, trainer_id, start_time, end_time
    )
    VALUES (
        1, 105, 1, @test1_start, @test1_end
    );

    PRINT N'TEST 1 THAT BAI: Trigger khong chan ca trung lich HLV.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 1 - Da chan dung BR_07: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================
   TEST CASE 2 - BR_08
   Cung phong 101, thoi gian giao voi session 1.
   Dung trainer 5 de khong phat sinh BR_07/BR_09.
   ============================================================ */
DECLARE @test2_start DATETIME;
DECLARE @test2_end DATETIME;

SELECT
    @test2_start = DATEADD(MINUTE, 30, start_time),
    @test2_end = DATEADD(MINUTE, 90, start_time)
FROM dbo.[session]
WHERE session_id = 1;

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.[session] (
        class_id, room_id, trainer_id, start_time, end_time
    )
    VALUES (
        1, 101, 5, @test2_start, @test2_end
    );

    PRINT N'TEST 2 THAT BAI: Trigger khong chan ca trung phong.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 2 - Da chan dung BR_08: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================
   TEST CASE 3 - BR_09
   HLV 1 ket thuc session 1 luc 09:00.
   Ca moi bat dau 09:05 va ket thuc 09:20.
   Session 3 bat dau 09:30, nen khoang nghi giua ca moi va
   session 3 cung chi 10 phut. Cac khoang nay khong giao nhau,
   do do Trigger phai chan boi BR_09.
   ============================================================ */
DECLARE @test3_start DATETIME;
DECLARE @test3_end DATETIME;

SELECT
    @test3_start = DATEADD(MINUTE, 5, end_time),
    @test3_end = DATEADD(MINUTE, 20, end_time)
FROM dbo.[session]
WHERE session_id = 1;

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.[session] (
        class_id, room_id, trainer_id, start_time, end_time
    )
    VALUES (
        1, 105, 1, @test3_start, @test3_end
    );

    PRINT N'TEST 3 THAT BAI: Trigger khong kiem tra khoang nghi 15 phut.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT N'TEST 3 - Da chan dung BR_09: ' + ERROR_MESSAGE();
END CATCH;
GO
