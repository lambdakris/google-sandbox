terraform {  
  backend "gcs" {
    bucket = "lambdakris-sandbox-prev"
    prefix = "platform"
  }
  required_providers {
    random = {
      source = "hashicorp/random"
      version = ">= 3.6.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 3.0.0"
    }
    google = {
      source = "hashicorp/google"
      version = ">= 5.22.0"
    }
  }
}

provider "random" {}

provider "docker" {}

provider "google" {
  project = var.project
}

resource "google_project_service" "enabled" {
  for_each = toset([
    "cloudresourcemanager",
    "iam",
    "iamcredentials",
    "sts",
    "artifactregistry",
    "run"
  ])
  service = "${each.value}.googleapis.com"
  disable_dependent_services = true
}