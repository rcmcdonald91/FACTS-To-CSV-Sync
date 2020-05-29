param (

    [string]$ConfigFile = "$PSScriptRoot\config.json"

)

try {

    Import-Module -Name "$PSScriptRoot\functions.psm1" -Force

} catch {

    Write-Error $_.Exception.Message -ErrorAction Stop

}

# READ AND PARSE CONFIG FILE
$config = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

# READ ODBC Arguments
$OdbcArgs = @{}

$config.OdbcArgs.PSObject.Properties | ForEach-Object { $OdbcArgs[$_.Name] = $_.Value }

$MailArgs = @{}

$config.MailArgs.PSObject.Properties | ForEach-Object { $MailArgs[$_.Name] = $_.Value }

# BEGIN LOGGING
if($config.General.LoggingEnabled) {

    Start-Transcript -OutputDirectory $config.Paths.LogDir
    
}

# LOG RUNNING CONFIG
Write-Host "$($config | Format-List | Out-String)" -ForegroundColor Green

Write-Host "[$(Get-Date)] Script Started..." -ForegroundColor Green

Write-Host "[$(Get-Date)] Host: $env:computername" -ForegroundColor Green

# DELETE OLD CSV FILES
Get-ChildItem -Path $config.Paths.OutputDir -Recurse -Force | Where-Object { -not ($_.PSIsContainer) } | Remove-Item -Force

if($config.General.PreActionEnabled) {
    
    Write-Host "[$(Get-Date)] [CMD] [EXECUTE] Pre Action $($config.PreActionArgs | Out-String)" -ForegroundColor Green

    $PreActionArgs = @{}

    $config.PreActionArgs.PSObject.Properties | ForEach-Object { $PreActionArgs[$_.Name] = $_.Value }

    Invoke-Process @PreActionArgs

}

# ITERATE THROUGH EACH SQL QUERY AND EXECUTE THEM
Get-ChildItem -Path $config.Paths.SqlDir -Filter *.sql | ForEach-Object {

    Write-Host "[$(Get-Date)] [SQL] [READ] $($_.FullName)" -ForegroundColor Green
 
    # READ SQL QUERY (.sql same name as script)
    $query = Get-Content $_.FullName | Out-String

    Write-Host "[$(Get-Date)] [SQL] [QUERY] $($_.Name)" -ForegroundColor Green

    # EXECUTE SQL QUERY
    $results = Get-ODBCData @OdbcArgs -Query $query

    $csvFile = Join-Path -Path $config.Paths.OutputDir -ChildPath "$($_.BaseName).csv"

    Write-Host "[$(Get-Date)] [CSV] [WRITE] $csvFile" -ForegroundColor Green

    # WRITE CSV TO DISK
    $results | Export-Csv -Path $csvFile -NoTypeInformation

}

if($config.General.PostActionEnabled) {
    
    Write-Host "[$(Get-Date)] [CMD] [EXECUTE] Post Action $($config.PostActionArgs | Out-String)" -ForegroundColor Green

    $PostActionArgs = @{}

    $config.PostActionArgs.PSObject.Properties | ForEach-Object { $PostActionArgs[$_.Name] = $_.Value }

    Invoke-Process @PostActionArgs

}

Write-Host "[$(Get-Date)] Script Completed..." -ForegroundColor Green

if($config.General.LoggingEnabled) {

    Stop-Transcript

    if ($config.General.EmailEnabled) {

        $logFile = @(Get-ChildItem $config.Paths.LogDir | Sort-Object LastWriteTime | Select-Object FullName -Last 1)

        $outputFiles = @(Get-ChildItem $config.Paths.OutputDir | Select-Object FullName)

        Send-MailMessage @MailArgs -Attachments ($logFile + $outputFiles).FullName -ErrorAction Stop 

    }

}
