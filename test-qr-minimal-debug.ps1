$teacherEmail = "teacher1@college.com"
$teacherPassword = "teacher123"
$baseUrl = "http://localhost:8080/api"

# Step 1: Authenticate teacher
$authBody = @{
    email = $teacherEmail
    password = $teacherPassword
}
$authResponse = Invoke-WebRequest -Uri "$baseUrl/auth/login" -Method POST -ContentType "application/json" -Body ($authBody | ConvertTo-Json) -UseBasicParsing
$d = $authResponse.Content | ConvertFrom-Json
$teacherToken = $d.token
$teacherId = $d.id
$teacherName = $d.name

Write-Host "Teacher Token: $teacherToken"
Write-Host "Teacher ID: $teacherId (type: $($teacherId.GetType().Name))"
Write-Host "Teacher Name: $teacherName"

# Test minimal request first
$minimalBody = @{
    teacherId = [long]$teacherId
    teacherName = $teacherName
    subjectId = [long]1
    year = 1
    section = "A"
    department = "CS"
    teacherLatitude = 37.7749
    teacherLongitude = -122.4194
    qrExpiryTime = [long]600000
}

Write-Host "`nRequest as JSON:"
$json = $minimalBody | ConvertTo-Json
$json

Write-Host "`nSending request..."
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/teacher/generateQR" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $teacherToken"
            "Content-Type" = "application/json"
        } `
        -Body $json `
        -UseBasicParsing
    Write-Host "Success: $($response.StatusCode)"
    $response.Content
} catch {
    $err = $_
    Write-Host "Error Status: $($err.Exception.Response.StatusCode)"
    Write-Host "Error Message: $($err.Exception.Message)"
    if ($err.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($err.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response Body: '$body'"
    }
}
