job "postgres" {
  type = "service"

  group "postgres" {
    network {
      port "postgres" {
        to = 5432
      }
    }

    volume "db-volume" {
      type            = "csi"
      read_only       = false
      source          = "postgres-vol"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = false
    }

    service {
      name = "postgres"
      port = "postgres"

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.postgres.tls=true",
        "traefik.tcp.routers.postgres.tls.certResolver=default",
        "traefik.tcp.routers.postgres.entrypoints=postgres",
        "traefik.tcp.routers.postgres.rule=HostSNI(`postgres.internal.example.com`)",
      ]
    }

    task "postgres" {
      driver = "docker"

      vault {}

      config {
        image = "postgres:17-alpine"
        ports = ["postgres"]
      }

      volume_mount {
        volume      = "db-volume"
        destination = "/var/lib/postgresql/data"
      }

      template {
        data = <<EOH
{{ with secret "secret/data/default"}}
POSTGRES_USER={{ .Data.data.POSTGRES_USER }}
POSTGRES_PASSWORD={{ .Data.data.POSTGRES_PASSWORD }}
{{ end }}
PGDATA=/var/lib/postgresql/data/pgdata
EOH
        destination = "${NOMAD_SECRETS_DIR}/postgres.env"
        env         = true
      }

      resources {
        cpu    = 300
        memory = 256
      }
    }
  }
}
