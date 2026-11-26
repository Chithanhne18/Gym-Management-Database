USE gym_management_db;
GO

IF OBJECT_ID('dbo.trg_prevent_schedule_conflict', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_prevent_schedule_conflict;
GO

CREATE TRIGGER dbo.trg_prevent_schedule_conflict
ON dbo.[session]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    /*
       BR_07: Mot HLV khong the day hai ca co thoi gian giao nhau.
       BR_08: Mot phong khong the duoc su dung boi hai ca co thoi gian giao nhau.
       BR_09: Hai ca lien tiep cua cung HLV phai cach nhau toi thieu 15 phut.

       Trigger xu ly theo tap hop inserted, nen ho tro INSERT/UPDATE nhieu dong.
       Cac dong cu dang duoc UPDATE bi loai khoi phep so sanh.
    */

    -- BR_07: Kiem tra trung lich HLV voi cac ca da ton tai.
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.[session] AS s
            ON s.trainer_id = i.trainer_id
           AND s.session_id <> i.session_id
        WHERE NOT EXISTS (
            SELECT 1
            FROM inserted AS x
            WHERE x.session_id = s.session_id
        )
          AND i.start_time < s.end_time
          AND i.end_time > s.start_time
    )
    OR EXISTS (
        -- BR_07: Kiem tra trung lich giua cac dong trong cung mot lenh.
        SELECT 1
        FROM inserted AS i
        INNER JOIN inserted AS j
            ON i.session_id < j.session_id
           AND i.trainer_id = j.trainer_id
        WHERE i.start_time < j.end_time
          AND i.end_time > j.start_time
    )
    BEGIN
        THROW 51007,
              N'BR_07: Huấn luyện viên đã có ca dạy trùng thời gian.',
              1;
    END;

    -- BR_08: Kiem tra trung lich phong voi cac ca da ton tai.
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.[session] AS s
            ON s.room_id = i.room_id
           AND s.session_id <> i.session_id
        WHERE NOT EXISTS (
            SELECT 1
            FROM inserted AS x
            WHERE x.session_id = s.session_id
        )
          AND i.start_time < s.end_time
          AND i.end_time > s.start_time
    )
    OR EXISTS (
        -- BR_08: Kiem tra trung lich giua cac dong trong cung mot lenh.
        SELECT 1
        FROM inserted AS i
        INNER JOIN inserted AS j
            ON i.session_id < j.session_id
           AND i.room_id = j.room_id
        WHERE i.start_time < j.end_time
          AND i.end_time > j.start_time
    )
    BEGIN
        THROW 51008,
              N'BR_08: Phòng tập đã có ca dạy trùng thời gian.',
              1;
    END;

    -- BR_09: Kiem tra khoang cach giua hai ca cua cung HLV.
    -- Cong thuc doi xung phat hien ca giao nhau va ca cach nhau duoi 15 phut.
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.[session] AS s
            ON s.trainer_id = i.trainer_id
           AND s.session_id <> i.session_id
        WHERE NOT EXISTS (
            SELECT 1
            FROM inserted AS x
            WHERE x.session_id = s.session_id
        )
          AND i.start_time < DATEADD(MINUTE, 15, s.end_time)
          AND s.start_time < DATEADD(MINUTE, 15, i.end_time)
    )
    OR EXISTS (
        -- BR_09: Kiem tra khoang nghi giua cac dong trong cung mot lenh.
        SELECT 1
        FROM inserted AS i
        INNER JOIN inserted AS j
            ON i.session_id < j.session_id
           AND i.trainer_id = j.trainer_id
        WHERE i.start_time < DATEADD(MINUTE, 15, j.end_time)
          AND j.start_time < DATEADD(MINUTE, 15, i.end_time)
    )
    BEGIN
        THROW 51009,
              N'BR_09: Huấn luyện viên phải nghỉ ít nhất 15 phút giữa hai ca.',
              1;
    END;
END;
GO
