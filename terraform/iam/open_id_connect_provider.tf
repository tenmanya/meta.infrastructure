# OIDC is setup to allow GitHub to assume roles in our AWS org.
# For this to work, we have enabled Identiy Center on our account/org by click-ops opt-in:
#
# Cf. https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws#configuring-the-role-and-trust-policy
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"]
}

output "iam-open-id-connect-provider-github" {
  value = aws_iam_openid_connect_provider.github
}

data "aws_iam_policy_document" "oidc-provider-github-assume-role-with-web-idenity" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [resource.aws_iam_openid_connect_provider.github.arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:cloud-nova-crop/*"]
    }
  }
}
