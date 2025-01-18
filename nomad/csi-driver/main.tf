variable "hcloud_token" {
  type = string
}

resource "vault_kv_secret_v2" "controller_hcloud_token" {
  mount = "secret"
  name  = "default/hcloud-csi-controller"

  data_json = jsonencode({
    HCLOUD_TOKEN = var.hcloud_token
  })
}

resource "vault_kv_secret_v2" "node_hcloud_token" {
  mount = "secret"
  name  = "default/hcloud-csi-node"

  data_json = jsonencode({
    HCLOUD_TOKEN = var.hcloud_token
  })
}

resource "nomad_job" "csi_controller" {
  jobspec = file("${path.module}/hcloud-csi-controller.hcl")
}

resource "nomad_job" "csi_node" {
  jobspec = file("${path.module}/hcloud-csi-node.hcl")
}
