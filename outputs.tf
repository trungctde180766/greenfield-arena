output "alb_url" {
  description = "🌐 Truy cập ứng dụng qua URL này (ALB DNS Name)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ssh_command" {
  description = "💻 Lệnh SSH vào máy chủ EC2 (sử dụng private key được tạo tự động)"
  value       = "ssh -i ${var.project_name}-key.pem ubuntu@${aws_instance.k8s_node.public_ip}"
}
