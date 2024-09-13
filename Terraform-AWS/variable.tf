variable "github_token" {
  description = "GitHub token for accessing the repository"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}
terraform { 
   required_version = ">= 1.3.0"
  cloud { 
    
    organization = "my-organization-mak" 

    workspaces { 
      name = "Oraganization_mak" 
    } 
   
  } 
}