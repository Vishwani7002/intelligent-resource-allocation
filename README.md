# Intelligent Resource Allocation and Conflict Management System

```{=html}
<p align="center">
```
`<strong>`{=html}A DBMS-driven platform for intelligent resource
allocation, booking management, and conflict
prevention.`</strong>`{=html}
```{=html}
</p>
```
```{=html}
<p align="center">
```
`<img src="frontend/images/ira-logo.png" alt="IRA Logo" width="420">`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

## 📌 Overview

The **Intelligent Resource Allocation and Conflict Management System
(IRA)** is a full-stack DBMS project designed to efficiently manage
shared institutional resources such as classrooms, laboratories, seminar
halls, workshops, conference rooms, and equipment.

The system provides a centralized platform for:

-   Resource availability management
-   Booking request creation
-   Approval and rejection workflows
-   Automatic booking conflict prevention
-   Maintenance scheduling
-   Resource usage tracking
-   Role-based access control
-   Dashboard analytics
-   Database-driven reporting

The project focuses on demonstrating practical **DBMS concepts** through
a functional web application.

------------------------------------------------------------------------

## 🎯 Problem Statement

Educational institutions often manage shared resources through
disconnected spreadsheets, manual approvals, or informal communication.
This can result in:

-   Double bookings
-   Resource conflicts
-   Poor visibility of availability
-   Scheduling errors
-   Difficulty tracking maintenance
-   Inaccurate usage records
-   Lack of centralized control

IRA addresses these problems using a structured relational database and
a web-based management interface.

------------------------------------------------------------------------

## ✨ Key Features

### 👤 User Management

-   Role-based users
-   Department association
-   Active/inactive user status
-   Secure login authentication
-   Access control for administrative operations

### 🏫 Resource Management

-   Classrooms
-   Seminar halls
-   Laboratories
-   Computing facilities
-   Mechanical workshop
-   Conference rooms
-   Equipment
-   Resource capacity and status tracking

### 📅 Booking Management

-   Submit resource booking requests
-   View booking history
-   Track booking status
-   Approve or reject requests
-   Prevent overlapping bookings

### ⚠️ Conflict Management

The system automatically checks for conflicts before approving a
booking.

It prevents: - Overlapping bookings - Booking resources during
maintenance - Invalid resource states - Unauthorized approval operations

### 🔧 Maintenance Management

-   Schedule maintenance
-   Track maintenance status
-   Record maintenance descriptions
-   Prevent bookings during scheduled maintenance

### 📊 Dashboard & Analytics

The dashboard provides: - Total resources - Available resources - Total
bookings - Pending requests - Maintenance records - Resource status
information - Department-wise booking information

------------------------------------------------------------------------

## 🧠 DBMS Concepts Demonstrated

This project is primarily designed to showcase practical database
concepts.

  DBMS Concept            Implementation
  ----------------------- -----------------------------------------
  Relational Database     MySQL
  Primary Keys            All major entities
  Foreign Keys            Relationships between entities
  Constraints             `CHECK`, `UNIQUE`, `NOT NULL`
  Indexes                 Frequently queried columns
  Views                   Resource, booking and maintenance views
  Stored Procedures       Availability and booking operations
  Transactions            Transaction-safe booking approval
  Rollback                Demonstrated during transaction testing
  Triggers                Conflict and maintenance validation
  Joins                   Multi-table reporting queries
  Aggregation             Dashboard and analytical queries
  Role-based Access       Application + database workflow
  Referential Integrity   Foreign-key relationships

------------------------------------------------------------------------

## 🗄️ Database Design

The database contains the following major entities:

``` text
Departments
    │
    └── Users
          │
          └── Booking Requests
                  │
                  └── Bookings
                         │
                         └── Usage Records

Resource Types
    │
    └── Resources
          │
          ├── Locations
          │
          ├── Booking Requests
          │
          └── Maintenance Records
```

### Main Tables

1.  `departments`
2.  `users`
3.  `resource_types`
4.  `locations`
5.  `resources`
6.  `booking_requests`
7.  `bookings`
8.  `maintenance_records`
9.  `usage_records`

------------------------------------------------------------------------

## 🏗️ System Architecture

``` text
┌──────────────────────────┐
│        User / Admin      │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│       Web Frontend       │
│      HTML / CSS / JS     │
└────────────┬─────────────┘
             │ REST API
             ▼
┌──────────────────────────┐
│       Flask Backend      │
│       Python / API       │
└────────────┬─────────────┘
             │ SQL
             ▼
┌──────────────────────────┐
│       MySQL Database     │
│ Tables / Views / SPs /   │
│ Triggers / Transactions  │
└──────────────────────────┘
```

------------------------------------------------------------------------

## 🛠️ Technology Stack

