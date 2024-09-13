# Output the public IP of the instance
output "endpoint" {
  value = "${aws_instance.my_instance.public_ip}:8080"
}
output "userdata" {
  value = (aws_instance.my_instance.user_data)
  sensitive = true
}