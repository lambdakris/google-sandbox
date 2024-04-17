terraform {
  backend "gcs" {
    bucket = "lambdakris-sandbox-prev"
    prefix = "solutions/hello"
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

variable "project" {
  default = "onyx-silo-419016"
}

variable "region" {
  default = "us-central1"
}

provider "random" {}

provider "docker" {
  registry_auth {
    address = "us-central1-docker.pkg.dev" 
  }
}

provider "google" {
  project = var.project
}

resource "google_artifact_registry_repository" "hello_reg" {
  location = var.region
  repository_id = "hello-reg"
  format = "DOCKER"
}

resource "docker_image" "hello_app" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.hello_reg.repository_id}/hello-app"
  build {
    context = "../app"
  }
}

resource "docker_image" "hello_otel" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.hello_reg.repository_id}/hello-otel"
  build {
    context = "../otel"
  }
}

resource "docker_registry_image" "hello_app" {
  name = docker_image.hello_app.name
}

resource "docker_registry_image" "hello_otel" {
  name = docker_image.hello_otel.name
}

resource "google_cloud_run_v2_service" "hello_app" {
  location = var.region
  name = "hello-app"
  template {
    containers {
      image = docker_registry_image.hello_app.name
      env {
        name = "OTEL_COLLECTOR_ENDPOINT"
        value = "localhost:4317"
      }
    }
    containers {
      image = docker_registry_image.hello_otel.name
      env {
        name = "OTEL_COLLECTOR_ENDPOINT"
        value = "localhost:4317"
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "hello_app" {
  location = var.region
  name = google_cloud_run_v2_service.hello_app.name
  role = "roles/run.invoker"
  member = "user:maker@lambdakris.dev"
}