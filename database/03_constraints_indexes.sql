-- 03_constraints_indexes.sql
USE intelligent_resource_allocation;

CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_resources_type ON resources(resource_type_id);
CREATE INDEX idx_resources_location ON resources(location_id);
CREATE INDEX idx_resources_status ON resources(status);
CREATE INDEX idx_requests_resource_time ON booking_requests(resource_id, start_time, end_time);
CREATE INDEX idx_requests_status ON booking_requests(status);
CREATE INDEX idx_bookings_resource_time ON bookings(resource_id, start_time, end_time);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_maintenance_resource_time ON maintenance_records(resource_id, start_time, end_time);
CREATE INDEX idx_maintenance_status ON maintenance_records(status);
