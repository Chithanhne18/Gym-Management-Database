# Hệ thống Quản lý Phòng tập Thể hình (Gym Membership & Personal Training Planner)

**Môn học:** Cơ sở dữ liệu — `DATABASES (INT1313_CLC)`  
**Lớp / Nhóm lớp:** `INT1313_CLC_02` — Học kỳ 1, Năm học 2026–2027  
**Cơ sở đào tạo:** Học viện Công nghệ Bưu chính Viễn thông — Cơ sở tại TP. Hồ Chí Minh (PTIT HCM)  
**Giảng viên hướng dẫn:** Thầy Lê Hà Thanh (`lehathanh@ptithcm.edu.vn`)  
**Chủ đề đồ án:** Topic #9 — *Gym Membership & Personal Training Planner*  
**Kho lưu trữ GitHub:** <https://github.com/Chithanhne18/Gym-Management-Database>

---

## 1. Thông tin Thành viên Nhóm (Group Members)

| STT | Họ và Tên | Mã Sinh Viên (MSSV) | Email sinh viên PTIT | Phân công chính |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Trương Chí Thành** | `N23DCAT064` | `n23dcat064@student.ptithcm.edu.vn` | Nhóm trưởng; Thiết kế Phase 1 & 2, chốt DDL chuẩn (`01_schema_ddl.sql`), Phase 3 (Triggers Booking/Maintenance, Views, SP Check-in, 6 Complex Queries), tổng hợp tài liệu & nộp bài. |
| 2 | **Nguyễn Ngọc Toàn** | `N24DECE097` | `n24dece097@student.ptithcm.edu.vn` | Chuẩn hóa Dataset & đặc tả dữ liệu (`data/`), kiểm thử toàn diện SQL & ứng dụng (QA), tổng hợp báo cáo & slide bảo vệ. |
| 3 | **Nguyễn Anh Tuấn** | `N24DECE102` | `n24dece102@student.ptithcm.edu.vn` | Phase 3 (Trigger chống trùng lịch `trg_prevent_schedule_conflict`, View chỗ trống, 5 nhóm Complex Queries, test cases) & Phase 4 (Web App Python Flask kết nối SQL Server). |

---

## 2. Mô tả Tổng quan Dự án

Hệ thống cơ sở dữ liệu quan hệ quản lý toàn diện 3 trụ cột nghiệp vụ cốt lõi của một phòng tập thể hình:
1. **Quản lý Lịch trình & Đặt chỗ (Scheduling & Booking):** Điều phối `gym_class`, `room`, `trainer`, `session` (hỗ trợ cả lớp nhóm và PT 1-kèm-1 khi `class_id IS NULL`) và `booking`. Giải quyết triệt để **DB Challenge** bằng SQL Triggers ngay tại tầng CSDL: chặn trùng lịch HLV (`BR_07`), chặn trùng lịch phòng (`BR_08`), đảm bảo 15 phút nghỉ đệm giữa 2 ca dạy (`BR_09`), và kiểm soát sức chứa phòng / ca PT (`BR_10`, `BR_11`, `BR_12`).
2. **Quản lý Hội viên, Thẻ & Thanh toán định kỳ (Membership & Recurring Billing):** Quản lý `member`, `membership_card`, `membership_plan`, `membership`, `billing_log`, `gym_visit`. Lưu vết đầy đủ hợp đồng theo thời gian và trạng thái thanh toán (`SUCCESS`, `PENDING`, `FAILED`), tự động chặn check-in hoặc đặt chỗ nếu thẻ bị khóa hoặc hợp đồng hết hạn (`BR_03`, `BR_13`, `BR_14`).
3. **Quản lý Thiết bị & Bảo trì (Equipment & Maintenance):** Theo dõi vị trí thiết bị (`equipment`) theo phòng và nhật ký sửa chữa (`maintenance_log`). Thiết bị có `end_date IS NULL` được đánh dấu không khả dụng (`BR_16`), đồng thời chặn mở trùng phiếu bảo trì.

