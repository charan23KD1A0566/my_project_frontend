# QR Attendance System - Complete Workflow Test
# This script tests the entire QR attendance flow

$API_BASE = "https://my-project-80ir.onrender.com/api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QR ATTENDANCE SYSTEM - WORKFLOW TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# STEP 1: Teacher Login
# ============================================
Write-Host "[1/6] TEACHER LOGIN" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

$teacherLoginBody = @{
    email = "teacher1@college.com"
    password = "teacher123"
    role = "teacher"
} | ConvertTo-Json

try {
    $teacherResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $teacherLoginBody
    
    $teacherToken = $teacherResponse.token
    $teacherId = $teacherResponse.id
    
    Write-Host "✅ Teacher Login Successful" -ForegroundColor Green
    Write-Host "   Email: $($teacherResponse.email)"
    Write-Host "   Name: $($teacherResponse.name)"
    Write-Host "   Token: $($teacherToken.Substring(0,30))..."
    Write-Host ""
} catch {
    Write-Host "❌ Teacher Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================
# STEP 2: Generate QR Code
# ============================================
Write-Host "[2/6] GENERATE QR CODE" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

$qrBody = @{
    teacherId = 1
    teacherName = "Dr. CTeacher0"
    subjectId = 1
    qrExpiryTime = 5
    teacherLatitude = 40.7128
    teacherLongitude = -74.0060
} | ConvertTo-Json

try {
    $qrResponse = Invoke-RestMethod -Uri "$API_BASE/teacher/generateQR" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $teacherToken"
        } `
        -Body $qrBody
    
    $sessionId = $qrResponse.sessionId
    $qrToken = $qrResponse.token
    $expiryTime = $qrResponse.expiryTime
    
    Write-Host "✅ QR Code Generated Successfully" -ForegroundColor Green
    Write-Host "   Session ID: $sessionId"
    Write-Host "   Token: $qrToken"
    Write-Host "   Expiry Time: $expiryTime"
    Write-Host "   QR Image: $(if($qrResponse.qrImageBase64) {"Base64 encoded ($(($qrResponse.qrImageBase64.Length)/1000)KB)"} else {"NOT FOUND"})"
    Write-Host ""
} catch {
    Write-Host "❌ QR Generation Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================
# STEP 3: Student Login
# ============================================
Write-Host "[3/6] STUDENT LOGIN" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

$studentLoginBody = @{
    email = "student1@college.com"
    password = "student123"
    role = "student"
} | ConvertTo-Json

try {
    $studentResponse = Invoke-RestMethod -Uri "$API_BASE/auth/login" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $studentLoginBody
    
    $studentToken = $studentResponse.token
    $studentId = $studentResponse.id
    
    Write-Host "✅ Student Login Successful" -ForegroundColor Green
    Write-Host "   Email: $($studentResponse.email)"
    Write-Host "   Name: $($studentResponse.name)"
    Write-Host "   Token: $($studentToken.Substring(0,30))..."
    Write-Host ""
} catch {
    Write-Host "❌ Student Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================
# STEP 4: Mark Attendance
# ============================================
Write-Host "[4/6] MARK ATTENDANCE" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

$attendanceBody = @{
    sessionId = $sessionId
    token = $qrToken
    studentLatitude = 40.7128
    studentLongitude = -74.0060
} | ConvertTo-Json

try {
    $attendanceResponse = Invoke-RestMethod -Uri "$API_BASE/student/mark-attendance" `
        -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $studentToken"
        } `
        -Body $attendanceBody
    
    Write-Host "✅ Attendance Marked Successfully" -ForegroundColor Green
    Write-Host "   Response: $attendanceResponse"
    Write-Host ""
} catch {
    Write-Host "❌ Mark Attendance Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Full Error: $($_.Exception)" -ForegroundColor Red
    Write-Host ""
    # Continue to next test even if this fails
}

# ============================================
# STEP 5: Get Student Attendance History
# ============================================
Write-Host "[5/6] GET ATTENDANCE HISTORY" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

try {
    $historyResponse = Invoke-RestMethod -Uri "$API_BASE/student/attendance-history" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $studentToken"
        }
    
    if ($historyResponse -and $historyResponse.Count -gt 0) {
        Write-Host "✅ Attendance History Retrieved" -ForegroundColor Green
        Write-Host "   Total Records: $($historyResponse.Count)"
        
        if ($historyResponse -is [array]) {
            $latest = $historyResponse[0]
        } else {
            $latest = $historyResponse
        }
        
        Write-Host "   Latest Record:"
        Write-Host "     - Subject: $($latest.subjectName)"
        Write-Host "     - Date: $($latest.date)"
        Write-Host "     - Time: $($latest.time)"
        Write-Host "     - Status: $($latest.status)"
    } else {
        Write-Host "⚠️  No attendance records found" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "⚠️  Could not retrieve attendance history: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================
# STEP 6: Get All Students (Verification)
# ============================================
Write-Host "[6/6] VERIFY DATABASE - GET ALL STUDENTS" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray

try {
    $studentsResponse = Invoke-RestMethod -Uri "$API_BASE/students" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $studentToken"
        }
    
    $totalStudents = $studentsResponse.Count
    Write-Host "✅ Students Retrieved from Database" -ForegroundColor Green
    Write-Host "   Total Students: $totalStudents"
    
    if ($studentsResponse -and ($studentsResponse -is [array])) {
        $firstStudent = $studentsResponse[0]
        Write-Host "   First Student Sample:"
        Write-Host "     - Name: $($firstStudent.name)"
        Write-Host "     - Email: $($firstStudent.email)"
        Write-Host "     - Roll: $($firstStudent.rollNumber)"
        Write-Host "     - Section: $($firstStudent.section.sectionName)"
    }
    Write-Host ""
} catch {
    Write-Host "⚠️  Could not verify student count: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================
# SUMMARY
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Teacher Login: SUCCESS"
Write-Host "✅ QR Generation: SUCCESS (Session: $sessionId)"
Write-Host "✅ Student Login: SUCCESS"
Write-Host "✅ Mark Attendance: TESTED (Check status above)"
Write-Host "✅ Attendance History: TESTED (Check status above)"
Write-Host "✅ Database Verification: TESTED (Check status above)"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "WORKFLOW TEST COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
