-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: seed_data.sql (Du lieu mau DML day du cho 13 bang - MS SQL Server)
-- LUU Y: Chay file sql/01_schema_ddl.sql truoc khi chay file nay.
--        File nay co the chay lai nhieu lan (tu dong xoa & nap lai sach se).
-- ============================================================================

USE gym_management_db;
GO

SET NOCOUNT ON;

-- 1. XOA DU LIEU CU THEO THU TU NGUOC KHOA NGOAI
DELETE FROM booking;
DELETE FROM session;
DELETE FROM maintenance_log;
DELETE FROM equipment;
DELETE FROM billing_log;
DELETE FROM membership;
DELETE FROM gym_visit;
DELETE FROM membership_card;
DELETE FROM gym_class;
DELETE FROM room;
DELETE FROM trainer;
DELETE FROM membership_plan;
DELETE FROM member;
GO

-- Khoi tao moc thoi gian tuong doi theo ngay hien tai de test cac query thoi han luon dung
DECLARE @today DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

-- 2. BANG DANH MUC GOC (STRONG ENTITIES)

-- 2.1. Goi tap niem yet (4 goi)
SET IDENTITY_INSERT membership_plan ON;
INSERT INTO membership_plan (plan_id, name, price) VALUES
    (1, N'Gói Cơ Bản (1 Tháng)', 500000.00),
    (2, N'Gói Tiêu Chuẩn (3 Tháng)', 1350000.00),
    (3, N'Gói VIP Kèm PT (3 Tháng)', 2500000.00),
    (4, N'Gói Diamond Trọn Gói (1 Năm)', 8000000.00);
SET IDENTITY_INSERT membership_plan OFF;

-- 2.2. Phong tap & suc chua (5 phong)
SET IDENTITY_INSERT room ON;
INSERT INTO room (room_id, capacity) VALUES
    (101, 20), -- Studio Yoga / Zumba
    (102, 15), -- Khu Boxing / HIIT
    (103, 1),  -- Phong PT 1-kem-1
    (104, 2),  -- Phong nhom nho (dung test ty le lap day >= 80% va full capacity)
    (105, 25); -- Khu Cardio & Ta nang (khong xep lop, dung test phong trong)
SET IDENTITY_INSERT room OFF;

-- 2.3. Bo mon tap nhom (5 mon)
SET IDENTITY_INSERT gym_class ON;
INSERT INTO gym_class (class_id, class_name) VALUES
    (1, N'Yoga Căn Bản'),
    (2, N'Boxing Thể Lực'),
    (3, N'Zumba Fitness'),
    (4, N'HIIT Đốt Mỡ'),
    (5, N'Pilates Phục Hồi');
SET IDENTITY_INSERT gym_class OFF;

-- 2.4. Huan luyen vien (5 HLV - HLV 5 chua co lich de test query tim HLV ranh)
SET IDENTITY_INSERT trainer ON;
INSERT INTO trainer (trainer_id, full_name) VALUES
    (1, N'Nguyễn Văn An'),
    (2, N'Trần Thị Bích'),
    (3, N'Lê Hoàng Nam'),
    (4, N'Phạm Quốc Bảo'),
    (5, N'Võ Minh Châu');
SET IDENTITY_INSERT trainer OFF;

-- 2.5. Hoi vien (12 hoi vien goc)
SET IDENTITY_INSERT member ON;
INSERT INTO member (member_id, full_name, email) VALUES
    (1,  N'Trương Chí Thanh', 'thanh.tc@ptithcm.edu.vn'),
    (2,  N'Phạm Minh Tuấn',   'tuan.pm@ptithcm.edu.vn'),
    (3,  N'Lê Văn Toàn',      'toan.lv@ptithcm.edu.vn'),
    (4,  N'Nguyễn Thị Mai',   'mai.nt@gmail.com'),
    (5,  N'Trần Quốc Huy',    'huy.tq@gmail.com'),
    (6,  N'Lê Hoàng Anh',     'anh.lh@gmail.com'),
    (7,  N'Phạm Thu Hà',      'ha.pt@gmail.com'),
    (8,  N'Đặng Tuấn Kiệt',   'kiet.dt@gmail.com'),
    (9,  N'Vũ Ngọc Linh',     'linh.vn@gmail.com'),
    (10, N'Hoàng Gia Bảo',    'bao.hg@gmail.com'),
    (11, N'Bùi Thanh Thảo',   'thao.bt@gmail.com'),
    (12, N'Ngô Đức Duy',      'duy.nd@gmail.com');
