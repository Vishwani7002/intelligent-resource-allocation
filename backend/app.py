from flask import Flask, jsonify, request
from flask_cors import CORS
from werkzeug.security import check_password_hash

from db import get_db_connection


app = Flask(__name__)
CORS(app)


@app.route("/")
def home():
    return jsonify({
        "message": "Intelligent Resource Allocation System API is running"
    })


@app.route("/api/test-db")
def test_database():

    connection = get_db_connection()

    cursor = connection.cursor(dictionary=True)

    cursor.execute("SELECT DATABASE() AS database_name")

    result = cursor.fetchone()

    cursor.close()
    connection.close()

    return jsonify(result)

@app.route("/api/resources", methods=["GET"])
def get_resources():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            resource_id,
            resource_name,
            resource_type,
            building_name,
            floor_number,
            room_number,
            capacity,
            status,
            description
        FROM vw_resource_details
        ORDER BY resource_name
    """)

    resources = cursor.fetchall()

    cursor.close()
    connection.close()

    return jsonify(resources)



@app.route("/api/bookings", methods=["GET"])
def get_bookings():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                booking_id,
                request_id,
                user_name,
                email,
                department_name,
                resource_name,
                start_time,
                end_time,
                booking_status,
                approved_at
            FROM vw_booking_details
            ORDER BY start_time
        """)

        bookings = cursor.fetchall()

        # Convert MySQL date/time values into JSON-friendly strings
        for booking in bookings:
            for field in ("start_time", "end_time", "approved_at"):
                if booking[field] is not None:
                    booking[field] = booking[field].isoformat(sep=" ")

        return jsonify(bookings)

    except Exception:
        app.logger.exception("Could not retrieve bookings")
        return jsonify({"error": "Could not retrieve bookings"}), 500

    finally:
        cursor.close()
        connection.close()

@app.route("/api/maintenance", methods=["GET"])
def get_maintenance():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
                maintenance_id,
                resource_name,
                reported_by,
                start_time,
                end_time,
                maintenance_type,
                description,
                status
            FROM vw_resource_maintenance
            ORDER BY start_time
        """)

        maintenance_records = cursor.fetchall()

        for record in maintenance_records:
            for field in ("start_time", "end_time"):
                if record[field] is not None:
                    record[field] = record[field].isoformat(sep=" ")

        return jsonify(maintenance_records)

    except Exception:
        app.logger.exception("Could not retrieve maintenance records")
        return jsonify({
            "error": "Could not retrieve maintenance records"
        }), 500

    finally:
        cursor.close()
        connection.close()
@app.route("/api/booking-requests", methods=["POST"])
def create_booking_request():

    data = request.get_json(silent=True) or {}

    required_fields = [
        "user_id",
        "resource_id",
        "requested_start",
        "requested_end",
        "purpose"
    ]

    for field in required_fields:
        if field not in data:
            return jsonify({
                "error": f"Missing field: {field}"
            }), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        # Verify that the requesting user exists and is active
        cursor.execute("""
            SELECT user_id, status
            FROM users
            WHERE user_id = %s
        """, (data["user_id"],))

        user = cursor.fetchone()

        if not user:
            return jsonify({
                "error": "User does not exist."
            }), 403

        if user["status"] != "ACTIVE":
            return jsonify({
                "error": "User account is inactive."
            }), 403

        # Verify that the resource exists
        cursor.execute("""
            SELECT resource_id, status
            FROM resources
            WHERE resource_id = %s
        """, (data["resource_id"],))

        resource = cursor.fetchone()

        if not resource:
            return jsonify({
                "error": "Resource does not exist."
            }), 404

        if resource["status"] in (
            "UNAVAILABLE",
            "RETIRED"
        ):
            return jsonify({
                "error": "Resource is currently unavailable."
            }), 400

        # Create booking request
        cursor.execute("""
            INSERT INTO booking_requests (
                user_id,
                resource_id,
                requested_start,
                requested_end,
                purpose,
                status
            )
            VALUES (%s, %s, %s, %s, %s, 'PENDING')
        """, (
            data["user_id"],
            data["resource_id"],
            data["requested_start"],
            data["requested_end"],
            data["purpose"]
        ))

        connection.commit()

        request_id = cursor.lastrowid

        return jsonify({
            "message": "Booking request created successfully",
            "request_id": request_id,
            "status": "PENDING"
        }), 201

    except Exception:

        connection.rollback()

        app.logger.exception(
            "Could not create booking request"
        )

        return jsonify({
            "error": "Could not create booking request"
        }), 500

    finally:

        cursor.close()
        connection.close()   

@app.route("/api/booking-requests", methods=["GET"])
def get_booking_requests():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT
    br.request_id,
    br.user_id,
    u.full_name AS requester,
    u.email,
    d.department_name,
    br.resource_id,
    r.resource_name,
    br.requested_start,
    br.requested_end,
    br.purpose,
    br.status,
    br.requested_at,
    br.reviewed_by,
    br.reviewed_at
FROM booking_requests br
JOIN users u
    ON br.user_id = u.user_id
JOIN departments d
    ON u.department_id = d.department_id
JOIN resources r
    ON br.resource_id = r.resource_id
ORDER BY br.requested_at DESC
        """)

        requests_data = cursor.fetchall()

        for item in requests_data:
            for field in ("requested_start", "requested_end", "requested_at"):
                if item[field] is not None:
                    item[field] = item[field].isoformat(sep=" ")

        return jsonify(requests_data)

    except Exception:
        app.logger.exception("Could not retrieve booking requests")

        return jsonify({
            "error": "Could not retrieve booking requests"
        }), 500

    finally:
        cursor.close()
        connection.close()
