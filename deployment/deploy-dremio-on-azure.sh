#!/bin/bash
# deploy-dremio-on-azure.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print section header
section() {
    echo -e "\n${YELLOW}===== $1 =====${NC}\n"
}

# Check Azure CLI installation
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI not found. Installing...${NC}"
    brew update && brew install azure-cli
fi

# Login to Azure
section "Logging in to Azure"
az login

# Set variables
RESOURCE_GROUP="dremio-analytics-rg"
LOCATION="westeurope"  # Choose a region close to you
VM_NAME="dremio-analytics-vm"
VM_SIZE="Standard_B2ms"  # Budget-friendly size with 2 vCPUs and 8GB RAM
ADMIN_USERNAME="dremiouser"
EMAIL="vando.miguel@outlook.com"  # Change this

section "Creating Resource Group"
az group create --name $RESOURCE_GROUP --location $LOCATION

section "Creating VM"
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Ubuntu2204 \
    --size $VM_SIZE \
    --admin-username $ADMIN_USERNAME \
    --generate-ssh-keys \
    --public-ip-sku Standard

section "Opening required ports"
az vm open-port \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --port 9000,9001,9047,31010,32010,32011,19120,8088 \
    --priority 100

# Get VM IP
VM_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

section "Setting up Docker and deploying services"
cat > setup-dremio-vm.sh << 'EOF'
#!/bin/bash
# Update and install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git

# Add user to docker group
sudo usermod -aG docker $USER

# Clone the repository
git clone https://github.com/vandop/dremio-personal-analytics.git
cd dremio-personal-analytics

# Start the services (using sudo for now)
sudo docker compose up -d

echo "Setup complete! Dremio services are now running."
EOF

chmod +x setup-dremio-vm.sh
scp setup-dremio-vm.sh $ADMIN_USERNAME@$VM_IP:~/
ssh $ADMIN_USERNAME@$VM_IP "bash ~/setup-dremio-vm.sh"

section "Setting auto-shutdown schedule"
az vm auto-shutdown \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --time 1900 \
    --email $EMAIL

section "Creating start/stop scripts"
# Start script
cat > start-dremio-vm.sh << EOF
#!/bin/bash
# Start Dremio VM
az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME
sleep 20
VM_IP=\$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
echo "VM started! You can access:"
echo "- Dremio: http://\$VM_IP:9047"
echo "- MinIO: http://\$VM_IP:9000 (login: admin/password)"
echo "- Superset: http://\$VM_IP:8088"
echo ""
echo "SSH connection: ssh $ADMIN_USERNAME@\$VM_IP"
EOF

# Stop script
cat > stop-dremio-vm.sh << EOF
#!/bin/bash
# Stop Dremio VM
az vm stop --resource-group $RESOURCE_GROUP --name $VM_NAME
echo "VM shutdown complete. No further charges will accrue for compute resources."
EOF

chmod +x start-dremio-vm.sh stop-dremio-vm.sh

section "Creating budget alert"
START_DATE=$(date -v1d +"%Y-%m-01")
END_DATE=$(date -v1d -v+12m +"%Y-%m-01")

az consumption budget create \
    --budget-name "DremioMonthlyBudget" \
    --category cost \
    --amount 100 \
    --time-grain monthly \
    --start-date $START_DATE \
    --end-date $END_DATE \
    --resource-group-filter $RESOURCE_GROUP \
    --notification \
        notificationEnabled=true \
        thresholdType=Actual \
        threshold=80 \
        contactEmails=$EMAIL

section "Setup Complete!"
echo -e "${GREEN}Dremio Analytics environment has been successfully deployed to Azure!${NC}"
echo ""
echo "VM IP: $VM_IP"
echo "Resource Group: $RESOURCE_GROUP"
echo ""
echo "Access your services at:"
echo "- Dremio: http://$VM_IP:9047"
echo "- MinIO: http://$VM_IP:9000 (login: admin/password)"
echo "- Superset: http://$VM_IP:8088"
echo ""
echo "Use ./start-dremio-vm.sh to start the VM"
echo "Use ./stop-dremio-vm.sh to stop the VM"
echo ""
echo -e "${YELLOW}IMPORTANT: VM will automatically shut down at 19:00 UTC daily${NC}"
echo "Estimated monthly cost (if used 8 hours/day, 20 days/month): €30-45"