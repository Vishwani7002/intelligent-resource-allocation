-- 04_sample_data.sql
-- Demo data for Intelligent Resource Allocation and Conflict Management System
USE intelligent_resource_allocation;

INSERT INTO departments (department_name, department_code) VALUES
('Artificial Intelligence and Data Science', 'AIDS'),
('Computer Science and Engineering', 'CSE'),
('Electronics and Communication Engineering', 'ECE'),
('Mechanical Engineering', 'MECH');

-- Demo passwords are stored as Werkzeug hashes in the Flask application.
-- These hashes correspond to the demo passwords used by the local project.
INSERT INTO users (full_name, email, password_hash, department_id, role, status) VALUES
('System Administrator', 'admin@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'ADMIN', 'ACTIVE'),
('Resource Manager', 'resource.manager@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'ADMIN', 'ACTIVE'),
('Dr. Ananya Rao', 'ananya.rao@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'FACULTY', 'ACTIVE'),
('Dr. Vikram Reddy', 'vikram.reddy@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'FACULTY', 'ACTIVE'),
('Dr. Rahul Kumar', 'rahul.kumar@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'FACULTY', 'ACTIVE'),
('Dr. Meera Sharma', 'meera.sharma@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'FACULTY', 'ACTIVE'),
('Prof. Priya Nair', 'priya.nair@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 3, 'FACULTY', 'ACTIVE'),
('Arjun Sharma', 'arjun.sharma@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'STUDENT', 'ACTIVE'),
('Nisha Patel', 'nisha.patel@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'STUDENT', 'ACTIVE'),
('Rohan Verma', 'rohan.verma@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'STUDENT', 'ACTIVE'),
('Kavya Reddy', 'kavya.reddy@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 1, 'STUDENT', 'ACTIVE'),
('Sneha Reddy', 'sneha.reddy@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'STUDENT', 'ACTIVE'),
('Aditya Rao', 'aditya.rao@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'STUDENT', 'ACTIVE'),
('Pooja Singh', 'pooja.singh@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'STUDENT', 'ACTIVE'),
('Harsh Gupta', 'harsh.gupta@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 2, 'STUDENT', 'ACTIVE'),
('Karthik Rao', 'karthik.rao@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 3, 'STUDENT', 'ACTIVE'),
('Neha Iyer', 'neha.iyer@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 3, 'STUDENT', 'ACTIVE'),
('Aman Khan', 'aman.khan@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 3, 'STUDENT', 'ACTIVE'),
('Vivek Mehta', 'vivek.mehta@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 4, 'STUDENT', 'ACTIVE'),
('Rahul Das', 'rahul.das@ira.local', 'scrypt:32768:8:1$demo$replace_with_application_hash', 4, 'STUDENT', 'ACTIVE');

INSERT INTO resource_types (type_name, description) VALUES
('Classroom', 'General classroom'),
('Seminar Hall', 'Large seminar and presentation space'),
('Software Engineering Lab', 'Software engineering laboratory'),
('Computing Lab', 'General computing laboratory'),
('AIDS Lab', 'Artificial Intelligence and Data Science laboratory'),
('ECE Lab', 'Electronics and Communication laboratory'),
('Mechanical Workshop', 'Mechanical engineering workshop'),
('Conference Room', 'Meeting and discussion room'),
('Projector', 'Presentation projector');

INSERT INTO locations (building_name, floor_no, room_name, capacity, description) VALUES
('Academic Block', 1, 'AIDS Lab', 70, 'AIDS laboratory'),
('Academic Block', 1, 'Computing Lab', 150, 'Computing laboratory'),
('Academic Block', 1, 'Conference Room', 25, 'Conference room'),
('Academic Block', 1, 'CS 101', 80, 'Classroom'),
('Academic Block', 1, 'CS 102', 60, 'Classroom'),
('Academic Block', 2, 'CS 201', 60, 'Classroom'),
('Academic Block', 2, 'CS 202', 70, 'Classroom'),
('Academic Block', 1, 'EC 101', 60, 'Classroom'),
('Academic Block', 2, 'EC 201', 60, 'Classroom'),
('Academic Block', 1, 'ECE Lab', 50, 'ECE laboratory'),
('Academic Block', 2, 'Hundry Seminar Hall', 150, 'Seminar hall'),
('Academic Block', 2, 'Krishna Seminar Hall', 350, 'Seminar hall'),
('Academic Block', 1, 'ME 101', 50, 'Mechanical classroom'),
('Academic Block', 2, 'ME 201', 50, 'Mechanical classroom'),
('Workshop Block', 1, 'Mechanical Workshop', 100, 'Mechanical workshop'),
('Academic Block', 1, 'SE Lab', 70, 'Software engineering laboratory'),
('Academic Block', 2, 'Tungabhadra Seminar Hall', 150, 'Seminar hall');

INSERT INTO resources (resource_name, resource_type_id, location_id, capacity, status, description) VALUES
('AIDS Lab', 5, 1, 70, 'AVAILABLE', 'AIDS laboratory'),
('Computing Lab', 4, 2, 150, 'AVAILABLE', 'Computing laboratory'),
('Conference Room', 8, 3, 25, 'AVAILABLE', 'Conference room'),
('CS 101', 1, 4, 80, 'AVAILABLE', 'Classroom'),
('CS 102', 1, 5, 60, 'AVAILABLE', 'Classroom'),
('CS 201', 1, 6, 60, 'AVAILABLE', 'Classroom'),
('CS 202', 1, 7, 70, 'AVAILABLE', 'Classroom'),
('EC 101', 1, 8, 60, 'AVAILABLE', 'Classroom'),
('EC 201', 1, 9, 60, 'AVAILABLE', 'Classroom'),
('ECE Lab', 6, 10, 50, 'AVAILABLE', 'ECE laboratory'),
('Hundry Seminar Hall', 2, 11, 150, 'AVAILABLE', 'Seminar hall'),
('Krishna Seminar Hall', 2, 12, 350, 'AVAILABLE', 'Seminar hall'),
('ME 101', 1, 13, 50, 'AVAILABLE', 'Mechanical classroom'),
('ME 201', 1, 14, 50, 'AVAILABLE', 'Mechanical classroom'),
('Mechanical Workshop', 7, 15, 100, 'AVAILABLE', 'Mechanical workshop'),
('SE Lab', 3, 16, 70, 'AVAILABLE', 'Software engineering laboratory'),
('Tungabhadra Seminar Hall', 2, 17, 150, 'AVAILABLE', 'Seminar hall');

-- Booking-request seed data. Use these after the tables and triggers/procedures are created.
INSERT INTO booking_requests
(user_id, resource_id, start_time, end_time, purpose, status, reviewed_by, reviewed_at) VALUES
(8, 16, '2026-10-20 09:00:00', '2026-10-20 11:00:00', 'Software project work', 'APPROVED', 1, '2026-10-19 10:00:00'),
(12, 1, '2026-10-20 11:00:00', '2026-10-20 13:00:00', 'AIDS lab practical', 'APPROVED', 1, '2026-10-19 10:10:00'),
(16, 10, '2026-10-20 14:00:00', '2026-10-20 16:00:00', 'ECE project work', 'APPROVED', 1, '2026-10-19 10:20:00'),
(19, 15, '2026-10-21 09:00:00', '2026-10-21 12:00:00', 'Workshop practice', 'REJECTED', 2, '2026-10-19 10:30:00'),
(9, 12, '2026-10-21 10:00:00', '2026-10-21 13:00:00', 'Seminar presentation', 'APPROVED', 1, '2026-10-19 10:40:00'),
(20, 14, '2026-10-21 14:00:00', '2026-10-21 16:00:00', 'Mechanical class', 'REJECTED', 2, '2026-10-19 10:50:00'),
(9, 4, '2026-10-22 09:00:00', '2026-10-22 11:00:00', 'Class activity', 'APPROVED', 1, '2026-10-19 11:00:00'),
(14, 2, '2026-10-22 11:00:00', '2026-10-22 13:00:00', 'Computing lab work', 'APPROVED', 1, '2026-10-19 11:10:00'),
(15, 6, '2026-10-22 14:00:00', '2026-10-22 16:00:00', 'Project work', 'CANCELLED', NULL, NULL),
(17, 11, '2026-10-23 09:00:00', '2026-10-23 12:00:00', 'ECE seminar', 'APPROVED', 1, '2026-10-19 11:30:00'),
(14, 2, '2026-10-27 10:00:00', '2026-10-27 12:00:00', 'Computing lab work', 'APPROVED', 1, '2026-10-19 11:40:00'),
(15, 2, '2026-10-27 11:00:00', '2026-10-27 13:00:00', 'Project work', 'PENDING', NULL, NULL),
(14, 2, '2026-10-28 10:00:00', '2026-10-28 12:00:00', 'Computing lab work', 'APPROVED', 1, '2026-10-19 12:00:00'),
(8, 4, '2026-10-27 10:00:00', '2026-10-27 12:00:00', 'Class activity', 'APPROVED', 1, '2026-10-19 12:10:00'),
(15, 4, '2026-10-27 11:00:00', '2026-10-27 13:00:00', 'Project work', 'PENDING', NULL, NULL),
(9, 1, '2026-10-24 10:00:00', '2026-10-24 12:00:00', 'AIDS lab work', 'PENDING', NULL, NULL),
(8, 4, '2026-10-27 09:00:00', '2026-10-27 10:00:00', 'Class activity', 'APPROVED', 1, '2026-10-19 12:20:00'),
(9, 4, '2026-10-27 09:30:00', '2026-10-27 10:30:00', 'Class activity', 'PENDING', NULL, NULL),
(9, 1, '2026-10-24 10:00:00', '2026-10-24 12:00:00', 'AIDS lab work', 'REJECTED', 1, '2026-10-19 12:30:00');

INSERT INTO bookings
(request_id, resource_id, user_id, start_time, end_time, status) VALUES
(1, 16, 8, '2026-10-20 09:00:00', '2026-10-20 11:00:00', 'COMPLETED'),
(2, 1, 12, '2026-10-20 11:00:00', '2026-10-20 13:00:00', 'CONFIRMED'),
(3, 10, 16, '2026-10-20 14:00:00', '2026-10-20 16:00:00', 'CONFIRMED'),
(5, 12, 9, '2026-10-21 10:00:00', '2026-10-21 13:00:00', 'CONFIRMED'),
(7, 4, 9, '2026-10-22 09:00:00', '2026-10-22 11:00:00', 'COMPLETED'),
(8, 2, 14, '2026-10-22 11:00:00', '2026-10-22 13:00:00', 'CONFIRMED'),
(10, 11, 17, '2026-10-23 09:00:00', '2026-10-23 12:00:00', 'CONFIRMED'),
(11, 2, 14, '2026-10-27 10:00:00', '2026-10-27 12:00:00', 'CONFIRMED'),
(13, 2, 14, '2026-10-28 10:00:00', '2026-10-28 12:00:00', 'CONFIRMED'),
(14, 4, 8, '2026-10-27 10:00:00', '2026-10-27 12:00:00', 'CONFIRMED'),
(17, 4, 8, '2026-10-27 09:00:00', '2026-10-27 10:00:00', 'CONFIRMED');

INSERT INTO maintenance_records
(resource_id, reported_by, maintenance_type, start_time, end_time, description, status) VALUES
(1, 2, 'Computer Maintenance', '2026-10-24 09:00:00', '2026-10-24 13:00:00', 'Scheduled computer maintenance', 'SCHEDULED'),
(2, 1, 'Network Maintenance', '2026-10-18 09:00:00', '2026-10-18 12:00:00', 'Network maintenance completed', 'COMPLETED'),
(15, 2, 'Equipment Maintenance', '2026-10-24 10:00:00', '2026-10-24 16:00:00', 'Workshop equipment maintenance', 'IN_PROGRESS'),
(10, 1, 'Equipment Inspection', '2026-10-25 09:00:00', '2026-10-25 12:00:00', 'Routine equipment inspection', 'SCHEDULED'),
(7, 2, 'Electrical Maintenance', '2026-10-26 09:00:00', '2026-10-26 11:00:00', 'Electrical maintenance cancelled', 'CANCELLED');

INSERT INTO usage_records
(booking_id, actual_start_time, actual_end_time, usage_status, notes) VALUES
(1, '2026-10-20 09:05:00', '2026-10-20 10:55:00', 'COMPLETED', 'Completed successfully'),
(3, '2026-10-20 14:05:00', NULL, 'IN_PROGRESS', 'Currently in use'),
(5, NULL, NULL, 'NOT_STARTED', NULL),
(7, '2026-10-22 09:10:00', '2026-10-22 10:50:00', 'COMPLETED', 'Completed successfully'),
(10, NULL, NULL, 'NO_SHOW', 'User did not start the booking');

-- Remove the duplicate seed row above if running this file manually:
-- DELETE FROM usage_records WHERE usage_id = LAST_INSERT_ID();