### Frontend

-   HTML5
-   CSS3
-   JavaScript

### Backend

-   Python
-   Flask
-   REST API
-   Flask-CORS
-   Werkzeug

### Database

-   MySQL 8
-   MySQL Workbench

### Development Tools

-   Visual Studio Code
-   Git
-   GitHub

------------------------------------------------------------------------

## 📁 Project Structure

``` text
intelligent_resource_allocation/
│
├── backend/
│   ├── app.py
│   ├── db.py
│   ├── requirements.txt
│   └── test_*.py
│
├── frontend/
│   ├── index.html
│   ├── login.html
│   ├── resources.html
│   ├── bookings.html
│   ├── requests.html
│   ├── maintenance.html
│   │
│   ├── css/
│   │   └── style.css
│   │
│   ├── js/
│   │   └── app.js
│   │
│   └── images/
│       └── ira-logo.png
│
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_constraints_indexes.sql
│   ├── 04_sample_data.sql
│   ├── 05_views.sql
│   ├── 06_stored_procedures.sql
│   ├── 07_triggers.sql
│   └── 08_demo_queries.sql
│
├── .gitignore
└── README.md
```

------------------------------------------------------------------------

## 🚀 Getting Started

### 1. Clone the repository

``` bash
git clone https://github.com/Vishwani7002/intelligent-resource-allocation.git
cd intelligent-resource-allocation
```

### 2. Create and activate a Python virtual environment

``` bash
python -m venv venv
```

On Windows Command Prompt:

``` cmd
venv\Scripts\activate.bat
```

### 3. Install backend dependencies

``` bash
pip install -r backend/requirements.txt
```

### 4. Configure the database

Create a MySQL database named:

``` sql
CREATE DATABASE intelligent_resource_allocation;
```

Configure the backend database connection using a local `.env` file.

Example:

``` env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=YOUR_MYSQL_PASSWORD
DB_NAME=intelligent_resource_allocation
DB_PORT=3306
```

> Never commit your real database password or other secrets to GitHub.

### 5. Run the Flask backend

``` bash
cd backend
python app.py
```

The backend runs locally at:

``` text
http://127.0.0.1:5000
```

### 6. Open the frontend

Open:

``` text
frontend/login.html
```

in your browser.

------------------------------------------------------------------------

## 🔐 Demo Roles

The application supports different roles, including:

-   **ADMIN**
-   **FACULTY**
-   **STAFF**
-   **STUDENT**

Administrative booking approval operations are restricted to authorized
roles.

> Demo credentials should be kept for local demonstration only and
> should not be used as production credentials.

------------------------------------------------------------------------

## 🔄 Example Workflow

``` text
User Login
    ↓
Browse Available Resources
    ↓
Submit Booking Request
    ↓
System Validates Resource
    ↓
Check Booking Conflicts
    ↓
Check Maintenance Schedule
    ↓
Admin / Staff Approval
    ↓
Booking Confirmed
    ↓
Resource Usage Recorded
```

------------------------------------------------------------------------

## 🛡️ Conflict Prevention

One of the core features of IRA is preventing invalid resource
allocation.

For example, if a resource is already booked:

``` text
09:00 ───────── 11:00
        Existing Booking
```

a new request for:

``` text
10:00 ───────── 12:00
        New Request
```

is detected as a conflict and cannot be approved.

The database also prevents booking a resource during an applicable
maintenance period.

------------------------------------------------------------------------

## 🧪 Testing

The project includes backend test scripts for important operations,
including:

-   Booking request creation
-   Booking approval
-   Booking rejection
-   Role validation
-   Database connectivity

The database layer was also tested for:

-   Constraint enforcement
-   Conflict detection
-   Maintenance restrictions
-   Stored procedures
-   Transaction rollback
-   Trigger behavior

------------------------------------------------------------------------

## 📈 Future Enhancements

Possible future improvements include:

-   Email notifications
-   Calendar integration
-   Advanced scheduling algorithms
-   Resource recommendation based on requirements
-   Utilization forecasting
-   Mobile application
-   QR-based resource check-in
-   Automated analytics reports
-   Cloud deployment

------------------------------------------------------------------------

## 🎓 Academic Purpose

This project was developed to demonstrate how core **Database Management
System concepts** can be integrated into a practical full-stack
application.

The main emphasis is on:

**Database Design → Data Integrity → Conflict Detection → Transaction
Management → Resource Allocation → Analytics**

------------------------------------------------------------------------

## 👥 Project

**Project:** Intelligent Resource Allocation and Conflict Management
System

**Repository:**\
https://github.com/Vishwani7002/intelligent-resource-allocation

------------------------------------------------------------------------

## 📄 License

This project is intended primarily for academic and educational
purposes.
