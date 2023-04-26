#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⠙⢿⣿⣿⠟⠉⠄⣿⣿⠄⢀⣀⣀⣀⡀⠙⣿
#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⢠⡀⠙⠋⢀⡄⠄⣿⣿⠄⠈⠉⠉⠉⠁⠄⣿
#   ⣧⠄⠙⠻⠿⠛⠁⣠⣿⣿⠄⢸⣿⣦⣴⣿⡇⠄⣿⣿⠄⠘⠛⠛⠛⠛⠄⣼
#   ⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣶⣾⣿⣿⣿⣿⣷⣶⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿
#   ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄


# Relevant Variables to change:
#------------------------------------------------------------------------------------------------------


#-[azureTenant]---------------------------------------
# (String) Azure Tenant ID
# default Value: no value
azureTenant = ""


#-[azureSubscription]---------------------------------------
# (String) Azure Subscription ID
# default Value: no value
azureSubscription = ""


#-[rgAddition]---------------------------------------
# (Number) Ressource Group Name Addition | example: rg-stz-chn-k8s-0 <-- last digit
# default Value: no value
rgAddition = 


#-[MasterCount]--------------------------------------
# (Number) Kubernetes Master Node Count | example: 2 --> 2 Kubernetes Master Nodes will be created
# default Value: 1
#MasterCount = 


#-[WorkerCount]--------------------------------------
# (Number) Kubernetes Worker Node Count | example: 2 --> 2 Kubernetes Worker Nodes will be created
# default Value: no value
WorkerCount = 


#-[vmType]---------------------------------------
# (String) Azure virtual machine resource type | example: Standard_B1s
# default Value: Standard_B2s
#vmType = ""


#-[diskType]---------------------------------------
# (String) Azure virtual machine disk | example: Premium_LRS
# default Value: StandardSSD_LRS
#diskType = ""


# Other Variables to maybe change:
#------------------------------------------------------------------------------------------------------


#-[azregion]---------------------------------------
# (String) default Region to lable Resources in Azure | example: rg-stz-chn-k8s-0 (chn)
# default Value: chn
#azregion = ""


#-[location]---------------------------------------
# (String) default Location for Resources | example: Switzerland North
# default Value: Switzerland North
#location = ""


#-[cShortName]---------------------------------------
# (String) Contraction of Customer- or personal Name | example: rg-stz-chn-k8s-0 (stz)
# default Value: no value
cShortName = ""


#-[servicename]---------------------------------------
# (String) short Description of Service Name | example: rg-stz-chn-k8s-0 (k8s)
# default Value: k8s
#servicename = ""


#-[vmnameMaster]---------------------------------------
# (String) Virtual Machine Kubernetes Master Name | example: k8s-master-0
# default Value: k8s-master-
#vmnameMaster = ""


#-[vmnameWorker]---------------------------------------
# (String) Virtual Machine Kubernetes Node Name | example: k8s-worker-1
# default Value: k8s-worker-
#vmnameWorker = ""