-- 08_demo_queries.sql
USE intelligent_resource_allocation;

-- 1. Show all resources
SELECT * FROM vw_resource_details;

-- 2. Show available resources for a time range
CALL sp_get_available_resources('2026-10-27 09:00:00', '2026-10-27 10:00:00');

-- 3. Show pending booking requests
CALL sp_get_pending_requests();

-- 4. Show booking history/details
SELECT * FROM vw_booking_details ORDER BY start_time;

-- 5. Show maintenance records
SELECT * FROM vw_resource_maintenance ORDER BY start_time;

-- 6. Find resources with capacity >= 100
SELECT resource_name, capacity, status
FROM resources
WHERE capacity >= 100
ORDER BY capacity DESC;

-- 7. Count resources by status
SELECT status, COUNT(*) AS resource_count
FROM resources
GROUP BY status;

-- 8. Count booking requests by status
SELECT status, COUNT(*) AS request_count
FROM booking_requests
GROUP BY status;

-- 9. Demonstrate a transaction with rollback
START TRANSACTION;

UPDATE booking_requests
SET status = 'CANCELLED'
WHERE request_id = 12;

SELECT request_id, status
FROM booking_requests
WHERE request_id = 12;

ROLLBACK;

SELECT request_id, status
FROM booking_requests
WHERE request_id = 12;

-- 10. Detect overlapping booking requests
SELECT
    a.request_id AS request_a,
    b.request_id AS request_b,
    a.resource_id,
    a.start_time AS a_start,
    a.end_time AS a_end,
    b.start_time AS b_start,
    b.end_time AS b_end
FROM booking_requests a
JOIN booking_requests b
  ON a.resource_id = b.resource_id
 AND a.request_id < b.request_id
 AND a.status IN ('PENDING','APPROVED')
 AND b.status IN ('PENDING','APPROVED')
 AND a.start_time < b.end_time
 AND a.end_time > b.start_time;

-- 11. Department-wise active user count
SELECT d.department_code, COUNT(*) AS active_users
FROM users u
JOIN departments d ON u.department_id = d.department_id
WHERE u.status = 'ACTIVE'
GROUP BY d.department_code
ORDER BY active_users DESC;

-- 12. Resource utilization through completed/in-progress usage
SELECT
    r.resource_name,
    COUNT(ur.usage_id) AS usage_count
FROM resources r
LEFT JOIN bookings b ON r.resource_id = b.resource_id
LEFT JOIN usage_records ur ON b.booking_id = ur.booking_id
GROUP BY r.resource_id, r.resource_name
ORDER BY usage_count DESC;
