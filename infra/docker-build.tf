resource "null_resource" "build_and_push_image" {
  depends_on = [aws_ecr_repository.tasky]
  
  triggers = {
    dockerfile_hash = filesha256("${path.module}/../Dockerfile")
    main_go_hash    = filesha256("${path.module}/../main.go")
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Login to ECR
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.tasky.repository_url}
      
      # Build image from parent directory
      cd ${path.module}/..
      docker buildx build --platform linux/amd64 -t tasky:latest .
      
      # Tag and push
      docker tag tasky:latest ${aws_ecr_repository.tasky.repository_url}:latest
      docker push ${aws_ecr_repository.tasky.repository_url}:latest
    EOT
  }
}