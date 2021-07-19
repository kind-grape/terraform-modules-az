# Terraform Modules

This repo contains a set of modules in the [modules folder](modules) for
deploying various resources type on Azure account

This module includes:

* `apim`: deploy an API Management instance
* `compute/linux_virtual_machine`: Deploys a Linux VM, a NIC to attach to the
  server and associate to the backend address pool
* `hub`:
* `management`:
* `network`: Deployes an Azure LB, including frontend IP config, backend pool,
  LB probe/health-check and lb forwarding rule
* `springcloud`: 
* `waf`:
