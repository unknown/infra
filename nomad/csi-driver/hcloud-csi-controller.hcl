job "hcloud-csi-controller" {
  type = "service"

  group "controller" {
    update {
      max_parallel     = 1
      canary           = 1
      min_healthy_time = "10s"
      healthy_deadline = "1m"
      auto_revert      = true
      auto_promote     = true
    }

    task "plugin" {
      driver = "docker"

      vault {}

      config {
        image   = "hetznercloud/hcloud-csi-driver:v2.11.0"
        command = "bin/hcloud-csi-driver-controller"
      }

      env {
        CSI_ENDPOINT   = "unix://csi/csi.sock"
        ENABLE_METRICS = true
      }

      template {
        data        = <<EOH
{{ with secret "secret/data/default/hcloud-csi-controller" }}
HCLOUD_TOKEN={{ .Data.data.HCLOUD_TOKEN }}
{{ end }}
EOH
        destination = "${NOMAD_SECRETS_DIR}/hcloud-token.env"
        env         = true
      }

      csi_plugin {
        id        = "csi.hetzner.cloud"
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
