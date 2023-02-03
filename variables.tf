variable "credentials" {
  type = object({
    access_key = string
    secret_key = string
  })

  description = "My AWS credentials"
}