---

## 3. Cấu trúc Kho lưu trữ (Repository Structure)

```text
Gym-Management-Database/
├── README.md                                  # Tài liệu tổng quan & hướng dẫn cài đặt, vận hành
├── .gitignore                                 # Cấu hình loại trừ file môi trường (.env, .venv, __pycache__)
├── docs/
│   ├── Project_Final_Report.pdf               # Báo cáo tổng hợp chi tiết đầy đủ cả 4 Phase (PDF)
│   ├── Project_Final_Report.html              # Nguồn HTML của Báo cáo tổng hợp
│   ├── ReportProject_Phase_1.pdf              # Báo cáo Giai đoạn 1 (Conceptual Design)
│   ├── ReportProject_Phase_2.pdf              # Báo cáo Giai đoạn 2 (Logical Design & BCNF)
│   └── erd_diagram.jpg                        # Sơ đồ thực thể kết hợp (ERD 13 bảng)
├── sql/
│   ├── 01_schema_ddl.sql                      # Script DDL tạo DB, 13 bảng (BCNF), FK, CHECK, 7 Indexes
│   ├── phase3_tuan/
│   │   ├── 02_tuan_trigger.sql                # Trigger trg_prevent_schedule_conflict (BR_07, BR_08, BR_09)
│   │   ├── 03_tuan_view.sql                   # View vw_session_availability
│   │   ├── 04_tuan_complex_queries.sql        # 5 nhóm Complex Queries về Lịch trình, HLV, Phòng
│   │   ├── 05_tuan_trigger_tests.sql          # Script test Trigger chống trùng lịch (Rollback an toàn)
│   │   └── README_TUAN.md
│   └── phase3_thanh/
│       ├── 02_thanh_trigger.sql               # Triggers trg_check_booking_eligibility & trg_prevent_duplicate_open_maintenance
│       ├── 03_thanh_view_and_proc.sql         # Views (vw_member_billing_overview, vw_equipment_maintenance_status) & SP sp_check_in_gym
│       ├── 04_thanh_complex_queries.sql       # 6 Complex Queries về Doanh thu, Gia hạn, Check-in, Bảo trì
│       ├── 05_thanh_tests.sql                 # Script test Trigger Booking/Bảo trì & SP Check-in
│       └── README_THANH.md
├── data/
│   ├── seed_data.sql                          # Script DML nạp dữ liệu mẫu đầy đủ cho 13 bảng + các case biên
│   └── DATA_SOURCE.md                         # Mô tả nguồn dữ liệu & cấu trúc ánh xạ vào 13 bảng
└── app/
    └── tuan_gym_phase4/                       # Ứng dụng Web Python Flask (Phase 4) kết nối SQL Server
        ├── app.py
        ├── requirements.txt
        ├── .env.example
        ├── README_TUAN.md
        ├── static/
        └── templates/
```

---

## 4. Hướng dẫn Cài đặt, Triển khai & Vận hành (Installation, Deployment & Operation)

### Yêu cầu hệ thống
- **Hệ quản trị CSDL:** Microsoft SQL Server (2019/2022 Express hoặc Developer) + **SQL Server Management Studio (SSMS)**.
- **Môi trường chạy ứng dụng Web (Phase 4):** Python `3.10+`, Microsoft **ODBC Driver 17** hoặc **18 for SQL Server**.

### Bước 1: Triển khai Cơ sở dữ liệu & Chạy Phase 3 (trên SSMS)
Mở **SSMS**, kết nối vào SQL Server local (`localhost` hoặc `localhost\SQLEXPRESS`), sau đó mở và bấm **Execute (`F5`)** lần lượt từng file theo đúng thứ tự sau:

