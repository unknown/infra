terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
    }
  }
}

resource "hcloud_firewall" "server_ingress" {
  name = "${var.name}-server-ingress"

  # SSH
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"

    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  # HTTP
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"

    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  # HTTPS
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"

    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  # Postgres
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "5432"

    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  # Redis
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6379"

    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}

resource "hcloud_network" "hashistack_network" {
  name     = "${var.name}-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "hashistack_subnet" {
  network_id   = hcloud_network.hashistack_network.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = "10.0.2.0/24"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "nomad" {
  name       = "${var.name}-hcloud-key-pair"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "nomad_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "./nomad-hcloud-key-pair.pem"
  file_permission = "0400"
}

resource "hcloud_server" "server" {
  count        = var.server_count
  name         = "${var.name}-server-${count.index}"
  image        = var.image
  location     = var.location
  server_type  = var.server_instance_type
  ssh_keys     = [hcloud_ssh_key.nomad.id]
  depends_on   = [hcloud_network_subnet.hashistack_subnet]
  firewall_ids = [hcloud_firewall.server_ingress.id]

  network {
    network_id = hcloud_network.hashistack_network.id
    ip         = "10.0.2.${10 + (count.index + 1)}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_server" "client" {
  count       = var.client_count
  name        = "${var.name}-client-${count.index}"
  image       = var.image
  location    = var.location
  server_type = var.client_instance_type
  ssh_keys    = [hcloud_ssh_key.nomad.id]
  depends_on  = [hcloud_network_subnet.hashistack_subnet]

  network {
    network_id = hcloud_network.hashistack_network.id
    ip         = "10.0.2.${10 + var.server_count + (count.index + 1)}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl", {
    servers = tomap({
      for server in hcloud_server.server :
      server.name => server.ipv4_address
    })
    clients = tomap({
      for client in hcloud_server.client :
      client.name => client.ipv4_address
    })
  })

  filename = "../ansible/inventory"
}
