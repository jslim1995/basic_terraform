terraform {
    cloud {
        organization = "basic-test"

        workspaces {
            name = "cli_test"
        }
    }
}