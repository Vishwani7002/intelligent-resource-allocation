-- 05_views.sql
USE intelligent_resource_allocation;

CREATE OR REPLACE VIEW vw_resource_details AS
SELECT
    r.resource_id,
    r.resource_name,
    rt.type_name AS resource_type,
    l.building_name,
    l.floor_no,
    l.room_name,
    r.capacity,
    r.status,
    r.description
FROM resources r
JOIN resource_types rt ON r.resource_type_id = rt.resource_type_id
JOIN locations l ON r.location_id = l.location_id;

CREATE OR REPLACE VIEW vw_booking_details AS
SELECT
    b.booking_id,
    b.request_id,
    r.resource_name,
    u.full_name AS booked_by,
    u.email,
    b.start_time,
    b.end_time,
    b.status,
    br.purpose
FROM bookings b
JOIN resources r ON b.resource_id = r.resource_id
JOIN users u ON b.user_id = u.user_id
JOIN booking_requests br ON b.request_id = br.request_id;

CREATE OR REPLACE VIEW vw_resource_maintenance AS
SELECT
    m.maintenance_id,
    r.resource_name,
    u.full_name AS reported_by,
    m.maintenance_type,
    m.start_time,
    m.end_time,
    m.description,
    m.status
FROM maintenance_records m
JOIN resources r ON m.resource_id = r.resource_id
JOIN users u ON m.reported_by = u.user_id;
