variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch monitored by CodePipeline"
  type        = string
  default     = "main"
}