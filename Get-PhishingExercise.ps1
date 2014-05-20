Function Get-PhishingExercise {
<#
.NAME
   Get-PhishingExercise

.SYNOPSIS
 
    Get-PhishingExercise
    
    Author: Chris Campbell (@obscuresec)
    License: BSD 3-Clause
    
.DESCRIPTION

    This script was created to be used with a client-side phishing test.

.PARAMETER SecondsWaited

    Specifies the number of seconds to wait in between each phase of the test.
     
.LINK

    https://github.com/obscuresec/random/Get-PhishingExercise

.NOTES

    This script won't be used in the normal fashion and should be tailored each test.

#>

[CmdletBinding()] Param(     
        [ValidateNotNullOrEmpty()] 
        [int32] $SecondsWaited = '600'
        )

    #Generally bad form, but since this will be in the background its probably the right call
    $ErrorActionPreference = 'SilentlyContinue'

    $StartTime = Get-Date

    #Create random logname to disguise it a bit
    [string] $LogTitle = (-join ([Char[]]'abcdefghijklmnopqrstuvwxyz1234567890' | Get-Random -Count 16)) + ".log"

    #Pick a location to change it up for each machine, add more if necessary
    [int32] $LocationNumber = (Get-Random 3)

        if ($LocationNumber -eq 0) {$LogPath = $Env:TEMP}
        if ($LocationNumber -eq 1) {$LogPath = $Env:PUBLIC}
        if ($LocationNumber -eq 2) {$LogPath = $Env:APPDATA}

    [string] $LogFile = Join-Path $LogPath $LogTitle 

    #Phase 0, the user has the opportunity to self-report
    [string] $LogMessage = "$Env:USERNAME enabled the macro at $StartTime. The user should be thanked for reporting, but reminded not to open unknown files."
    Add-Content -Value $LogMessage -Path $LogFile

    Start-Sleep -Seconds $SecondsWaited

    #Phase 1, the user receives a warning to call and is instructed to give the encoded location of log file
    $PopupTime = Get-Date
    $PopupTitle = 'Your Computer is Compromised!'
    #Don't want the user to delete log file so we will encode it!
    $StringBytes = [System.Text.Encoding]::UTF8.GetBytes($LogFile)
    $EncodedLogFile = [System.Convert]::ToBase64String($StringBytes) 
    $PopupMessage = "Please immediately contact your security point-of-contact! Code: $EncodedLogFile"
    Add-Type -AssemblyName "System.Drawing","System.Windows.Forms"
    [Windows.Forms.MessageBox]::Show($PopupMessage, $PopupTitle, [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information) | Out-Null

    $LogMessage = "At $PopupTime $Env:USERNAME was warned with a popup with the following message: $PopupMessage. User must be retrained."
    Add-Content -Value $LogMessage -Path $LogFile

    $AcceptTime = Get-Date
    $LogMessage = "At $AcceptTime $Env:USERNAME clicked on the message. Why didn't they report this?"
    Add-Content -Value $LogMessage -Path $LogFile

    Start-Sleep -Seconds $SecondsWaited

    #Phase 2, activity flags antivirus which should report to a centralized server and give log directory
    [string] $EncodedEicar = 'WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo='
    $EicarBytes = [System.Convert]::FromBase64String($EncodedEicar)
    [string] $Eicar = [System.Text.Encoding]::UTF8.GetString($EicarBytes)
    $EicarPath = Join-Path $LogPath Eicar.com
    Set-Content -Value $Eicar -Encoding ascii -Path $EicarPath -Force

    $EicarTime = Get-Date
    $LogMessage = "At $EicarTime, the Eicar string was written to $EicarPath. How long does it take for the AV admin to notice?"
    Add-Content -Value $LogMessage -Path $LogFile

    Start-Sleep -Seconds $SecondsWaited

    #Phase 3, the machine begins resolving malicious domains which should flag network IDS

    #Pick a random evil C2 location to resolve (taken from Mandiant APT1 report) 
    [int32] $LocationNumber = (Get-Random 5)

        Switch ($LocationNumber) {
            0 {$EvilC2 = 'applesoftupdate.com'}
            1 {$EvilC2 = 'java.earthsolution.org'}
            2 {$EvilC2 = 'news.nytimesnews.net'}
            3 {$EvilC2 = 'sea.arrowservice.net'}
            4 {$EvilC2 = 'www.uszzcs.com'}
        }

    #Format path to look something like a URL
    [string] $HintUrl = ($LogFile.replace('\','.')).Substring(3)
 
    $LoopRange = 1..25          
    $RangeCount = $LoopRange.Count            
    
        For ($i=0; $i -lt $RangeCount; $i++) {            
              
            #Resolve the malicious hostname and attempt to resolve to give directory name to analyst
            [System.Net.Dns]::GetHostAddresses($EvilC2) | Out-Null
            [System.Net.Dns]::GetHostAddresses($HintUrl) | Out-Null
    
            #Clear the dns cache to force another resolution, easy with powershell 3 but not 2
            Invoke-Expression 'ipconfig /flushdns'

            Start-Sleep -Seconds 30
        }

    $C2Time = Get-Date
    $LogMessage = "At $C2Time, attackers established C2 of compromised machine using $EvilC2. A full investigation is now required."
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 4, this is a notional phase where the script includes local privilege escalation
    $Phase4Time = Get-Date
    $LogMessage = "At $Phase4Time, attackers escalated local privileges to SYSTEM. A enterprise-wide investigation is now required." 
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 5, this is a notional phase where the script includes PTH to admin token
    $Phase5Time = Get-Date
    $LogMessage = "At $Phase5Time, attackers passed the local administrator hash to an administrator's machine. All accounts must be locked and passwords reset during remediation effort." 
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 6, this is a notional phase where the script includes impersonating domain admin token
    $Phase6Time = Get-Date
    $LogMessage = "At $Phase6Time, attackers secure domain administrator rights and steal all user's hashes. A complete domain rebuild will be necessary." 
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 7, this is a notional phase where the script includes targeting of sensitive business data
    $Phase7Time = Get-Date
    $LogMessage = "At $Phase7Time, attackers secure access to the sensitive R&D server and steal IP. The company is now at risk of losing all competitive advantage and profitibility." 
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 8, this is a notional phase where the script includes exfiltration of sensitive business data
    $Phase8Time = Get-Date
    $LogMessage = "At $Phase8Time, attackers exfil the crown jewels and begin hiding tracks." 
    Add-Content -Value $LogMessage -Path $LogFile
    Start-Sleep -Seconds $SecondsWaited

    #Phase 9, notional final phase
    $Phase9Time = Get-Date
    $LogMessage = "At $Phase9Time, this exercise ends. Thankfully this was only an exercise." 
    Add-Content -Value $LogMessage -Path $LogFile
}
