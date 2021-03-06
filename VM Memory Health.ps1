﻿cls

# Reporting script only. This script makes no changes. Please run at your own risk.

#Report on Process Memory usage

write-host ""

$AllProcesses = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process | 
Select-Object -Property @{Name='Process';Expression={$_.Name}},
                        @{Name='CPU_Usage';Expression={$_.PercentProcessorTime}},
                        @{Name='Memory_Usage_(MB)';Expression={[math]::Round($_.WorkingSetPrivate/1Mb,2)}}


$out2 = $AllProcesses | Sort-Object -Descending "Memory_Usage_(MB)"

# Sum of process memory

$out2 | Out-Host

Write-Host ""

$sum = $out2 | Measure-Object -Sum "Memory_Usage_(MB)"

Write-host "Current Process Memory Use in MB"

# Take away the total line. very basic formula assume _total is top line
($sum.Sum) - $($out2[0].'Memory_Usage_(MB)')


write-host ""

# Total And availble RAM

$os = Get-Ciminstance Win32_OperatingSystem
	
$pctFree = [math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100,2)

$mem = $os | Select @{Name = "PercentFree"; Expression = {$pctFree}},
@{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}},
@{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}

# For some reason this won't pause to compute, so put output down screem

##########################

# RAM Cache

write-host "RAM Cache in GB"

$counters= @(
"\Memory\Cache Bytes", `
"\Memory\Modified page list bytes", `
"\Memory\Standby Cache Core Bytes", `
"\Memory\Standby Cache normal Priority Bytes" , `
"\Memory\Standby Cache Reserve Bytes")
    
$output = $(foreach ($counter in $counters ) { `
Get-counter -counter $counter | `
foreach {$_.CounterSamples | `
foreach {write-output $_.CookedValue }} }) | `
foreach -begin {$sum=0} -process { $sum += $_ } -end {$sum/1024/1024/1024}

[math]::Round($output,2)

#####################

Write-Host ""
Write-Host "RAM Status"

$mem


