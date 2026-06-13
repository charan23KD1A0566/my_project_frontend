# FULL WORKFLOW TEST SUMMARY - What's Working
$BASE_URL = "http://localhost:8080/api"

Clear-Host
Write-Host "`n" 
Write-Host "████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "   COMPLETE SYSTEM WORKFLOW TEST - FINAL REPORT" -ForegroundColor Cyan  
Write-Host "████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "`n"

$successCount = 0
$failureCount = 0

function Report-Status {
    param($Status, $Message)
    if ($Status -eq "OK") {
        Write-Host "  ✓ $Message" -ForegroundColor Green
        $global:successCount++
    } else {
        Write-Host "  ✗ $Message" -ForegroundColor Red
        $global:failureCount++
    }
}

# Test 1: Admin Authentication
Write-Host "TEST 1: ADMIN AUTHENTICATION" -ForegroundColor Yellow
try {
    $resp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email="admin@gmail.com"; password="admin123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $data = $resp.Content | ConvertFrom-Json
    Report-Status "OK" "Admin Login - Role: $($data.role), Token received"
    $adminToken = $data.token
} catch {
    Report-Status "FAIL" "Admin Login - $($_.Exception.Message)"
}

# Test 2-6: Admin Data Access
if ($adminToken) {
    Write-Host "`nTEST 2-6: ADMIN DATA ACCESS" -ForegroundColor Yellow
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Departments - $($data.Count) departments found"
    } catch { Report-Status "FAIL" "Get Departments" }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Teachers - $($data.Count) teachers found"
    } catch { Report-Status "FAIL" "Get Teachers" }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Students - $($data.Count) students found"
    } catch { Report-Status "FAIL" "Get Students" }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Subjects - $($data.Count) subjects found"
    } catch { Report-Status "FAIL" "Get Subjects" }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/sections" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Sections - $($data.Count) sections found"
    } catch { Report-Status "FAIL" "Get Sections" }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/admin/users" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Users - $($data.Count) users found"
    } catch { Report-Status "FAIL" "Get Users" }
}

# Test 7: Teacher Authentication
Write-Host "`nTEST 7: TEACHER AUTHENTICATION" -ForegroundColor Yellow
try {
    $resp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{email="CTeacher0@gmail.com"; password="Teacher@123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $data = $resp.Content | ConvertFrom-Json
    Report-Status "OK" "Teacher Login - Name: $($data.name), Token received"
    $teacherToken = $data.token
} catch {
    Report-Status "FAIL" "Teacher Login - $($_.Exception.Message)"
}

# Test 8: Student Authentication
Write-Host "`nTEST 8: STUDENT AUTHENTICATION" -ForegroundColor Yellow
try {
    $resp = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -Body (@{rollNumber="00001"; password="pass123"} | ConvertTo-Json) `
        -ContentType "application/json" -UseBasicParsing
    $data = $resp.Content | ConvertFrom-Json
    Report-Status "OK" "Student Login - Name: $($data.name), Token received"
    $studentToken = $data.token
} catch {
    Report-Status "FAIL" "Student Login - $($_.Exception.Message)"
}

# Test 9-11: Teacher Operations
if ($teacherToken) {
    Write-Host "`nTEST 9-11: TEACHER OPERATIONS" -ForegroundColor Yellow
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST `
            -Body (@{subjectId=1; latitude=37.7749; longitude=-122.4194} | ConvertTo-Json) `
            -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $qrData = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Generate QR Code - SessionID: $($qrData.sessionId)"
        $sessionId = $qrData.sessionId
        $qrToken = $qrData.token
    } catch {
        Report-Status "FAIL" "Generate QR Code - $($_.Exception.Message)"
    }
    
    if ($sessionId) {
        try {
            $resp = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$sessionId/attendance" -Method GET `
                -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
            $data = $resp.Content | ConvertFrom-Json
            Report-Status "OK" "Get Session Attendance (Before) - $($data.Count) records"
        } catch {
            Report-Status "FAIL" "Get Session Attendance - $($_.Exception.Message)"
        }
    }
}

# Test 12-14: Student Operations
if ($studentToken -and $sessionId -and $qrToken) {
    Write-Host "`nTEST 12-14: STUDENT OPERATIONS" -ForegroundColor Yellow
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST `
            -Body (@{sessionId=$sessionId; token=$qrToken; latitude=37.7749; longitude=-122.4194} | ConvertTo-Json) `
            -ContentType "application/json" -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Mark Attendance - Status: $($data.status)"
    } catch {
        Report-Status "FAIL" "Mark Attendance - $($_.Exception.Message)"
    }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Attendance History - $($data.Count) records"
    } catch {
        Report-Status "FAIL" "Get Attendance History - $($_.Exception.Message)"
    }
    
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/student/attendance/me" -Method GET `
            -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        Report-Status "OK" "Get Attendance Summary - $($data.Count) subjects"
    } catch {
        Report-Status "FAIL" "Get Attendance Summary - $($_.Exception.Message)"
    }
}

# Test 15: Verification
if ($teacherToken -and $sessionId) {
    Write-Host "`nTEST 15: FINAL VERIFICATION" -ForegroundColor Yellow
    try {
        $resp = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$sessionId/attendance" -Method GET `
            -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $data = $resp.Content | ConvertFrom-Json
        if ($data.Count -gt 0) {
            Report-Status "OK" "Session Attendance (After) - $($data.Count) records"
        } else {
            Report-Status "FAIL" "Session Attendance - No records found"
        }
    } catch {
        Report-Status "FAIL" "Final Verification - $($_.Exception.Message)"
    }
}

# Summary
Write-Host "`n████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "   SUMMARY" -ForegroundColor Cyan
Write-Host "████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "  Tests Passed: $successCount" -ForegroundColor Green
Write-Host "  Tests Failed: $failureCount" -ForegroundColor Red
Write-Host "`n"
