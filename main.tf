resource "aws_key_pair" "autodeploy" {
  key_name   = "new_autodeploy_key"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.autodeploy.key_name
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = var.name_tag
  }
}

resource "aws_security_group" "ssh_access" {
 name        = "ssh_access"
 description = "Security group for SSH access"

 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = var.team_member_ips
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}