job "hcloud-csi-node" {
  type = "system"

  group "node" {
    task "plugin" {
      driver = "docker"

      vault {}

      config {
        image      = "hetznercloud/hcloud-csi-driver:v2.11.0"
        command    = "bin/hcloud-csi-driver-node"
        privileged = true
      }

      env {
        CSI_ENDPOINT   = "unix://csi/csi.sock"
        ENABLE_METRICS = true
      }

      template {
        data        = <<EOH
{{ with secret "secret/data/default/hcloud-csi-node" }}
HCLOUD_TOKEN={{ .Data.data.HCLOUD_TOKEN }}
{{ end }}
EOH
        destination = "${NOMAD_SECRETS_DIR}/hcloud-token.env"
        env         = true
      }

      csi_plugin {
        id        = "csi.hetzner.cloud"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
