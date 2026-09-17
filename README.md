# Gym Membership & Personal Training Planner

> A database project for managing gym memberships, training schedules,
> Personal training sessions, bookings, payments, gym visits,
> Equipment, and maintenance activities.

---

## 📌 Project Overview

This project is a database system designed to manage gym memberships,
training schedules, personal training sessions, bookings, payments,
gym visits, equipment, and maintenance activities.

The system focuses on maintaining data consistency and enforcing
important business rules related to gym operations.

## 🎯 Project Objectives

- Manage gym members and membership cards.
- Manage membership plans and membership contracts.
- Track recurring billing and payment status.
- Manage group classes and personal training sessions.
- Manage trainers and training rooms.
- Manage member bookings.
- Record gym check-in activities.
- Manage gym equipment and maintenance history.
- Prevent scheduling conflicts between trainers and rooms.
- Enforce room capacity and booking constraints.

## 🧩 Main Entities

The conceptual database model currently contains 13 entities:

| # | Entity | Description |
|---|---|---|
| 1 | MEMBER | Stores gym member information |
| 2 | MEMBERSHIP_CARD | Stores physical membership card information |
| 3 | MEMBERSHIP_PLAN | Defines membership plans and prices |
| 4 | MEMBERSHIP | Records a member's membership contract |
| 5 | BILLING_LOG | Records recurring billing transactions |
| 6 | GYM_VISIT | Records gym check-in activities |
| 7 | GYM_CLASS | Defines group activity types such as Yoga and Boxing |
| 8 | ROOM | Stores training room information and capacity |
| 9 | TRAINER | Stores trainer information |
| 10 | SESSION | Represents a scheduled training activity |
| 11 | BOOKING | Records a member's booking for a session |
| 12 | EQUIPMENT | Stores gym equipment information |
| 13 | MAINTENANCE_LOG | Records equipment maintenance history |

## 📐 Core Business Rules

- A member can have multiple memberships over time.
- Each membership belongs to one member and one membership plan.
- Only an active membership can create a new booking or check in.
- A group class session must reference a gym class.
- A personal training session does not reference a gym class.
- A trainer cannot be assigned to overlapping sessions.
- A room cannot contain overlapping sessions.
- A trainer must have at least 15 minutes between consecutive sessions.
- Group class bookings cannot exceed room capacity.
- A personal training session can have at most one booking.
- A member cannot book the same session more than once.
- An inactive or blocked membership card cannot be used for check-in.
- Equipment with an unfinished maintenance record cannot be used.

## 📄 Documentation

- [Phase 1 Report](docs/reports/report_phase_1.pdf)

## 📊 Project Status

| Component | Status |
|---|---|
| Business Analysis | ✅ Completed |
| Business Rules | ✅ Completed |
| Conceptual Model | ✅ Completed |
| Data Dictionary | ✅ Completed |
| ER Diagram |  ✅ Completed  |
| Database Schema | ⏳ Not Started |
| Sample Data | ⏳ Not Started |
| SQL Queries | ⏳ Not Started |
| Testing | ⏳ Not Started |

## 👥 Team Members
  Nguyễn Ngọc Toàn, làm report
  Nguyễn Anh Tuấn,  sửa văn bản
  Nguyễn Chí Thanh. sửa văn bản

## 🎓 Course Information

**Course:** INT1313 – Databases  
**Semester:** Semester 1, 2026–2027  
**Project:** Gym Membership & Personal Training Planner
