provider "aws" {
  region = "ap-south-1"
}

variable "subnet_id" {
  default = "subnet-0ac6935ca0c433c05"
}

resource "aws_security_group" "app_sg" {
  name        = "ec2_sg"
  description = "Allow HTTP and limited SSH traffic to EC2 instance"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_instance" "app" {
  ami                         = "ami-0327f51db613d7bd2"
  instance_type               = "t2.micro"
  key_name                    = "office-key" 
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install python3-pip -y
              pip3 install flask

              cat <<EOL > /home/ec2-user/app.py
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "Hello World this is manikanta, I am showing it to Chakri"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOL

              chown ec2-user:ec2-user /home/ec2-user/app.py
              nohup python3 /home/ec2-user/app.py > /home/ec2-user/nohup.out 2>&1 &
EOF

  tags = {
    Name = "HelloWorldEC2"
  }
}

