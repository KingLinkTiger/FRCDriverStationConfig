<# 
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.

 .Parameter Start
  The first month to display.

 .Parameter End
  The last month to display.

 .Parameter FirstDayOfWeek
  The day of the month on which the week begins.

 .Parameter HighlightDay
  Specific days (numbered) to highlight. Used for date ranges like (25..31).
  Date ranges are specified by the Windows PowerShell range syntax. These dates are
  enclosed in square brackets.

 .Parameter HighlightDate
  Specific days (named) to highlight. These dates are surrounded by asterisks.


 .Example
   # Show a default display of this month.
   Show-Calendar

 .Example
   # Display a date range.
   Show-Calendar -Start "March, 2010" -End "May, 2010"

 .Example
   # Highlight a range of days.
   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"
#>


<#
    Enable-Firewall
    Force disable the Windows Firewall on the System
#>

function Enable-Firewall(){
    Write-Host "Enable-Firewall ran"
    $FirewallEnabled = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name "EnableFirewall").EnableFirewall

    Write-Host "Checking if firewall is currently running."
    if($FirewallEnabled){
        Write-Host "Firewall currently enabled. Doing nothing."
    }else{
         Write-Host "Firewall is not running, enabaling it."
        netsh -c advfirewall set allprofiles state on 2>&1 | Out-Null
        Write-Host "Firewall has been enabled."
    }
}

function Disable-Firewall(){
    <#
        Force disable the network
    #>
    Write-Host "Enable-Firewall ran"
    $FirewallEnabled = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name "EnableFirewall").EnableFirewall
    
    Write-Host "Checking if firewall is currently running."
    if($FirewallEnabled){
        Write-Host "Firewall is running, disabling it."
        netsh -c advfirewall set allprofiles state off 2>&1 | Out-Null
        Write-Host "Firewall has been disabled."
    }else{
        Write-Host "Firewall not enabled. Doing nothing."
    }
}

function Check-IPAddress(){
    param(
        [Parameter(Mandatory=$true)][string]$IPAddress,
        [Parameter(Mandatory=$true)][int]$TeamNumber
    )

    $ValidFRCIP = $false

    #Get-IPAddress

    $IPAddressSplit = ($IPAddress).split(".")
    $FirstOctet = $IPAddressSplit[0]
    $SecondOctet = $IPAddressSplit[1]
    $ThirdOctet = $IPAddressSplit[2]
    $FourthOctet = $IPAddressSplit[3]
    

    Write-Host $FirstOctet
    if($FirstOctet -eq 10){
        Write-Host "First Octet Good!"
        $FirstOctetGood = $true
    }else{
        Write-Host "First Octet BAD!"
    }

    $FirstTeamSet = $TeamNumber.ToString().Substring(0,2)
    $SecondTeamSet = $TeamNumber.ToString().Substring(2,2)
    

    Write-Host $SecondOctet
    if($SecondOctet -eq $FirstTeamSet){
        Write-Host "Second Octet Good!"
        $SecondOctetGood = $true
    }else{
        Write-Host "Second Octet BAD!"
    }

    Write-Host $ThirdOctet
    if($ThirdOctet -eq $SecondTeamSet){
        Write-Host "Third Octet Good!"
        $ThirdOctetGood = $true
    }else{
        Write-Host "Third Octet BAD!"
    }

    Write-Host $FourthOctet
    <#
        Fouth Octet cannot be 1 or 255.
        2 is reserved for RIO
    #>

    if(($FourthOctet -ne 1) -or ($FourthOctet -ne 255) -or ($FourthOctet -ne 2)){
        Write-Host "Fourth Octet Good!"
        $ForthOctetGood = $true
    }else{
        Write-Host "Fourth Octet BAD!"
    }

    if($FirstOctetGood -and $SecondOctetGood -and $ThirdOctetGood -and $ForthOctetGood){
        $ValidFRCIP = $true
    }

    return $ValidFRCIP

}

