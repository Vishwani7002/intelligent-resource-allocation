const currentPage =
    window.location.pathname.split("/").pop();

const publicPages = [
    "login.html"
];

const loggedInUser =
    sessionStorage.getItem("loggedInUser");

if (
    !publicPages.includes(currentPage) &&
    !loggedInUser
) {
    window.location.href = "login.html";
}

if (loggedInUser) {

    const user =
        JSON.parse(loggedInUser);

    if (
        currentPage === "requests.html" &&
        user.role !== "ADMIN" &&
        user.role !== "STAFF"
    ) {
        alert(
            "Access denied. Only ADMIN or STAFF users can manage booking requests."
        );

        window.location.href =
            "index.html";
    }
}
const API_URL = "http://127.0.0.1:5000";


async function loadDashboard() {

    try {

        const response = await fetch(
            `${API_URL}/api/dashboard-stats`
        );

        const data = await response.json();


        if (!response.ok) {

            console.error(
                "Dashboard API error:",
                data.error
            );

            return;

        }


        // =========================
        // SUMMARY CARDS
        // =========================

        document.getElementById(
            "totalResources"
        ).textContent =
            data.summary.total_resources;


        document.getElementById(
            "availableResources"
        ).textContent =
            data.summary.available_resources;


        document.getElementById(
            "totalBookings"
        ).textContent =
            data.summary.total_bookings;


        document.getElementById(
            "pendingRequests"
        ).textContent =
            data.summary.pending_requests;


        document.getElementById(
            "maintenanceRecords"
        ).textContent =
            data.summary.maintenance_records;



        // =========================
        // RESOURCE STATUS
        // =========================

        const resourceStatus =
            document.getElementById(
                "resourceStatus"
            );


        resourceStatus.innerHTML = "";


        data.resource_status.forEach(item => {

            resourceStatus.innerHTML += `

                <div class="analytics-item">

                    <strong>
                        ${item.status}
                    </strong>

                    <span>
                        ${item.count}
                    </span>

                </div>

            `;

        });



        // =========================
        // DEPARTMENT BOOKINGS
        // =========================

        const departmentBookings =
            document.getElementById(
                "departmentBookings"
            );


        departmentBookings.innerHTML = "";


        data.department_bookings.forEach(item => {

            departmentBookings.innerHTML += `

                <div class="analytics-item">

                    <strong>
                        ${item.department_code}
                    </strong>

                    <span>
                        ${item.booking_count}
                    </span>

                </div>

            `;

        });



        // =========================
        // RECENT BOOKINGS
        // =========================

        const recentBookings =
            document.getElementById(
                "recentBookings"
            );


        recentBookings.innerHTML = "";


        data.recent_bookings.forEach(
            booking => {

                recentBookings.innerHTML += `

                    <tr>

                        <td>
                            ${booking.booking_id}
                        </td>

                        <td>
                            ${booking.user_name}
                        </td>

                        <td>
                            ${booking.resource_name}
                        </td>

                        <td>
                            ${booking.start_time}
                        </td>

                        <td>
                            ${booking.end_time}
                        </td>

                        <td>
                            ${booking.booking_status}
                        </td>

                    </tr>

                `;

            }
        );


    } catch (error) {

        console.error(
            "Could not load dashboard:",
            error
        );

    }

}
async function loadUsers() {

    try {

        const response = await fetch(
            `${API_URL}/api/users`
        );

        const users = await response.json();

        if (!response.ok) {
            console.error(
                "Could not load users:",
                users.error
            );
            return;
        }

        const userSelect =
            document.getElementById("userId");

        if (!userSelect) {
            return;
        }

        userSelect.innerHTML =
            `<option value="">Select User</option>`;

        users.forEach(user => {

            userSelect.innerHTML += `
                <option value="${user.user_id}">
                    ${user.full_name}
                    (${user.department_code} - ${user.role})
                </option>
            `;

        });

    } catch (error) {

        console.error(
            "Could not load users:",
            error
        );

    }
}
async function loadReviewers() {

    try {

        const response = await fetch(
            `${API_URL}/api/users`
        );

        const users = await response.json();

        if (!response.ok) {
            console.error(
                "Could not load reviewers:",
                users.error
            );
            return;
        }

        const reviewerSelect =
            document.getElementById("reviewerId");

        if (!reviewerSelect) {
            return;
        }

        reviewerSelect.innerHTML =
            `<option value="">Select Reviewer</option>`;

        users
            .filter(user =>
                user.role === "ADMIN" ||
                user.role === "STAFF"
            )
            .forEach(user => {

                reviewerSelect.innerHTML += `
                    <option value="${user.user_id}">
                        ${user.full_name}
                        (${user.department_code} - ${user.role})
                    </option>
                `;

            });

    } catch (error) {

        console.error(
            "Could not load reviewers:",
            error
        );

    }
}
async function loadResourceOptions() {

    try {

        const response = await fetch(
            `${API_URL}/api/resources`
        );

        const resources = await response.json();

        if (!response.ok) {
            console.error(
                "Could not load resources:",
                resources.error
            );
            return;
        }

        const resourceSelect =
            document.getElementById("resourceId");

        if (!resourceSelect) {
            return;
        }

        resourceSelect.innerHTML =
            `<option value="">Select Resource</option>`;

        resources.forEach(resource => {

            resourceSelect.innerHTML += `
                <option value="${resource.resource_id}">
                    ${resource.resource_name}
                    (${resource.resource_type} - Capacity: ${resource.capacity})
                </option>
            `;

        });

    } catch (error) {

        console.error(
            "Could not load resources:",
            error
        );

    }
}
const bookingRequestForm =
    document.getElementById("bookingRequestForm");

