resource "aws_key_pair" "autodeploy" {
  key_name   = "new_autodeploy_key"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "ubuntu_instance" {
 ami           = var.ami
 instance_type = var.instance_type
 key_name      = aws_key_pair.autodeploy.key_name

 tags = {
   Name = var.name_tag
 }

 connection {
   type        = "ssh"
   user        = "ubuntu"
   private_key = file(var.private_key_path)
   host        = self.public_ip
 }

 provisioner "remote-exec" {
   inline = [
     "sudo apt-get update",
     "sudo apt-get install -y apache2",
     "sudo systemctl start apache2",
     "sudo systemctl enable apache2"
   ]
 }
}

