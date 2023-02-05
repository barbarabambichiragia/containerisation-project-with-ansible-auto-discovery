#Create VPC 
resource "aws_vpc" "PAADEU2_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "PAADEU2_vpc"
  }
}

#Create Subnets
resource "aws_subnet" "SnPub1" {
  vpc_id            = aws_vpc.PAADEU2_vpc.id
  cidr_block        = var.SnPub1_cidr
  availability_zone = "eu-west-2b"

  tags = {
    "Name" = "SnPub1"
  }
}

resource "aws_subnet" "SnPri1" {
  vpc_id            = aws_vpc.PAADEU2_vpc.id
  cidr_block        = var.SnPri1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    "Name" = "SnPri1"
  }
}

resource "aws_subnet" "SnPub2" {
  vpc_id            = aws_vpc.PAADEU2_vpc.id
  cidr_block        = var.SnPub2_cidr
  availability_zone = "eu-west-2a"

  tags = {
    "Name" = "SnPub2"
  }
}
resource "aws_subnet" "SnPri2" {
  vpc_id            = aws_vpc.PAADEU2_vpc.id
  cidr_block        = var.SnPri2_cidr
  availability_zone = "eu-west-2b"

  tags = {
  "Name" = "SnPri2" }
}

#Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.PAADEU2_vpc.id
  tags = {
    Name = "igw"
  }
}

# Create Elastic IP
resource "aws_eip" "PAADEU2_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "PAADEU2_eip"
  }
}

#create NAT gateway 
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.PAADEU2_eip.id
  subnet_id     = aws_subnet.SnPub1.id
  tags = {
    Name = "ngw"
  }
}

#Create Public Route Table 
resource "aws_route_table" "PAADEU2_Pub_RT" {
  vpc_id = aws_vpc.PAADEU2_vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "PAADEU2_Pub_RT"
  }
}

#Create Private Route Table 
resource "aws_route_table" "PAADEU2_Prv_RT" {
  vpc_id = aws_vpc.PAADEU2_vpc.id

  route {
    cidr_block     = var.all_cidr
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    "Name" = "PAADEU2_Prv_RT"
  }
}

# Create Route Table Association for Public Subnet1
resource "aws_route_table_association" "SnPub1_association1" {
  subnet_id      = aws_subnet.SnPub1.id
  route_table_id = aws_route_table.PAADEU2_Pub_RT.id
}
# Create Route Table Association for Public Subnet2
resource "aws_route_table_association" "SnPub2_association2" {
  subnet_id      = aws_subnet.SnPub2.id
  route_table_id = aws_route_table.PAADEU2_Pub_RT.id
}
# Create Route Table Association for Private Subnet1
resource "aws_route_table_association" "SnPri1_association3" {
  subnet_id      = aws_subnet.SnPri1.id
  route_table_id = aws_route_table.PAADEU2_Prv_RT.id
}

# Create Route Table Association for Private Subnet2
resource "aws_route_table_association" "SnPri2_association4" {
  subnet_id      = aws_subnet.SnPri2.id
  route_table_id = aws_route_table.PAADEU2_Prv_RT.id
}


#Create security groups for all server

#Security Group for Jenkins, Ansible, and Docker servers (Allows proxy and ssh)
resource "aws_security_group" "jenkins_server_sg" {
  name        = "jenkins_server_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id
  ingress {
    description = "HTTP"
    from_port   = var.port_http
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  ingress {
    description = "jenkins"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "pvt_server_sg"
  }
}

#Security Group for Docker
resource "aws_security_group" "docker_sg" {
  name        = "docker_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id
  ingress {
    description = "HTTP"
    from_port   = var.port_http
    to_port     = var.port_http
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  ingress {
    description = "docker"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "docker_sg"
  }
}

#Security group for ansible servers 
resource "aws_security_group" "ansible_sg" {
  name        = "ansible_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "ansible_sg"
  }
}

#Security group for sonarqube servers
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube_sg"
  description = "Allow sonarqube traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id
  ingress {
    description = "sonarqube"
    from_port   = var.sonarqube_port
    to_port     = var.sonarqube_port
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }

  ingress {
    description = "sonarqube"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    protocol    = "tcp"
    cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
  }
  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "sonarqube_sg"
  }
}
# #Security group for mysql servers
# resource "aws_security_group" "mysql_sg" {
#   name        = "mysql_sg"
#   description = "Allow mysql traffic"
#   vpc_id      = aws_vpc.PAADEU2_vpc.id
#   ingress {
#     description = "Allow ssh traffic"
#     from_port   = var.port_ssh
#     to_port     = var.port_ssh
#     protocol    = "tcp"
#     cidr_blocks = [var.SnPub1_cidr]
#   }
#   ingress {
#     description = "Allow mysql traffic"
#     from_port   = var.mysql_port
#     to_port     = var.mysql_port
#     protocol    = "tcp"
#     cidr_blocks = [var.SnPub1_cidr, var.SnPub2_cidr]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [var.all_cidr]
#   }
#   tags = {
#     Name = "mysql_sg"
#   }
# }

