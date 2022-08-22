terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}
variable "buckets_info" {
  type =map(object({
    name = string
    location = string 
    storage_class = optional(string)
    project_id =string 
  }))
  
}
locals {
  bucket = defaults(var.buckets_info,{
    storage_class = "STANDARD"
  })
}