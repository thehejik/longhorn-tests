# Query AWS for RHEL AMI
locals {
  aws_ami_rockylinux_arch = var.arch == "amd64" ? "x86_64" : "aarch64"
}

data "aws_ami" "aws_ami_rockylinux" {

  most_recent      = true
  owners           = [var.aws_ami_rockylinux_account_number]

  filter {
    name   = "name"
    values = ["Rocky Linux ${var.distro_version}*"]
  }

  filter {
    name   = "architecture"
    values = ["${local.aws_ami_rockylinux_arch}"]
  }
}


# Generate template file for k3s server on arm64
data "template_file" "provision_arm64_server" {
  template = var.arch == "arm64" ? file("${path.module}/user-data-scripts/provision_arm64_server.sh.tpl") : null
  vars = {
    k3s_cluster_secret = random_password.k3s_cluster_secret.result
    k3s_server_public_ip = aws_eip.lh_aws_eip_controlplane[0].public_ip
    k3s_version =  var.k3s_version
  }
}

# Generate template file for k3s agent on arm64
data "template_file" "provision_arm64_agent" {
  template = var.arch == "arm64" ? file("${path.module}/user-data-scripts/provision_arm64_agent.sh.tpl") : null
  vars = {
    k3s_server_url = "https://${aws_eip.lh_aws_eip_controlplane[0].public_ip}:6443"
    k3s_cluster_secret = random_password.k3s_cluster_secret.result
    k3s_version =  var.k3s_version
  }
}

