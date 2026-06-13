# COMPREHENSIVE WORKFLOW TEST - Complete System Validation
$BASE_URL = "http://localhost:8080/api"

Clear-Host
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "   COMPLETE SYSTEM WORKFLOW TEST"  -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

function ApiCall {
    param($Method, $Endpoint, $Body, $Token, $Description)
    try {
        $url = "$BASE_URL$Endpoint"
        $headers = @{ }
        if ($Token) { $headers["Authorization"] = "Bearer $Token" }
        
        $params = @{
            Uri = $url
            Method = $Method
            UseBasicParsing = $true
        }
        
        if ($Token) { $params["Headers"] = $headers }
        if ($Body) { $params["Body"] = ($Body | ConvertTo-Json); $params["ContentType"] = "application/json" }
        
        $resp = Invoke-WebRequest @params
        $data = $resp.Content | ConvertFrom-Json
        Write-Host "✓ $Description" -ForegroundColor Green
        return $data
    } catch {
        Write-Host "✗ $Description - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception -is [System.Net.WebException]) {
            try {
                $errResp = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($errResp)
                $errBody = $reader.ReadToEnd()
                Write-Host "   Response: $errBody" -ForegroundColor Yellow
            } catch { }
        }
        return $null
    }
}

# ========== PHASE 1: AUTHENTICATION ==========
Write-Host "`n>>> PHASE 1: AUTHENTICATION" -ForegroundColor Yellow

# Admin
$adminToken = $null
$adminData = ApiCall "POST" "/auth/login" @{email="admin@gmail.com"; password="admin123"} $null "Admin Login"
if ($adminData -and $adminData.token) {
    $adminToken = $adminData.token
    Write-Host "   Admin Role: $($adminData.role)" -ForegroundColor Gray
}

# Teacher
$teacherToken = $null
$teacherData = ApiCall "POST" "/auth/login" @{email="CTeacher0@gmail.com"; password="Teacher@123"} $null "Teacher Login"
if ($teacherData -and $teacherData.token) {
    $teacherToken = $teacherData.token
    Write-Host "   Teacher: $($teacherData.name), Role: $($teacherData.role)" -ForegroundColor Gray
}

# Student
$studentToken = $null
$studentData = ApiCall "POST" "/auth/login" @{rollNumber="00001"; password="pass123"} $null "Student Login"
if ($studentData -and $studentData.token) {
    $studentToken = $studentData.token
    Write-Host "   Student: $($studentData.name), Role: $($studentData.role)" -ForegroundColor Gray
}

# ========== PHASE 2: ADMIN DATA VERIFICATION ==========
Write-Host "`n>>> PHASE 2: ADMIN DATA VERIFICATION" -ForegroundColor Yellow

ApiCall "GET" "/admin/departments" $null $adminToken "Departments" | ForEach-Object { Write-Host "   Found $($_.Count) departments" -ForegroundColor Gray }
ApiCall "GET" "/admin/teachers" $null $adminToken "Teachers" | ForEach-Object { Write-Host "   Found $($_.Count) teachers" -ForegroundColor Gray }
ApiCall "GET" "/admin/students" $null $adminToken "Students" | ForEach-Object { Write-Host "   Found $($_.Count) students" -ForegroundColor Gray }
ApiCall "GET" "/admin/subjects" $null $adminToken "Subjects" | ForEach-Object { Write-Host "   Found $($_.Count) subjects" -ForegroundColor Gray }
ApiCall "GET" "/admin/sections" $null $adminToken "Sections" | ForEach-Object { Write-Host "   Found $($_.Count) sections" -ForegroundColor Gray }

# ========== PHASE 3: TEACHER QR GENERATION ==========
Write-Host "`n>>> PHASE 3: TEACHER QR GENERATION" -ForegroundColor Yellow

if ($teacherToken) {
    $qrData = ApiCall "POST" "/teacher/generateQR" @{subjectId=1; latitude=37.7749; longitude=-122.4194} $teacherToken "Generate QR Code"
    if ($qrData -and $qrData.sessionId) {
        $sessionId = $qrData.sessionId
        $qrToken = $qrData.token
        Write-Host "   Session ID: $sessionId" -ForegroundColor Gray
        Write-Host "   Token: $($qrToken.Substring(0,20))..." -ForegroundColor Gray
        Write-Host "   Expiry Time: $($qrData.expiryTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "   Skipping QR generation - No teacher token" -ForegroundColor Yellow
}

# ========== PHASE 4: STUDENT ATTENDANCE ==========
Write-Host "`n>>> PHASE 4: STUDENT ATTENDANCE" -ForegroundColor Yellow

if ($studentToken -and $sessionId -and $qrToken) {
    $attData = ApiCall "POST" "/student/mark-attendance" @{sessionId=$sessionId; token=$qrToken; latitude=37.7749; longitude=-122.4194} $studentToken "Mark Attendance"
    if ($attData) {
        Write-Host "   Attendance Status: $($attData.status)" -ForegroundColor Gray
    }
    
    $histData = ApiCall "GET" "/student/attendance-history" $null $studentToken "Attendance History"
    if ($histData) {
        Write-Host "   History Records: $($histData.Count)" -ForegroundColor Gray
    }
    
    $summData = ApiCall "GET" "/student/attendance/me" $null $studentToken "Attendance Summary"
    if ($summData) {
        Write-Host "   Subjects with Attendance: $($summData.Count)" -ForegroundColor Gray
    }
} else {
    Write-Host "   Skipping student operations - Missing token/session" -ForegroundColor Yellow
}

# ========== PHASE 5: VERIFICATION ==========
Write-Host "`n>>> PHASE 5: VERIFICATION" -ForegroundColor Yellow

if ($teacherToken -and $sessionId) {
    $finalData = ApiCall "GET" "/teacher/session/$sessionId/attendance" $null $teacherToken "Session Attendance (Final Check)"
    if ($finalData) {
        Write-Host "   Students in Session: $($finalData.Count)" -ForegroundColor Gray
        if ($finalData.Count -gt 0) {
            Write-Host "   First Student: $($finalData[0].studentName) - Status: $($finalData[0].status)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n=================================================" -ForegroundColor Cyan
Write-Host "   WORKFLOW TEST COMPLETE" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
