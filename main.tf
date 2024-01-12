resource "aws_key_pair" "autodeploy" {
  #key_name   = "new_autodeploy_key"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.autodeploy.key_name
  
  # # subnet_id              = aws_subnet.my_subnet.id
  # associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = var.name_tag
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    host = self.public_ip
  }

  provisioner "remote-exec" {
   inline = [
     "sudo apt-get update",
     "sudo apt-get install -f -y apache2",
     "sudo systemctl start apache2",
     "sudo systemctl enable apache2",
     "sudo rm /var/www/html/index.html",
     "sudo wget -O /var/www/html/index.html https://github.com/abidino1/jenkins_cicd/raw/dev/index.html"
   ]
 }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "MyVPC"
  }
}

# resource "aws_subnet" "my_subnet" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = var.subnet_cidr
#   availability_zone = var.availability_zone

# tags = {
# Name = "MySubnet"
#   }
#}

resource "aws_security_group" "ssh_access" {
 name        = "ssh_access"
 description = "Security group for SSH access"
 vpc_id = aws_vpc.my_vpc.id

 ingress {
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = var.team_member_ips
 }

 ingress {
   description = "http"
   from_port   = 80
   to_port     = 80
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