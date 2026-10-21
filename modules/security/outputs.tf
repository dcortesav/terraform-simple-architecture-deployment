output "database_security_group_id" {
  description = "ID of the database security group."
  value       = huaweicloud_networking_secgroup.database.id
}

output "ldap_security_group_id" {
  description = "ID of the LDAP security group."
  value       = huaweicloud_networking_secgroup.ldap.id
}
