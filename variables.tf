# Define variables
variable "vpc_cidr" {
  default = "10.0.0.0/20"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/21"
}

variable "private_subnet_cidr" {
  default = "10.0.8.0/21"
}

variable "all_traffic_cidr" {
  default = "0.0.0.0/0"
}
variable "home_ip" {
  #add ip here
}

variable "ami_windows" {
  default = "ami-0f9c44e98edf38a2b"
}

variable "ami_linux" {
  default = "ami-07d9b9ddc6cd8dd30"
}

variable "instance_type_windows" {
  default = "t2.medium"
}

variable "instance_type_linux" {
  default = "t2.medium"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "key_name" {
  default = "VPC_Test_Windows"
}

variable "expressJS_port" {
  default = 3000
}


