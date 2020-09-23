Set-ExecutionPolicy RemoteSigned
# Connect to Exchange Server
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
# 1.2
Set-TransportConfig -MaxReceiveSize 20MB
# 1.3
Set-SenderIDConfig -Enabled $false
# 1.4
 Set-SendConnector ExampleSendConnector -DNSRoutingEnabled $false -SmartHosts exchexample.com
# 1.5
Set-SenderFilterConfig -Enabled $false
# 1.6
Set-SenderReputationConfig -SenderBlockingEnabled $false -OpenProxyDetectionEnabled $true
# 1.8
Set-SendConnector -identity ExampleSendConnector -IgnoreSTARTTLS: $true
# 1.9
Set-PopSettings -LoginType PlainTextLogin
# 1.13
Set-TransportService ExchNodeMain -MessageTrackingLogEnabled $false
# 1.14
Set-TransportService ExchNodeMain -MessageTrackingLogEnabled $false
# 1.15
Set-ImapSettings -LoginType PlainTextLogin
# 1.16
Set-TransportService ExchNodeMain -ConnectivityLogEnabled $false
# 1.17
Set-TransportConfig -MaxSendSize "5MB"
# 2.1
Set-MailboxDatabase "DB1" -IssueWarningQuota "1.7 GB"
# 2.3
Set-MailboxDatabase "DB1" -ProhibitSendQuota "1.95 GB"
# 2.4
Set-Mailboxdatabase "DB1" -MailboxRetention 20.00:00:00
# 2.8
Set-MobileDeviceMailboxPolicy default -PasswordExpiration 180
# 2.9
Set-MobileDeviceMailboxPolicy default -MinPasswordLength 2
# 2.13
Set-UMMailboxPolicy -id ExampleUMMailboxPolicy -AllowPinlessVoiceMailAccess $true
# 2.14
Set-MailboxDatabase -Identity DB1 -DeletedItemRetention 21
# 2.18
Set-MobileDeviceMailboxPolicy -Identity Default -AlphanumericPasswordRequired $false
# 2.19
Set-RpcClientAccess -Server ExchNodeMain -EncryptionRequired $false
# 3.1
Set-AdminAuditLogConfig -AdminAuditLogCmdlets "None"
# 3.3
Set-ExecutionPolicy Unrestricted
# 3.4
Set-AdminAuditLogConfig -AdminAuditLogEnabled $False
# 3.5
Set-RemoteDomain -Identity Default -AutoReplyEnabled $true
# 3.9
Set-RemoteDomain -Identity Default -AutoForwardEnabled $true
# 3.10
Set-OWAVirtualDirectory -identity "owa (Default Web Site)" -SMimeEnabled $false
# 3.11
Set-AdminAuditLogConfig -AdminAuditLogEnabled $false