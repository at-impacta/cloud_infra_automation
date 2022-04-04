variable "planos" {
    type = map
    default = {
        "small" = "1xCPU-1GB"
        "medium" = "1xCPU-2GB"
        "large"
    }
}

output "chaves" {
    value = keys(var.planos)
}