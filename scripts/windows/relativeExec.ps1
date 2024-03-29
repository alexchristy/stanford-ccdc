# Prompt the user for the relative script path
$relativeScriptPath = Read-Host "Please enter the relative path to the script you want to run"

# Resolve the relative path to an absolute path
$localScriptPath = Resolve-Path $relativeScriptPath

# The rest of the script remains the same
$computers = Get-ADComputer -Filter *
$jobs = @()

foreach ($computer in $computers) {
    $job = Invoke-Command -ComputerName $computer.Name -ScriptBlock { param($path) & $path } -ArgumentList $localScriptPath -AsJob
    $jobs += $job
}

$jobs | Wait-Job

foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    Write-Host "Results for $($job.Location):"
    Write-Host $result
    Write-Host "-----------------------------------"
    Remove-Job -Job $job
}
