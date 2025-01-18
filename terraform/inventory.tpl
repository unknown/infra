[all:vars]
ansible_user=root

[servers]
%{ for name, ip in servers ~}
${name} ansible_host=${ip}
%{ endfor ~}

[clients]
%{ for name, ip in clients ~}
${name} ansible_host=${ip}
%{ endfor ~}
