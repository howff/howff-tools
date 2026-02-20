#!/bin/bash

# Use -d or -v for debugging
if [ "$1" == "-d" -o "$1" == "-v" ]; then
        debug=1
fi

# Configuration:
hosts=("nsh-fs02 (for S3)"  "nsh-rc-desktop01"  "nsh-gpu-desktop01"  "nsh-gpu-swarm01"  "smi-webs01 (for SemEHR/RGO container)"  "smi-edris-db01 (for SemEHR/nshdr postgres)"  "$(id -un)@smi-data-mgmt01 (to extract)"  "$(id -un)@smi-edris-db01 (for cohort)"  "smi-edris-db01 (for cohort)")

# Use the content of this file as the password to decrypt the vault:
export ANSIBLE_VAULT_PASSWORD_FILE=/home/smi/smi_vault_password

# Decrypt the vault and grab the password
# view outputs two lines, second line is vault_ansible_become_password: "blah"
export SSHPASS=$(ansible-vault view src/deploy/inventories/nsh/group_vars/all/vault | sed -n '/password/s/^.*"\(.*\)"/\1/p')
if [ "$debug" != "" ]; then echo SSHPASS=$SSHPASS; fi

n=0
for hostlabel in "${hosts[@]}"; do
    echo " ${n} = ${hostlabel}"
    n=$((n+1))
done

printf "Enter number : "
read num

hostname=${hosts[$num]%% *}
username=${hosts[$num]%%@*}

# if no username in host then prepend agans-smi
if [ "$username" == "${hosts[$num]}" ]; then
    hostname="agans-smi@${hostname}"
fi

if tmux list-sessions | grep "${hostname}: " > /dev/null; then
    if [ "$debug" != "" ]; then echo tmux attach -t ${hostname}; read enter; fi
    tmux attach -t ${hostname}
else
    if [ "$debug" != "" ]; then echo tmux new -s ${hostname} sshpass -e -v ssh ${hostname}; read enter; fi
    tmux new -s ${hostname} -e SSHPASS=$SSHPASS sshpass -e -v ssh ${hostname}
fi
