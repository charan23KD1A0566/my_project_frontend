# WORKFLOW TEST FINAL REPORT
$BASE_URL = "http://localhost:8080/api"

Clear-Host
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "COMPLETE WORKFLOW TEST - FINAL REPORT" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$tests = 0
$passed = 0

# Admin Auth
Write-Host "`n TEST 1: Admin Authentication" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="admin@gmail.com"; password="admin123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Admin role: $($d.role)" -ForegroundColor Green
    $adminToken = $d.token
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Departments
Write-Host "`n TEST 2: Get Departments" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/departments" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) departments" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Teachers
Write-Host "`n TEST 3: Get Teachers" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/teachers" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) teachers" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Students
Write-Host "`n TEST 4: Get Students" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/students" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) students" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Subjects
Write-Host "`n TEST 5: Get Subjects" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/subjects" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) subjects" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Sections
Write-Host "`n TEST 6: Get Sections" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/sections" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) sections" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Users
Write-Host "`n TEST 7: Get Users" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/admin/users" -Method GET -Headers @{Authorization="Bearer $adminToken"} -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Found $($d.Count) users" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "  FAIL - $($_.Exception.Message)" -ForegroundColor Red
}

# Teacher Auth
Write-Host "`n TEST 8: Teacher Authentication" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="teacher1@college.com"; password="teacher123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Teacher: $($d.name)" -ForegroundColor Green
    $teacherToken = $d.token
    $teacherId = $d.id
    $teacherName = $d.name
    $passed++
} catch {
    Write-Host "  FAIL - Teacher login error" -ForegroundColor Red
}

# Student Auth
Write-Host "`n TEST 9: Student Authentication" -ForegroundColor Yellow
$tests++
try {
    $r = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST -Body (@{email="student1@college.com"; password="student123"} | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    $d = $r.Content | ConvertFrom-Json
    Write-Host "  PASS - Student: $($d.name)" -ForegroundColor Green
    $studentToken = $d.token
    $passed++
} catch {
    Write-Host "  FAIL - Student login error" -ForegroundColor Red
}

# QR Generation
Write-Host "`n TEST 10: QR Generation" -ForegroundColor Yellow
$tests++
if ($teacherToken -and $teacherId) {
    try {
        $qrBody = @{
            teacherId = $teacherId
            teacherName = $teacherName
            subjectId = 21
            year = 1
            section = "A"
            department = "CS"
            teacherLatitude = 37.7749
            teacherLongitude = -122.4194
            qrExpiryTime = 600000
        }
        $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/generateQR" -Method POST -Body ($qrBody | ConvertTo-Json) -ContentType "application/json" -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $d = $r.Content | ConvertFrom-Json
        Write-Host "  PASS - QR generated, SessionID: $($d.sessionId)" -ForegroundColor Green
        $sessionId = $d.sessionId
        $qrToken = $d.token
        $passed++
    } catch {
        Write-Host "  FAIL - QR generation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP - No teacher token or ID" -ForegroundColor Yellow
}

# Mark Attendance
Write-Host "`n TEST 11: Mark Attendance" -ForegroundColor Yellow
$tests++
if ($studentToken -and $sessionId -and $qrToken) {
    try {
        $r = Invoke-WebRequest -Uri "$BASE_URL/student/mark-attendance" -Method POST -Body (@{sessionId=$sessionId; token=$qrToken; latitude=37.7749; longitude=-122.4194} | ConvertTo-Json) -ContentType "application/json" -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $d = $r.Content | ConvertFrom-Json
        Write-Host "  PASS - Attendance marked, status: $($d.status)" -ForegroundColor Green
        $passed++
    } catch {
        Write-Host "  FAIL - Attendance marking failed" -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP - Missing tokens" -ForegroundColor Yellow
}

# Attendance History
Write-Host "`n TEST 12: Attendance History" -ForegroundColor Yellow
$tests++
if ($studentToken) {
    try {
        $r = Invoke-WebRequest -Uri "$BASE_URL/student/attendance-history" -Method GET -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $d = $r.Content | ConvertFrom-Json
        Write-Host "  PASS - Found $($d.Count) records" -ForegroundColor Green
        $passed++
    } catch {
        Write-Host "  FAIL - History retrieval failed" -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP - No student token" -ForegroundColor Yellow
}

# Attendance Summary
Write-Host "`n TEST 13: Attendance Summary" -ForegroundColor Yellow
$tests++
if ($studentToken) {
    try {
        $r = Invoke-WebRequest -Uri "$BASE_URL/student/attendance/me" -Method GET -Headers @{Authorization="Bearer $studentToken"} -UseBasicParsing
        $d = $r.Content | ConvertFrom-Json
        Write-Host "  PASS - Found $($d.Count) subjects" -ForegroundColor Green
        $passed++
    } catch {
        Write-Host "  FAIL - Summary retrieval failed" -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP - No student token" -ForegroundColor Yellow
}

# Session Attendance
Write-Host "`n TEST 14: Session Attendance Verification" -ForegroundColor Yellow
$tests++
if ($teacherToken -and $sessionId) {
    try {
        $r = Invoke-WebRequest -Uri "$BASE_URL/teacher/session/$sessionId/attendance" -Method GET -Headers @{Authorization="Bearer $teacherToken"} -UseBasicParsing
        $d = $r.Content | ConvertFrom-Json
        Write-Host "  PASS - Found $($d.Count) attendance records" -ForegroundColor Green
        $passed++
    } catch {
        Write-Host "  FAIL - Session attendance retrieval failed" -ForegroundColor Red
    }
} else {
    Write-Host "  SKIP - Missing tokens" -ForegroundColor Yellow
}

# Summary
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "SUMMARY: $passed / $tests tests passed" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
