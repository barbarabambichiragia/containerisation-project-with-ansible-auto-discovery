
output "PAADEU2_bastion_host" {
  value       = aws_instance.PAADEU2_bastion_host.public_ip
  description = "bastion host ip"
}
output "PAADEU2_dockerserver" {
  value       = aws_instance.PAADEU2_docker_server.private_ip
  description = "Docker server ip"
}

output "Ansible_IP" {
  value = aws_instance.PAADEU2_ansible_node.private_ip
}


output "sonarqube_server" {
  value = aws_instance.PPADEU2_sonarqube_server.private_ip
}

output "PAADEU2_jenkins_server" {
  value       = aws_instance.PPADEU2_jenkins_server.private_ip
  description = "Jenkins server ip"
}
output "Load_Balancer_dns" {
  value = aws_lb.PAADEU2-Jenkins-LB.dns_name
}
output "sonarqube_server_lb" {
  value = aws_lb.PAADEU2-LB.dns_name
}
output "docker_server_lb" {
  value = aws_lb.PAADEU2-Docker-LB.dns_name
}
