$API = "http://localhost:8080/api"

Write-Host "=== ADMIN OPERATIONS ==="

# Admin login
$adminLogin = @{
    email = "admin@gmail.com"
    password = "admin123"
} | ConvertTo-Json

$adminResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $adminLogin
$adminToken = $adminResp.token
Write-Host "Admin logged in"

# Get all teachers (admin endpoint)
$adminHeaders = @{Authorization = "Bearer $adminToken"}
try {
    $teachers = Invoke-RestMethod -Uri "$API/admin/teachers" -Method GET -Headers $adminHeaders
    Write-Host "Teachers count: $($teachers.Count)"
    if ($teachers.Count -gt 0) {
        Write-Host "First teacher:"
        $teachers[0] | ConvertTo-Json -Depth 2
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "`n=== SUBJECT OPERATIONS ==="

# Get all subjects
try {
    $subjects = Invoke-RestMethod -Uri "$API/admin/subjects" -Method GET -Headers $adminHeaders
    Write-Host "Subjects count: $($subjects.Count)"
    if ($subjects.Count -gt 0) {
        Write-Host "First 3 subjects:"
        $subjects | Select-Object -First 3 | ForEach-Object {
            Write-Host "  ID: $($_.id), Name: $($_.name), Section: $($_.section), Year: $($_.year)"
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "`n=== TEACHER LOGIN AND QR TEST ==="

# Teacher login
$teacherLogin = @{
    email = "teacher1@college.com"
    password = "teacher123"
} | ConvertTo-Json

$teacherResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST -ContentType "application/json" -Body $teacherLogin
$teacherToken = $teacherResp.token
Write-Host "Teacher logged in"

# Try to generate QR with teacher 1, subject 1
$teacherHeaders = @{Authorization = "Bearer $teacherToken"}

# First, let's find which teachers and subjects actually exist
Write-Host "`n=== Searching for valid test data ==="
if ($teachers.Count -gt 0 -and $subjects.Count -gt 0) {
    $teacher1 = $teachers | Select-Object -First 1
    $subject1 = $subjects | Where-Object { $_.section -ne $null } | Select-Object -First 1
    
    if ($teacher1 -and $subject1) {
        Write-Host "Found test data: Teacher ID=$($teacher1.id), Subject ID=$($subject1.id)"
        
        $qrBody = @{
            teacherId = $teacher1.id
            teacherName = $teacher1.name
            subjectId = $subject1.id
            teacherLatitude = 28.5355
            teacherLongitude = 77.3910
        } | ConvertTo-Json
        
        Write-Host "QR Body: $qrBody"
        
        try {
            $qrResp = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST -ContentType "application/json" -Body $qrBody -Headers $teacherHeaders
            Write-Host "QR Generated Successfully!"
            $qrResp | ConvertTo-Json -Depth 2
        } catch {
            Write-Host "QR Generation Error: $($_.Exception.Message)"
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $body = $reader.ReadToEnd()
                Write-Host "Response: $body"
            }
        }
    } else {
        Write-Host "No valid test data found"
        Write-Host "Teachers with valid data: $(@($teachers | Where-Object { $_.id }).Count)"
        Write-Host "Subjects with section: $(@($subjects | Where-Object { $_.section }).Count)"
    }
}
