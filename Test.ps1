$NetworkAdapters = Get-NetAdapter -Name "*" -Physical
foreach($NetworkAdapter in $NetworkAdapters){
    if($NetworkAdapter.InterfaceDescription -match "Ethernet"-or $NetworkAdapter.InterfaceDescription -match "Local Area Connection"){
        <#
            Extended network adapter properties
            $NetworkAdapter | Get-NetAdapterAdvancedProperty
        #>
        $NetworkAdapter | Get-NetIPAddress
        
        $IPAddressSplit = (($NetworkAdapter | Get-NetIPAddress -AddressFamily IPv4).IPAddress).split(".")
        $FirstOctet = $IPAddressSplit[0]
        $SecondOctet = $IPAddressSplit[1]
        $ThirdOctet = $IPAddressSplit[2]
        $FourthOctet = $IPAddressSplit[3]
        Write-Host $IPAddressSplit

        Write-Host $FirstOctet
        Write-Host $SecondOctet
        Write-Host $ThirdOctet
        Write-Host $FourthOctet
    }
}