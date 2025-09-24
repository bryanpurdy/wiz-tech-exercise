resource "aws_key_pair" "bryan" {
  key_name   = "bryan-key"
  public_key = file("~/.ssh/bryan-key.pub")
}

resource "aws_security_group" "mongo_sg" {
  name        = "wiz-mongo-sg"
  description = "Allow SSH from home and Mongo inside VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.92.144.143/32"] # ✅ only your home IP
  }

  ingress {
  description = "MongoDB from home"
  from_port   = 27017
  to_port     = 27017
  protocol    = "tcp"
  cidr_blocks = ["73.92.144.143/32"]
}

  ingress {
    description = "MongoDB from within VPC"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # ✅ only VPC traffic allowed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongo" {
  ami                    = "ami-0c55b159cbfafe1f0" # Ubuntu 18.04 in us-east-2
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.mongo_sg.id]
  key_name               = aws_key_pair.bryan.key_name

  # ✅ This makes AWS give the instance a public IP automatically
  associate_public_ip_address = true

  tags = {
    Name = "wiz-mongo"
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1
              set -xe

              # Update packages
              apt-get update -y

              # Install Docker
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              apt-get install -y docker.io

              systemctl start docker
              systemctl enable docker

              # Run MongoDB in Docker
              docker run -d -p 27017:27017 --name mongo \
                -e MONGO_INITDB_ROOT_USERNAME=admin \
                -e MONGO_INITDB_ROOT_PASSWORD='SuperWeakP@ss!' \
                mongo:4.4
              EOF
}

# ✅ Outputs
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
