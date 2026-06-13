# QUICK WORKFLOW TEST - Complete System Lifecycle
$BASE_URL = "http://localhost:8080/api"
$ADMIN_EMAIL = "admin@gmail.com"
$ADMIN_PASS = "admin123"
$TEACHER_EMAIL = "CTeacher0@gmail.com"
$TEACHER_PASS = "Teacher@123"
$STUDENT_ROLL = "00001"
$STUDENT_PASS = "pass123"

function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Endpoint,
        [hashtable]$Body,
        [string]$Token,
        [string]$Description
    )
    
    try {
        $url = "$BASE_URL$Endpoint"
        $headers = @{}
        if ($Token) { $headers["Authorization"] = "Bearer $Token" }
        
        if ($Method -eq "GET") {
            $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $headers -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $Method -Body ($Body | ConvertTo-Json) `
                -ContentType "application/json" -Headers $headers -UseBasicParsing
        }
        
        $data = $response.Content | ConvertFrom-Json
        Write-Host "✅ $Description" -ForegroundColor Green
        return $data
    } catch {
        Write-Host "❌ $Description - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Clear-Host
Write-Host "==========================================`n" -ForegroundColor Cyan
Write-Host "   FULL WORKFLOW TEST - Complete System`n" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# PHASE 1: AUTHENTICATION
Write-Host "PHASE 1: AUTHENTICATION" -ForegroundColor Yellow
$adminLogin = Test-Endpoint "POST" "/auth/login" @{email=$ADMIN_EMAIL; password=$ADMIN_PASS} $null "Admin Login"
$adminToken = $adminLogin.token

$teacherLogin = Test-Endpoint "POST" "/auth/login" @{email=$TEACHER_EMAIL; password=$TEACHER_PASS} $null "Teacher Login"
$teacherToken = $teacherLogin.token

$studentLogin = Test-Endpoint "POST" "/auth/login" @{rollNumber=$STUDENT_ROLL; password=$STUDENT_PASS} $null "Student Login"
$studentToken = $studentLogin.token

# PHASE 2: ADMIN VERIFICATION
Write-Host "`nPHASE 2: ADMIN VERIFICATION" -ForegroundColor Yellow
Test-Endpoint "GET" "/admin/departments" $null $adminToken "Get Departments" | Out-Null
Test-Endpoint "GET" "/admin/teachers" $null $adminToken "Get Teachers" | Out-Null
Test-Endpoint "GET" "/admin/students" $null $adminToken "Get Students" | Out-Null
Test-Endpoint "GET" "/admin/subjects" $null $adminToken "Get Subjects" | Out-Null

# PHASE 3: TEACHER OPERATIONS
Write-Host "`nPHASE 3: TEACHER OPERATIONS" -ForegroundColor Yellow
$qrResponse = Test-Endpoint "POST" "/teacher/generateQR" @{subjectId=1; latitude=37.7749; longitude=-122.4194} $teacherToken "Generate QR"

if ($qrResponse -and $qrResponse.sessionId) {
    $sessionId = $qrResponse.sessionId
    Write-Host "   Session ID: $sessionId" -ForegroundColor Gray
    
    # Get session attendance before marking
    Test-Endpoint "GET" "/teacher/session/$sessionId/attendance" $null $teacherToken "Get Session Attendance" | Out-Null
}

# PHASE 4: STUDENT OPERATIONS
Write-Host "`nPHASE 4: STUDENT OPERATIONS" -ForegroundColor Yellow
if ($qrResponse -and $qrResponse.token) {
    $attendanceBody = @{
        sessionId = $qrResponse.sessionId
        token = $qrResponse.token
        latitude = 37.7749
        longitude = -122.4194
    }
    Test-Endpoint "POST" "/student/mark-attendance" $attendanceBody $studentToken "Mark Attendance" | Out-Null
    Test-Endpoint "GET" "/student/attendance-history" $null $studentToken "Get Attendance History" | Out-Null
    Test-Endpoint "GET" "/student/attendance/me" $null $studentToken "Get Attendance Summary" | Out-Null
}

# PHASE 5: VERIFICATION
Write-Host "`nPHASE 5: VERIFICATION" -ForegroundColor Yellow
if ($qrResponse -and $qrResponse.sessionId) {
    $finalCheck = Test-Endpoint "GET" "/teacher/session/$sessionId/attendance" $null $teacherToken "Final Attendance Check"
    if ($finalCheck -and $finalCheck.length -gt 0) {
        Write-Host "   Total students in session: $($finalCheck.length)" -ForegroundColor Gray
    }
}

Write-Host "`n==========================================`n" -ForegroundColor Cyan
Write-Host "   WORKFLOW TEST COMPLETE`n" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan
