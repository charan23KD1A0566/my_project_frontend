$BASE_URL = "http://localhost:8080/api"

Write-Host "Testing /api/auth/login endpoint..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/auth/login" -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"admin@gmail.com","password":"admin123"}' `
        -UseBasicParsing

    Write-Host "✅ SUCCESS" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch [System.Net.WebException] {
    $errorResponse = $_.Exception.Response
    Write-Host "❌ ERROR" -ForegroundColor Red
    Write-Host "Status Code: $($errorResponse.StatusCode)"
    Write-Host "Status Description: $($errorResponse.StatusDescription)"
    
    if ($errorResponse.ContentLength -gt 0) {
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $content = $reader.ReadToEnd()
        $reader.Close()
        Write-Host "Response: $content"
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