function Get-IPAddress(){

    $KernalVersion = [System.Environment]::OSVersion.Version

    if($KernalVersion.Major -eq "5"){
        #Windows XP
        Write-Host "Windows XP - Wait What!?"

    }elseif($KernalVersion.Major -eq "6"){
        #Windows 7

        $NetAdapterIPs = (get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -ne $null} | Select-Object $NetAdapterIPs.PSStandardMembers).IPAddress
        foreach($IP in $NetAdapterIPs){
            if($IP -match "."){
                return $IP
            }
        }


        if($KernalVersion.Minor -eq "0"){
            #Windows 7 Base
            Write-Host "Windows 7 Base"
        }elseif($KernalVersion.Minor -eq "1"){
            #Windows 7 SP1
            Write-Host "Windows 7 SP1"
        }   

    }elseif($KernalVersion.Major -eq "8"){
        #Windows 8
        Write-Host "Windows 8"

    }elseif($KernalVersion.Major -eq "10"){
        #Windows 10
        Write-Host "Windows 10"
        $NetworkAdapters = Get-NetAdapter -Name "*" -Physical
        foreach($NetworkAdapter in $NetworkAdapters){
            if($NetworkAdapter.InterfaceDescription -match "Ethernet"-or $NetworkAdapter.InterfaceDescription -match "Local Area Connection"){
            #if($NetworkAdapter.Description -match "Ethernet"-or $NetworkAdapter.Description -match "Local Area Connection"){
                <#
                    Extended network adapter properties
                    $NetworkAdapter | Get-NetAdapterAdvancedProperty
                #>
    
                return ($NetworkAdapter | Get-NetIPAddress).IPAddress
                
                

            }
        }    
    }
}





