# FETCH CLUSTER INFORMATION
data "vsphere_datacenter" "datacenter" {
  name = var.datacenter
}
data "vsphere_compute_cluster" "cluster" {
  count         = var.cluster != null ? 1 : 0
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# FETCH TEMPLATE INFORMATION
data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# FETCH DATASTORE INFORMATION
data "vsphere_datastore" "datastore" {
  count         = var.datastore != null ? 1 : 0
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
data "vsphere_datastore_cluster" "datastore_cluster" {
  count         = var.datastore == null ? 1 : 0
  name          = var.datastore_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# FETCH DATASTORE INFORMATION FOR SUPLEMENTARY STORAGE
data "vsphere_datastore" "datastore_storage" {
  count         = length(var.additionnal_storage)
  name          = var.additionnal_storage[count.index].datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# FETCH RESOURCE INFORMATION
data "vsphere_resource_pool" "resource_pool" {
  count         = var.resource_pool != null ? 1 : 0
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# FETCH vSWITCH PORTGROUP INFORMATION
data "vsphere_network" "network" {
  count         = var.networking.interfaces != null ? length(var.networking.interfaces) : 0
  name          = var.networking.interfaces[count.index].portgroup
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

locals {
  template_disk_count = length(data.vsphere_virtual_machine.template.disks)
}

# UPDATE VMs
resource "vsphere_virtual_machine" "vm" {
  name                      = var.name
  resource_pool_id          = var.resource_pool != null ? data.vsphere_resource_pool.resource_pool[0].id : data.vsphere_compute_cluster.cluster[0].resource_pool_id
  annotation                = var.annotation

  datastore_id              = var.datastore == null ? null : data.vsphere_datastore.datastore[0].id
  datastore_cluster_id      = var.datastore != null ? null : data.vsphere_datastore_cluster.datastore_cluster[0].id

  num_cpus                  = var.num_cpus
  num_cores_per_socket      = var.num_cores_per_socket
  cpu_hot_add_enabled       = var.cpu_hot_add_enabled
  cpu_hot_remove_enabled    = var.cpu_hot_remove_enabled
  memory                    = var.memory
  memory_hot_add_enabled    = var.memory_hot_add_enabled
  
  guest_id                  = data.vsphere_virtual_machine.template.guest_id

  scsi_type                 = var.scsi_type != null ? var.scsi_type : data.vsphere_virtual_machine.template.scsi_type

  dynamic "network_interface" {
    for_each = var.networking.interfaces
    content {
      network_id   = data.vsphere_network.network[network_interface.key].id
      adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }
  }

  // Disks defined in the original template
  disk {
      label            = "disk0"
      size             = var.boot_disk_size != null ? var.boot_disk_size : data.vsphere_virtual_machine.template.disks[0].size
      unit_number      = 0
      thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
      eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
  }

  // Additional disks defined by Terraform config
  dynamic "disk" {
    for_each = var.additionnal_storage
    iterator = terraform_disks
    content {
      label             = var.additionnal_storage[terraform_disks.key].label != null ? var.additionnal_storage[terraform_disks.key].label : "disk${terraform_disks.key + local.template_disk_count}"
      size              = var.additionnal_storage[terraform_disks.key].size
      unit_number       = terraform_disks.key + local.template_disk_count
      datastore_id      = data.vsphere_datastore.datastore_storage[terraform_disks.key].id
      thin_provisioned  = var.additionnal_storage[terraform_disks.key].thin_provisioned != null ? var.additionnal_storage[terraform_disks.key].thin_provisioned : false
      eagerly_scrub     = var.additionnal_storage[terraform_disks.key].eagerly_scrub != null ? var.additionnal_storage[terraform_disks.key].eagerly_scrub : false
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.hostname != null ? var.hostname : var.name
        domain    = var.domain
      }
      
      dynamic "network_interface" {
        for_each = var.networking.interfaces
        content {
          ipv4_address = var.networking.interfaces[network_interface.key].ipv4_address
          ipv4_netmask = var.networking.interfaces[network_interface.key].ipv4_netmask
        }
      }

      ipv4_gateway = var.networking.gateway
      dns_server_list = var.nameservers
    }
  }
}