@app.route("/api/booking-requests/<int:request_id>/approve", methods=["POST"])
def approve_booking_request(request_id):

    data = request.get_json(silent=True) or {}

    reviewer_id = data.get("reviewer_id")

    if not reviewer_id:
        return jsonify({
            "error": "reviewer_id is required"
        }), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        # Check reviewer authorization
        cursor.execute("""
            SELECT role, status
            FROM users
            WHERE user_id = %s
        """, (reviewer_id,))

        reviewer = cursor.fetchone()

        if not reviewer:
            return jsonify({
                "error": "Reviewer does not exist."
            }), 403

        if reviewer["status"] != "ACTIVE":
            return jsonify({
                "error": "Reviewer account is inactive."
            }), 403

        if reviewer["role"] not in ("ADMIN", "STAFF"):
            return jsonify({
                "error": "Only ADMIN or STAFF users can approve booking requests."
            }), 403

        # Approve booking request through transaction procedure
        cursor.callproc(
            "sp_approve_booking_transaction",
            [request_id, reviewer_id]
        )

        connection.commit()

        return jsonify({
            "message": "Booking request approved successfully",
            "request_id": request_id,
            "status": "APPROVED"
        }), 200

    except Exception as e:

        connection.rollback()

        error_message = str(e)

        if "maintenance" in error_message.lower():
            error_message = (
                "Cannot approve booking: "
                "the resource is under maintenance during this time."
            )

        elif "already booked" in error_message.lower():
            error_message = (
                "Cannot approve booking: "
                "the resource is already booked during this time."
            )

        elif "Only pending requests" in error_message:
            error_message = (
                "Cannot approve booking: "
                "this request is no longer pending."
            )

        app.logger.exception("Could not approve booking request")

        return jsonify({
            "error": error_message
        }), 400

    finally:

        cursor.close()
        connection.close()    
@app.route("/api/booking-requests/<int:request_id>/reject", methods=["POST"])
def reject_booking_request(request_id):

    data = request.get_json(silent=True) or {}

    reviewer_id = data.get("reviewer_id")

    if not reviewer_id:
        return jsonify({
            "error": "reviewer_id is required"
        }), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        # Check reviewer authorization
        cursor.execute("""
            SELECT role, status
            FROM users
            WHERE user_id = %s
        """, (reviewer_id,))

        reviewer = cursor.fetchone()

        if not reviewer:
            return jsonify({
                "error": "Reviewer does not exist."
            }), 403

        if reviewer["status"] != "ACTIVE":
            return jsonify({
                "error": "Reviewer account is inactive."
            }), 403

        if reviewer["role"] not in ("ADMIN", "STAFF"):
            return jsonify({
                "error": "Only ADMIN or STAFF users can reject booking requests."
            }), 403

        cursor.execute("""
            SELECT status
            FROM booking_requests
            WHERE request_id = %s
        """, (request_id,))

        result = cursor.fetchone()

        if not result:
            return jsonify({
                "error": "Booking request not found"
            }), 404

        if result["status"] != "PENDING":
            return jsonify({
                "error": "Only pending requests can be rejected"
            }), 400

        cursor.execute("""
            UPDATE booking_requests
            SET
                status = 'REJECTED',
                reviewed_by = %s,
                reviewed_at = CURRENT_TIMESTAMP
            WHERE request_id = %s
        """, (reviewer_id, request_id))

        connection.commit()

        return jsonify({
            "message": "Booking request rejected successfully",
            "request_id": request_id,
            "status": "REJECTED"
        }), 200

    except Exception as e:

        connection.rollback()

        app.logger.exception("Could not reject booking request")

        return jsonify({
            "error": str(e)
        }), 400

    finally:

        cursor.close()
        connection.close()
@app.route("/api/available-resources", methods=["GET"])
def get_available_resources():

    start_time = request.args.get("start_time")
    end_time = request.args.get("end_time")

    if not start_time or not end_time:
        return jsonify({
            "error": "start_time and end_time are required"
        }), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        cursor.callproc(
            "sp_get_available_resources",
            [start_time, end_time]
        )

        available_resources = []

        for result in cursor.stored_results():
            available_resources = result.fetchall()

        for resource in available_resources:

            for field in resource:

                if resource[field] is not None:
                    if hasattr(resource[field], "isoformat"):
                        resource[field] = resource[field].isoformat(
                            sep=" "
                        )

        return jsonify(available_resources)

    except Exception:

        app.logger.exception(
            "Could not retrieve available resources"
        )

        return jsonify({
            "error": "Could not retrieve available resources"
        }), 500

    finally:

        cursor.close()
        connection.close()
