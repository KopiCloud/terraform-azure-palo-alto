###########################
## Palo Alto - Variables ##
###########################

variable "palo_alto_public_subnet_ip_fw01" {
  type        = string 
  description = "The Palo Alto public subnet ip address"
}

variable "palo_alto_public_subnet_ip_fw02" {
  type        = string 
  description = "The Palo Alto public subnet ip address"
}

variable "palo_alto_private_subnet_ip_fw01" {
  type        = string 
  description = "The Palo Alto private subnet ip address"
}

variable "palo_alto_private_subnet_ip_fw02" {
  type        = string 
  description = "The Palo Alto private subnet ip address"
}

variable "palo_alto_private_subnet_lb_ip" {
  type        = string 
  description = "The Palo Alto private subnet ip address for the Load Balancer"
}

variable "palo_alto_mgmt_subnet_ip_fw01" {
  type        = string 
  description = "The Palo Alto management subnet ip address"
}

variable "palo_alto_mgmt_subnet_ip_fw02" {
  type        = string 
  description = "The Palo Alto management subnet ip address"
}

variable "palo_alto_ha_subnet_ip_fw01" {
  type        = string 
  description = "The Palo Alto high availability subnet ip address"
}

variable "palo_alto_ha_subnet_ip_fw02" {
  type        = string 
  description = "The Palo Alto high availability subnet ip address"
}

variable "firewall_admin_user" {
  description = "The admin user of the firewall."
  type        = string
  default     = "pafwadm"
}

variable "firewall_admin_password" {
  type        = string
  description = "The password for the admin user of the firewalls"
  default     = "S3cur3Cr3d3nt1@l$"
} 
