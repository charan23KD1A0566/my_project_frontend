$API = "http://localhost:8080/api"

# Teacher login
$teacherLogin = @{
    email = "teacher1@college.com"
    password = "teacher123"
} | ConvertTo-Json

Write-Host "Logging in as teacher..."
$teacherResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $teacherLogin
$teacherToken = $teacherResp.token
$teacherHeaders = @{Authorization = "Bearer $teacherToken"}

# Call generateQR with full error capture
$qrReq = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 21
    teacherLatitude = 28.5355
    teacherLongitude = 77.391
} | ConvertTo-Json

Write-Host "QR Request Body:"
Write-Host $qrReq

Write-Host "`nCalling generateQR endpoint with TEACHER auth..."
try {
    $resp = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST -ContentType "application/json" -Body $qrReq -Headers $teacherHeaders -ErrorAction Stop
    Write-Host "SUCCESS! Response:"
    $resp | ConvertTo-Json -Depth 5
} catch {
    Write-Host "ERROR CAUGHT!"
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
    Write-Host "Exception Type: $($_.Exception.GetType().FullName)"
    Write-Host "Message: $($_.Exception.Message)"
    
    # Try to read error body
    try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Host "Response Body:"
        Write-Host $body
    } catch {
        Write-Host "Could not read response body"
    }
}
