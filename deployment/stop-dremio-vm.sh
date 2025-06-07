#!/bin/bash
# Stop Dremio VM
az vm stop --resource-group dremio-analytics-rg --name dremio-analytics-vm
echo "VM shutdown complete. No further charges will accrue for compute resources."
