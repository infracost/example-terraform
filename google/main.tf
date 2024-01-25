provider "google" {
 region      = "us-central1"
}

resource "google_compute_instance" "my_instance" {
 zone         = "us-central1-a"

 machine_type = "n1-standard-16" # <<<<< Try changing this to n1-standard-32 to compare the costs

 scheduling {
   preemptible = true
 }

  guest_accelerator {
    type = "nvidia-tesla-t4" # <<<<< Try changing this to nvidia-tesla-p4 to compare the costs
    count = 4
  }

  labels = {
    Environment = "production"
    Service = "web-app"
  }
}

resource "google_cloudfunctions_function" "my_function" {
  runtime = "nodejs10"
  available_memory_mb = 512

  labels = {
    Environment = "Prod"
  }
}
