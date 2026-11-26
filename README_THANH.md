# Phase 3 - Phần của Thanh

Đề tài: Gym Membership & Personal Training Planner  
Database: `gym_management_db`  
Nền tảng: Microsoft SQL Server / SSMS (T-SQL)

## Danh sách tệp
- `02_thanh_trigger.sql`:
  - Trigger `trg_check_booking_eligibility` trên `dbo.booking` (kiểm tra BR_03/BR_14 hạn hợp đồng, BR_10 sức chứa phòng nhóm, BR_11 giới hạn 1 học viên cho ca PT 1-kèm-1).
  - Trigger `trg_prevent_duplicate_open_maintenance` trên `dbo.maintenance_log` (BR_16 chặn mở trùng phiếu bảo trì chưa kết thúc).
- `03_thanh_view_and_proc.sql`:
  - View `vw_member_billing_overview`: tổng hợp hội viên, thẻ, hợp đồng mới nhất và tổng tiền theo trạng thái thanh toán.
  - View `vw_equipment_maintenance_status`: theo dõi khả dụng thiết bị.
  - Stored Procedure `sp_check_in_gym`: kiểm tra trạng thái thẻ (BR_13) và hạn hợp đồng (BR_14) trước khi ghi nhận vào `gym_visit`.
- `04_thanh_complex_queries.sql`: 6 câu truy vấn phức tạp (Doanh thu & công nợ theo gói; Hội viên sắp hết hạn 7 ngày chưa gia hạn; Hội viên check-in vượt trung bình; Kiểm toán booking vi phạm điều kiện thẻ/hợp đồng; Thiết bị đang bảo trì tích lũy; Báo cáo 360 độ hội viên).
- `05_thanh_tests.sql`: 4 test case kiểm thử Trigger + 3 test case cho `sp_check_in_gym` (đều rollback sạch sẽ).

## Thứ tự chạy trên SSMS
1. `sql/01_schema_ddl.sql`
2. `data/seed_data.sql`
3. `PHASE3_TUAN_SQL/02_tuan_trigger.sql` & `PHASE3_TUAN_SQL/03_tuan_view.sql`
4. `PHASE3_THANH_SQL/02_thanh_trigger.sql`
5. `PHASE3_THANH_SQL/03_thanh_view_and_proc.sql`
6. `PHASE3_THANH_SQL/04_thanh_complex_queries.sql`
7. `PHASE3_THANH_SQL/05_thanh_tests.sql`
