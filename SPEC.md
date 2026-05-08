# Office Vehicle Usage System - Specification

## 1. Project Overview

**Project Name:** PinjamMobil - Office Vehicle Usage System  
**Project Type:** Full-stack Web Application  
**Core Functionality:** A comprehensive system for managing office vehicle lending, tracking usage, and handling approval workflows for employee vehicle requests.  
**Target Users:** Admin, Employees (Borrowers), Supervisors (Approvers), Drivers

## 2. Tech Stack

- **Backend:** Laravel 10.x (PHP 8.2+)
- **Frontend:** Blade Templates + Bootstrap 5
- **Database:** MySQL 8.0
- **Authentication:** Laravel Breeze / JWT
- **Development Server:** Built-in PHP server

## 3. Database Schema

### 3.1 Users Table
| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Primary key |
| name | VARCHAR(255) | Full name |
| email | VARCHAR(255) | Unique email |
| password | VARCHAR(255) | Hashed password |
| role | ENUM | admin, employee, supervisor, driver |
| department | VARCHAR(100) | User department |
| phone | VARCHAR(20) | Contact number |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

### 3.2 Vehicles Table
| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Primary key |
| name | VARCHAR(100) | Vehicle name |
| plate_number | VARCHAR(20) | Unique plate number |
| type | ENUM | car, van, truck, motorcycle |
| condition | ENUM | good, needs_maintenance, unavailable |
| availability | ENUM | available, in_use, maintenance |
| driver_id | BIGINT | FK to users (optional) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

### 3.3 Vehicle Requests Table
| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Primary key |
| borrower_id | BIGINT | FK to users |
| vehicle_id | BIGINT | FK to vehicles (assigned by admin) |
| driver_id | BIGINT | FK to users (assigned by admin) |
| destination | VARCHAR(255) | Trip destination |
| purpose | TEXT | Purpose of use |
| start_datetime | DATETIME | Requested start time |
| end_datetime | DATETIME | Requested return time |
| status | ENUM | pending, supervisor_approved, supervisor_rejected, admin_approved, admin_rejected, in_progress, completed |
| supervisor_notes | TEXT | Supervisor approval notes |
| admin_notes | TEXT | Admin assignment notes |
| approved_by | BIGINT | FK to users (supervisor) |
| assigned_by | BIGINT | FK to users (admin) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

### 3.4 Usage Records Table
| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Primary key |
| request_id | BIGINT | FK to vehicle_requests |
| start_km | DECIMAL(10,2) | Starting kilometer |
| end_km | DECIMAL(10,2) | Ending kilometer |
| fuel_used | DECIMAL(6,2) | Fuel usage (liters) |
| notes | TEXT | Trip notes/issues |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

### 3.5 Notifications Table
| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Primary key |
| user_id | BIGINT | FK to users |
| type | VARCHAR(50) | Notification type |
| title | VARCHAR(255) | Notification title |
| message | TEXT | Notification message |
| is_read | BOOLEAN | Read status |
| created_at | TIMESTAMP | Creation timestamp |

## 4. User Roles & Permissions

### 4.1 Admin
- Manage all vehicles (CRUD)
- View all requests
- Assign vehicle and driver to requests
- Approve/reject requests
- View reports and dashboards
- Manage all users

### 4.2 Employee (Borrower)
- Create vehicle request
- View own request status
- View own request history

### 4.3 Supervisor (Approver)
- View pending requests from employees
- Approve/reject requests with notes
- View approved requests

### 4.4 Driver
- View assigned trips
- Fill in usage data (start km, end km, fuel, notes)
- Mark vehicle as returned

## 5. API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/user` - Get current user

### Vehicles (Admin)
- `GET /api/vehicles` - List all vehicles
- `POST /api/vehicles` - Create vehicle
- `GET /api/vehicles/{id}` - Get vehicle details
- `PUT /api/vehicles/{id}` - Update vehicle
- `DELETE /api/vehicles/{id}` - Delete vehicle

### Requests
- `GET /api/requests` - List requests (role-based)
- `POST /api/requests` - Create request (employee)
- `GET /api/requests/{id}` - Get request details
- `PUT /api/requests/{id}/supervisor-approve` - Supervisor approval (supervisor)
- `PUT /api/requests/{id}/admin-assign` - Admin assignment (admin)
- `PUT /api/requests/{id}/start-trip` - Start trip (driver)
- `PUT /api/requests/{id}/complete` - Complete trip (driver)

### Usage Records
- `POST /api/usage` - Create usage record
- `GET /api/usage/request/{id}` - Get usage by request

### Dashboard & Reports
- `GET /api/dashboard/stats` - Get dashboard statistics
- `GET /api/reports/usage` - Usage history report
- `GET /api/reports/mileage` - Mileage tracking report

### Notifications
- `GET /api/notifications` - List user notifications
- `PUT /api/notifications/{id}/read` - Mark as read

## 6. UI/UX Requirements

### Layout
- Responsive Bootstrap 5 layout
- Sidebar navigation for dashboard
- Top navbar with user profile and notifications
- Card-based content display

### Pages
1. **Login/Register** - Authentication forms
2. **Dashboard** - Statistics and quick actions
3. **Vehicle Management** - CRUD interface for vehicles
4. **Request Form** - Borrower request submission
5. **Request List** - View and manage requests
6. **Request Details** - Full request info with actions
7. **Usage Entry** - Driver form for trip data
8. **Reports** - Usage history and analytics
9. **Profile** - User profile and settings

### Color Scheme
- Primary: #2c3e50 (Dark Blue)
- Secondary: #3498db (Blue)
- Success: #27ae60 (Green)
- Warning: #f39c12 (Orange)
- Danger: #e74c3c (Red)
- Background: #f8f9fa (Light Gray)

## 7. Workflow States

```
Request Flow:
pending → supervisor_approved → admin_approved → in_progress → completed
   ↓              ↓                    ↓
  rejected      rejected            admin_rejected

Vehicle Status:
available ←→ in_use ←→ maintenance
```

## 8. Acceptance Criteria

1. User can register and login with role selection
2. Admin can create, edit, delete vehicles
3. Employee can submit vehicle request with all required fields
4. Supervisor can approve/reject pending requests
5. Admin can assign vehicle and driver to approved requests
6. Driver can input usage data and mark trip as complete
7. Dashboard shows correct statistics
8. Notifications are generated for key events
9. All forms have proper validation
10. Responsive design works on mobile and desktop