# BASE VARIABLES

variable "name" {
  description = "The name of the virtual machine used to deploy the vms"
}

variable "datacenter" {
  description = "Name of the datacenter you want to deploy the VM to"
}

variable "cluster" {
  description = "Name of the cluster you want to deploy the VM to"
}

variable "template" {
  description = "Name of the template available in the vSphere"
}

variable "ssh_user" {
  description = "Username to connect to ssh"
  type        = string
}

variable "ssh_password" {
  description = "Datastore to deploy the VM (With DRS only!)."
   type        = string
}

variable "annotation" {
  description = "A user-provided description of the virtual machine. The default is no annotation."
  default     = "Managed by Terraform. NEVER EDIT THE VM MANUALY!"
}

# RESOURCES VARIABLES

variable "datastore" {
  description = "Datastore to deploy the VM."
  default     = null
}

variable "datastore_cluster" {
  description = "Datastore to deploy the VM (With DRS only!)."
  default     = null
}

variable "resource_pool" {
  description = "Cluster resource pool that VM will be deployed to. you use following to choose default pool in the cluster (esxi1) or (Cluster)/Resources"
  default     = null
}

variable "num_cpus" {
  description = "number of CPU (core per CPU) for the VM"
  type        = number
}

variable "num_cores_per_socket" {
  description = "The number of cores to distribute among the CPUs in this virtual machine. If specified, the value supplied to num_cpus must be evenly divisible by this value."
  type        = number
  default     = 1
}

variable "cpu_hot_add_enabled" {
  description = "Allow CPUs to be added to this virtual machine while it is running."
  type        = bool
  default     = null
}

variable "cpu_hot_remove_enabled" {
  description = "Allow CPUs to be removed to this virtual machine while it is running."
  type        = bool
  default     = null
}

variable "memory" {
  description = "VM RAM size in megabytes"
  type        = number
}

variable "memory_hot_add_enabled" {
  description = "Allow memory to be added to this virtual machine while it is running."
  type        = bool
  default     = true
}

variable "scsi_type" {
  description = "Disk adapter for this virtual machine."
  type        = string
  default     = null
}

# NETWORKING VARIABLES

variable "hostname" {
  description = "default VM hostname for linux guest customization"
  type        = string
  default     = null
}

variable "domain" {
  description = "default VM domain for linux guest customization"
  type        = string
  default     = null
}

variable "nameservers" {
  type    = list(string)
  default = ["1.1.1.1", "1.0.0.1"]
}

variable "networking" {
    description = "Networking configuration for the vm."
    type        = object({
      gateway       = string
      interfaces    = list(object({
          name          = string
          portgroup     = string
          ipv4_address  = string
          ipv4_netmask  = number
      }))
    })
    default     = {
        interfaces  = []
        gateway     = null
    }
}

#  STORAGE VARIBLES
variable "boot_disk_size" {
  description = "Size of the boot disk (> template) - null for same as template."
  type        = number
  default     = null
}

variable "additionnal_storage" {
  description = "Storage data disk settings"
  type        = list(object({
      label             = string
      datastore         = string
      size              = number
      thin_provisioned  = bool
      eagerly_scrub     = bool
  }))
  default = []
}

variable "enable_disk_uuid" {
  description = "Expose the UUIDs of attached virtual disks to the virtual machine, allowing access to them in the guest."
  default     = null
}


# ****************** WIP ****************** 
# ****************** WIP ****************** 
# ****************** WIP ****************** 

#Linux Customization Variables
variable "hw_clock_utc" {
  description = "Tells the operating system that the hardware clock is set to UTC"
  default     = "true"
}
