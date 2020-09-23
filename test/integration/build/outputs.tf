output "ssh_public_key" {
  value = aws_key_pair.generated_key.public_key
}

output "ssh_private_key" {
  value = tls_private_key.priv_key
}

output "ssh_private_key_pem" {
  value = tls_private_key.priv_key.private_key_pem
}

output "instance_username" {
  value = aws_cloudformation_stack.exchange2016.parameters.DomainAdminUser
}

output "domain_netbios_name" {
  value = aws_cloudformation_stack.exchange2016.parameters.DomainNetBIOSName
}