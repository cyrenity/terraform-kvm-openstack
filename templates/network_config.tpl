ethernets:
%{ for index,interface in interfaces ~}
%{ if ips[index] != "" }
    ${interface}:
        addresses: 
        - ${ips[index]}/24
        dhcp4: false
        gateway4: 10.10.0.1
        match:
            macaddress: ${macs[index]}
        nameservers:
            addresses: 
            - 1.1.1.1
            - 8.8.8.8
        set-name: ${interface}
%{ else }
    ${interface}:
        dhcp4: false
        match:
            macaddress: ${macs[index]}
        set-name: ${interface}
%{ endif }
%{ endfor ~}
version: 2
