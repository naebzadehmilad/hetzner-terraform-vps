variable "hcloud_token"  {
  type = string
}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.13"
}

provider "hcloud" {
  token = var.hcloud_token
}

variable "network_zone" {
  type = string
}


variable "location" {
  type = string
  default = "nbg1"
}


variable "name" {
  type = string

}

variable "server_type" {
  type = string
  default = "c11"
}

variable "type" {
  type = string
  default = "cloud"
}
variable "image" {
  type = string
  default = "ubuntu-20.04"
}



data "hcloud_ssh_key" "ssh_key" {
  fingerprint = "53:70:64:23:e2:08:92:25:97:de:fb:8a:7f:52:27:ac"
}

resource "hcloud_network" "private1" {
  name     = "private1"
  ip_range = "192.168.10.0/24"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.private1.id
  network_zone = "eu-central"
  ip_range     = "192.168.10.0/24"
}

resource "hcloud_server" "server" {
  name        = var.name
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]

  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.10"
    alias_ips  = [
      "192.168.10.11",
      "192.168.10.12"
    ]
  }
}
