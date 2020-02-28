param (

    [string]$sqlPath = "$PSScriptRoot\sql",

    [string]$outputPath = "$PSScriptRoot\output" 

)

Write-Host "[$(Get-Date)] Scripted Started..." -ForegroundColor Green

#SETs FACTS ODBC CREDENTIALS
$factsLoginName = "<REPLACE ME>"
$factsPassword = "<REPLACE ME>"
$factsDatabaseName = "<REPLACE ME>"
$factsServer = "<REPLACE ME>"
$factsPort = "<REPLACE ME>"

##################################

Get-ChildItem -Path $sqlPath -Filter *.sql | ForEach-Object {

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

    #READ SQL QUERY (.sql same name as script)
    $query = Get-Content $_.FullName

    Write-Host "[$(Get-Date)] Executing: $($_.FullName)" -ForegroundColor Green

    #EXECUTE SQL QUERY
    $cmd = New-object System.Data.Odbc.OdbcCommand($query, $conn)

    #CREATE ODBC DATASET
    $ds = New-Object system.Data.DataSet

    #FILL ODBC DATASET WITH DATA
    (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null

    #CLOSE AND CLEANUP
    $conn.close()

    $csvPath = "$outputPath\$($_.BaseName).csv"

    Write-Host "[$(Get-Date)] Writing: $csvPath" -ForegroundColor Green

    $ds.Tables[0] | Export-Csv -Path "$csvPath" -NoTypeInformation

}

Write-Host "[$(Get-Date)] Scripted completed..." -ForegroundColor Green
