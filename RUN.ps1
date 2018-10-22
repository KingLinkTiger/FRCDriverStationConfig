Set-Location (Split-Path $MyInvocation.MyCommand.Path)
Import-Module .\FRCDriverStationConfig.psm1

function Show-Menu{
    param(
        [String]$Title = "FTA/A Driver Station Config Menu"
    )

    Write-Host "========== $Title =========="

    Write-Host "Enter the number corespoinding to the command you want to run."
    Write-Host "1: Standard DS Config"
    Write-Host "2: DS Config & Disable Firewall"
    Write-Host "Q: Quit"
}

do{
    Show-Menu
    $input = Read-Host "Please make a selection."

    switch($input){
        '1'{
            cls
            Invoke-FRCDriverStationConfig -Install
        } '2' {
            cls 
            Invoke-FRCDriverStationConfig -Install -DisableFirewall
        } 'q' {
            return
        }
    }
}until($input -eq 'q')