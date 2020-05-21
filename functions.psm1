function Test-ODBCConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerAddress,

        [Parameter(Mandatory=$false)]
        [string]$ServerPort = "1433",

        [Parameter(Mandatory=$true)]
        [string]$LoginName,

        [Parameter(Mandatory=$true)]
        [string]$LoginPassword,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName

    )

    try {

        $conn = New-Object System.Data.Odbc.OdbcConnection

        $conn.ConnectionString = "Driver={{SQL Server}};Server={0},{1};Database={2};Uid={3};Pwd={4}" -f $ServerAddress,$ServerPort,$DatabaseName,$LoginName,$LoginPassword

        $conn.Open()

        $true

    } catch {
         
        Write-Error $_.Exception.Message

        $false

    } finally {

        $conn.Close()

    }
        

}

function Get-ODBCData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerAddress,

        [Parameter(Mandatory=$false)]
        [string]$ServerPort = "1433",

        [Parameter(Mandatory=$true)]
        [string]$LoginName,

        [Parameter(Mandatory=$true)]
        [string]$LoginPassword,

        [Parameter(Mandatory=$true)]
        [string]$DatabaseName,

        [Parameter(Mandatory=$true)]
        [string]$Query

    )

    try {

        $conn = New-Object System.Data.Odbc.OdbcConnection

        $conn.ConnectionString = "Driver={{SQL Server}};Server={0},{1};Database={2};Uid={3};Pwd={4}" -f $ServerAddress,$ServerPort,$DatabaseName,$LoginName,$LoginPassword

        $conn.Open()

        # EXECUTE SQL QUERY
        $cmd = New-Object System.Data.Odbc.OdbcCommand($Query, $conn)

        # CREATE ODBC DATASET
        $ds = New-Object System.Data.DataSet

        # FILL ODBC DATASET WITH DATA
        (New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).fill($ds) | Out-Null

        # RETURN TABLE
        $ds.Tables[0]

    } catch {
         
        Write-Error $_.Exception.Message

    } finally {

        $conn.Close()

    }
        

}

function Invoke-Process {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $FilePath,

        [Parameter(Mandatory=$false)]
        $ArgumentList
    )

    $ErrorActionPreference = 'Stop'

    try {

        $stdOutTempFile = "$env:TEMP\$((New-Guid).Guid)"

        $stdErrTempFile = "$env:TEMP\$((New-Guid).Guid)"

        $startProcessParams = @{
            FilePath               = $FilePath
            ArgumentList           = $ArgumentList
            RedirectStandardError  = $stdErrTempFile
            RedirectStandardOutput = $stdOutTempFile
            Wait                   = $true;
            PassThru               = $true;
            WindowStyle            = "Hidden";
        }
        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run with args: [$($ArgumentList)]")) {
            $cmd = Start-Process @startProcessParams
            $cmdOutput = Get-Content -Path $stdOutTempFile -Raw
            $cmdError = Get-Content -Path $stdErrTempFile -Raw
            if ($cmd.ExitCode -ne 0) {
                if ($cmdError) {
                    throw $cmdError.Trim()
                }
                if ($cmdOutput) {
                    throw $cmdOutput.Trim()
                }
            } else {
                if ([string]::IsNullOrEmpty($cmdOutput) -eq $false) {
                    Write-Output -InputObject $cmdOutput
                }
            }
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    } finally {
        Remove-Item -Path $stdOutTempFile, $stdErrTempFile -Force -ErrorAction Ignore
    }

   
}
