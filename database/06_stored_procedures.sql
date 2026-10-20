-- 06_stored_procedures.sql
USE intelligent_resource_allocation;

DROP PROCEDURE IF EXISTS sp_get_available_resources;
DROP PROCEDURE IF EXISTS sp_get_pending_requests;
DROP PROCEDURE IF EXISTS sp_approve_booking_request;
DROP PROCEDURE IF EXISTS sp_approve_booking_transaction;

DELIMITER $$

CREATE PROCEDURE sp_get_available_resources(
    IN p_start_time DATETIME,
    IN p_end_time DATETIME
)
BEGIN
    SELECT r.*
    FROM vw_resource_details r
    WHERE r.status = 'AVAILABLE'
      AND NOT EXISTS (
          SELECT 1
          FROM bookings b
          WHERE b.resource_id = r.resource_id
            AND b.status <> 'CANCELLED'
            AND b.start_time < p_end_time
            AND b.end_time > p_start_time
      )
      AND NOT EXISTS (
          SELECT 1
          FROM maintenance_records m
          WHERE m.resource_id = r.resource_id
            AND m.status IN ('SCHEDULED','IN_PROGRESS')
            AND m.start_time < p_end_time
            AND m.end_time > p_start_time
      )
    ORDER BY r.resource_name;
END$$

CREATE PROCEDURE sp_get_pending_requests()
BEGIN
    SELECT
        br.request_id,
        u.full_name,
        r.resource_name,
        br.start_time,
        br.end_time,
        br.purpose,
        br.status
    FROM booking_requests br
    JOIN users u ON br.user_id = u.user_id
    JOIN resources r ON br.resource_id = r.resource_id
    WHERE br.status = 'PENDING'
    ORDER BY br.start_time;
END$$

CREATE PROCEDURE sp_approve_booking_request(
    IN p_request_id INT,
    IN p_reviewer_id INT
)
BEGIN
    UPDATE booking_requests
    SET status = 'APPROVED',
        reviewed_by = p_reviewer_id,
        reviewed_at = NOW()
    WHERE request_id = p_request_id
      AND status = 'PENDING';
END$$

CREATE PROCEDURE sp_approve_booking_transaction(
    IN p_request_id INT,
    IN p_reviewer_id INT
)
BEGIN
    DECLARE v_resource_id INT;
    DECLARE v_user_id INT;
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_status VARCHAR(20);

    SELECT resource_id, user_id, start_time, end_time, status
    INTO v_resource_id, v_user_id, v_start, v_end, v_status
    FROM booking_requests
    WHERE request_id = p_request_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Booking request not found';
    END IF;

    IF v_status <> 'PENDING' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only pending requests can be approved';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.resource_id = v_resource_id
          AND b.status <> 'CANCELLED'
          AND b.start_time < v_end
          AND b.end_time > v_start
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Resource already has a conflicting booking';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM maintenance_records m
        WHERE m.resource_id = v_resource_id
          AND m.status IN ('SCHEDULED','IN_PROGRESS')
          AND m.start_time < v_end
          AND m.end_time > v_start
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Resource is under maintenance during requested time';
    END IF;

    START TRANSACTION;

    UPDATE booking_requests
    SET status = 'APPROVED',
        reviewed_by = p_reviewer_id,
        reviewed_at = NOW()
    WHERE request_id = p_request_id;

    INSERT INTO bookings
        (request_id, resource_id, user_id, start_time, end_time, status)
    VALUES
        (p_request_id, v_resource_id, v_user_id, v_start, v_end, 'CONFIRMED');

    COMMIT;
END$$

DELIMITER ;
