import requests

url = "http://127.0.0.1:5000/api/booking-requests/12/reject"

data = {
    "reviewer_id": 8
}

response = requests.post(url, json=data)

print("Status:", response.status_code)
print("Response:", response.json())