@app.route("/api/dashboard-stats", methods=["GET"])
def get_dashboard_stats():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        # Total resources
        cursor.execute("""
            SELECT COUNT(*) AS total_resources
            FROM resources
        """)

        total_resources = cursor.fetchone()["total_resources"]


        # Available resources
        cursor.execute("""
            SELECT COUNT(*) AS available_resources
            FROM resources
            WHERE status = 'AVAILABLE'
        """)

        available_resources = cursor.fetchone()["available_resources"]


        # Total bookings
        cursor.execute("""
            SELECT COUNT(*) AS total_bookings
            FROM bookings
        """)

        total_bookings = cursor.fetchone()["total_bookings"]


        # Pending requests
        cursor.execute("""
            SELECT COUNT(*) AS pending_requests
            FROM booking_requests
            WHERE status = 'PENDING'
        """)

        pending_requests = cursor.fetchone()["pending_requests"]


        # Maintenance records
        cursor.execute("""
            SELECT COUNT(*) AS maintenance_records
            FROM maintenance_records
        """)

        maintenance_records = cursor.fetchone()["maintenance_records"]


        # Resource status
        cursor.execute("""
            SELECT
                status,
                COUNT(*) AS count
            FROM resources
            GROUP BY status
            ORDER BY status
        """)

        resource_status = cursor.fetchall()


        # Department-wise bookings
        cursor.execute("""
            SELECT
                d.department_code,
                COUNT(b.booking_id) AS booking_count
            FROM departments d
            LEFT JOIN users u
                ON d.department_id = u.department_id
            LEFT JOIN bookings b
                ON u.user_id = b.user_id
            GROUP BY
                d.department_id,
                d.department_code
            ORDER BY booking_count DESC
        """)

        department_bookings = cursor.fetchall()


        # Recent bookings
        cursor.execute("""
            SELECT
                booking_id,
                user_name,
                resource_name,
                start_time,
                end_time,
                booking_status
            FROM vw_booking_details
            ORDER BY approved_at DESC
            LIMIT 5
        """)

        recent_bookings = cursor.fetchall()


        for booking in recent_bookings:

            for field in (
                "start_time",
                "end_time"
            ):

                if booking[field] is not None:

                    booking[field] = booking[field].isoformat(
                        sep=" "
                    )


        return jsonify({

            "summary": {

                "total_resources":
                    total_resources,

                "available_resources":
                    available_resources,

                "total_bookings":
                    total_bookings,

                "pending_requests":
                    pending_requests,

                "maintenance_records":
                    maintenance_records

            },

            "resource_status":
                resource_status,

            "department_bookings":
                department_bookings,

            "recent_bookings":
                recent_bookings

        })


    except Exception:

        app.logger.exception(
            "Could not retrieve dashboard statistics"
        )

        return jsonify({
            "error":
                "Could not retrieve dashboard statistics"
        }), 500


    finally:

        cursor.close()
        connection.close()
                                                
@app.route("/api/users", methods=["GET"])
def get_users():

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        cursor.execute("""
            SELECT
                u.user_id,
                u.full_name,
                u.email,
                u.role,
                d.department_code
            FROM users u
            JOIN departments d
                ON u.department_id = d.department_id
            WHERE u.status = 'ACTIVE'
            ORDER BY u.full_name
        """)

        users = cursor.fetchall()

        return jsonify(users)

    except Exception:

        app.logger.exception("Could not retrieve users")

        return jsonify({
            "error": "Could not retrieve users"
        }), 500

    finally:

        cursor.close()
        connection.close()
@app.route("/api/login", methods=["POST"])
def login():

    data = request.get_json(silent=True) or {}

    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({
            "error": "Email and password are required"
        }), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:

        cursor.execute("""
            SELECT
                u.user_id,
                u.full_name,
                u.email,
                u.password_hash,
                u.role,
                u.status,
                d.department_code
            FROM users u
            JOIN departments d
                ON u.department_id = d.department_id
            WHERE u.email = %s
        """, (email,))

        user = cursor.fetchone()

        if not user:
            return jsonify({
                "error": "Invalid email or password"
            }), 401

        if user["status"] != "ACTIVE":
            return jsonify({
                "error": "User account is inactive"
            }), 403

        if not check_password_hash(
            user["password_hash"],
            password
        ):
            return jsonify({
                "error": "Invalid email or password"
            }), 401

        return jsonify({
            "message": "Login successful",
            "user": {
                "user_id": user["user_id"],
                "full_name": user["full_name"],
                "email": user["email"],
                "role": user["role"],
                "department_code": user["department_code"]
            }
        }), 200

    except Exception:

        app.logger.exception("Login failed")

        return jsonify({
            "error": "Login failed"
        }), 500

    finally:

        cursor.close()
        connection.close()        
if __name__ == "__main__":
    app.run(debug=True)
