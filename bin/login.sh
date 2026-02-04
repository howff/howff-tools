#!/bin/bash
# Display menu of hosts and login using password taken from ansible vault.
# Uses one tmux session per host.

# Use the content of this file as the password to decrypt the vault:
export ANSIBLE_VAULT_PASSWORD_FILE=/home/smi/smi_vault_password

# Decrypt the vault and grab the password
# view outputs two lines, second line is vault_ansible_become_password: "blah"
export SSHPASS=$(ansible-vault view src/deploy/inventories/nsh/group_vars/all/vault | sed -n '/password/s/^.*"\(.*\)"/\1/p')

hosts=("nsh-fs02 (for S3)"  "nsh-rc-desktop01"  "nsh-gpu-desktop01"  "nsh-gpu-swarm01"  "smi-webs01 (for SemEHR/RGO container)"  "smi-edris-db01 (for SemEHR/nshdr
 postgres)"  "$(id -un)@smi-data-mgmt01 (to extract)"  "$(id -un)@smi-edris-db01 (for cohort)")
n=0
for hostlabel in "${hosts[@]}"; do
    echo " ${n} = ${hostlabel}"
    n=$((n+1))
done
printf "Enter number : "
read num
hostname=${hosts[$num]%% *}
username=${hosts[$num]%%@*}

# if no username in host then prepend agans-smi otherwise use the logged-in username
if [ "$username" == "${hosts[$num]}" ]; then
    hostname="agans-smi@${hostname}"
fi

# Start a new tmux session or reuse an existing one
# Session name will be username@hostname
if tmux list-sessions | grep "${hostname}: " > /dev/null; then
    tmux attach -t ${hostname}
else
    tmux new -s ${hostname} sshpass -e -v ssh ${hostname}
fi