SET IDENTITY_INSERT member OFF;

-- 3. CAC BANG PHU THUOC & QUAN HE

-- 3.1. The hoi vien (co du trang thai ACTIVE, BLOCKED, INACTIVE)
SET IDENTITY_INSERT membership_card ON;
INSERT INTO membership_card (card_id, member_id, status) VALUES
    (1001, 1,  'ACTIVE'),
    (1002, 2,  'ACTIVE'),
    (1003, 3,  'BLOCKED'),   -- Test BR_13: the bi khoa
    (1004, 4,  'ACTIVE'),
    (1005, 5,  'ACTIVE'),
    (1006, 6,  'ACTIVE'),
    (1007, 7,  'ACTIVE'),
    (1008, 8,  'ACTIVE'),
    (1009, 9,  'ACTIVE'),
    (1010, 10, 'INACTIVE'),  -- Test BR_13: the ngung hoat dong
    (1011, 11, 'ACTIVE'),
    (1012, 12, 'ACTIVE');
SET IDENTITY_INSERT membership_card OFF;

-- 3.2. Hop dong goi tap (co du hop dong con han, sap het han trong 7 ngay, da het han, va lich su gia han BR_01)
SET IDENTITY_INSERT membership ON;
INSERT INTO membership (membership_id, member_id, plan_id, start_date, end_date) VALUES
    (1,  1,  3, DATEADD(DAY, -30,  @today), DATEADD(DAY, 60,  @today)), -- Con han dai
    (2,  2,  4, DATEADD(DAY, -45,  @today), DATEADD(DAY, 320, @today)), -- Goi 1 nam con han
    (3,  3,  2, DATEADD(DAY, -10,  @today), DATEADD(DAY, 80,  @today)), -- Con han nhung the BLOCKED
    (4,  4,  1, DATEADD(DAY, -26,  @today), DATEADD(DAY, 4,   @today)), -- Sap het han trong 4 ngay
    (5,  5,  1, DATEADD(DAY, -45,  @today), DATEADD(DAY, -15, @today)), -- Da het han
    (6,  6,  2, DATEADD(DAY, -88,  @today), DATEADD(DAY, 2,   @today)), -- Sap het han trong 2 ngay
    (7,  7,  1, DATEADD(DAY, -120, @today), DATEADD(DAY, -90, @today)), -- Hop dong cu da het han (BR_01)
    (8,  7,  2, DATEADD(DAY, -15,  @today), DATEADD(DAY, 75,  @today)), -- Hop dong gia han moi cua member 7
    (9,  8,  3, DATEADD(DAY, -20,  @today), DATEADD(DAY, 70,  @today)), -- Con han
    (10, 9,  1, DATEADD(DAY, -5,   @today), DATEADD(DAY, 25,  @today)), -- Con han
    (11, 10, 2, DATEADD(DAY, -100, @today), DATEADD(DAY, -10, @today)), -- Da het han
    (12, 11, 3, DATEADD(DAY, -40,  @today), DATEADD(DAY, 50,  @today)), -- Con han
    (13, 12, 1, DATEADD(DAY, -24,  @today), DATEADD(DAY, 6,   @today)); -- Sap het han trong 6 ngay
SET IDENTITY_INSERT membership OFF;

