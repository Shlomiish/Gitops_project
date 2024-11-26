variable "region" {
  description = "The region of AWS"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "local_ip" {
  description = "my local IP address to allow SSH access"
  type        = string
  //default     = "213.57.121.34/32" 
  default = "147.235.218.106"
}

variable "azs" {
  description = "The availability zones for the VPC"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ubuntu_ami" {
  description = "The AMI for the instances configuration"
  type        = string

  default = "ami-08eb150f611ca277f"
   
}

variable "key_pair" {
  description = "The key pair to connect from SSH"
  type = string
  default = "keyPair"
}

variable "instance_type" {
  description = "The instance type"
  type = list(string)
  default = ["t3.micro", "t3.medium", "t3.large"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "app_image" {
  description = "Docker image for the app"
  type        = string
  default = "shlomi00212/flask-hello-world:latest"
}