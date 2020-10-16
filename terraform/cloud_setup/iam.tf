# Retrieve user
data "aws_iam_user" "main" {
  user_name = var.user_name
}

# Retrieve role
data "aws_iam_role" "main" {
  name = var.role_name
}

# Create EKSAdmin policy
resource "aws_iam_policy" "eks_admin" {
  name        = "EKSAdminPolicy"
  path        = "/"
  description = "EKS Administrator policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": "eks:*",
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "user_attachment" {
  count      = length(var.policies)
  user       = data.aws_iam_user.main.user_name
  policy_arn = element(concat(var.policies,[aws_iam_policy.eks_admin.arn]), count.index)
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  count      = length(var.policies)
  role       = data.aws_iam_role.main.name
  policy_arn = element(concat(var.policies,[aws_iam_policy.eks_admin.arn]), count.index)
}

# IAM User - attach public key
resource "aws_iam_user_ssh_key" "main" {
  username   = data.aws_iam_user.main.user_name
  encoding   = "SSH"
  public_key = var.public_key

  provisioner "local-exec" {
    command = "git remote set-url aws ssh://${self.ssh_public_key_id}@${trimprefix(aws_codecommit_repository.main.clone_url_ssh,"ssh://")}"
  }
  depends_on = [aws_codecommit_repository.main]
}