# Repository Monitor Script
# Checks for new pushes from collaborators every 30 seconds

param(
    [int]$CheckInterval = 30,  # seconds between checks
    [string]$RepoPath = "c:\Users\nikif\Documents\GitHub\task-flow"
)

Write-Host "TaskFlow Repository Monitor Started" -ForegroundColor Green
Write-Host "Checking every $CheckInterval seconds for new changes..." -ForegroundColor Yellow
Write-Host "Repository: $RepoPath" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Magenta
Write-Host ("-" * 50) -ForegroundColor Gray

# Store initial state
Set-Location $RepoPath
$initialCommit = (git rev-parse HEAD).Trim()
$initialBranches = git branch -r
$checkCount = 0

try {
    while ($true) {
        $checkCount++
        $timestamp = Get-Date -Format "HH:mm:ss"
        
        Write-Host "[$timestamp] Check #$checkCount - Fetching from remote..." -ForegroundColor Gray
        
        # Fetch latest changes quietly
        git fetch origin 2>&1 | Out-Null
        
        # Check for new commits
        $currentCommit = (git rev-parse HEAD).Trim()
        $remoteCommit = (git rev-parse origin/main).Trim()
        
        if ($currentCommit -ne $remoteCommit) {
            Write-Host "" 
            Write-Host "🎉 NEW CHANGES DETECTED!" -ForegroundColor Green -BackgroundColor Black
            Write-Host "Remote has new commits!" -ForegroundColor Yellow
            
            # Show what changed
            Write-Host "`nNew commits:" -ForegroundColor Cyan
            git log --oneline $currentCommit..$remoteCommit --pretty=format:"%h %ad %an - %s" --date=short
            
            Write-Host "`nWould you like to pull these changes? (Y/N): " -ForegroundColor Yellow -NoNewline
            $response = Read-Host
            
            if ($response -eq "Y" -or $response -eq "y") {
                Write-Host "Pulling changes..." -ForegroundColor Green
                git pull origin main
                Write-Host "✅ Repository updated!" -ForegroundColor Green
            } else {
                Write-Host "⏸️ Changes available but not pulled" -ForegroundColor Yellow
            }
            
            # Update our tracking
            $initialCommit = (git rev-parse HEAD).Trim()
            Write-Host ("-" * 50) -ForegroundColor Gray
        }
        
        # Check for new branches
        $currentBranches = git branch -r
        $newBranches = Compare-Object $initialBranches $currentBranches | Where-Object {$_.SideIndicator -eq '=>'}
        
        if ($newBranches) {
            Write-Host "" 
            Write-Host "🌿 NEW BRANCH(ES) DETECTED!" -ForegroundColor Magenta
            $newBranches | ForEach-Object { 
                Write-Host "  $($_.InputObject)" -ForegroundColor Cyan
            }
            $initialBranches = $currentBranches
            Write-Host ("-" * 50) -ForegroundColor Gray
        }
        
        # Check for pull requests (if GitHub CLI is available)
        try {
            $prCheck = Invoke-RestMethod -Uri "https://api.github.com/repos/NikolasNeofytou/task-flow/pulls" -Headers @{"User-Agent"="PowerShell"} -ErrorAction SilentlyContinue
            if ($prCheck -and $prCheck.Count -gt 0) {
                Write-Host "" 
                Write-Host "📋 PULL REQUEST(S) FOUND!" -ForegroundColor Blue
                foreach ($pr in $prCheck) {
                    Write-Host "  #$($pr.number): $($pr.title)" -ForegroundColor Cyan
                    Write-Host "    by $($pr.user.login) - $($pr.created_at)" -ForegroundColor Gray
                }
                Write-Host ("-" * 50) -ForegroundColor Gray
            }
        } catch {
            # Silently continue if GitHub API is not accessible
        }
        
        # Wait before next check
        Start-Sleep -Seconds $CheckInterval
    }
}
catch [System.Management.Automation.RuntimeException] {
    Write-Host "`n👋 Monitoring stopped by user" -ForegroundColor Yellow
}
catch {
    Write-Host "`n⚠️ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host "`nRepository monitoring ended at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
}