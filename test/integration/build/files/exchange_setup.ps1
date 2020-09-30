Set-ExecutionPolicy RemoteSigned

Write-Host "Install Chef Client for remediation"
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;

New-SendConnector -Internet -Name ExampleSendConnector -AddressSpaces exchexample.com;

New-ReceiveConnector -Name ExampleReceiveConnector -Usage Custom -Bindings 10.0.0.0:16 -RemoteIPRanges 192.168.0.1-192.168.0.24;

New-UMDialPlan -Name ExampleUMDialPlan -NumberOfDigitsInExtension 4 -CountryOrRegionCode 44;

New-UMMailboxPolicy -Name ExampleUMMailboxPolicy -UMDialPlan ExampleUMDialPlan;