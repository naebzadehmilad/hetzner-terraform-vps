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

variable "root_password" {
  type = string
}


data "hcloud_ssh_key" "ssh_key" {
  fingerprint = "53:70:64:23:e2:08:92:25:97:de:fb:8a:7f:52:27:ac"
}

locals {
  cloud_config = <<EOF
#cloud-config
password: ${var.root_password}
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
  - ssh-keygen -t rsa -b 2048 -f /root/.ssh/my_rsa_key
  - apt update && apt upgrade
  - apt install -y net-tools netcat ansible
  - sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - sudo apt-get update
  - sudo apt-get install docker-ce docker-ce-cli containerd.io -y
  - reboot
EOF
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

resource "hcloud_server" "manage" {
  count = 1
  name        = "manage1"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"


  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.8"
  }
}

resource "hcloud_server" "nginx" {
  count = 2
  name        =  "nginx-${count.index + 1}"
  server_type = "cx11"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"

  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 5}"
  }
}



resource "hcloud_server" "master" {
  count = 3
  name        = "k8sm-${count.index + 1}"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"

  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 10}"
  }
}

resource "hcloud_server" "etcd" {
  count = 2
  name        = "etcd-${count.index + 1}"
  server_type = "cx11"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"

  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 15}"
  }
}



resource "hcloud_server" "worker" {
 count = 4
  name        = "k8sw1-${count.index + 1}"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"

  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 20}"
  }


}



resource "hcloud_server" "percona" {
  count = 3
  name        = "percona-${count.index + 1}"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"
  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 200}"
  }



}

resource "hcloud_server" "gitlab" {
  count = 1
  name        = "gitlab-${count.index + 1}"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"
  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 37}"
  }
}


resource "hcloud_server" "runner" {
  count = 1
  name        = "runner-${count.index + 1}"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"
  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.${count.index + 110}"
  }
}

resource "hcloud_server" "monitoring" {
  name        = "mon-1"
  server_type = "cx21"
  image       = var.image
  location    = var.location
  ssh_keys  = ["${data.hcloud_ssh_key.ssh_key.id}"]
  user_data = "${local.cloud_config}"


  network {
    network_id = hcloud_network.private1.id
    ip         = "192.168.10.120"
  }

}
