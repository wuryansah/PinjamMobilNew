# PinjamMobil - Office Vehicle Usage System

A full-stack Laravel application for managing office vehicle usage and lending.

## Features

- **User Management**: Role-based access (Admin, Employee, Supervisor, Driver)
- **Vehicle Management**: Add, edit, delete vehicles with availability tracking
- **Request System**: Employee vehicle requests with approval workflow
- **Approval Workflow**: Pending → Supervisor Approval → Admin Assignment → In Progress → Completed
- **Usage Tracking**: Start/End kilometer, fuel usage, notes
- **Dashboard**: Role-based statistics and overview
- **Reports**: Usage history, mileage, vehicle utilization
- **Notifications**: Request status updates

## Tech Stack

- Laravel 12.x (PHP 8.2+)
- Blade Templates + Bootstrap 5
- MySQL 8.0
- Laravel Breeze (Authentication)

## Setup

```bash
# Install dependencies
composer install
npm install

# Copy env and configure database
cp .env.example .env
# Update .env with MySQL credentials

# Generate key and migrate
php artisan key:generate
php artisan migrate

# Build assets
npm run build

# Start server
php artisan serve
```

## User Roles

| Role | Access |
|------|--------|
| Admin | Full access, vehicle CRUD, reports |
| Employee | Submit requests, view own requests |
| Supervisor | Approve/reject requests |
| Driver | Manage assigned trips, record usage |

## Database

- users (with role field)
- vehicles
- vehicle_requests (with workflow status)
- usage_records
- notifications

## API Documentation

See `SPEC.md` for detailed specifications.

## License

MIT