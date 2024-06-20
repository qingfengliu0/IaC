variable "cloudflare_email" {
  description = "Cloudflare email"
  type        = string
  default     = ""
}

variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
}

variable "dns_name" {
  description = "DNS name"
  type        = string
}

variable "dns_value" {
  description = "DNS value"
  type        = string
}