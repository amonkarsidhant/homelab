terraform {
  required_version = ">= 1.0"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default    = "development"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default    = "latest"
}

resource "docker_image" "app" {
  name         = "minio.homelabdev.space/homelab/app"
  keep_locally = true
}

resource "docker_container" "app" {
  image = docker_image.app.name
  name  = "homelab-app-${var.environment}"
  
  env = [
    "ENV=${var.app_version}",
    "ENVIRONMENT=${var.environment}"
  ]
  
  ports {
    internal = 8080
    external = 8080
  }
}

output "container_name" {
  value = docker_container.app.name
}