if (bookingRequestForm) {

    bookingRequestForm.addEventListener(
        "submit",
        async function (event) {

            event.preventDefault();

            const userId =
                document.getElementById("userId").value;

            const resourceId =
                document.getElementById("resourceId").value;

            const startInput =
                document.getElementById("requestedStart").value;

            const endInput =
                document.getElementById("requestedEnd").value;

            const purpose =
                document.getElementById("purpose").value;

            // Convert datetime-local format
            // 2026-10-27T10:00
            // into MySQL DATETIME format
            // 2026-10-27 10:00:00

            const requestedStart =
                startInput.replace("T", " ") + ":00";

            const requestedEnd =
                endInput.replace("T", " ") + ":00";

            try {

                const response = await fetch(
                    `${API_URL}/api/booking-requests`,
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/json"
                        },

                        body: JSON.stringify({
                            user_id: Number(userId),
                            resource_id: Number(resourceId),
                            requested_start: requestedStart,
                            requested_end: requestedEnd,
                            purpose: purpose
                        })
                    }
                );

                const result =
                    await response.json();

                if (!response.ok) {

                    alert(
                        result.error ||
                        "Could not create booking request."
                    );

                    return;
                }

                alert(
                    "Booking request created successfully!"
                );

                bookingRequestForm.reset();

                if (
                    window.location.pathname.endsWith(
                        "requests.html"
                    )
                ) {
                    loadRequests();
                }

            } catch (error) {

                console.error(
                    "Could not create booking request:",
                    error
                );

                alert(
                    "Could not connect to the server."
                );

            }

        }
    );

}

