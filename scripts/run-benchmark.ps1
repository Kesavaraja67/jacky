# run-benchmark.ps1 - Automated Benchmark for Jacky Models
# Runs llama-bench and manual llama-server session to collect Phase 0 metrics

param(
    [string]$ModelPath = "$env:APPDATA\Jacky\models\qwen2.5-1.5b-instruct-q4_k_m.gguf",
    [string]$ModelLabel = "FAST (Qwen2.5-1.5B Q4_K_M)"
)

$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   JACKY BENCHMARK: $ModelLabel                  " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if (-not (Test-Path $ModelPath)) {
    Write-Error "Model file not found at: $ModelPath"
    return
}

$modelFile = Get-Item $ModelPath
$modelSizeMB = [math]::Round($modelFile.Length / 1MB, 2)
$modelSizeGB = [math]::Round($modelFile.Length / 1GB, 2)

Write-Host "Model file: $ModelPath"
Write-Host "Model size: $modelSizeMB MB ($modelSizeGB GB)" -ForegroundColor White

# Record baseline RAM
$os = Get-CimInstance Win32_OperatingSystem
$baselineFreeMB = [math]::Round($os.FreePhysicalMemory / 1024, 2)
Write-Host "Baseline Free RAM before run: $baselineFreeMB MB" -ForegroundColor Yellow

$benchExe = Join-Path $env:APPDATA "Jacky\bin\llama-bench.exe"
$serverExe = Join-Path $env:APPDATA "Jacky\bin\llama-server.exe"

# 1. Run llama-bench
Write-Host "`n--- Running llama-bench (-t 3, -p 512, -n 128, -r 3) ---" -ForegroundColor Yellow
$benchOutput = & $benchExe -m $ModelPath -t 3 -p 512 -n 128 -r 3 -o md 2>&1
$benchOutput | ForEach-Object { Write-Output $_ }

# 2. Measure cold-start load time with llama-server
Write-Host "`n--- Measuring cold-load time & RAM with llama-server ---" -ForegroundColor Yellow
$port = 18080
$startTime = [System.Diagnostics.Stopwatch]::StartNew()

$serverProc = Start-Process -FilePath $serverExe `
    -ArgumentList "-m `"$ModelPath`" -t 3 -c 2048 --host 127.0.0.1 --port $port" `
    -PassThru -WindowStyle Hidden

$ready = $false
$maxWaitSec = 60
$healthUrl = "http://127.0.0.1:$port/health"

for ($i = 0; $i -lt $maxWaitSec; $i++) {
    Start-Sleep -Milliseconds 500
    try {
        $res = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($res.StatusCode -eq 200) {
            $ready = $true
            break
        }
    } catch {}
}

$startTime.Stop()
$loadTimeSec = [math]::Round($startTime.Elapsed.TotalSeconds, 2)

if ($ready) {
    Write-Host "[x] llama-server ready in: $loadTimeSec seconds" -ForegroundColor Green
    
    # Record working set RAM
    $proc = Get-Process -Id $serverProc.Id -ErrorAction SilentlyContinue
    $wsMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
    Write-Host "Peak Working Set RAM: $wsMB MB" -ForegroundColor White
    
    # 3. Test chat completion request
    Write-Host "`n--- Sending Test Chat Completion Request ---" -ForegroundColor Yellow
    $chatUrl = "http://127.0.0.1:$port/v1/chat/completions"
    $body = @{
        messages = @(
            @{ role = "system"; content = "You are Jacky, a sharp, loyal assistant." },
            @{ role = "user"; content = "Explain what an operating system kernel does in 2 concise sentences." }
        )
        max_tokens = 100
        temperature = 0.2
    } | ConvertTo-Json -Depth 5
    
    $reqWatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $resp = Invoke-RestMethod -Uri $chatUrl -Method Post -Body $body -ContentType "application/json" -TimeoutSec 30
        $reqWatch.Stop()
        $reqTimeSec = [math]::Round($reqWatch.Elapsed.TotalSeconds, 2)
        
        $content = $resp.choices[0].message.content
        $usage = $resp.usage
        
        Write-Host "Response received in $reqTimeSec s:" -ForegroundColor White
        Write-Host "$content" -ForegroundColor Gray
        Write-Host "`nPrompt tokens: $($usage.prompt_tokens), Completion tokens: $($usage.completion_tokens)" -ForegroundColor White
        if ($usage.completion_tokens -gt 0 -and $reqTimeSec -gt 0) {
            $genSpeed = [math]::Round($usage.completion_tokens / $reqTimeSec, 2)
            Write-Host "Effective Generation Speed: $genSpeed tokens/sec" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Chat completion request failed: $_"
    }
} else {
    Write-Error "Server failed to become ready within $maxWaitSec seconds."
}

# Stop server process
Write-Host "`nTerminating llama-server process..."
Stop-Process -Id $serverProc.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Check RAM after stop
$os = Get-CimInstance Win32_OperatingSystem
$afterFreeMB = [math]::Round($os.FreePhysicalMemory / 1024, 2)
Write-Host "Free RAM after shutdown: $afterFreeMB MB" -ForegroundColor Yellow

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "   BENCHMARK RUN COMPLETE                         " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
