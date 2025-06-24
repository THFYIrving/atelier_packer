variable "image_name" {
  type    = string
  default = "ubuntu:focal"
}

variable "file_content" {
  type    = string
  default = "This is an example file."
}

variable "tags" {
  type    = list(string)
  default = ["latest", "v1.0"]
}
