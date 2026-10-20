-- 07_triggers.sql
USE intelligent_resource_allocation;

DROP TRIGGER IF EXISTS trg_prevent_booking_conflict;
DROP TRIGGER IF EXISTS trg_prevent_maintenance_booking;
DROP TRIGGER IF EXISTS trg_maintenance_status_insert;
DROP TRIGGER IF EXISTS trg_maintenance_status_update;

DELIMITER $$

CREATE TRIGGER trg_prevent_booking_conflict
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.resource_id = NEW.resource_id
          AND b.status <> 'CANCELLED'
          AND b.start_time < NEW.end_time
          AND b.end_time > NEW.start_time
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Booking conflict: resource already booked for the selected time';
    END IF;
END$$

CREATE TRIGGER trg_prevent_maintenance_booking
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM maintenance_records m
        WHERE m.resource_id = NEW.resource_id
          AND m.status IN ('SCHEDULED','IN_PROGRESS')
          AND m.start_time < NEW.end_time
          AND m.end_time > NEW.start_time
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Booking blocked: resource is under maintenance';
    END IF;
END$$

CREATE TRIGGER trg_maintenance_status_insert
AFTER INSERT ON maintenance_records
FOR EACH ROW
BEGIN
    IF NEW.status IN ('SCHEDULED','IN_PROGRESS') THEN
        UPDATE resources
        SET status = 'MAINTENANCE'
        WHERE resource_id = NEW.resource_id
          AND status <> 'RETIRED';
    END IF;
END$$

CREATE TRIGGER trg_maintenance_status_update
AFTER UPDATE ON maintenance_records
FOR EACH ROW
BEGIN
    IF NEW.status IN ('COMPLETED','CANCELLED') THEN
        IF NOT EXISTS (
            SELECT 1
            FROM maintenance_records m
            WHERE m.resource_id = NEW.resource_id
              AND m.maintenance_id <> NEW.maintenance_id
              AND m.status IN ('SCHEDULED','IN_PROGRESS')
        ) THEN
            UPDATE resources
            SET status = 'AVAILABLE'
            WHERE resource_id = NEW.resource_id
              AND status = 'MAINTENANCE';
        END IF;
    ELSEIF NEW.status IN ('SCHEDULED','IN_PROGRESS') THEN
        UPDATE resources
        SET status = 'MAINTENANCE'
        WHERE resource_id = NEW.resource_id
          AND status <> 'RETIRED';
    END IF;
END$$

DELIMITER ;
