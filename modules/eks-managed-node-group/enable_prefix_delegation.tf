
resource "aws_eks_addon" "vpc-cni" {

  count = var.vpc_cni_enable_prefix_delegation ? 1 : 0
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"

  addon_version            = "v1.11.0-eksbuild.1"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = null

  lifecycle {
    ignore_changes = [
    ]
  }

  tags = var.tags
}

resource "null_resource" "enable_prefix_delegation" {
  count = var.vpc_cni_enable_prefix_delegation ? 1 : 0
  # change trigger to run every time
  # triggers = {
  #   build_number = "${timestamp()}"
  # }

  provisioner "local-exec" {
    command = "pwd"
  }

  provisioner "local-exec" {
    command = "ls -l ."
  }

  provisioner "local-exec" {
    command = "aws eks --region ${var.cluster_region} update-kubeconfig --name ${var.cluster_name}"
  }

  # download kubectl
  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/linux/amd64/kubectl && chmod +x kubectl"
  }

  # # download kubectl
  # provisioner "local-exec" {
  #   command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/darwin/amd64/kubectl && chmod +x kubectl"
  # }


  # run kubectl
  provisioner "local-exec" {
    command = "./kubectl set env daemonset -n kube-system aws-node ENABLE_PREFIX_DELEGATION=true"
  }

  depends_on = [aws_eks_addon.vpc-cni]

}
