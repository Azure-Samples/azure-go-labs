# Azure Samples Lab for Go

A collection of samples demonstrating how to create cloud-native applications with Go on azure.

## 1. Build and Containerize your Go application


In this lab we will build a sample Go web application locally as a binary. We will then build the Go application using Docker's multi-stage build capabilities using Azure Container Registry Build. 

[Go to lab](1-app-hello-echo) | Duration: 5-10 minutes

## 2. Deploy your Go application to an Azure Virtual Machine Scale Set using Azure CLI, Azure Resource Manager or Terraform

In this lab we will deploy our sample Go web application binary to an Azure Virtual Machine Scale Set with the help of cloud-init, systemd and your choice of Azure CLI, Azure Resource Manager or Terraform.

[Go to lab](2-vmss-cli-arm-tf) | Duration: 10 minutes

## 3. Deploy your Go application to Azure Web Apps, Azure Web Apps for Containers, Azure Container Instances or Azure Kubernetes Service

In this lab we will deploy our Go web application, in a container, to your choice of Azure Web Apps Azure Web Apps for Containers, Azure Container Instances and Azure Kubernetes Service.

[Go to lab](3-web-app-aci-aks) | Duration: 10-15 minutes

## 4. Deploy and try a Go modules proxy from project Athens

In this lab you will try out a Go modules proxy and optionally deploy your own on Azure App Service.

[Go to lab](4-go-modules-proxy) | Duration: 10 or 20 minutes
