provider "google" {
  region  = "us-central1"
  project = "test"
}

resource "google_compute_instance" "cud_demo" {
  name         = "cud-demo"
  zone         = "us-central1-a"
  machine_type = "n1-standard-32"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 289
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
    tier      = "db-custom-4-15360"
    disk_type = "PD_SSD"
    disk_size = 200

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_storage_bucket" "cud_demo_logs" {
  name     = "cud-demo-logs"
  location = "US"

  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  labels = {
    environment = "production"
    service     = "cud-demo"
  }
}