-- 3.3. Lich su thanh toan dinh ky (du trang thai SUCCESS, PENDING, FAILED)
SET IDENTITY_INSERT billing_log ON;
INSERT INTO billing_log (billing_id, membership_id, amount, payment_status) VALUES
    (1,  1,  2500000.00, 'SUCCESS'),
    (2,  2,  4000000.00, 'SUCCESS'), -- Tra dot 1
    (3,  2,  4000000.00, 'SUCCESS'), -- Tra dot 2
    (4,  3,  1350000.00, 'PENDING'), -- Dang cho thanh toan / an han 3 ngay (BR_15)
    (5,  4,  500000.00,  'SUCCESS'),
    (6,  5,  500000.00,  'FAILED'),  -- Thanh toan gia han that bai
    (7,  6,  1350000.00, 'SUCCESS'),
    (8,  7,  500000.00,  'SUCCESS'),
    (9,  8,  1350000.00, 'SUCCESS'),
    (10, 9,  2500000.00, 'SUCCESS'),
    (11, 10, 500000.00,  'PENDING'),
    (12, 11, 1350000.00, 'FAILED'),
    (13, 12, 2500000.00, 'SUCCESS'),
    (14, 13, 500000.00,  'SUCCESS');
SET IDENTITY_INSERT billing_log OFF;

-- 3.4. Nhat ky quet the vao phong gym (Member 9 va 10 chua check-in lan nao)
SET IDENTITY_INSERT gym_visit ON;
INSERT INTO gym_visit (visit_id, member_id, check_in_time) VALUES
    (1,  1,  DATEADD(HOUR, 7,  DATEADD(DAY, -5, @today))),
    (2,  1,  DATEADD(HOUR, 7,  DATEADD(DAY, -4, @today))),
    (3,  1,  DATEADD(HOUR, 18, DATEADD(DAY, -2, @today))),
    (4,  1,  DATEADD(HOUR, 8,  DATEADD(DAY, -1, @today))),
    (5,  2,  DATEADD(HOUR, 17, DATEADD(DAY, -6, @today))),
    (6,  2,  DATEADD(HOUR, 17, DATEADD(DAY, -3, @today))),
    (7,  2,  DATEADD(HOUR, 18, DATEADD(DAY, -1, @today))),
    (8,  4,  DATEADD(HOUR, 9,  DATEADD(DAY, -3, @today))),
    (9,  5,  DATEADD(HOUR, 19, DATEADD(DAY, -20, @today))),
    (10, 6,  DATEADD(HOUR, 16, DATEADD(DAY, -4, @today))),
    (11, 6,  DATEADD(HOUR, 16, DATEADD(DAY, -2, @today))),
    (12, 7,  DATEADD(HOUR, 8,  DATEADD(DAY, -7, @today))),
    (13, 7,  DATEADD(HOUR, 8,  DATEADD(DAY, -3, @today))),
    (14, 7,  DATEADD(HOUR, 8,  DATEADD(DAY, -1, @today))),
    (15, 8,  DATEADD(HOUR, 18, DATEADD(DAY, -2, @today))),
    (16, 11, DATEADD(HOUR, 7,  DATEADD(DAY, -1, @today))),
    (17, 12, DATEADD(HOUR, 20, DATEADD(DAY, -2, @today)));
SET IDENTITY_INSERT gym_visit OFF;

-- 3.5. Thiet bi phong tap (10 thiet bi)
SET IDENTITY_INSERT equipment ON;
INSERT INTO equipment (equipment_id, room_id, name) VALUES
    (1,  101, N'Thảm tập Yoga Manduka PRO'),
    (2,  101, N'Bóng tập Pilates Anti-Burst'),
    (3,  102, N'Bao cát đấm bốc Everlast Pro'),
    (4,  102, N'Bộ găng & đích đấm Boxing'),
    (5,  103, N'Máy tập đa năng Cable Crossover'),
    (6,  104, N'Xe đạp tập AirBike Assault'),
    (7,  104, N'Bộ tạ tay Kettlebell Set'),
    (8,  105, N'Máy chạy bộ điện Matrix T70'),
    (9,  105, N'Giàn tạ Squat Rack Olympic'),
    (10, 105, N'Máy chèo thuyền Concept2 Rower');
