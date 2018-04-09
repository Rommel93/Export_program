#Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

variable "amis" {
    description = "AMIs by region"
    default =  "ami-53b7152e" #Linux RHEL
}

variable "instance_type" {
    description = "Instance Type for Servers"
    default =  "t2.micro"
}

variable "port" {
  description = "The port the server will use"
  default = 80
}

variable "protocol" {
  description = "Protocol used"
  default = "HTTP"
}

variable "key" {
  description = "key to access to the servers"
  default = "Linux"
}

variable "dbname" {
  description = "Name for the DB"
  default = "mydb"
}

variable "dbuser" {
  description = "User for the DB"
  default = "dbadmin"
}

variable "dbpass" {
  description = "Pass for the DB"
  default = "123dbpass"
}
