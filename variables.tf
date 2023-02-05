

#VPC CIDR 
variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
}

#Public Subnet 1
variable "SnPub1_cidr" {
  default = "10.0.1.0/24"
}

#Public Subnet 2
variable "SnPub2_cidr" {
  default = "10.0.3.0/24"
}

#Private Subnet 1
variable "SnPri1_cidr" {
  default = "10.0.2.0/24"
}

#Private Subnet 2
variable "SnPri2_cidr" {
  default = "10.0.4.0/24"
}

variable "all_cidr" {
  default     = "0.0.0.0/0"
  description = "this is the cidr block open to the world"

}

#Open Ports for Security Groups
variable "port_ssh" {
  default     = 22
  description = "inbound port allowing for SSH access"
}

variable "port_http" {
  default     = 8085
  description = "port allowing HTTP access"
}

variable "jenkins_port" {
  default     = 8080
  description = "access to port 8080"
}

variable "docker_port" {
  default     = 8080
  description = "access to port 8080"
}
variable "egress" {
  default = 0
}

variable "sonarqube_port" {
  default     = 9000
  description = "allow sonarqube traffic"
}

variable "http_port" {
  default     = 80
  description = "allow sonarqube traffic"
}

variable "mysql_port" {
  default = 3306
}

variable "aws_instance_class" {
  default = "db.t2.medium"
}

variable "database_username" {
  default = "Admin"
}

variable "db_passward" {
  default = "Admin123"
}

variable "ami" {
  default = "ami-035c5dc086849b5de"
}

variable "instance_type" {
  default = "t2.medium"
}

#Ansible Playbook.yaml path
variable "ansible_playbook_path" {
  default = "MyPlaybook.yaml"
}


variable "ami_ubuntu" {
  default = "ami-0fb391cce7a602d1f"
}

# variable "vpc_security_group_ids" {
#     default = ""
# }
# variable "subnet_id1" {
#     default = ""
# }
# variable "asg_node" {
#     default = ""
# }
