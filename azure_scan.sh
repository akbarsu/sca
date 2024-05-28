#!/bin/bash

# Subscription passed as the first argument
subscription=$1

# Commands to execute
commands=(
    "az network public-ip list --query \"[].{Name:name, IPAddress:ipAddress, DNSSettings:dnsSettings}\" --output json"
    "az network nsg list --query \"[].{Name:name, SecurityRules:securityRules, DefaultSecurityRules:defaultSecurityRules}\" --output json"
    "az network vnet list --query \"[].{Name:name, AddressSpace:addressSpace, Subnets:subnets, DNSSettings:dnsSettings}\" --output json"
    "az network private-endpoint list --query \"[].{Name:name, NetworkInterfaces:networkInterfaces, PrivateLinkServiceConnections:privateLinkServiceConnections}\" --output json"
    "az network nat gateway list --query \"[].{Name:name, PublicIPAddresses:publicIpAddresses, Subnets:subnets}\" --output json"
    "az network lb list --query \"[].{Name:name, FrontendIPConfigurations:frontendIpConfigurations, BackendPools:backendAddressPools, LoadBalancingRules:loadBalancingRules}\" --output json"
    "az network application-gateway list --query \"[].{Name:name, FrontendIPConfigurations:frontendIpConfigurations, BackendPools:backendAddressPools, HTTPSettings:httpSettingsCollection}\" --output json"
    "az network route-table list --query \"[].{Name:name, Routes:routes, Subnets:subnets}\" --output json"
    "az network application-gateway waf-policy list --query \"[].{Name:name, PolicySettings:policySettings, Rules:customRules}\" --output json"
    "az network firewall policy list --query \"[].{Name:name, Rules:ruleCollectionGroups, Settings:threatIntelMode}\" --output json"
    "az network firewall list --query \"[].{Name:name, IPConfigurations:ipConfigurations, Rules:rules}\" --output json"
    "az network vhub list --query \"[].{Name:name, AddressPrefixes:addressPrefixes, RouteTables:routeTables}\" --output json"
    "az network asg list --query \"[].{Name:name, SecurityRules:securityRules}\" --output json"
    "az network bastion list --query \"[].{Name:name, IPConfigurations:ipConfigurations}\" --output json"
    "az network ddos-protection list --query \"[].{Name:name, ProtectionPlanSettings:protectionPlanSettings}\" --output json"
    "az network private-link service list --query \"[].{Name:name, Properties:properties, IPConfigurations:ipConfigurations}\" --output json"
    "az network vwan list --query \"[].{Name:name, Properties:properties, Hubs:hubs}\" --output json"
    "az network service-endpoint policy list --query \"[].{Name:name, Definitions:serviceEndpointPolicyDefinitions}\" --output json"
    "az network express-route gateway list --query \"[].{Name:name, Properties:properties, Connections:connections}\" --output json"
    "az network vpn-site list --query \"[].{Name:name, Properties:properties, IPConfigurations:ipConfigurations}\" --output json"
    "az network public-ip prefix list --query \"[].{Name:name, Properties:properties, IPRanges:ipPrefixes}\" --output json"
    "az network ip-group list --query \"[].{Name:name, Properties:properties, IPAddresses:ipAddresses}\" --output json"
    "az acr list --query \"[].{Name:name, Properties:properties, NetworkRules:networkRules}\" --output json"
    "az aks list --query \"[].{Name:name, Properties:properties, NodePools:nodePools}\" --output json"
    "az cosmosdb list --query \"[].{Name:name, Properties:properties, ConnectionStrings:connectionStrings}\" --output json"
    "az webapp list --query \"[].{Name:name, Properties:properties, Configurations:configurations}\" --output json"
    "az keyvault list --query \"[].{Name:name, Properties:properties, AccessPolicies:accessPolicies}\" --output json"
)

# Mapping of commands to resource types or categories
declare -A command_resource_mapping=(
    ["az network public-ip list"]="network/public-ip"
    ["az network nsg list"]="network/nsg"
    ["az network vnet list"]="network/vnet"
    ["az network private-endpoint list"]="network/private-endpoint"
    ["az network nat gateway list"]="network/nat-gateway"
    ["az network lb list"]="network/lb"
    ["az network application-gateway list"]="network/application-gateway"
    ["az network route-table list"]="network/route-table"
    ["az network application-gateway waf-policy list"]="network/application-gateway-waf-policy"
    ["az network firewall policy list"]="network/firewall-policy"
    ["az network firewall list"]="network/firewall"
    ["az network vhub list"]="network/vhub"
    ["az network asg list"]="network/asg"
    ["az network bastion list"]="network/bastion"
    ["az network ddos-protection list"]="network/ddos-protection"
    ["az network private-link service list"]="network/private-link-service"
    ["az network vwan list"]="network/vwan"
    ["az network service-endpoint policy list"]="network/service-endpoint-policy"
    ["az network express-route gateway list"]="network/express-route-gateway"
    ["az network vpn-site list"]="network/vpn-site"
    ["az network public-ip prefix list"]="network/public-ip-prefix"
    ["az network ip-group list"]="network/ip-group"
    ["az acr list"]="container-registry"
    ["az aks list"]="kubernetes-service"
    ["az cosmosdb list"]="cosmosdb"
    ["az webapp list"]="web-app"
    ["az keyvault list"]="key-vault"
)

resource_group_commands=(
    "az network vnet-gateway list"
    "az network vpn-connection list"
    "az network local-gateway list"
    "az network manager list"
    "az network front-door waf-policy list"
    "az search service list"
)

