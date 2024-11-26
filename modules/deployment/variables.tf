variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "app_image" {
  description = "Docker image for the weather app"
  type        = string
}

variable "cluster_auth_token" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority" {
  type = string
}


