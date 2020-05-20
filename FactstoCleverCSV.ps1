param (

    [string]$ConfigFile = "$PSScriptRoot\config.json"

)

# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 

$config = Get-Content -Path $ConfigFile | ConvertFrom-Json

if($config.Logging.Enabled) {

    Start-Transcript -OutputDirectory $config.Logging.LogDir
    
}

Write-Host "[$(Get-Date)] Script Started..." -ForegroundColor Green

Write-Host "[$(Get-Date)] Host: $env:computername" -ForegroundColor Green

##################################

# DELETE OLD CSV FILES
Get-ChildItem -Path $config.General.OutputDir -Recurse -Force | Where-Object { -not ($_.PSIsContainer) } | Remove-Item -Force

# ITERATE THROUGH EACH SQL QUERY AND EXECUTE THEM
Get-ChildItem -Path $config.General.SqlDir -Filter *.sql | ForEach-Object {

    Write-Host "[$(Get-Date)] [SQL] [CONNECTION] $($_.FullName)" -ForegroundColor Green

    # CREATE NEW ODBC CONNECTION OBJECT
    $conn = New-Object System.Data.Odbc.OdbcConnection

    # CREATE ODBC CONNNECTION STRING
    $conn.ConnectionString = "Driver={{SQL Server}};Server={0},{1};Database={2};Uid={3};Pwd={4}" -f $config.ODBC.ServerAddress,$config.ODBC.ServerPort,$config.ODBC.DatabaseName,$config.ODBC.LoginName,$config.ODBC.LoginPassword
  
    Try {

        # TRY TO CONNECT TO THE ODBC CONNECTION
        $conn.open()

    } Catch {

        Write-Error "[$(Get-Date)] [SQL] [ERROR] ODBC CONNECTION ERROR" -ErrorAction Stop 

    }

    # READ SQL QUERY (.sql same name as script)
    $query = Get-Content $_.FullName

    Write-Host "[$(Get-Date)] [SQL] [QUERY] $($_.FullName)" -ForegroundColor Green

    # EXECUTE SQL QUERY
    $cmd = New-object System.Data.Odbc.OdbcCommand($query, $conn)

    # CREATE ODBC DATASET
    $ds = New-Object system.Data.DataSet

    # FILL ODBC DATASET WITH DATA
    (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null

    # CLOSE AND CLEANUP
    $conn.close()

    $csvFile = $config.General.OutputDir, "$($_.BaseName).csv" -join "\"

    Write-Host "[$(Get-Date)] [CSV] [WRITE] $csvFile" -ForegroundColor Green

    # WRITE CSV TO DISK
    $ds.Tables[0] | Export-Csv -Path $csvFile -NoTypeInformation

}

Write-Host "[$(Get-Date)] Script Completed..." -ForegroundColor Green

if($config.Logging.Enabled) {

    Stop-Transcript

    if ($config.Email.Enabled) {

        $logFile = Get-ChildItem $config.Logging.LogDir | Sort-Object LastWriteTime | Select-Object -Last 1

        $mailArguments = @{

            SmtpServer = $config.Email.SmtpServer

            Port = $config.Email.SmtpPort

            From = $config.Email.SenderAddress

            To = $config.Email.ReceiverAddresses

            UseSsl = $config.Email.SmtpSecure

            Encoding = $textEncoding

            Attachments = $logFile.FullName

        }

        Send-MailMessage @mailArguments -ErrorAction Stop

    }

}
