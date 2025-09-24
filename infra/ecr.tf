resource "aws_ecr_repository" "tasky" {
  name = "tasky"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "tasky-repo"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.tasky.repository_url
}