function Invoke-FRCDriverStationConfig(){
    param(
        [Parameter(ParameterSetName='Install',Mandatory=$true)][switch]$Install,
        [Parameter(ParameterSetName='Uninstall',Mandatory=$true)][switch]$Uninstall,
        [Parameter(Mandatory=$true)][int]$TeamNumber,
        [Parameter(Mandatory=$false)][switch]$DisableFirewall
    )

    if($Install){
        <#
            If the user specified to install the config
        #>
    
        if($DisableFirewall){
            Write-Host "Disable Firewall switch has been set. Disabling the Firewall."
            Disable-Firewall
        }else{
            #Check Firewall
            $FirewallEnabled = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name "EnableFirewall").EnableFirewall
        
            if($FirewallEnabled){

                Write-Host "Windows Firewall is enabled. Checking if correct ports are open."
        
                $FirewallRules = @(
                    "FRC Driver Station (TCP) - Inbound",
                    "FRC Driver Station (TCP) - Outbound",
                    "FRC Driver Station (UDP) - Inbound",
                    "FRC Driver Station (UDP) - Outbound",
                    "FRC Driver Station (UDP) - Outbound Control Data",
                    "FRC Driver Station (UDP) - Inbound Control Data"
                )
        
        
                $RuleMissing = $false
                Foreach($Rule in $FirewallRules){
                    if(-not (Get-NetFirewallRule -DisplayName $Rule)){
                        $RuleMissing = $true
                    }
                }
                
                <#
                    If any rule is missing try to re-create all of the rules.
                    TODO: Implement a one by one check.
                #>
                if($RuleMissing){
                    
                    <#
                        TCP Ports that need to be open
        
                        HTTP(TCP) 80
                        HTTP(TCP) 443
                        TCP 554
                        TCP 1180-1190
                        TCP 1735
                        TCP 5800-5810
                    #>
                    New-NetFirewallRule -DisplayName "FRC Driver Station (TCP) - Inbound" -Protocol TCP -LocalPort 80,443,554,1180-1190,1735,5800-5810 -Direction Inbound -Enabled True
                    New-NetFirewallRule -DisplayName "FRC Driver Station (TCP) - Outbound" -Protocol TCP -LocalPort 80,443,554,1180-1190,1735,5800-5810 -Direction Outbound -Enabled True
                    
                    <#
                        UDP
        
                        UDP 554
                        UDP 1130
                        UDP 1140
                        UDP 1180-1190
                        UDP 5800-5810
                    #>
                    New-NetFirewallRule -DisplayName "FRC Driver Station (UDP) - Inbound" -Protocol TCP -LocalPort 554,1180-1190,5800-5810 -Direction Inbound -Enabled True
                    New-NetFirewallRule -DisplayName "FRC Driver Station (UDP) - Outbound" -Protocol TCP -LocalPort 554,1180-1190,5800-5810 -Direction Outbound -Enabled True
        
                    New-NetFirewallRule -DisplayName "FRC Driver Station (UDP) - Outbound Control Data" -Protocol TCP -LocalPort 1130 -Direction Outbound -Enabled True
                    New-NetFirewallRule -DisplayName "FRC Driver Station (UDP) - Inbound Control Data" -Protocol TCP -LocalPort 1140 -Direction Inbound -Enabled True
                }else{
                    Write-Host "Firewall Rules are present on the system"
                }
        
                <#
                    Check if Firewall Rules are Enabled and enable them if they are not
                #>
        
                Foreach($Rule in $FirewallRules){
                    if(-not (Get-NetFirewallRule -DisplayName $Rule).Enabled){
                        Set-NetFirewallRule -DisplayName $Rule -Enabled True
                    }
                }
        
            }else{
        
                Write-Host "Firewall is not Enabled"
            }
        }
    

    
    
    
    
    
    
    
        <#
            Check Network Adapters and IP Addresses
            Check that the Ethernet adapters are enabled and up, Disable and Wireless and Blutooth adapters, 
            and check the configuration of the ethernet adapter to make sure we are using a DHCP address from FMS
        #>

        
        $NetworkAdapters = Get-NetAdapter -Name "*" -Physical
        foreach($NetworkAdapter in $NetworkAdapters){
            if($NetworkAdapter.InterfaceDescription -match "Wireless"){
                Write-Host "Found Wireless Adapter. Disabling it"
                $NetworkAdapter | Disable-NetAdapter -Confirm:$false
            }
        }

        $BlutoothAdapters = Get-NetAdapter -Name "*" | Where-Object {$_.InterfaceDescription -match "Bluetooth"}
        foreach($BlutoothAdapter in $BlutoothAdapters){
            Write-Host "Found Blutooth Adapter. Disabling it"
            $BlutoothAdapter | Disable-NetAdapter -Confirm:$false
        }
        
        <#
            Check the Driver Station IP Address
            Make sure the driver station has an IP address from FMS
        #>
        $ValidDSIP = Check-IPAddress -IPAddress (Get-IPAddress) -TeamNumber $TeamNumber
        if($ValidDSIP){
            Write-Host "[DS IP] The driver station IP address is valid!"
        }else{
            Write-Host "[DS IP] The driver station IP address is NOT valid!"
        }

        <#
            Check Windows 10 Version
            Do this to inform the team that they are using an older version of Windows 10
            and should update after the event so they don't accidently update during the event
        #>

    
    }elseif ($Uninstall) {
        <#
            If the user specified to uninstall the config
        #>
    
        <#
            Remove ALL firewall rules this script creates
        #>
    
        $FirewallRules = @(
            "FRC Driver Station (TCP) - Inbound",
            "FRC Driver Station (TCP) - Outbound",
            "FRC Driver Station (UDP) - Inbound",
            "FRC Driver Station (UDP) - Outbound",
            "FRC Driver Station (UDP) - Outbound Control Data",
            "FRC Driver Station (UDP) - Inbound Control Data"
        )
    
        Foreach($Rule in $FirewallRules){
            if((Get-NetFirewallRule -DisplayName $Rule)){
                Remove-NetFirewallRule -DisplayName $Rule
            }
        }
        
    }
}

<#
    Export our module Members
#>
Export-ModuleMember -function Enable-Firewall
Export-ModuleMember -function Disable-Firewall
Export-ModuleMember -function Invoke-FRCDriverStationConfig
Export-ModuleMember -function Eject-Drive