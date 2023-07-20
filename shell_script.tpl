#!/bin/bash
## https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
sudo echo "test" | tee test.txt
sudo mkdir /home/ubuntu/${dir_name}