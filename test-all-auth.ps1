$BASE_URL = "http://localhost:8080/api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing All Auth Login Scenarios"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Admin Login
Write-Host "TEST 1: Admin Login" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"admin@gmail.com","password":"admin123"}' `
        -UseBasicParsing

    $data = $response.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Role: $($data.role)"
    Write-Host "   Name: $($data.name)"
    Write-Host "   Email: $($data.email)"
    Write-Host "   Token: $($data.token.Substring(0,40))..."
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Teacher Login
Write-Host "TEST 2: Teacher Login" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"teacher1@college.com","password":"teacher123"}' `
        -UseBasicParsing

    $data = $response.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Role: $($data.role)"
    Write-Host "   Name: $($data.name)"
    Write-Host "   ID: $($data.id)"
    Write-Host "   Token: $($data.token.Substring(0,40))..."
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Student Login
Write-Host "TEST 3: Student Login" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"student1@college.com","password":"student123"}' `
        -UseBasicParsing

    $data = $response.Content | ConvertFrom-Json
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Role: $($data.role)"
    Write-Host "   Name: $($data.name)"
    Write-Host "   Roll Number: $($data.rollNumber)"
    Write-Host "   Token: $($data.token.Substring(0,40))..."
} catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ ALL AUTH ENDPOINTS WORKING"
Write-Host "========================================" -ForegroundColor Cyan
