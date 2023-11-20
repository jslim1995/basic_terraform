terraform {
  cloud {
    organization = "basic-test"

    workspaces {
      name = "basic_terraform"
    }
  }
}
