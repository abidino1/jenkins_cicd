resource "aws_key_pair" "autodeploy" {
  #key_name   = "new_autodeploy_key"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.autodeploy.key_name
  }
}

user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              EOF

  tags = {
    Name = var.name_tag
  }