SET IDENTITY_INSERT equipment OFF;

-- 3.6. Nhat ky bao tri thiet bi (Co may da sua xong va may dang hong end_date IS NULL)
SET IDENTITY_INSERT maintenance_log ON;
INSERT INTO maintenance_log (log_id, equipment_id, start_date, end_date) VALUES
    (1, 1, DATEADD(DAY, -40, @today), DATEADD(DAY, -39, @today)), -- Da sua xong
    (2, 3, DATEADD(DAY, -30, @today), DATEADD(DAY, -28, @today)), -- Da sua xong
    (3, 6, DATEADD(DAY, -15, @today), DATEADD(DAY, -14, @today)), -- Da sua xong
    (4, 8, DATEADD(DAY, -20, @today), DATEADD(DAY, -18, @today)), -- Sua lan 1 xong
    (5, 8, DATEADD(DAY, -2,  @today), NULL),                       -- May 8 dang hong lan 2
    (6, 5, DATEADD(DAY, -1,  @today), NULL);                       -- May 5 phong 103 dang hong
SET IDENTITY_INSERT maintenance_log OFF;

-- 3.7. Lich trinh ca day (10 ca hop le, khong trung phong/HLV, dam bao >= 15 phut dem)
SET IDENTITY_INSERT session ON;
INSERT INTO session (session_id, class_id, room_id, trainer_id, start_time, end_time) VALUES
    -- Ngay +1 (Ngay mai)
    (1,  1,    101, 1, DATEADD(HOUR, 8,  DATEADD(DAY, 1, @today)), DATEADD(HOUR, 9,  DATEADD(DAY, 1, @today))),
    (2,  2,    102, 2, DATEADD(MINUTE, 510, DATEADD(DAY, 1, @today)), DATEADD(MINUTE, 570, DATEADD(DAY, 1, @today))), -- 08:30 - 09:30
    (3,  3,    101, 1, DATEADD(MINUTE, 570, DATEADD(DAY, 1, @today)), DATEADD(MINUTE, 630, DATEADD(DAY, 1, @today))), -- 09:30 - 10:30 (cach ca 1 30p)
    (4,  NULL, 103, 3, DATEADD(HOUR, 10, DATEADD(DAY, 1, @today)), DATEADD(HOUR, 11, DATEADD(DAY, 1, @today))), -- PT 1-kem-1
    (5,  4,    104, 4, DATEADD(HOUR, 14, DATEADD(DAY, 1, @today)), DATEADD(HOUR, 15, DATEADD(DAY, 1, @today))), -- Phong nho cap=2
    (6,  5,    102, 2, DATEADD(HOUR, 14, DATEADD(DAY, 1, @today)), DATEADD(HOUR, 15, DATEADD(DAY, 1, @today))),
    (7,  NULL, 103, 3, DATEADD(MINUTE, 1050, DATEADD(DAY, 1, @today)), DATEADD(MINUTE, 1110, DATEADD(DAY, 1, @today))), -- 17:30 - 18:30 PT
    -- Ngay +2 (Ngay kia)
    (8,  1,    101, 1, DATEADD(MINUTE, 450, DATEADD(DAY, 2, @today)), DATEADD(MINUTE, 510, DATEADD(DAY, 2, @today))), -- 07:30 - 08:30
    (9,  4,    104, 4, DATEADD(HOUR, 18, DATEADD(DAY, 2, @today)), DATEADD(HOUR, 19, DATEADD(DAY, 2, @today))),
    (10, 2,    102, 2, DATEADD(MINUTE, 1110, DATEADD(DAY, 2, @today)), DATEADD(MINUTE, 1170, DATEADD(DAY, 2, @today))); -- 18:30 - 19:30
SET IDENTITY_INSERT session OFF;

