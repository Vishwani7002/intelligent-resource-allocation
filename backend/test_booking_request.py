import requests

url = "http://127.0.0.1:5000/api/booking-requests"

data = {
    "user_id": 15,
    "resource_id": 10,
    "requested_start": "2026-10-27 11:00:00",
    "requested_end": "2026-10-27 13:00:00",
    "purpose": "Conflict testing"
}

response = requests.post(url, json=data)

print("Status:", response.status_code)
print("Response:", response.json())