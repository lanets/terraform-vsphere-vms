output "edited_vm" {
  value = vsphere_virtual_machine.vm
}
output "edited_policy" {
  value = vsphere_compute_cluster_vm_anti_affinity_rule.cluster_vm_anti_affinity_rule
}
