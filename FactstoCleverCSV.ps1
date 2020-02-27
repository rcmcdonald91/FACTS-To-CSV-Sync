param (

    [string]$sqlPath = "$PSScriptRoot\sql",

    [string]$outputPath = "$PSScriptRoot\output" 

)

##Determine Start Time
$startTime = Get-Date

#SETs FACTS ODBC CREDENTIALS
$factsLoginName = "<REPLACE ME>"
$factsPassword = "<REPLACE ME>"
$factsDatabaseName = "<REPLACE ME>"
$factsServer = "<REPLACE ME>"
$factsPort = "<REPLACE ME>"

##################################

Get-ChildItem -Path $sqlPath -Filter *.sql | ForEach-Object {

    Write-Host "[$(Get-Date)] Processsing: $($_.FullName)" -ForegroundColor Green

    #CREATE ODBC CONNECTION OBJECT
    $conn = New-Object System.Data.Odbc.OdbcConnection

    #CREATE ODBC CONNNECTION STRING
    $conn.ConnectionString = "Driver={SQL Server};Server=$factsServer,$factsPort;Database=$factsDatabaseName;Uid=$factsLoginName;Pwd=$factsPassword"

    Try {

        #OPEN ODBC CONNECTION
        $conn.open()

    } Catch {

        Write-Error "[$(Get-Date)] ERROR: ODBC CONNECTION ERROR" -ErrorAction Stop 

    }

    #READ SQL QUERY FILE
    $query = Get-Content $_.FullName

    #EXECUTE SQL QUERY
    $cmd = New-object System.Data.Odbc.OdbcCommand($query, $conn)

    #CREATE ODBC DATASET
    $ds = New-Object system.Data.DataSet

    #FILL ODBC DATASET WITH DATA
    (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null

    #CLOSE AND CLEANUP
    $conn.close()

    $ds.Tables[0] | Export-Csv -Path "$outputPath\$($_.BaseName).csv" -NoTypeInformation

    ##Determine End Time
    $TotalTime = $("{0:hh\:mm\:ss}" -f (New-TimeSpan -Start $StartTime -End $(Get-Date)))

}

Write-Host "Script completed in $TotalTime" -ForegroundColor Green
