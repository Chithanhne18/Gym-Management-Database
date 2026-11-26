# Phase 3 - Phan cua Tuan

De tai: Gym Membership & Personal Training Planner
Database: `gym_management_db`
Nen tang: Microsoft SQL Server / SSMS (T-SQL)

## Danh sach tep

- `02_tuan_trigger.sql`: Trigger `trg_prevent_schedule_conflict` cho BR_07, BR_08, BR_09.
- `03_tuan_view.sql`: View `vw_session_availability`.
- `04_tuan_complex_queries.sql`: 5 nhom truy van phuc tap; Query 4 tach thanh 4A va 4B de tim phong va HLV ranh.
- `05_tuan_trigger_tests.sql`: 3 test case cho Trigger.

## Thu tu chay

1. `sql/01_schema_ddl.sql` cua nhom.
2. `data/seed_data.sql` cua nhom.
3. `02_tuan_trigger.sql`.
4. `03_tuan_view.sql`.
5. `04_tuan_complex_queries.sql`.
6. `05_tuan_trigger_tests.sql`.

Chay bang SQL Server Management Studio (SSMS), chon dung database `gym_management_db`.

## Luu y

- Cac tep nay dung T-SQL cho SQL Server, khong dung cu phap MySQL.
- `session.class_id IS NULL` duoc hien thi la `PT 1-kem-1`.
- Chi booking co `status = 'CONFIRMED'` moi duoc tinh vao so cho da dat.
- Query 1 su dung tuan tinh tu ngay hien tai; `DATEFIRST` theo cau hinh session SQL Server.
- Query 3 tinh cac ca co `start_time` nam trong thang hien tai.
- Query 4 dung khoang thoi gian 08:00-10:00 ngay mai; co the sua hai bien thoi gian de demo.
- Test trigger can du lieu seed co `session_id = 1`, `session_id = 3`, `trainer_id = 5`, `room_id = 105`.
- Cac test deu dung transaction va rollback de khong de lai du lieu test neu trigger khong chan.
- Khong chay lai `01_schema_ddl.sql` hoac `seed_data.sql` sau khi tao trigger/view va can giu du lieu test, vi schema/seed co lenh xoa va tao lai bang/du lieu.
