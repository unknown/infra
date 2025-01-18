data "nomad_plugin" "csi" {
  plugin_id        = "csi.hetzner.cloud"
  wait_for_healthy = true
}

resource "nomad_csi_volume" "postgres_volume" {
  depends_on = [data.nomad_plugin.csi]

  plugin_id    = data.nomad_plugin.csi.plugin_id
  volume_id    = "postgres-vol"
  name         = "postgres-vol"
  namespace    = "default"
  capacity_min = "10G"

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  mount_options {
    fs_type     = "ext4"
    mount_flags = ["discard", "defaults"]
  }
}

resource "nomad_job" "postgres" {
  depends_on = [nomad_csi_volume.postgres_volume]

  jobspec = file("${path.module}/postgres.hcl")
}