-- 3.8. Phieu dat cho tham gia ca day (17 luot dat cho, dam bao UNIQUE(session_id, member_id))
SET IDENTITY_INSERT booking ON;
INSERT INTO booking (booking_id, session_id, member_id, status) VALUES
    (1,  1, 1,  'CONFIRMED'),
    (2,  1, 4,  'CONFIRMED'),
    (3,  1, 6,  'CONFIRMED'),
    (4,  1, 7,  'CONFIRMED'),
    (5,  1, 8,  'CONFIRMED'),
    (6,  2, 2,  'CONFIRMED'),
    (7,  2, 6,  'CONFIRMED'),
    (8,  2, 9,  'CONFIRMED'),
    (9,  3, 7,  'CONFIRMED'),
    (10, 3, 11, 'CONFIRMED'),
    (11, 4, 1,  'CONFIRMED'), -- Ca PT 4 da du 1/1 nguoi
    (12, 5, 1,  'CONFIRMED'), -- Ca 5 (room 104 cap=2) dat 2/2 (100% day)
    (13, 5, 2,  'CONFIRMED'),
    (14, 8, 1,  'CONFIRMED'),
    (15, 8, 12, 'CONFIRMED'),
    (16, 9, 4,  'CONFIRMED'), -- Ca 9 (room 104 cap=2) dat 1/2 (con 1 cho trong)
    (17, 9, 5,  'CANCELLED'); -- Da huy nen khong tinh vao suc chua
SET IDENTITY_INSERT booking OFF;

-- ============================================================================
-- 4. BO SUNG DU LIEU MOCK CHO DU 50 HOI VIEN (Toan bo sung + QA Validation)
-- Nguon: du lieu tong hop/mo phong do nhom tao, khong phai du lieu khach hang that.
-- Giu nguyen 12 hoi vien va cac test case goc cua nhom.
-- ============================================================================

-- 4.1. Bo sung hoi vien (member_id 13-50)
SET IDENTITY_INSERT member ON;
INSERT INTO member (member_id, full_name, email) VALUES
    (13, N'Lê Văn Minh 01', 'member013@gym-demo.example'),
    (14, N'Bùi Gia Hoàng 02', 'member014@gym-demo.example'),
    (15, N'Nguyễn Văn Quốc 03', 'member015@gym-demo.example'),
    (16, N'Vũ Gia Gia 04', 'member016@gym-demo.example'),
    (17, N'Phan Văn Thanh 05', 'member017@gym-demo.example'),
    (18, N'Phạm Gia Đức 06', 'member018@gym-demo.example'),
    (19, N'Đỗ Văn Tuấn 07', 'member019@gym-demo.example'),
    (20, N'Trần Gia Bảo 08', 'member020@gym-demo.example'),
    (21, N'Đặng Văn Hải 09', 'member021@gym-demo.example'),
    (22, N'Dương Gia Khánh 10', 'member022@gym-demo.example'),
    (23, N'Hoàng Văn Ngọc 11', 'member023@gym-demo.example'),
    (24, N'Ngô Gia Phương 12', 'member024@gym-demo.example'),
    (25, N'Lê Văn Thảo 13', 'member025@gym-demo.example'),
    (26, N'Bùi Gia Anh 14', 'member026@gym-demo.example'),
    (27, N'Nguyễn Văn Huy 15', 'member027@gym-demo.example'),
    (28, N'Vũ Gia Linh 16', 'member028@gym-demo.example'),
    (29, N'Phan Văn Mai 17', 'member029@gym-demo.example'),
    (30, N'Phạm Gia Trang 18', 'member030@gym-demo.example'),
    (31, N'Đỗ Văn Vy 19', 'member031@gym-demo.example'),
    (32, N'Trần Gia Minh 20', 'member032@gym-demo.example'),
    (33, N'Đặng Văn Hoàng 21', 'member033@gym-demo.example'),
    (34, N'Dương Gia Quốc 22', 'member034@gym-demo.example'),
    (35, N'Hoàng Văn Gia 23', 'member035@gym-demo.example'),
    (36, N'Ngô Gia Thanh 24', 'member036@gym-demo.example'),
    (37, N'Lê Văn Đức 25', 'member037@gym-demo.example'),
    (38, N'Bùi Gia Tuấn 26', 'member038@gym-demo.example'),
    (39, N'Nguyễn Văn Bảo 27', 'member039@gym-demo.example'),
    (40, N'Vũ Gia Hải 28', 'member040@gym-demo.example'),
    (41, N'Phan Văn Khánh 29', 'member041@gym-demo.example'),
    (42, N'Phạm Gia Ngọc 30', 'member042@gym-demo.example'),
    (43, N'Đỗ Văn Phương 31', 'member043@gym-demo.example'),
    (44, N'Trần Gia Thảo 32', 'member044@gym-demo.example'),
    (45, N'Đặng Văn Anh 33', 'member045@gym-demo.example'),
    (46, N'Dương Gia Huy 34', 'member046@gym-demo.example'),
    (47, N'Hoàng Văn Linh 35', 'member047@gym-demo.example'),
    (48, N'Ngô Gia Mai 36', 'member048@gym-demo.example'),
    (49, N'Lê Văn Trang 37', 'member049@gym-demo.example'),
    (50, N'Bùi Gia Vy 38', 'member050@gym-demo.example');
