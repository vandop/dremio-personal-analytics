#!/bin/bash
# check-azure-costs.sh

RESOURCE_GROUP="dremio-analytics-rg"

# Get current month in YYYY-MM format
CURRENT_MONTH=$(date +"%Y-%m")
MONTH_START="${CURRENT_MONTH}-01"
TODAY=$(date +"%Y-%m-%d")

echo "Checking Azure costs for $RESOURCE_GROUP from $MONTH_START to $TODAY..."

# Get cost data
az consumption usage list \
    --start-date $MONTH_START \
    --end-date $TODAY \
    --query "[?contains(instanceId, '$RESOURCE_GROUP')].{Service:consumedService, Cost:pretaxCost, Currency:currency, Date:date}" \
    -o table

# Get total
TOTAL=$(az consumption usage list \
    --start-date $MONTH_START \
    --end-date $TODAY \
    --query "sum([?contains(instanceId, '$RESOURCE_GROUP')].pretaxCost)" \
    -o tsv)

echo ""
echo "Total cost: $TOTAL EUR"
echo "Budget: 100.00 EUR"
echo "Remaining: $(echo "100 - $TOTAL" | bc) EUR"