# Helper function to execute commands with retry logic
execute_command() {
    local cmd=$1
    local resource_type=$2
    local output_dir=$3
    local retries=3
    local delay=5
    local backoff=2

    local output_file="$output_dir/$(echo $cmd | sed -e 's/.*az //' -e 's/ list.*//g' -e 's/ /_/g').json"

    echo "Executing command for $resource_type..." | tee -a "$output_directory/realtime_output.log"
    for ((i=1; i<=retries; i++)); do
        if eval "$cmd" > "$output_file" 2> "${output_file%.json}.log"; then
            echo "Command completed for $resource_type" | tee -a "$output_directory/realtime_output.log"
            break
        else
            error_message=$(<"${output_file%.json}.log")
            if [[ "$error_message" == *"rate limit"* || "$error_message" == *"network error"* ]]; then
                echo "Retryable error detected: $error_message" | tee -a "$output_directory/realtime_output.log"
                sleep $((delay * backoff))
                backoff=$((backoff * 2))
            else
                echo "Non-retryable error detected: $error_message" | tee -a "$output_directory/realtime_output.log"
                break
            fi
        fi
    done
    cat "${output_file%.json}.log" >> "$output_dir/mega_log.log"
}

# Function to fetch and cache resource lists
fetch_resources() {
    local subscription=$1

    az account set --subscription "$subscription" || { echo "Failed to set subscription: $subscription"; return 1; }

    resource_groups=$(az group list --query "[].name" -o tsv) || { echo "Failed to fetch resource groups"; return 1; }
    vm_names=$(az vm list --query "[].name" -o tsv) || { echo "Failed to fetch VM names"; return 1; }
    webapp_names=$(az webapp list --query "[].name" -o tsv) || { echo "Failed to fetch Web App names"; return 1; }
    location=$(az network watcher list --query "[0].location" -o tsv) || { echo "Failed to fetch locations"; return 1; }
}

# Main script execution
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"script_output.log" 2>&1

echo "Script started at $(date +"%Y-%m-%d %H:%M:%S")" | tee -a "$output_directory/realtime_output.log"

output_directory="azure_scan_results_${subscription}_$(date +"%Y%m%d_%H%M%S")"
mkdir -p "$output_directory"

fetch_resources "$subscription"

# Execute each command
echo "Executing commands for global resources..." | tee -a "$output_directory/realtime_output.log"
for cmd in "${commands[@]}"; do
    resource_type=${command_resource_mapping[$cmd]}
    output_dir="$output_directory/$resource_type"
    mkdir -p "$output_dir"
    execute_command "$cmd" "$resource_type" "$output_dir" &
done
wait
echo "Global resource commands completed" | tee -a "$output_directory/realtime_output.log"

# Resource group dependent commands
echo "Executing commands for resource group resources..." | tee -a "$output_directory/realtime_output.log"
for rg in $resource_groups; do
    for cmd in "${resource_group_commands[@]}"; do
        resource_type=${command_resource_mapping[$cmd]}
        output_dir="$output_directory/$resource_type/$rg"
        mkdir -p "$output_dir"
        execute_command "$cmd --resource-group $rg --query \"[].{Name:name, Properties:properties}\" --output json" "$resource_type" "$output_dir" &
    done
done
wait
echo "Resource group commands completed" | tee -a "$output_directory/realtime_output.log"

# VM extension list command
echo "Executing commands for VM extensions..." | tee -a "$output_directory/realtime_output.log"
for vm_name in $vm_names; do
    output_dir="$output_directory/vm-extension/$subscription/$vm_name"
    mkdir -p "$output_dir"
    execute_command "az vm extension list --vm-name $vm_name --query \"[].{Name:name, Properties:properties, Settings:settings}\" --output json" "vm-extension" "$output_dir" &
done
wait
echo "VM extension commands completed" | tee -a "$output_directory/realtime_output.log"

# Web App deployment slot list command
echo "Executing commands for Web App deployment slots..." | tee -a "$output_directory/realtime_output.log"
for webapp_name in $webapp_names; do
    for rg in $resource_groups; do
        output_dir="$output_directory/webapp-deployment-slot/$subscription/$webapp_name/$rg"
        mkdir -p "$output_dir"
        execute_command "az webapp deployment slot list --resource-group $rg --name $webapp_name --query \"[].{Name:name, Properties:properties, Configurations:configurations}\" --output json" "webapp-deployment-slot" "$output_dir" &
    done
done
wait
echo "Web App deployment slot commands completed" | tee -a "$output_directory/realtime_output.log"

# Location dependent command
echo "Executing commands for network watchers..." | tee -a "$output_directory/realtime_output.log"
locations=$(echo "$location" | tr ',' ' ')
for loc in $locations; do
    network_watcher_cmd="az network watcher connection-monitor list --location $loc --query \"[].{Name:name, Properties:properties, Endpoints:endpoints}\" --output json"
    output_dir="$output_directory/network-watcher/$loc"
    mkdir -p "$output_dir"
    execute_command "$network_watcher_cmd" "network-watcher" "$output_dir" &
done
wait
echo "Network watcher commands completed" | tee -a "$output_directory/realtime_output.log"

echo "All commands executed for subscription: $subscription. Check the $output_directory directory for output files, script_output.log for script execution logs, mega_log.log for combined logs, and realtime_output.log for real-time progress updates." | tee -a "$output_directory/realtime_output.log"

echo "Script completed at $(date +"%Y-%m-%d %H:%M:%S")" | tee -a "$output_directory/realtime_output.log"
exec 1>&3 2>&4
