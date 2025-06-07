#!/bin/bash
# Start Dremio VM
az vm start --resource-group dremio-analytics-rg --name dremio-analytics-vm
sleep 20
VM_IP=$(az vm show -d -g dremio-analytics-rg -n dremio-analytics-vm --query publicIps -o tsv)
echo "VM started! You can access:"
echo "- Dremio: http://$VM_IP:9047"
echo "- MinIO: http://$VM_IP:9000 (login: admin/password)"
echo "- Superset: http://$VM_IP:8088"
echo ""
echo "SSH connection: ssh dremiouser@$VM_IP"
