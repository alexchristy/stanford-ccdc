# Define the script path
$localScriptPath = "C:\Temp\cute.ps1"

# Retrieve all AD computers
$computers = Get-ADComputer -Filter *

# Use a hashtable to store job information for easy lookup
$jobs = @{}

foreach ($computer in $computers) {
    # Execute the script on the remote computer as a background job
    $job = Invoke-Command -ComputerName $computer.Name -FilePath $localScriptPath -AsJob
    # Store the job with the computer name as key
    $jobs[$computer.Name] = $job
}

# Wait for all jobs to complete
Get-Job | Wait-Job

# Retrieve and display the results of each job
foreach ($computerName in $jobs.Keys) {
    $job = $jobs[$computerName]
    $result = Receive-Job -Job $job
    Write-Host "Results for $computerName:"
    Write-Host $result
    Write-Host "-----------------------------------"
    # Cleanup the job
    Remove-Job -Job $job
}
