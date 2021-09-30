version: 2
ethernets:
%{ for index,interface in interfaces ~}
%{ if ips[index] != "" }
    ${interface}:
        addresses: 
        - ${ips[index]}/24
        dhcp4: false
        gateway4: 192.168.0.1
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
vlans:
%{ for index,vlan in vlans ~}
    vlan.${vlan}:
        id: ${vlan}
        link: eth0
        addresses: [${vlan_ips[index]}/24]
%{ endfor ~}