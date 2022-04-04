variable "project" {
    type = string
}

variable "enviroment" {
    type = string
}

output "format_value" {
    value = format("%s_%s", var.project, var.enviroment)
}