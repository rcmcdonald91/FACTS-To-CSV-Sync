# FACTStoCleverCSV

A collection of SQL queries and PowerShell to produce Clever CSVs from FACTS/RenWeb SIS*

*Requires ODBC access to FACTS/RenWeb

Instructions:
1. Edit config.json and supply your ODBC connection information provided by FACTS/RenWeb.
2. Run ./FactstoCleverCSV.ps1
3. Clever CSVs will be placed in /output.
4. These CSVs can be uploaded directly to Clever (configured by a PostAction using rclone or similar utility).
