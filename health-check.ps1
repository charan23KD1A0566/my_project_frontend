#!/usr/bin/env powershell

$API = "https://my-project-80ir.onrender.com/api"

Write-Host "Backend Health Check" -ForegroundColor Cyan
Write-Host ""

# Test 1: Admin login
Write-Host "[1] Admin Login..." -ForegroundColor Yellow
try {
    $admin = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body (ConvertTo-Json @{email='admin@gmail.com';password='admin123';role='admin'})
    Write-Host "SUCCESS - Token: $($admin.token.Substring(0,30))..." -ForegroundColor Green
    $adminToken = $admin.token
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Test 2: Get departments
Write-Host "`n[2] Get Departments..." -ForegroundColor Yellow
try {
    $depts = Invoke-RestMethod -Uri "$API/admin/departments" -Method GET `
        -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "SUCCESS - Found $($depts.Count) departments" -ForegroundColor Green
    foreach ($d in $depts) {
        Write-Host "   - $($d.name) (ID: $($d.id))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Get sections
Write-Host "`n[3] Get Sections..." -ForegroundColor Yellow
try {
    $sections = Invoke-RestMethod -Uri "$API/admin/sections" -Method GET `
        -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "SUCCESS - Found $($sections.Count) sections" -ForegroundColor Green
    Write-Host "   First 5: $($sections[0..4] | ConvertTo-Json -Compress)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Get teachers  
Write-Host "`n[4] Get Teachers..." -ForegroundColor Yellow
try {
    $teachers = Invoke-RestMethod -Uri "$API/admin/teachers" -Method GET `
        -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "SUCCESS - Found $($teachers.Count) teachers" -ForegroundColor Green
    foreach ($t in $teachers) {
        Write-Host "   - ID: $($t.id), Name: $($t.name), Email: $($t.email)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Get subjects
Write-Host "`n[5] Get Subjects..." -ForegroundColor Yellow
try {
    $subjects = Invoke-RestMethod -Uri "$API/admin/subjects" -Method GET `
        -Headers @{"Authorization"="Bearer $adminToken"}
    Write-Host "SUCCESS - Found $($subjects.Count) subjects" -ForegroundColor Green
    Write-Host "   First 5: " -ForegroundColor Cyan
    foreach ($s in $subjects[0..4]) {
        Write-Host "      - $($s.name) (Dept: $($s.department.name), Year: $($s.year), Section: $($s.section.sectionName), Teacher: $($s.teacher.name))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nHealth Check Complete" -ForegroundColor Cyan