loadDashboard();
loadUsers();
loadResourceOptions();
loadReviewers();
async function loadResources() {

    try {

        const response = await fetch(
            `${API_URL}/api/resources`
        );

        const resources = await response.json();

        const table =
            document.getElementById("resourcesTable");

        table.innerHTML = "";


        resources.forEach(resource => {

            const row =
                document.createElement("tr");

            row.innerHTML = `

                <td>${resource.resource_id}</td>

                <td>
                    ${resource.resource_name}
                </td>

                <td>
                    ${resource.resource_type}
                </td>

                <td>
                    ${resource.building_name}
                    -
                    ${resource.room_number}
                </td>

                <td>
                    ${resource.capacity}
                </td>

                <td>
                    ${resource.status}
                </td>

                <td>
                    ${resource.description || ""}
                </td>

            `;

            table.appendChild(row);

        });

    }

    catch (error) {

        console.error(
            "Could not load resources:",
            error
        );

        document.getElementById(
            "resourcesTable"
        ).innerHTML = `
            <tr>
                <td colspan="7">
                    Could not load resources.
                </td>
            </tr>
        `;

    }

}
if (
    window.location.pathname.endsWith("resources.html")
) {
    loadResources();
}
async function loadBookings() {

    try {

        const response = await fetch(
            `${API_URL}/api/bookings`
        );

        const bookings = await response.json();

        const table =
            document.getElementById("bookingsTable");

        table.innerHTML = "";


        bookings.forEach(booking => {

            const row =
                document.createElement("tr");


            row.innerHTML = `

                <td>
                    ${booking.booking_id}
                </td>

                <td>
                    ${booking.user_name}
                </td>

                <td>
                    ${booking.department_name}
                </td>

                <td>
                    ${booking.resource_name}
                </td>

                <td>
                    ${booking.start_time}
                </td>

                <td>
                    ${booking.end_time}
                </td>

                <td>
                    ${booking.booking_status}
                </td>

            `;


            table.appendChild(row);

        });


    } catch (error) {

        console.error(
            "Could not load bookings:",
            error
        );


        document.getElementById(
            "bookingsTable"
        ).innerHTML = `

            <tr>

                <td colspan="7">
                    Could not load bookings.
                </td>

            </tr>

        `;

    }

}


if (
    window.location.pathname.endsWith("bookings.html")
) {

    loadBookings();

}
async function loadRequests() {

    try {

        const response = await fetch(
            `${API_URL}/api/booking-requests`
        );

        const requests = await response.json();

        const table =
            document.getElementById("requestsTable");

        table.innerHTML = "";


        requests.forEach(request => {

            const row =
                document.createElement("tr");


            let actionButtons = "";


            if (request.status === "PENDING") {

                actionButtons = `

                    <button
                        onclick="approveRequest(${request.request_id})">

                        Approve

                    </button>


                    <button
                        onclick="rejectRequest(${request.request_id})">

                        Reject

                    </button>

                `;

            } else {

                actionButtons = "No action";

            }


            row.innerHTML = `

                <td>
                    ${request.request_id}
                </td>

                <td>
                    ${request.requester}
                </td>

                <td>
                    ${request.department_name}
                </td>

                <td>
                    ${request.resource_name}
                </td>

                <td>
                    ${request.requested_start}
                </td>

                <td>
                    ${request.requested_end}
                </td>

                <td>
                    ${request.purpose}
                </td>

                <td>
                    ${request.status}
                </td>

                <td>
                    ${actionButtons}
                </td>

            `;


            table.appendChild(row);

        });


    } catch (error) {

        console.error(
            "Could not load booking requests:",
            error
        );


        document.getElementById(
            "requestsTable"
        ).innerHTML = `

            <tr>

                <td colspan="9">

                    Could not load booking requests.

                </td>

            </tr>

        `;

    }

}



async function approveRequest(requestId) {

    const confirmed =
        confirm(
            "Are you sure you want to approve this booking request?"
        );


    if (!confirmed) {

        return;

    }


    try {

        const response = await fetch(

            `${API_URL}/api/booking-requests/${requestId}/approve`,

            {

                method: "POST",

                headers: {

                    "Content-Type": "application/json"

                },

                body: JSON.stringify({

                   reviewer_id: Number(
                        document.getElementById("reviewerId").value
)

                })

            }

        );


        const result =
            await response.json();


        if (response.ok) {

            alert(
                "Booking request approved successfully!"
            );

            loadRequests();

        } else {

            alert(
                "Approval failed: " +
                result.error
            );

        }


    } catch (error) {

        console.error(
            "Approval error:",
            error
        );

        alert(
            "Could not connect to the backend."
        );

    }

}



