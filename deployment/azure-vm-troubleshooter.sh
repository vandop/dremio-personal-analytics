#!/bin/bash

RESOURCE_GROUP="dremio-analytics-rg"
VM_NAME="dremio-analytics-vm"
NSG_NAME="dremio-analytics-vmNSG"
PORTS=(9000 9047 8088 31010 32010 32011 19120)

# 1️⃣ Check if VM is running
echo "Checking VM status..."
VM_STATUS=$(az vm get-instance-view --resource-group $RESOURCE_GROUP --name $VM_NAME --query "instanceView.statuses[?code=='PowerState/running']" --output tsv)
if [ -z "$VM_STATUS" ]; then
    echo "❌ VM is NOT running! Start it with: az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME"
    exit 1
else
    echo "✅ VM is running."
fi

# 2️⃣ Get Public IP Address
VM_IP=$(az vm list-ip-addresses --resource-group $RESOURCE_GROUP --name $VM_NAME --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv)
if [ -z "$VM_IP" ]; then
    echo "❌ No public IP found! Your VM might be using a private network."
    exit 1
else
    echo "✅ VM Public IP: $VM_IP"
fi

# 3️⃣ Check if Ports are Open
for PORT in "${PORTS[@]}"; do
    echo "Checking connectivity to port $PORT..."
    nc -zv $VM_IP $PORT 2>&1 | grep -q "succeeded"
    if [ $? -eq 0 ]; then
        echo "✅ Port $PORT is open."
    else
        echo "❌ Port $PORT is closed or blocked."
    fi
done

# 4️⃣ Check NSG Rules
echo "Checking NSG rules for relevant ports..."
for PORT in "${PORTS[@]}"; do
    RULE_EXISTS=$(az network nsg rule list --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --query "[?destinationPortRange=='$PORT' && access=='Allow']" --output tsv)
    if [ -z "$RULE_EXISTS" ]; then
        echo "❌ No NSG rule found to allow traffic on port $PORT!"
    else
        echo "✅ NSG rule exists for port $PORT."
    fi
done

# 5️⃣ Check if Services are Running on the VM
echo "Checking services on the VM..."
ssh azureuser@$VM_IP << EOF
    echo "Checking MinIO (port 9000)..."
    systemctl is-active minio || echo "❌ MinIO is NOT running!"
    echo "Checking Dremio (port 9047)..."
    systemctl is-active dremio || echo "❌ Dremio is NOT running!"
    echo "Checking Superset (port 8088)..."
    systemctl is-active superset || echo "❌ Superset is NOT running!"
EOF

echo "✅ Troubleshooting complete!"