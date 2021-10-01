# terraform-kvm-openstack
Installing Openstack on KVM infrastructure using Terraform 

### Start bootstrap process using ansible playbook

* Variables are stored in `group_vars/all` file
* Terraform related variables are inside `variable.tf` file
  

```bash
ansible-playbook playbook.yml --ask-become-pass
```


### Cleanup
```bash
ansible-playbook cleanup-playbook.yml --ask-become-pass
```

WORK IN PROGRESS