SET IDENTITY_INSERT member OFF;
GO

-- 4.2. Bo sung the hoi vien (card_id 1013-1050)
SET IDENTITY_INSERT membership_card ON;
INSERT INTO membership_card (card_id, member_id, status) VALUES
    (1013, 13, 'ACTIVE'),
    (1014, 14, 'ACTIVE'),
    (1015, 15, 'ACTIVE'),
    (1016, 16, 'ACTIVE'),
    (1017, 17, 'ACTIVE'),
    (1018, 18, 'ACTIVE'),
    (1019, 19, 'ACTIVE'),
    (1020, 20, 'BLOCKED'),
    (1021, 21, 'ACTIVE'),
    (1022, 22, 'ACTIVE'),
    (1023, 23, 'ACTIVE'),
    (1024, 24, 'ACTIVE'),
    (1025, 25, 'ACTIVE'),
    (1026, 26, 'ACTIVE'),
    (1027, 27, 'ACTIVE'),
    (1028, 28, 'ACTIVE'),
    (1029, 29, 'ACTIVE'),
    (1030, 30, 'ACTIVE'),
    (1031, 31, 'ACTIVE'),
    (1032, 32, 'ACTIVE'),
    (1033, 33, 'ACTIVE'),
    (1034, 34, 'ACTIVE'),
    (1035, 35, 'BLOCKED'),
    (1036, 36, 'ACTIVE'),
    (1037, 37, 'ACTIVE'),
    (1038, 38, 'ACTIVE'),
    (1039, 39, 'ACTIVE'),
    (1040, 40, 'ACTIVE'),
    (1041, 41, 'ACTIVE'),
    (1042, 42, 'ACTIVE'),
    (1043, 43, 'ACTIVE'),
    (1044, 44, 'ACTIVE'),
    (1045, 45, 'ACTIVE'),
    (1046, 46, 'ACTIVE'),
    (1047, 47, 'ACTIVE'),
    (1048, 48, 'ACTIVE'),
    (1049, 49, 'ACTIVE'),
    (1050, 50, 'ACTIVE');
SET IDENTITY_INSERT membership_card OFF;
GO

-- @today la bien cuc bo theo batch; khai bao lai sau lenh GO.
DECLARE @today DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

-- 4.3. Bo sung hop dong: moi hoi vien moi co it nhat mot membership
-- Chu ky goi tap duoc phan bo lan luot de tao du lieu da dang.
SET IDENTITY_INSERT membership ON;
INSERT INTO membership (membership_id, member_id, plan_id, start_date, end_date)
SELECT
    member_id + 1,
    member_id,
    ((member_id - 13) % 4) + 1,
    DATEADD(DAY, -((member_id % 25) + 5), @today),
    DATEADD(DAY,
        CASE ((member_id - 13) % 4)
            WHEN 0 THEN 25
            WHEN 1 THEN 65
            WHEN 2 THEN 85
            ELSE 330
        END,
        @today)
