# DATA SOURCE – Gym Membership & Personal Training Planner

## 1. Mục đích

Tài liệu này mô tả nguồn gốc và cách xây dựng dữ liệu mẫu dùng cho Phase 3
(Implementation & Queries) của đồ án INT1313 – Database, đề tài #9:
**Gym Membership & Personal Training Planner**.

## 2. Căn cứ yêu cầu

Trong tài liệu *Milestone Project Plan and Evaluation*, Phase 3 yêu cầu:
- SQL DDL Script;
- mock data insertion (DML);
- 10+ complex queries (Joins, Subqueries, Aggregations);
- 2 Triggers/Views.

Các tài liệu giảng viên đã cung cấp trong cuộc trao đổi không nêu yêu cầu bắt buộc
phải lấy dữ liệu từ Kaggle hoặc Hugging Face, cũng không chỉ định một Dataset công khai
cụ thể. Vì vậy, bộ dữ liệu trong `seed_data.sql` được ghi nhận trung thực là
**mock data (tổng hợp/mô phỏng)** phục vụ triển khai và kiểm thử database.

## 3. Nguồn dữ liệu

| Thành phần | Nguồn | Cách sử dụng |
|---|---|---|
| 12 hội viên ban đầu và các bản ghi nghiệp vụ ban đầu | File `seed_data.sql` do thành viên nhóm cung cấp | Giữ lại làm dữ liệu mock nền và giữ nguyên các tình huống kiểm thử đã thiết kế |
| 38 hội viên bổ sung (member_id 13–50) | Dữ liệu tổng hợp do nhóm tạo bằng quy tắc xác định | Bổ sung để đạt 50 hội viên; tên và email là dữ liệu demo, không đại diện người thật |
| Membership, membership_card, billing_log và gym_visit bổ sung | Dữ liệu tổng hợp do nhóm tạo bằng câu lệnh SQL | Tạo quan hệ hợp lệ và thêm dữ liệu phục vụ truy vấn, thống kê và kiểm thử |
| Danh mục gói tập, phòng, bộ môn, huấn luyện viên, thiết bị, lịch tập, booking và bảo trì | Dữ liệu mock nền do nhóm cung cấp | Giữ lại các tình huống nghiệp vụ đã có trong file seed ban đầu |

**Không sử dụng dữ liệu cá nhân thực tế hoặc tuyên bố dữ liệu mô phỏng là dữ liệu thu thập từ Kaggle.**
Không có URL Dataset bên ngoài được khai báo vì phiên bản dữ liệu này không nhập dữ liệu
từ một Dataset bên ngoài.

## 4. Ánh xạ vào 13 bảng

| Bảng | Cách tạo dữ liệu |
|---|---|
| `member` | Giữ 12 bản ghi nền; bổ sung 38 hội viên demo |
| `membership_plan` | Giữ danh mục 4 gói tập trong seed nền |
| `trainer` | Giữ 5 huấn luyện viên demo |
| `room` | Giữ 5 phòng với sức chứa khác nhau |
| `gym_class` | Giữ 5 bộ môn tập nhóm |
| `membership_card` | Giữ 12 thẻ nền; bổ sung thẻ cho 38 hội viên mới |
| `gym_visit` | Giữ lịch sử check-in nền; bổ sung lượt check-in mô phỏng |
| `membership` | Giữ các hợp đồng nền; bổ sung một hợp đồng cho mỗi hội viên mới |
| `billing_log` | Giữ lịch sử thanh toán nền; bổ sung giao dịch theo gói tập |
| `equipment` | Giữ 10 thiết bị demo |
| `maintenance_log` | Giữ lịch sử bảo trì, gồm thiết bị đã sửa và đang bảo trì |
| `session` | Giữ 10 ca tập nền, gồm ca nhóm và PT 1-kèm-1 |
| `booking` | Giữ 17 lượt đặt chỗ nền để kiểm thử trạng thái và quan hệ |

## 5. Quy tắc tạo dữ liệu bổ sung

- `member_id` bổ sung nằm trong khoảng 13–50.
- Email sử dụng miền `.example` dành cho dữ liệu minh họa, ví dụ `member013@gym-demo.example`.
- Mỗi hội viên mới có một thẻ hội viên và một hợp đồng.
- Gói tập được phân bổ luân phiên giữa các `plan_id` hiện có.
- Số tiền billing lấy theo giá của gói tập được tham chiếu.
- Trạng thái billing được phân bổ theo quy tắc xác định để có `SUCCESS`, `PENDING` và `FAILED`.
- Mỗi hội viên mới có 2–3 lượt check-in mô phỏng trong khoảng 28 ngày gần nhất.
- Ngày bắt đầu và kết thúc membership được tạo sao cho `end_date > start_date`.
- Các ID được bổ sung tiếp nối ID hiện có để tránh xung đột khóa chính.

Dữ liệu sinh thêm là dữ liệu tổng hợp để demo, không phải lịch sử giao dịch thực tế.

## 6. Data quality và kiểm tra toàn vẹn

File seed giữ các ràng buộc đã khai báo trong `01_schema_ddl.sql`, bao gồm:
- Primary Key và Foreign Key;
- UNIQUE cho email và cặp (`session_id`, `member_id`) trong booking;
- CHECK cho giá gói tập, sức chứa phòng, ngày hợp đồng, trạng thái thẻ,
  trạng thái thanh toán, trạng thái booking và thời gian bảo trì/ca tập.

Cuối file seed có các truy vấn kiểm tra số lượng bản ghi và các kiểm tra Foreign Key
cho `membership`, `membership_card`, `billing_log` và `gym_visit`. Nếu phát hiện
Foreign Key không hợp lệ hoặc số hội viên dưới 50, script sẽ phát sinh lỗi QA.

## 7. Cách chạy

1. Mở SQL Server Management Studio (SSMS).
2. Chạy `01_schema_ddl.sql` trước để tạo database và 13 bảng.
3. Chạy `seed_data.sql` sau đó.
4. Xem kết quả các truy vấn đếm bản ghi ở cuối script.
5. Chỉ xác nhận nạp dữ liệu thành công khi thông báo QA PASSED xuất hiện.

**Lưu ý:** `01_schema_ddl.sql` hiện có lệnh DROP TABLE và tạo lại bảng. Chỉ chạy
trong môi trường đồ án/dev vì chạy lại schema sẽ xóa dữ liệu hiện có trong các bảng.

## 8. Giới hạn và minh bạch dữ liệu

Bộ dữ liệu hiện tại được thiết kế cho mục đích học tập, demo chức năng và kiểm thử
các truy vấn SQL. Dữ liệu không dùng để suy luận về hành vi khách hàng thật, dự báo
kinh doanh hoặc đại diện cho một phòng gym cụ thể.

Nếu nhóm bổ sung Dataset công khai ở phiên bản sau, cần cập nhật mục này bằng:
- Tên Dataset và URL nguồn;
- Tác giả/đơn vị cung cấp và giấy phép sử dụng;
- Các cột gốc được sử dụng;
- Quy trình làm sạch và ánh xạ;
- Những trường/bản ghi được nhóm tự sinh thêm.