async function rejectRequest(requestId) {

    const confirmed =
        confirm(
            "Are you sure you want to reject this booking request?"
        );


    if (!confirmed) {

        return;

    }


    try {

        const response = await fetch(

            `${API_URL}/api/booking-requests/${requestId}/reject`,

            {

                method: "POST",

                headers: {

                    "Content-Type": "application/json"

                },

                body: JSON.stringify({

                    reviewer_id: 1

                })

            }

        );


        const result =
            await response.json();


        if (response.ok) {

            alert(
                "Booking request rejected successfully!"
            );

            loadRequests();

        } else {

            alert(
                "Rejection failed: " +
                result.error
            );

        }


    } catch (error) {

        console.error(
            "Rejection error:",
            error
        );

        alert(
            "Could not connect to the backend."
        );

    }

}



if (
    window.location.pathname.endsWith("requests.html")
) {

    loadRequests();

}
async function loadMaintenance() {

    try {

        const response = await fetch(
            `${API_URL}/api/maintenance`
        );

        const maintenance =
            await response.json();

        const table =
            document.getElementById(
                "maintenanceTable"
            );

        table.innerHTML = "";


        maintenance.forEach(record => {

            const row =
                document.createElement("tr");


            row.innerHTML = `

                <td>
                    ${record.maintenance_id}
                </td>

                <td>
                    ${record.resource_name}
                </td>

                <td>
                    ${record.reported_by}
                </td>

                <td>
                    ${record.start_time}
                </td>

                <td>
                    ${record.end_time}
                </td>

                <td>
                    ${record.maintenance_type}
                </td>

                <td>
                    ${record.description || ""}
                </td>

                <td>
                    ${record.status}
                </td>

            `;


            table.appendChild(row);

        });


    } catch (error) {

        console.error(
            "Could not load maintenance records:",
            error
        );


        document.getElementById(
            "maintenanceTable"
        ).innerHTML = `

            <tr>

                <td colspan="8">

                    Could not load maintenance records.

                </td>

            </tr>

        `;

    }

}



if (
    window.location.pathname.endsWith(
        "maintenance.html"
    )
) {

    loadMaintenance();

}
const bookingForm =
    document.getElementById("bookingRequestForm");

if (bookingForm) {

    bookingForm.addEventListener(
        "submit",
        async function(event) {

            event.preventDefault();


            const data = {

                user_id:
                    Number(
                        document.getElementById(
                            "userId"
                        ).value
                    ),

                resource_id:
                    Number(
                        document.getElementById(
                            "resourceId"
                        ).value
                    ),

                requested_start:
                    document.getElementById(
                        "startTime"
                    ).value.replace("T", " ") + ":00",

                requested_end:
                    document.getElementById(
                        "endTime"
                    ).value.replace("T", " ") + ":00",

                purpose:
                    document.getElementById(
                        "purpose"
                    ).value

            };


            try {

                const response =
                    await fetch(
                        `${API_URL}/api/booking-requests`,
                        {
                            method: "POST",

                            headers: {
                                "Content-Type":
                                    "application/json"
                            },

                            body:
                                JSON.stringify(data)
                        }
                    );


                const result =
                    await response.json();


                if (response.ok) {

                    alert(
                        "Booking request submitted successfully!"
                    );


                    bookingForm.reset();

                    loadRequests();

                } else {

                    alert(
                        "Request failed: " +
                        result.error
                    );

                }


            } catch (error) {

                console.error(
                    "Booking request error:",
                    error
                );

                alert(
                    "Could not connect to the backend."
                );

            }

        }
    );

}
const availabilityForm =
    document.getElementById("availabilityForm");


