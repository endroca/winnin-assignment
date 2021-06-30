output "FirstEndPoint" {
  value = aws_api_gateway_deployment.firstEndPointDeploy.invoke_url
}

output "SecondEndPoint" {
  value = aws_api_gateway_deployment.secondEndPointDeploy.invoke_url
}