#Security group for Bastion Host servers 
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id

  ingress {
    description = "SSH"
    from_port   = var.port_ssh
    to_port     = var.port_ssh
    cidr_blocks = [var.all_cidr]
    protocol    = "tcp"
  }
  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "bastion_sg"
  }
}

#Security group for Load Balancer 
resource "aws_security_group" "sonarqube_lb_sg" {
  name        = "lb_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id

  ingress {
    description = "sonar"
    from_port   = var.sonarqube_port
    to_port     = var.sonarqube_port
    cidr_blocks = [var.all_cidr]
    protocol    = "tcp"
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [var.all_cidr]
    protocol    = "tcp"
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "sonarqube_lb_sg"
  }
}


# #create database subnet group
# resource "aws_db_subnet_group" "paadeu2_db_sn_group" {
#   name       = "paadeu2_db_sn_group"
#   subnet_ids = [aws_subnet.SnPri1.id, aws_subnet.SnPri2.id]

#   tags = {
#     Name = "paadeu2_db_sn_group"
#   }
# }

# #Create MySQL RDS Instance
# resource "aws_db_instance" "PAADEU2_RDS" {
#   identifier             = "database"
#   storage_type           = "gp2"
#   allocated_storage      = 20
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = var.aws_instance_class
#   port                   = var.mysql_port
#   db_name                = "PAADEU2"
#   username               = var.database_username
#   password               = var.db_passward
#   multi_az               = true
#   parameter_group_name   = "default.mysql8.0"
#   deletion_protection    = false
#   skip_final_snapshot    = true
#   db_subnet_group_name   = aws_db_subnet_group.paadeu2_db_sn_group.id
#   vpc_security_group_ids = [aws_security_group.mysql_sg.id]
# }

#Create TLS Key Pair
resource "tls_private_key" "PAADEU2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "PAADEU2_prv" {
  content  = tls_private_key.PAADEU2_key.private_key_pem
  filename = "PAADEU2_prv"
}


resource "aws_key_pair" "PAADEU2_pub_key" {
  key_name   = "PAADEU2_pub_key"
  public_key = tls_private_key.PAADEU2_key.public_key_openssh
}

#Create Bastion Host Server
resource "aws_instance" "PAADEU2_bastion_host" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.SnPub1.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.PAADEU2_pub_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
sudo hostnamectl set-hostname bastion
cat <<EOT>> /home/ec2-user/PAADEU2_prv
${tls_private_key.PAADEU2_key.private_key_pem}
EOF

  tags = {
    Name = "PAADEU2_bastion_host"
  }
}

data "aws_instance" "Docker_IP_address" {
  filter {
    name   = "tag:Name"
    values = ["PAADEU2_docker_server"]
  }
  depends_on = [
    aws_instance.PAADEU2_docker_server,
  ]
}

#Create Docker Server
resource "aws_instance" "PAADEU2_docker_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  subnet_id              = aws_subnet.SnPri1.id
  key_name               = aws_key_pair.PAADEU2_pub_key.key_name

  user_data = <<-EOF
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo pip3 install docker-py
sudo systemctl start docker
sudo systemctl enable docker
echo "license_key:eu01xx077bfebecb4a23bb2805b13c17cbd8NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/8/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo usermod -aG docker ec2-user
docker pull hello-world
sudo hostnamectl set-hostname Docker

  EOF
  tags = {
    Name = "PAADEU2_docker_server"
  }
}

