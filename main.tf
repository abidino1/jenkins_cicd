resource "aws_key_pair" "autodeploy" {
  #key_name   = "new_autodeploy_key"  # Set a unique name for your key pair
  public_key = file("/var/jenkins_home/.ssh/id_rsa.pub")
}

resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.autodeploy.key_name

  tags = {
    Name = var.name_tag
  }
}

# New EBS volume configuration
resource "aws_ebs_volume" "extra_volume" {
 availability_zone = "${aws_instance.public_instance.availability_zone}"
 size              = 10  # Size of the volume in GB
 type              = "gp2"  # General Purpose SSD
}

# Attach the new volume to the EC2 instance
resource "aws_volume_attachment" "extra_volume_attachment" {
 device_name = "/dev/sdh"
 volume_id   = "${aws_ebs_volume.extra_volume.id}"
 instance_id = "${aws_instance.public_instance.id}"
}
