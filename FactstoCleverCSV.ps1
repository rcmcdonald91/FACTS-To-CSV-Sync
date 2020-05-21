param (

    [string]$ConfigFile = "$PSScriptRoot\config.json"

)

Import-Module -Name "$PSScriptRoot\functions.psm1" -Force

# READ AND PARSE CONFIG FILE
$config = Get-Content -Path $ConfigFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

# BEGIN LOGGING
if($config.General.LoggingEnabled) {

    Start-Transcript -OutputDirectory $config.Paths.LogDir
    
}

# LOG RUNNING CONFIG
Write-Host "$($config | Format-List | Out-String)" -ForegroundColor Green

# READ ODBC Arguments
$OdbcArgs = @{}

$config.OdbcArgs.PSObject.Properties | Foreach-Object { $OdbcArgs[$_.Name] = $_.Value }

Write-Host "[$(Get-Date)] Script Started..." -ForegroundColor Green

Write-Host "[$(Get-Date)] Host: $env:computername" -ForegroundColor Green

# DELETE OLD CSV FILES
Get-ChildItem -Path $config.Paths.OutputDir -Recurse -Force | Where-Object { -not ($_.PSIsContainer) } | Remove-Item -Force

# ITERATE THROUGH EACH SQL QUERY AND EXECUTE THEM
Get-ChildItem -Path $config.Paths.SqlDir -Filter *.sql | ForEach-Object {

    Write-Host "[$(Get-Date)] [SQL] [READ] $($_.FullName)" -ForegroundColor Green
 
    # READ SQL QUERY (.sql same name as script)
    $query = Get-Content $_.FullName | Out-String

    Write-Host "[$(Get-Date)] [SQL] [QUERY] $($_.Name)" -ForegroundColor Green

    # EXECUTE SQL QUERY
    $results = Get-ODBCData @OdbcArgs -Query $query

    Write-Host "[$(Get-Date)] [CSV] [WRITE] $csvFile" -ForegroundColor Green

    $csvFile = Join-Path -Path $config.Paths.OutputDir -ChildPath "$($_.BaseName).csv"

    # WRITE CSV TO DISK
    $results | Export-Csv -Path $csvFile -NoTypeInformation

}

if($config.General.PostActionEnabled) {
    
    Write-Host "[$(Get-Date)] [CMD] [EXECUTE] Post Action $($config.PostActionArgs)" -ForegroundColor Green

    $PostActionArgs = @{}

    $config.PostActionArgs.PSObject.Properties | Foreach-Object { $PostActionArgs[$_.Name] = $_.Value }

    Invoke-Process @PostActionArgs

}

Write-Host "[$(Get-Date)] Script Completed..." -ForegroundColor Green

if($config.General.LoggingEnabled) {

    Stop-Transcript

    if ($config.General.EmailEnabled) {

        $logFile = Get-ChildItem $config.Paths.LogDir | Sort-Object LastWriteTime | Select-Object -Last 1

        $MailArgs = @{}

        $config.MailArgs.PSObject.Properties | ForEach-Object { $MailArgs[$_.Name] = $_.Value }

        $MailArgs = $MailArgs + @{

            Encoding     = [System.Text.Encoding]::UTF8

            Attachments  = $logFile.FullName

        }

        Send-MailMessage @MailArgs -ErrorAction Stop 

    }

}
