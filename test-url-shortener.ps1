
Write-Host "Starting URL Shortener Test..." -ForegroundColor Green
Write-Host ""

# Array of URLs to shorten
$urls = @(
    "https://github.com",
    "https://stackoverflow.com",
    "https://www.python.org",
    "https://www.docker.com",
    "https://grafana.com",
    "https://prometheus.io"
)

$baseUrl = "http://localhost:5000"
$shortCodes = @()

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
    Write-Host "Health check passed: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "Health check failed: $_" -ForegroundColor Red
}
Write-Host ""

# Test 2: Shorten URLs
Write-Host "Test 2: Shortening URLs" -ForegroundColor Cyan
foreach ($url in $urls) {
    try {
        $body = @{ url = $url } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$baseUrl/shorten" -Method Post -ContentType "application/json" -Body $body
        
        Write-Host "Shortened: $url" -ForegroundColor Green
        Write-Host "  Short URL: $($response.short_url)" -ForegroundColor Gray
        $shortCodes += $response.short_code
        
        Start-Sleep -Milliseconds 500
    } catch {
        Write-Host "Failed to shorten $url : $_" -ForegroundColor Red
    }
}
Write-Host ""

# Test 3: Test Redirects
Write-Host "Test 3: Testing Redirects" -ForegroundColor Cyan
foreach ($code in $shortCodes) {
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/$code" -MaximumRedirection 0 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 302) {
            Write-Host "Redirect works for code: $code" -ForegroundColor Green
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 302) {
            Write-Host "Redirect works for code: $code" -ForegroundColor Green
        } else {
            Write-Host "Redirect failed for code: $code" -ForegroundColor Red
        }
    }
    Start-Sleep -Milliseconds 300
}
Write-Host ""

# Test 4: Test 404 Error
Write-Host "Test 4: Testing 404 Error" -ForegroundColor Cyan
try {
    Invoke-RestMethod -Uri "$baseUrl/nonexistent123" -Method Get -ErrorAction Stop
    Write-Host "Should have returned 404" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "404 error correctly returned" -ForegroundColor Green
    } else {
        Write-Host "Unexpected error: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Test 5: Get Statistics
Write-Host "Test 5: Getting Statistics" -ForegroundColor Cyan
try {
    $stats = Invoke-RestMethod -Uri "$baseUrl/stats" -Method Get
    Write-Host "Total URLs in database: $($stats.total_urls)" -ForegroundColor Green
} catch {
    Write-Host "Failed to get stats: $_" -ForegroundColor Red
}
Write-Host ""

# Test 6: Generate Additional Load
Write-Host "Test 6: Generating Additional Load (for metrics)" -ForegroundColor Cyan
Write-Host "Creating 20 more URLs and accessing them..." -ForegroundColor Gray
for ($i = 1; $i -le 20; $i++) {
    try {
        $testUrl = "https://example.com/test/$i"
        $body = @{ url = $testUrl } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$baseUrl/shorten" -Method Post -ContentType "application/json" -Body $body
        
        # Access the shortened URL
        Invoke-WebRequest -Uri $response.short_url -MaximumRedirection 0 -ErrorAction SilentlyContinue
        
        if ($i % 5 -eq 0) {
            Write-Host "  Created and accessed $i URLs..." -ForegroundColor Gray
        }
        
        Start-Sleep -Milliseconds 100
    } catch {
        # Ignore errors for load testing
    }
}
Write-Host "Load generation complete" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "Test Summary" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host "Service URL: $baseUrl"
Write-Host "Prometheus: http://localhost:9090"
Write-Host "Grafana: http://localhost:3000 (admin/admin)"
Write-Host ""
Write-Host "You can now view metrics in Grafana dashboard!" -ForegroundColor Green
Write-Host "The metrics should show the URLs created and redirects performed." -ForegroundColor Green
Write-Host ""
