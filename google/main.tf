provider "google" {
  region  = "us-central1"
  project = "test"
}

resource "google_compute_instance" "cud_demo" {
  name         = "cud-demo"
  zone         = "us-central1-a"
  machine_type = "n1-standard-16"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  labels = {
    environment = "production"
    service     = "cud-demo"
  }
}

resource "google_sql_database_instance" "cud_demo" {
  name             = "cud-demo-sql"
  database_version = "POSTGRES_15"
  region           = "us-central1"

  settings {
    tier      = "db-custom-2-7680"
    disk_type = "PD_SSD"
    disk_size = 50

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_redis_instance" "cud_demo" {
  name           = "cud-demo-redis"
  tier           = "BASIC"
  memory_size_gb = 2
  region         = "us-central1"
  redis_version  = "REDIS_7_0"
}