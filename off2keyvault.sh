#!/bin/bash
# This will create a powershell script (in child directory ps1/) that will create a keyvault in Azure and populate it with your key value pairs from file.
# Usage: ./off2keyvault.sh mykeyvaluepairs.properties 

subscriptionid="PUT_YOUR_AZURE_SUBSCRIPTION_ID_HERE"
location="eastus2"
keyvaultname="foobar"

mkdir -p ps1
echo "Set-AzContext -Subscription ${subscriptionid}" > ./ps1/${keyvaultname}.ps1
echo "New-AzureRmKeyVault -VaultName ${keyvaultname} -ResourceGroupName ${resourcegroupname} -Location ${location}" >> ./ps1/${keyvaultname}.ps1
echo "" >> ./ps1/${keyvaultname}.ps1

while IFS= read -r line
do
  key="$( cut -d '=' -f 1 <<< "$line" )"
# keyfix converts underscores to dashes in key names. Azure doesn't support naming a key with an underscore. 
  keyfix="${key//\_/-}"
  value="$( cut -d '=' -f 2- <<< $line )"
  echo "$"${key} " = ConvertTo-SecureString -String " ${value} " -AsPlainText -Force" >> ./ps1/${keyvaultname}.ps1
  echo "Set-AzureKeyVaultSecret -VaultName "${keyvaultname}" -Name "${keyfix}" -SecretValue $"${key} >> ./ps1/${keyvaultname}.ps1
  echo "" >> ./ps1/${keyvaultname}.ps1
done < "${1}"

echo; echo "Your powershell script is here: ./ps1/${keyvaultname}.ps1";echo
