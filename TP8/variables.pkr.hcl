variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "L'environnement doit être 'dev', 'staging' ou 'production'."
  }
}

variable "git_version" {
  type    = string
  default = "1:2.34.1"
  validation {
    condition     = can(regex("^[0-9]+:[0-9]+\\.[0-9]+\\.[0-9]+$", var.git_version))
    error_message = "Format attendu : 'x:1.2.3' (avec epoch facultatif)."
  }
}
