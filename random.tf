resource "random_bytes" "Random_byte" {
  length = 2
}

resource "random_id" "Random_id" {
  byte_length = 8
}

resource "random_integer" "Random_integer" {
  min = 1
  max = 50000
}

resource "random_password" "Random_password" {
  length           = 16
  special          = true
}

resource "random_pet" "Random_pet" {
  count = 5
  length = 1
}

resource "random_shuffle" "Random_shuffle" {
  input        = ["us-west-1a", "us-west-1c", "us-west-1d", "us-west-1e"]
  result_count = 1
}

resource "random_string" "Random_string" {
  length           = 16
  special          = true
}

resource "random_uuid" "test" {
    
}