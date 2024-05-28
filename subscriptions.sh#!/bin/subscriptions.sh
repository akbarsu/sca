#!/bin/bash

# List of subscriptions
subscriptions=(
    "Dev_Azure_10000_CloudSandbox1"
    "Dev_Azure_10001_CloudSandbox2"
    "Dev_Azure_10002_CloudSandbox3"
    "dev_azure_10004_cloudenablement"
    "dev_azure_10009_vm_management"
    "dev_azure_10020_InfosecDev"
    "Dev_Azure_10023_IGA-DEV"
    "dev_azure_10026_ISODEV2"
    "dev_azure_10050_Database_Integration"
    "dev_azure_10101_dns-cutomapps-dev"
    "dev_azure_10120_itea-dev"
    "dev_azure_10130_itcorp-rpa"
    "dev_azure_10211_TestAutomation"
    "dev_azure_10231_DevOps"
    "dev_azure_10241_dfir"
    "dev_azure_10251_threatsim-ext"
    "dev_azure_10261_ThreatSimulation"
    "dev_azure_10271_DCInsights"
    "dev_azure_10283_dataprotect"
    "dev_azure_20051_CubixxDev"
    "dev_azure_20070_MobilityAppsDev"
    "dev_azure_20080_EDAP_Non-Prod"
    "dev_azure_20090_formularydecisions-dev"
    "dev_azure_20110_lashanalytics"
    "dev_azure_20120_INNO-DEV"
    "dev_azure_20130_cga_dev"
    "dev_azure_20170_zbb-dev"
    "dev_azure_20180_inno"
    "dev_azure_20190_gpo"
    "dev_azure_20190_storageanddata"
    "dev_azure_20200_XCE-DEV"
    "dev_azure_20231_wm-portal-dev"
    "dev_azure_20240_urochart-dev"
    "dev_azure_20341_intelligentauto"
    "dev_azure_20353_microtech"
    "dev_azure_20371_USSCOpEx"
    "dev_azure_20393_ADHGPO"
    "dev_azure_20401_ADHPlatform"
    "dev_azure_20411_ADHHHD"
    "dev_azure_20421_ADHCorePlatform"
    "dev_azure_20431_ADHWC"
    "dev_azure_20442_SiteCoreWebsites"
    "DXO"
    "EAP Non-Production"
    "EAP Production"
    "prd_azure_10003_cloudenablement"
    "prd_azure_10008_vm_management"
    "prd_azure_10021_InfosecDatalakePrd"
    "prd_azure_10025_IGA-PROD"
    "prd_azure_10030_ShareServices1"
    "prd_azure_10031_CorpShareServices"
    "prd_azure_10080_ab-ecm-cmg"
    "prd_azure_10103_dns-cutomapps-prod"
    "prd_azure_10132_itcorp-rpa"
    "prd_azure_10210_TestAutomation"
    "prd_azure_10230_DevOps"
    "prd_azure_10240_dfir"
    "prd_azure_10250_threatsim-ext"
    "prd_azure_10260_ThreatSimulation"
    "prd_azure_10270_DCInsights"
    "prd_azure_10280_dataprotect"
    "prd_azure_20050_CubixxPrd"
    "prd_azure_20052_CubixxCarenetPrd"
    "prd_azure_20060_WCDashPrd"
    "prd_azure_20071_MobilityAppsPrd"
    "prd_azure_20093_formularydecisions-prd"
    "prd_azure_20111_lashanalytics"
    "prd_azure_20122_INNO-PROD"
    "prd_azure_20133_cga_prd"
    "prd_azure_20143_pme-prod"
    "prd_azure_20155_abc-order"
    "prd_azure_20183_inno"
    "prd_azure_20191_storageanddata"
    "prd_azure_20192_gpo"
    "prd_azure_20242_urochart-prod"
    "prd_azure_20320_EDAP"
    "prd_azure_20330_WMSolutions"
    "prd_azure_20340_intelligentauto"
    "prd_azure_20350_microtech"
    "prd_azure_20370_USSCOpEx"
    "prd_azure_20380_AnimalHealthUS"
    "prd_azure_20390_ADHGPO"
    "prd_azure_20400_ADHPlatform"
    "prd_azure_20410_ADHHHD"
    "prd_azure_20420_ADHCorePlatform"
    "prd_azure_20430_ADHWC"
    "prd_azure_20440_SiteCoreWebsites"
    "prd_azure_50000_ahshareservices"
    "Provider Solutions Development"
    "Provider Solutions Sandbox"
    "Provider Solutions Test"
    "PSG Production"
    "PSG Staging"
    "qa_azure_10027_iga-qa"
    "qa_azure_20151_abc-order"
    "qa_azure_20181_inno"
    "qa_azure_20191_gpo"
    "sbx_azure_10090_itcorp-dev"
    "sbx_azure_10100_dns-sbx"
    "sbx_azure_20150_abc-order-dev"
    "sbx_azure_60061_ah-dizgz-dev"
    "sbx_azure_70001_cloudauto"
    "sbx_azure_70009_cloudauto"
    "sbx_azure_70011_cloudauto"
    "sbx_azure_70013_jetstream"
    "sbx_azure_70015_distributionservices"
    "sbx_azure_70017_testingservices"
    "sbx_azure_70018_dataanalytics"
    "sbx_azure_70019_infosec"
    "sbx_azure_70022_itops"
    "stg_azure_10102_dns-cutomapps-stg"
    "stg_azure_10131_itcorp-rpa"
    "stg_azure_10281_dataprotect"
    "stg_azure_20081_EDAP_Non-Prod"
    "stg_azure_20092_formularydecisions-stg"
    "stg_azure_20123_innomar"
    "stg_azure_20142_pme-stg"
    "stg_azure_20154_abc-order"
    "stg_azure_20391_ADHGPO"
    "stg_azure_20441_SiteCoreWebsites"
    "tst_azure_10005_cloudenablement"
    "tst_Azure_10024_IGA-TEST"
    "tst_azure_10140_it-internal-audit"
    "tst_azure_10282_dataprotect"
    "tst_azure_20091_formularydecisions-tst"
    "tst_azure_20121_INNO-TST"
    "tst_azure_20131_cga_tst"
    "tst_azure_20141_pme-qa"
    "tst_azure_20241_urochart-test"
    "tst_azure_20331_WMSolutions"
    "tst_azure_20352_microtech"
    "tst_azure_20381_AnimalHealthUS"
    "tst_azure_20392_ADHGPO"
)

# Path to the core script
core_script="azure_scan.sh"

# Path to Git Bash executable
git_bash_path="C:\\Program Files\\Git\\git-bash.exe"

# Maximum number of concurrent Git Bash instances
max_concurrent_instances=5

# Array to store PIDs of running instances
running_instances=()

# Function to wait for a running instance to complete
wait_for_instance() {
   while [ ${#running_instances[@]} -ge $max_concurrent_instances ]; do
       for pid in "${running_instances[@]}"; do
           if ! ps -p $pid > /dev/null; then
               running_instances=("${running_instances[@]/$pid}")
               break
           fi
       done
       sleep 1
   done
}

# Spawn Git Bash instances for each subscription
for subscription in "${subscriptions[@]}"; do
   wait_for_instance

   echo "Launching script for subscription: $subscription"
   start "" "$git_bash_path" -c "./$core_script $subscription" &
   running_instances+=($!)
   echo "Script launched for subscription: $subscription"
done

# Wait for all running instances to complete
for pid in "${running_instances[@]}"; do
   wait $pid
done

echo "All subscriptions processed. Check the respective output directories for results."
