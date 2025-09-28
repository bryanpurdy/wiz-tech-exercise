# Variable for SSH public key
variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

# Get latest Ubuntu 20.04 AMI (1+ year outdated as required)
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role for MongoDB instance with overly permissive permissions (as required)
resource "aws_iam_role" "mongo_role" {
  name = "wiz-mongo-overly-permissive-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Intentionally overly permissive policy (security weakness as required by exercise)
resource "aws_iam_role_policy" "mongo_overly_permissive" {
  name = "wiz-mongo-overly-permissive-policy"
  role = aws_iam_role.mongo_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "iam:*",
          "rds:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "mongo_profile" {
  name = "wiz-mongo-profile"
  role = aws_iam_role.mongo_role.name
}

resource "aws_key_pair" "bryan" {
  key_name   = "bryan-key"
  public_key = var.ssh_public_key
}

resource "aws_security_group" "mongo_sg" {
  name        = "wiz-mongo-sg"
  description = "Allow SSH from public internet and Mongo inside VPC"
  vpc_id      = module.vpc.vpc_id

  # SSH exposed to public internet (security weakness as required)
  ingress {
    description = "SSH from public internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB from VPC only (with authentication required)
  ingress {
    description = "MongoDB from within VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongo" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  key_name               = aws_key_pair.bryan.key_name
  iam_instance_profile   = aws_iam_instance_profile.mongo_profile.name

  associate_public_ip_address = true

  tags = {
    Name = "wiz-mongo"
  }

  user_data = base64encode(templatefile("${path.module}/mongo-setup.sh", {
    s3_bucket = aws_s3_bucket.wiz_bucket.bucket
  }))
}

# Outputs
output "mongo_instance_id" {
  value = aws_instance.mongo.id
}

output "mongo_private_ip" {
  value = aws_instance.mongo.private_ip
}

output "mongo_public_ip" {
  value = aws_instance.mongo.public_ip
}

output "mongo_sg_id" {
  value = aws_security_group.mongo_sg.id
}