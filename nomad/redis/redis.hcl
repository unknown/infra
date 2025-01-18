job "redis" {
  type = "service"

  group "redis" {
    network {
      port "redis" {
        to = 6379
      }
    }

    volume "redis-volume" {
      type            = "csi"
      read_only       = false
      source          = "redis-vol"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
      per_alloc       = false
    }

    service {
      name = "redis"
      port = "redis"

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.redis.tls=true",
        "traefik.tcp.routers.redis.tls.certResolver=default",
        "traefik.tcp.routers.redis.entrypoints=redis",
        "traefik.tcp.routers.redis.rule=HostSNI(`redis.internal.example.com`)",
      ]
    }

    task "redis" {
      driver = "docker"

      vault {}

      template {
        data = <<EOH
{{ with secret "secret/data/default" }}
REDIS_PASSWORD={{ .Data.data.REDIS_PASSWORD }}
{{ end }}
EOH
        destination = "${NOMAD_SECRETS_DIR}/redis.env"
        env         = true
      }

      config {
        image      = "redis:7.4-alpine"
        ports      = ["redis"]
        entrypoint = ["redis-server", "--requirepass", "${REDIS_PASSWORD}"]
      }

      volume_mount {
        volume      = "redis-volume"
        destination = "/data"
      }

      resources {
        cpu    = 300
        memory = 256
      }
    }
  }
}
