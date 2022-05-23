
Install-Module -Name ImportExcel 
Import-Module $PSScriptRoot\TanRest-master-latest\TanRest-master\TanRest

# What AD Query - Computer Site Name are we looking for?
$adquerycomputersites = @(
"CORP"
"Baltimore"
"Baton Rouge"
"DEV"
)

# Username and password in Clear Text 
$testUserName = 'TestTaniumUser'
$TestPassword = 'UseTokenizedLoginsPlease'
$TestCredential = [PSCredential]::new($TestUserName,(convertTo-SecureString $TestPassword -AsPlainText -force))

# Where should we save results? Default is "Results" in PSScriptRoot

$ResultsFolder = "$PSScriptRoot\Results"

# Tanium Server URL

$TaniumServer = 'https://testtanium.url.google.training'

# Tanium Question
$Question = 'Get Computer Name and AD Query - Computer Site Name and Uptime and "_Uptime (integer)"?ignoreCase=0 > 33" from all machines with Windows OS Type contains server'

# Folder testing
if (Test-Path -Path $ResultsFolder) {
    Write-Output "Results folder found."
} else {
    Write-Output "No Results folder found, creating now...."
    New-Item -Path $ResultsFolder -ItemType Directory
}



#Remove old files
Write-Output "Removing old files."
Remove-Item $ResultsFolder\* -Include *.xlsx

## Tanium Section - Asking for patch schedule and uptime for all servers
Write-Output "Initiating Tanium Web Session"
$WebSession = New-TaniumWebSession -ServerURI $TaniumServer -credential $TestCredential

$Parsed = New-TaniumCoreParseQuestion -data @{ text = $Question } 

$taniumarray = @{ query_text = $Parsed[0].question_text } | New-TaniumCoreQuestions |  # Ask the question
wait-TaniumCoreQuestionResultInfo -Timeout 120 |   # Wait for all machines to respond
Get-TaniumCoreQuestionResult | #  Get the results
Format-TaniumCoreQuestionResult # Format the results into a Powershell Friendly format

### end tanium ask

## Filter out [no results] because tanium is goofy

$taniumarray.where{$_.'_Uptime (integer)' -ne '[no results]'} | ConvertTo-Excel -AutoFilter -AutoFit -FreezeTopRow -ExcelWorkSheetName "Report Generated $DateTime" -FilePath "$ResultsFolder\Servers_MissedReboots_AllServers.xlsx"


foreach ($adquerycomputersite in $adquerycomputersites){

$DateTime = Get-Date -format "MMddyyyy-HHmmss"

$taniumarray.where{($_.'AD Query - Computer Site Name' -like "$adquerycomputersite*") -and $_.'_Uptime (integer)' -ne '[no results]'} |  ConvertTo-Excel -AutoFilter -AutoFit -FreezeTopRow -ExcelWorkSheetName "$adquerycomputersite$DateTime" -FilePath "$ResultsFolder\Servers_MissedReboots_$ADQueryComputersite.xlsx"

}
#Clean up

$Filestocheck = @(Get-ChildItem "$ResultsFolder\" -Filter *.xlsx)

Foreach ($file in $Filestocheck) {

    $RowCount = ((Get-ExcelFileSummary -Path "$ResultsFolder\$File" -ErrorAction SilentlyContinue).rows)
    
    If ($null -eq $RowCount) {

        Remove-Item "$ResultsFolder\$File"
        Write-Output "Removed $file"
    
     }

    Else {

        Write-Output "$file has $rowcount rows"
    }

}
