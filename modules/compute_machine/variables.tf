terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}
variable "compute_machines" {
  type = map(object({
    project_id = string
    vpc_name = string
    subnet_name =string
    machine_name = string
    tags = list(string)
    machine_type = string
    boot_disk_size = optional(string)
    os_image = string
    vm_location = string
    sa_email = string
    startup_script = string
    scopes = list(string)
  }))
}


locals {
  vm = defaults(var.compute_machines, {
    boot_disk_size = "20"
    startup_script = "echo  Hello > startup_script.sh" 
  })
}