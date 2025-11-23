terraform {
  backend "gcs" {
    bucket = "ahmedsayed-cluster"
    prefix = "terraform/state"
  }
}
