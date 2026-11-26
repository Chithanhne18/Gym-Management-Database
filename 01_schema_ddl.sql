-- ============================================================================
-- DO AN CO SO DU LIEU (INT1313_CLC) - PHASE 3
-- DE TAI #9: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- TAP TIN: 01_schema_ddl.sql (Chuan MS SQL Server / SSMS)
-- QUY UOC: SQLStyle.guide / Google SQL Style Guide (snake_case, UPPERCASE keywords)
-- ============================================================================

-- 1. TAO CO SO DU LIEU
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'gym_management_db')
BEGIN
    CREATE DATABASE gym_management_db;
END
GO

USE gym_management_db;
GO

-- 2. XOA BANG CU THEO THU TU NGUOC KHOA NGOAI (DE CHAY LAI AN TOAN)
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS session;
DROP TABLE IF EXISTS maintenance_log;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS billing_log;
DROP TABLE IF EXISTS membership;
DROP TABLE IF EXISTS gym_visit;
DROP TABLE IF EXISTS membership_card;
DROP TABLE IF EXISTS gym_class;
DROP TABLE IF EXISTS room;
DROP TABLE IF EXISTS trainer;
DROP TABLE IF EXISTS membership_plan;
DROP TABLE IF EXISTS member;
GO

-- ============================================================================
-- 3. TAO 13 BANG CHUAN HOA BCNF (THEO LƯỢC ĐỒ PHASE 2)
-- ============================================================================

-- 3.1. Bang member: Ho so hoi vien (Strong Entity)
CREATE TABLE member (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- 3.2. Bang membership_plan: Danh muc goi tap & bang gia (Strong Entity)
CREATE TABLE membership_plan (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_plan_price CHECK (price >= 0)
);

-- 3.3. Bang trainer: Ho so huan luyen vien (Strong Entity)
CREATE TABLE trainer (
    trainer_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL
);

-- 3.4. Bang room: Phong tap vat ly & suc chua toi da (Strong Entity)
CREATE TABLE room (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    capacity INT NOT NULL,
    CONSTRAINT chk_room_capacity CHECK (capacity > 0)
);

-- 3.5. Bang gym_class: Danh muc cac mon tap nhom (Strong Entity)
CREATE TABLE gym_class (
    class_id INT IDENTITY(1,1) PRIMARY KEY,
    class_name NVARCHAR(100) NOT NULL
);

-- 3.6. Bang membership_card: The quet vat ly (1:N voi member)
CREATE TABLE membership_card (
    card_id INT IDENTITY(1001,1) PRIMARY KEY,
    member_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_card_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_card_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'INACTIVE'))
);

-- 3.7. Bang gym_visit: Nhat ky check-in qua cua (1:N voi member)
CREATE TABLE gym_visit (
    visit_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    check_in_time DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT fk_visit_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE CASCADE
);

-- 3.8. Bang membership: Hop dong su dung goi tap (Giai quyet M:N member - plan)
CREATE TABLE membership (
    membership_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    CONSTRAINT fk_membership_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_membership_plan
        FOREIGN KEY (plan_id) REFERENCES membership_plan(plan_id)
        ON DELETE NO ACTION,
    CONSTRAINT chk_membership_date
        CHECK (end_date > start_date)
);

-- 3.9. Bang billing_log: Lich su thanh toan gia han dinh ky (1:N voi membership)
CREATE TABLE billing_log (
    billing_id INT IDENTITY(1,1) PRIMARY KEY,
    membership_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_billing_membership
        FOREIGN KEY (membership_id) REFERENCES membership(membership_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_billing_amount CHECK (amount >= 0),
    CONSTRAINT chk_billing_status CHECK (payment_status IN ('SUCCESS', 'PENDING', 'FAILED'))
);

-- 3.10. Bang equipment: Thiet bi vat ly dat tai phong tap (1:N voi room)
CREATE TABLE equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    room_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    CONSTRAINT fk_equipment_room
        FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE NO ACTION
);

-- 3.11. Bang maintenance_log: Nhat ky bao tri thiet bi (end_date IS NULL = dang hong)
CREATE TABLE maintenance_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_id INT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NULL DEFAULT NULL,
    CONSTRAINT fk_log_equipment
        FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_maintenance_date
        CHECK (end_date IS NULL OR end_date >= start_date)
);

-- 3.12. Bang session: Ca day thuc te (class_id IS NULL = PT 1-kem-1)
CREATE TABLE session (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    class_id INT NULL DEFAULT NULL,
    room_id INT NOT NULL,
    trainer_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    CONSTRAINT fk_session_class
        FOREIGN KEY (class_id) REFERENCES gym_class(class_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_session_room
        FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_trainer
        FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id)
        ON DELETE NO ACTION,
    CONSTRAINT chk_session_time
        CHECK (end_time > start_time)
);

-- 3.13. Bang booking: Phieu dat cho tham gia ca day (Giai quyet M:N member - session)
-- Luu y: fk_booking_member dung NO ACTION de tranh loi multiple cascade paths trong SQL Server
CREATE TABLE booking (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    member_id INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    CONSTRAINT fk_booking_session
        FOREIGN KEY (session_id) REFERENCES session(session_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_booking_member
        FOREIGN KEY (member_id) REFERENCES member(member_id)
        ON DELETE NO ACTION,
    CONSTRAINT uq_session_member
        UNIQUE (session_id, member_id),
    CONSTRAINT chk_booking_status
        CHECK (status IN ('CONFIRMED', 'CANCELLED'))
);
GO

-- ============================================================================
-- 4. HE THONG CHI MUC TOI UU TRUY VAN (INDEXES)
-- ============================================================================

CREATE INDEX idx_member_email
    ON member (email);

CREATE INDEX idx_membership_dates
    ON membership (member_id, start_date, end_date);

CREATE INDEX idx_session_timerange
    ON session (start_time, end_time);

CREATE INDEX idx_session_trainer
    ON session (trainer_id, start_time, end_time);

CREATE INDEX idx_session_room
    ON session (room_id, start_time, end_time);

CREATE INDEX idx_booking_session
    ON booking (session_id, status);

CREATE INDEX idx_maintenance_active
    ON maintenance_log (equipment_id, end_date);
GO
