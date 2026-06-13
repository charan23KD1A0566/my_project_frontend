$API = "http://localhost:8080/api"

# Test getting teachers
try {
    $teachers = Invoke-RestMethod -Uri "$API/teacher/all" -Method GET
    Write-Host "Teachers count: $($teachers.Count)"
    if ($teachers.Count -gt 0) {
        $teachers[0] | ConvertTo-Json
    }
} catch {
    Write-Host "Error getting teachers: $($_.Exception.Message)"
}

Write-Host ""

# Test getting subjects
try {
    $subjects = Invoke-RestMethod -Uri "$API/subject/all" -Method GET
    Write-Host "Subjects count: $($subjects.Count)"
    if ($subjects.Count -gt 0) {
        Write-Host "Sample subject:"
        $subjects[0] | ConvertTo-Json
    }
} catch {
    Write-Host "Error getting subjects: $($_.Exception.Message)"
}
