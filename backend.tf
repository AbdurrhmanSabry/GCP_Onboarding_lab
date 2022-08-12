terraform {
  backend "gcs" {
    bucket  = "gcp-terra-state-bucket6"
    prefix  = "terraform/state"
  }
}