# Create Ansible Server
resource "aws_instance" "PAADEU2_ansible_node" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.PAADEU2_pub_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.PAADEU2-Ansi-IAM-profile.id
  subnet_id              = aws_subnet.SnPri2.id
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install python3 python3-pip -y
sudo alternatives --set python /usr/bin/python3
sudo yum install ansible -y
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
cd /etc/ansible
sudo yum install unzip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
./aws/install -i /usr/local/aws-cli /usr/local/bin
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
sudo ln -svf /usr/local/bin/aws /usr/bin/aws
sudo chown ec2-user:ec2-user /etc/ansible/hosts
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[docker_host]
${data.aws_instance.Docker_IP_address.private_ip}  ansible_ssh_private_key_file=/etc/ansible/key.pem
EOT
sudo yum install vim -y
touch /etc/ansible/MyPlaybook.yaml /etc/ansible/discovery.sh /etc/ansible/key.pem
echo "${tls_private_key.PAADEU2_key.private_key_pem}" > /etc/ansible/key.pem
echo "${file(var.ansible_playbook_path)}" > /etc/ansible/MyPlaybook.yaml
cat <<EOT> /etc/ansible/discovery.sh
#!/bin/bash
# This script automatically update ansible host inventory

TAG='ASG-test'
AWSBIN='/usr/local/bin/aws'
awsDiscovery() {
	\$AWSBIN ec2 describe-instances --filters Name=tag:aws:autoscaling:groupName,Values=PAADEU2_ASG \
		--query Reservations[*].Instances[*].NetworkInterfaces[*].{PrivateIpAddresses:PrivateIpAddress} > /etc/ansible/ips.list
	}
inventoryUpdate() {
	echo > /etc/ansible/hosts 
  	echo [webservers] > /etc/ansible/hosts
	for instance in `cat /etc/ansible/ips.list`
	do
		ssh-keyscan -H \$instance >> ~/.ssh/known_hosts
echo "
\$instance ansible_user=ec2-user ansible_ssh_private_key_file=/etc/ansible/key.pem
" >> /etc/ansible/hosts
       done
}
instanceUpdate() {
  sleep 30
  ansible-playbook MyPlaybook.yaml 
  sleep 30
}

awsDiscovery
inventoryUpdate
#instanceUpdate
EOT
sudo chmod 755 /etc/ansible/discovery.sh
sudo chmod 400 key.pem
sudo chown -R ec2-user:ec2-user /etc/ansible 
echo "license_key: 984fd9395376105d6273106ec42913a399a2NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/amazonlinux/2/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo hostnamectl set-hostname ansible
  EOF

  tags = {
    Name = "PAADEU2_ansible_node"
  }
}

# Create IAM policy with a policy document to allow Ansible Node perform specific actions on AWS account to discover
# instances created by ASG without escalating the Ansible Node priviledges
data "aws_iam_policy_document" "PAADEU2-Ansi-policydoc" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "autoscaling:Describe*",
      "ec2:DescribeTags*"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "PAADEU2-Ansi-policy" {
  name   = "PAADEU2-policy-aws-cli"
  path   = "/"
  policy = data.aws_iam_policy_document.PAADEU2-Ansi-policydoc.json
}

# Create IAM role with a policy document to allow Ansible Node assume role
data "aws_iam_policy_document" "PAADEU2-Ansi-policydoc-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "PAADEU2-Ansi-role" {
  name               = "PAADEU2-Ansi-aws-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.PAADEU2-Ansi-policydoc-role.json
}

# Attach the IAM policy to the IAM role created
resource "aws_iam_role_policy_attachment" "PAADEU2-policy-role-attach" {
  role       = aws_iam_role.PAADEU2-Ansi-role.name
  policy_arn = aws_iam_policy.PAADEU2-Ansi-policy.arn
}

# Create IAM instance profile to be attached to our Ansible Node
resource "aws_iam_instance_profile" "PAADEU2-Ansi-IAM-profile" {
  name = "PAADEU2-Ansible-Node-profile"
  role = aws_iam_role.PAADEU2-Ansi-role.name
}

# SonarQube Server
resource "aws_instance" "PPADEU2_sonarqube_server" {
  ami                    = var.ami_ubuntu
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.SnPri1.id
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = aws_key_pair.PAADEU2_pub_key.key_name


  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo docker run -itd --name test-container -p 9000:9000 sonarqube
  EOF  

  tags = {
    Name = "PPADEU2_sonarqube_server"
  }
}

# Jenkins Server
resource "aws_instance" "PPADEU2_jenkins_server" {
  ami                    = var.ami_ubuntu
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.SnPri1.id
  vpc_security_group_ids = [aws_security_group.jenkins_server_sg.id]
  key_name               = aws_key_pair.PAADEU2_pub_key.key_name


  user_data = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt-get -y install openjdk-11-jdk
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y 
sudo apt-get install jenkins -y 
EOF  
  tags = {
    Name = "PPADEU2_jenkins_server"
  }
}