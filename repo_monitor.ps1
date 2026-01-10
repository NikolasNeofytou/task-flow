# Repository Monitor Script - Simple Version
# Checks for new pushes from collaborators

param(
    [int]$CheckInterval = 30,
    [string]$RepoPath = "c:\Users\nikif\Documents\GitHub\task-flow"
)

Write-Host "TaskFlow Repository Monitor Started" -ForegroundColor Green
Write-Host "Checking every $CheckInterval seconds..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Magenta
Write-Host ("-" * 50)

Set-Location $RepoPath
$checkCount = 0

while ($true) {
    try {
        $checkCount++
        $timestamp = Get-Date -Format "HH:mm:ss"
        Write-Host "[$timestamp] Check #$checkCount" -ForegroundColor Gray
        
        # Fetch from remote
        git fetch origin 2>$null
        
        # Check for differences
        $localCommit = git rev-parse HEAD
        $remoteCommit = git rev-parse origin/main
        
        if ($localCommit -ne $remoteCommit) {
            Write-Host ""
            Write-Host "NEW CHANGES DETECTED!" -ForegroundColor Green
            Write-Host "New commits available from collaborator:" -ForegroundColor Yellow
            
            git log --oneline $localCommit..$remoteCommit
            
            Write-Host ""
            Write-Host "Pull changes now? (Y/N): " -NoNewline -ForegroundColor Cyan
            $answer = Read-Host
            
            if ($answer -eq "Y" -or $answer -eq "y") {
                git pull origin main
                Write-Host "Repository updated!" -ForegroundColor Green
            }
            Write-Host ("-" * 50)
        }
        
        Start-Sleep -Seconds $CheckInterval
    }
    catch {
        Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
        break
    }
}