variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  description = "CIDR block for Private Subnet"
}

variable "region" {
  description = "Region in which the bastion host will be launched"
}

variable "availability_zones" {
  description = "AZ in which all the resources will be deployed"
}




#for aws instance type & ami
variable "instance_type" {
  default = "t2.micro"
 }
variable "ami" {
  default = "ami-076e3a557efe1aa9c"
}
variable "webservers" {
  type = list
  default = ["web1", "web2", "web3"]
}

#For Loadbalancer Type and specification
variable "load_balancer_type" {
  default = "application" 
} 

#For Database instance specification
variable "allocated_storage" {
   default = 10
}
variable "engine" {
 default = "postgresql"
 }
variable "instance_class" {
  default = "db.t3.micro"
}
variable "username" {
  default = "admin"
}
variable "password" {
 default = "admin"
}

#Create VPC
