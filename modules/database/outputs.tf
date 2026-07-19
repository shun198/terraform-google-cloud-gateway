output "instance_connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.main.private_ip_address
}

output "database_name" {
  value = google_sql_database.app.name
}

output "database_user" {
  value = google_sql_user.app.name
}

output "db_password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}

output "database_url_secret_id" {
  value = google_secret_manager_secret.database_url.secret_id
}

output "database_url_secret_version" {
  value     = google_secret_manager_secret_version.database_url.name
  sensitive = true
}
