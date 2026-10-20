import requests

request_id = 4
reviewer_id = 1

url = f"http://127.0.0.1:5000/api/booking-requests/{request_id}/reject"

response = requests.post(
    url,
    json={
        "reviewer_id": reviewer_id
    }
)

print("Status:", response.status_code)
print("Response:", response.json())