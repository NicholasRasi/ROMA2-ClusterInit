variable "subscription_id" {
  type        = string
  description = "The azure subscription id"
}

variable "rg_name" {
  type        = string
  description = "The resource group name"
}

variable "rg_location" {
  type        = string
  description = "The resource group location"
}

variable "network_name" {
  type        = string
  description = "The virtual network name"
}

variable "subnet_name" {
  type        = string
  description = "The subnet name"
}

variable "wlg_size" {
  type        = string
  description = "The size of the Workload Generator"
}

variable "wlg_count" {
  type        = number
  description = "The number of Workload Generators"
}

variable "cp_size" {
  type        = string
  description = "The size of the Control Plane"
}

variable "cp_count" {
  type        = number
  description = "The number of Control Planes"
}

variable "cpuw_size" {
  type        = string
  description = "The size of the CPU Worker"
}

variable "cpuw_count" {
  type        = number
  description = "The number of CPU Workers"
}

variable "gpuw_size" {
  type        = string
  description = "The size of the GPU Worker"
}

variable "gpuw_count" {
  type        = number
  description = "The number of GPU Workers"
}