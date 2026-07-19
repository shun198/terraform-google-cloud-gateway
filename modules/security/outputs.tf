output "security_policy_id" {
  value = google_compute_security_policy.waf.id
}

output "security_policy_self_link" {
  value = google_compute_security_policy.waf.self_link
}

output "security_policy_name" {
  value = google_compute_security_policy.waf.name
}
