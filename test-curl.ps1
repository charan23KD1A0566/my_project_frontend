$baseUrl = "http://localhost:8080/api"

# Test with curl for raw response
Write-Host "Testing with verbose curl output..."
curl.exe -v -X POST "$baseUrl/teacher/generateQR" `
  -H "Content-Type: application/json" `
  -d '{\"teacherId\":1}'
