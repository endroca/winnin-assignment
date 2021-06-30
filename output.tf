output "FirstEndPoint" {
  value = aws_api_gateway_deployment.firstEndPointDeploy.invoke_url
}