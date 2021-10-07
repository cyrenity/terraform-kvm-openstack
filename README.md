# terraform-kvm-openstack
[THIS IS WORK IN PROGRESS]

Installing Openstack on KVM infrastructure using Ansible & Terraform 

This ansible playbook will setup following 
  * Faucet - Openflow controller
  * OVS bridge for the infrastructure
  * Setup KVM instances using Terraform 
  * Deploy OpenStack Services using Kolla-Ansible (NOT YET DONE)

Variables are stored in `group_vars/all` file


### Start bootstrap process 
To initilize the process, issue:

```bash
ansible-playbook playbook.yml --ask-become-pass
```


### Cleanup 
To clean-up, issue:
```bash
ansible-playbook cleanup-playbook.yml --ask-become-pass
```

