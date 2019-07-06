output "webui" {
  value       = "http://${aws_instance.transmission_box.public_ip}:8080/transmission/web/"
  description = "Transmission web interface. NOTE: This address may return nothing for several minutes while provisioning completes."
}
