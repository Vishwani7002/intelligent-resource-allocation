-- 02_create_tables.sql
USE intelligent_resource_allocation;

CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    department_id INT NOT NULL,
    role ENUM('ADMIN','FACULTY','STAFF','STUDENT') NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT chk_users_status CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE IF NOT EXISTS resource_types (
    resource_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    building_name VARCHAR(100) NOT NULL,
    floor_no INT NOT NULL,
    room_name VARCHAR(100) NOT NULL,
    capacity INT,
    description VARCHAR(255),
    CONSTRAINT uq_location UNIQUE (building_name, floor_no, room_name),
    CONSTRAINT chk_location_capacity CHECK (capacity IS NULL OR capacity > 0)
);

CREATE TABLE IF NOT EXISTS resources (
    resource_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL UNIQUE,
    resource_type_id INT NOT NULL,
    location_id INT NOT NULL,
    capacity INT NOT NULL,
    status ENUM('AVAILABLE','UNAVAILABLE','MAINTENANCE','RETIRED') NOT NULL DEFAULT 'AVAILABLE',
    description VARCHAR(255),
    CONSTRAINT fk_resources_type
        FOREIGN KEY (resource_type_id) REFERENCES resource_types(resource_type_id),
    CONSTRAINT fk_resources_location
        FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT chk_resource_capacity CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS booking_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    resource_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    status ENUM('PENDING','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    reviewed_by INT NULL,
    reviewed_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_requests_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_requests_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id),
    CONSTRAINT fk_requests_reviewer
        FOREIGN KEY (reviewed_by) REFERENCES users(user_id),
    CONSTRAINT chk_request_time CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL UNIQUE,
    resource_id INT NOT NULL,
    user_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('CONFIRMED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'CONFIRMED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_request
        FOREIGN KEY (request_id) REFERENCES booking_requests(request_id),
    CONSTRAINT fk_bookings_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id),
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_booking_time CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS maintenance_records (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    resource_id INT NOT NULL,
    reported_by INT NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    description VARCHAR(255),
    status ENUM('SCHEDULED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_maintenance_resource
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id),
    CONSTRAINT fk_maintenance_reporter
        FOREIGN KEY (reported_by) REFERENCES users(user_id),
    CONSTRAINT chk_maintenance_time CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS usage_records (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    actual_start_time DATETIME NULL,
    actual_end_time DATETIME NULL,
    usage_status ENUM('NOT_STARTED','IN_PROGRESS','COMPLETED','NO_SHOW') NOT NULL DEFAULT 'NOT_STARTED',
    notes VARCHAR(255),
    CONSTRAINT fk_usage_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT chk_usage_time CHECK (
        actual_end_time IS NULL OR actual_start_time IS NULL OR actual_end_time > actual_start_time
    )
);