if (availabilityForm) {

    availabilityForm.addEventListener(
        "submit",
        async function(event) {

            event.preventDefault();


            const startTime =
                document.getElementById(
                    "availabilityStart"
                ).value;


            const endTime =
                document.getElementById(
                    "availabilityEnd"
                ).value;


            if (startTime >= endTime) {

                alert(
                    "End time must be after start time."
                );

                return;

            }


            const formattedStart =
                startTime.replace("T", " ") + ":00";


            const formattedEnd =
                endTime.replace("T", " ") + ":00";


            try {

                const response = await fetch(

                    `${API_URL}/api/available-resources` +
                    `?start_time=${encodeURIComponent(formattedStart)}` +
                    `&end_time=${encodeURIComponent(formattedEnd)}`

                );


                const resources =
                    await response.json();


                const table =
                    document.getElementById(
                        "availabilityTable"
                    );


                table.innerHTML = "";


                if (!response.ok) {

                    table.innerHTML = `

                        <tr>

                            <td colspan="6">

                                ${resources.error}

                            </td>

                        </tr>

                    `;

                    return;

                }


                if (resources.length === 0) {

                    table.innerHTML = `

                        <tr>

                            <td colspan="6">

                                No resources are available
                                during this time.

                            </td>

                        </tr>

                    `;

                    return;

                }


                resources.forEach(resource => {

                    const row =
                        document.createElement("tr");


                    row.innerHTML = `

                        <td>
                            ${resource.resource_id}
                        </td>

                        <td>
                            ${resource.resource_name}
                        </td>

                        <td>
                            ${resource.resource_type || resource.type_name || ""}
                        </td>

                        <td>
                            ${resource.building_name}
                            -
                            ${resource.room_number}
                        </td>

                        <td>
                            ${resource.capacity}
                        </td>

                        <td>
                            ${resource.status}
                        </td>

                    `;


                    table.appendChild(row);

                });


            } catch (error) {

                console.error(
                    "Availability search error:",
                    error
                );


                document.getElementById(
                    "availabilityTable"
                ).innerHTML = `

                    <tr>

                        <td colspan="6">

                            Could not connect to the backend.

                        </td>

                    </tr>

                `;

            }

        }
    );

}
const loginForm = document.getElementById("loginForm");

if (loginForm) {

    loginForm.addEventListener(
        "submit",
        async function (event) {

            event.preventDefault();

            const email =
                document.getElementById("email").value.trim();

            const password =
                document.getElementById("password").value;

            const loginMessage =
                document.getElementById("loginMessage");

            loginMessage.textContent = "Logging in...";

            try {

                const response = await fetch(
                    `${API_URL}/api/login`,
                    {
                        method: "POST",

                        headers: {
                            "Content-Type": "application/json"
                        },

                        body: JSON.stringify({
                            email: email,
                            password: password
                        })
                    }
                );

                const result =
                    await response.json();

                if (!response.ok) {

                    loginMessage.textContent =
                        result.error ||
                        "Login failed.";

                    return;
                }

                sessionStorage.setItem(
                    "loggedInUser",
                    JSON.stringify(result.user)
                );

                loginMessage.textContent =
                    "Login successful!";

                window.location.href =
                    "index.html";

            } catch (error) {

                console.error(
                    "Login error:",
                    error
                );

                loginMessage.textContent =
                    "Could not connect to the server.";
            }
        }
    );
}
function displayLoggedInUser() {

    const userInfo =
        document.getElementById("userInfo");

    if (!userInfo) {
        return;
    }

    const storedUser =
        sessionStorage.getItem("loggedInUser");

    if (!storedUser) {
        userInfo.textContent =
            "User information unavailable.";
        return;
    }

    const user =
        JSON.parse(storedUser);

    userInfo.innerHTML = `
    <div class="user-avatar">
        ${user.full_name
            .split(" ")
            .map(name => name[0])
            .join("")
            .substring(0, 2)
            .toUpperCase()}
    </div>

    <div class="user-details">

        <strong>
            ${user.full_name}
        </strong>

        <span>
            ${user.role}
        </span>

    </div>

    <span class="user-chevron">
        ▾
    </span>
`;
        const requestsNav =
        document.getElementById("requestsNav");

    if (
        requestsNav &&
        user.role !== "ADMIN" &&
        user.role !== "STAFF"
    ) {
        requestsNav.style.display = "none";
    }
}

displayLoggedInUser();
const logoutButton =
    document.getElementById("logoutButton");

if (logoutButton) {

    logoutButton.addEventListener(
        "click",
        function () {

            sessionStorage.removeItem(
                "loggedInUser"
            );

            window.location.href =
                "login.html";
        }
    );
}