FROM member
WHERE member_id BETWEEN 13 AND 50;
SET IDENTITY_INSERT membership OFF;
GO

-- 4.4. Bo sung billing log: tao cac trang thai SUCCESS/PENDING/FAILED
SET IDENTITY_INSERT billing_log ON;
INSERT INTO billing_log (billing_id, membership_id, amount, payment_status)
SELECT
    membership_id + 1,
    membership_id,
    plan.price,
    CASE
        WHEN membership_id % 10 = 0 THEN 'FAILED'
        WHEN membership_id % 7 = 0 THEN 'PENDING'
        ELSE 'SUCCESS'
    END
FROM membership
INNER JOIN membership_plan AS plan
    ON membership.plan_id = plan.plan_id
WHERE membership.member_id BETWEEN 13 AND 50;
SET IDENTITY_INSERT billing_log OFF;
GO

-- 4.5. Bo sung lich su check-in cho hoi vien moi.
-- Khai bao lai @today vi batch truoc da ket thuc bang GO.
DECLARE @today DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);
-- Moi hoi vien co 2-3 luot check-in vao cac ngay gan day.
INSERT INTO gym_visit (member_id, check_in_time)
SELECT
    member.member_id,
    DATEADD(
        MINUTE,
        360 + ((member.member_id * visit_no) % 720),
        DATEADD(DAY, -((member.member_id + visit_no) % 28), @today)
    )
FROM member
CROSS JOIN (VALUES (1), (2), (3)) AS visits(visit_no)
WHERE member.member_id BETWEEN 13 AND 50
  AND (member.member_id + visits.visit_no) % 4 <> 0;
GO

-- 4.6. Kiem tra nhanh so luong va tinh toan ven khoa ngoai.
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL SELECT 'membership_card', COUNT(*) FROM membership_card
UNION ALL SELECT 'membership', COUNT(*) FROM membership
UNION ALL SELECT 'billing_log', COUNT(*) FROM billing_log
UNION ALL SELECT 'gym_visit', COUNT(*) FROM gym_visit
UNION ALL SELECT 'booking', COUNT(*) FROM booking;

IF EXISTS (
    SELECT 1
    FROM membership AS m
    LEFT JOIN member AS mem ON mem.member_id = m.member_id
    LEFT JOIN membership_plan AS p ON p.plan_id = m.plan_id
    WHERE mem.member_id IS NULL OR p.plan_id IS NULL
)
    THROW 51001, 'QA FAILED: membership contains an invalid foreign key.', 1;

IF EXISTS (
    SELECT 1
    FROM membership_card AS c
    LEFT JOIN member AS m ON m.member_id = c.member_id
    WHERE m.member_id IS NULL
)
    THROW 51002, 'QA FAILED: membership_card contains an invalid foreign key.', 1;

IF EXISTS (
    SELECT 1
    FROM billing_log AS b
    LEFT JOIN membership AS m ON m.membership_id = b.membership_id
    WHERE m.membership_id IS NULL
)
    THROW 51003, 'QA FAILED: billing_log contains an invalid foreign key.', 1;

IF EXISTS (
    SELECT 1
    FROM gym_visit AS v
    LEFT JOIN member AS m ON m.member_id = v.member_id
    WHERE m.member_id IS NULL
)
    THROW 51004, 'QA FAILED: gym_visit contains an invalid foreign key.', 1;

IF (SELECT COUNT(*) FROM member) < 50
    THROW 51005, 'QA FAILED: expected at least 50 members.', 1;

PRINT N'QA PASSED: mock data loaded; at least 50 members and checked foreign keys.';
GO

PRINT N'Nap du lieu mock thanh cong cho ca 13 bang cua gym_management_db!';
GO