1. `sql/01_schema_ddl.sql` — Tạo CSDL `gym_management_db`, 13 bảng chuẩn BCNF, khóa ngoại, `CHECK`, `UNIQUE` và 7 `Indexes`.
2. `data/seed_data.sql` — Nạp dữ liệu mẫu cho cả 13 bảng (hỗ trợ chạy lại nhiều lần nhờ xóa ngược thứ tự khóa ngoại).
3. `sql/phase3_tuan/02_tuan_trigger.sql` — Cài đặt Trigger chống trùng lịch `trg_prevent_schedule_conflict`.
4. `sql/phase3_tuan/03_tuan_view.sql` — Tạo View `vw_session_availability`.
5. `sql/phase3_thanh/02_thanh_trigger.sql` — Cài đặt Trigger `trg_check_booking_eligibility` và `trg_prevent_duplicate_open_maintenance`.
6. `sql/phase3_thanh/03_thanh_view_and_proc.sql` — Tạo 2 Views tổng hợp và Stored Procedure `sp_check_in_gym`.
7. **Chạy truy vấn & kiểm thử:**
   - Chạy `sql/phase3_tuan/04_tuan_complex_queries.sql` và `sql/phase3_thanh/04_thanh_complex_queries.sql` để xem kết quả 11+ Complex Queries.
   - Chạy `sql/phase3_tuan/05_tuan_trigger_tests.sql` và `sql/phase3_thanh/05_thanh_tests.sql` (mở tab **Messages** trong SSMS để xem log Trigger chặn đúng `BR_07`, `BR_08`, `BR_09`, `BR_03`, `BR_10`, `BR_11`, `BR_16`).

> **Lưu ý:** Sau khi đã cài đặt Triggers/Views, **không chạy lại** `01_schema_ddl.sql` trừ khi muốn reset toàn bộ bảng từ đầu (vì file DDL có lệnh `DROP TABLE IF EXISTS`).

### Bước 2: Cài đặt & Chạy ứng dụng Web Phase 4 (Python Flask)
Mở PowerShell tại thư mục `app/tuan_gym_phase4/`:

```powershell
cd app/tuan_gym_phase4
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Mở file `.env` vừa tạo và chỉnh `DB_CONNECTION_STRING` phù hợp với máy đang chạy SQL Server (kiểm tra driver sẵn có bằng `python -c "import pyodbc; print(pyodbc.drivers())"`):

```ini
# Ví dụ dùng ODBC Driver 17 (hoặc đổi thành 18 tùy máy) với Windows Authentication:
DB_CONNECTION_STRING=DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=gym_management_db;Trusted_Connection=yes;TrustServerCertificate=yes;
```
*(Nếu dùng SQL Server Express, đổi `SERVER=localhost\SQLEXPRESS`).*

Khởi chạy ứng dụng:
```powershell
python app.py
```
Mở trình duyệt truy cập: **<http://127.0.0.1:5000>**

### Bước 3: Kịch bản Vận hành & Demo trực tiếp
1. **Dashboard (`/`):** Kiểm tra tổng số ca sắp tới, số HLV, phòng tập, lượt đặt chỗ `CONFIRMED`, thiết bị đang hỏng (`end_date IS NULL`).
2. **Tạo ca dạy (`/sessions/new`):** Cố tình tạo ca dạy trùng giờ với HLV hoặc phòng sẵn có (hoặc cách ca trước của HLV < 15 phút) &rarr; Trigger `trg_prevent_schedule_conflict` tự động chặn và trả thông báo lỗi `BR_07`/`BR_08`/`BR_09` lên giao diện.
3. **Đặt chỗ & Hủy (`/bookings`):** Đăng ký hội viên còn hạn vào ca còn chỗ, hủy để đổi sang `CANCELLED`, hoặc thử đặt cho hội viên hết hạn / ca đã đầy để kiểm tra Trigger `trg_check_booking_eligibility` (`BR_03`/`BR_10`/`BR_11`).
4. **Bảo trì thiết bị (`/maintenance`):** Ghi nhận thiết bị hỏng (`end_date = NULL`) và bấm **Hoàn tất** để ghi nhận `end_date = GETDATE()`.

