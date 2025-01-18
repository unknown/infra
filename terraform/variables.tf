variable "name" {
  description = "Prefix used to name various infrastructure components. Alphanumeric characters only."
  default     = "nomad"
}

variable "image" {
  description = "The Hetzner image to use for cloud instances."
  default     = "ubuntu-22.04"
}

variable "location" {
  description = "The Hetzner location to deploy to."
}

variable "network_zone" {
  description = "The Hetzner network zone to create a subnet in."
}

variable "server_instance_type" {
  description = "The Hetzner instance type to use for servers."
  default     = "cpx11"
}

variable "client_instance_type" {
  description = "The Hetzner instance type to use for clients."
  default     = "cpx11"
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "client_count" {
  description = "The number of clients to provision."
  default     = "3"
}
