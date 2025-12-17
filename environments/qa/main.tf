module "serverless_stack" {
  source      = "../../modules/lambda"
  environment = "qa"
}
