namespace "default" {
  policy = "deny"

  variables {
    path "nomad/jobs/*" {
      capabilities = ["write"]
    }
  }
}
