
param(
    [string]$Url
)

$baseUrl = "http://localhost:5000"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "     URL Shortener Service" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# If no URL provided, ask for it
if (-not $Url) {
    $Url = Read-Host "Enter the long URL to shorten"
}

# Validate URL
if ([string]::IsNullOrWhiteSpace($Url)) {
    Write-Host "Error: URL cannot be empty!" -ForegroundColor Red
    exit 1
}

try {
    Write-Host "Shortening URL..." -ForegroundColor Yellow
    Write-Host ""
    
    # Create short URL
    $body = @{ url = $Url } | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$baseUrl/shorten" `
        -Method Post `
        -ContentType "application/json" `
        -Body $body `
        -ErrorAction Stop
    
    # Display results
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Original URL:  " -NoNewline -ForegroundColor Gray
    Write-Host $response.long_url -ForegroundColor White
    Write-Host ""
    Write-Host "Short Code:    " -NoNewline -ForegroundColor Gray
    Write-Host $response.short_code -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Short URL:     " -NoNewline -ForegroundColor Gray
    Write-Host $response.short_url -ForegroundColor Cyan
    Write-Host ""
    
    # Copy to clipboard
    $response.short_url | Set-Clipboard
    Write-Host "Short URL copied to clipboard!" -ForegroundColor Green
    Write-Host ""
    
    # Ask if user wants to test the redirect
    $test = Read-Host "Do you want to test the redirect? (Y/N)"
    if ($test -eq "Y" -or $test -eq "y") {
        Write-Host "Opening in browser..." -ForegroundColor Yellow
        Start-Process $response.short_url
    }
    
} catch {
    Write-Host ""
    Write-Host "Error: Failed to shorten URL" -ForegroundColor Red
    Write-Host "Details: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure the service is running:" -ForegroundColor Yellow
    Write-Host "  docker-compose ps" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
