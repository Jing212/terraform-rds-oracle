variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "PJPrefix" { type = string }
variable "EnvType" { type = string }

# 你的电脑公网IP/32（有 VPN 就用 VPN 出口 IP）
variable "my_ip_cidr" { type = string }

# RDS 账号
variable "db_username" {
  type    = string
  default = "adminuser"
}
variable "db_password" {
  type      = string
  sensitive = true
}

# 规格/容量（Oracle 最小常用 db.t3.small）
variable "instance_class" { type = string }
variable "allocated_storage" { type = number } # GiB
