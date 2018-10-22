function Invoke-FRCDriverStationConfig(){
    param(
        [Parameter(Mandatory=$false)][string]$InvokeType = "Install"
    )

    if($InvokeType.ToUpper() -eq "Install".ToUpper()){
        <#
            If the user specified to install the config
        #>
    
    
    
        #Check Firewall
    
        $FirewallEnabled = Get-ItemPropertyValue -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name "EnableFirewall"
    
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
    
    
    
    
    
    
    
        <#
            Check Network Adapters and IP Addresses
            Check that the Ethernet adapters are enabled and up, Disable and Wireless and Blutooth adapters, 
            and check the configuration of the ethernet adapter to make sure we are using a DHCP address from FMS
        #>
        $NetworkAdapters = Get-NetAdapter -Name "*" -Physical
        foreach($NetworkAdapter in $NetworkAdapters){
            if($NetworkAdapter.InterfaceDescription -match "Wireless"){
                $NetworkAdapter | Disable-NetAdapter
            }
        }

        <#
            Check the Driver Station IP Address
            Make sure the driver station has an IP address from FMS
        

        $IPAddresses = Get-NetIPAddress -AddressFamily IPv4
        foreach($IPAddress in $IPAddresses){
            Write-Host $IPAddress.IPAddress

        }
        #>

        <#
            Check Windows 10 Version
            Do this to inform the team that they are using an older version of Windows 10
            and should update after the event so they don't accidently update during the event
        #>
    
    }elseif ($InvokeType.ToUpper() -eq "UnInstall".ToUpper()) {
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

