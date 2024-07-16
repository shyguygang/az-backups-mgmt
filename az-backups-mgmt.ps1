# Azure VM Backup Management Script
# Copyright g0hst 2022

param
( 
    [parameter(Mandatory=$true)]
    [string] $subscriptionId
)

# Function to connect to Azure and set context
function Connect-AzureEnvironment {
    Connect-AzAccount
    $context = Set-AzContext -SubscriptionId $subscriptionId
    Write-Host "Connected to Azure subscription: $($context.Subscription.Name)" -ForegroundColor Cyan
}

# Function to collect VM and backup vault information
function Get-AzureResources {
    Write-Host "Collecting Azure virtual machine Information" -BackgroundColor DarkBlue
    $script:vms = Get-AzVM

    Write-Host "Collecting all Backup Recovery Vault information" -BackgroundColor DarkBlue
    $script:backupVaults = Get-AzRecoveryServicesVault
}

# Function to generate VM backup report
function Generate-VMBackupReport {
    $script:list = [System.Collections.ArrayList]::new()
    $script:vmBackupReport = [System.Collections.ArrayList]::new()

    foreach ($vm in $vms) {
        $recoveryVaultInfo = Get-AzRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type 'AzureVM'
        
        if ($recoveryVaultInfo.BackedUp -eq $true) {
            Write-Host "$($vm.Name) - BackedUp : Yes" -BackgroundColor DarkGreen
            $vmBackupVault = $backupVaults | Where-Object {$_.ID -eq $recoveryVaultInfo.VaultId}
            $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vmBackupVault.ID -FriendlyName $vm.Name
            $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vmBackupVault.ID
        } else {
            Write-Host "$($vm.Name) - BackedUp : No" -BackgroundColor DarkRed
            [void]$list.Add([PSCustomObject]@{
                VM_Name = $vm.Name
                VM_ResourceGroupName = $vm.ResourceGroupName
            })
            $vmBackupVault = $null
            $container = $null
            $backupItem = $null
        }

        [void]$vmBackupReport.Add([PSCustomObject]@{
            VM_Name = $vm.Name
            VM_Location = $vm.Location
            VM_ResourceGroupName = $vm.ResourceGroupName
            VM_BackedUp = $recoveryVaultInfo.BackedUp
            VM_RecoveryVaultName = $vmBackupVault.Name
            VM_RecoveryVaultPolicy = $backupItem.ProtectionPolicyName
            VM_BackupHealthStatus = $backupItem.HealthStatus
            VM_BackupProtectionStatus = $backupItem.ProtectionStatus
            VM_LastBackupStatus = $backupItem.LastBackupStatus
            VM_LastBackupTime = $backupItem.LastBackupTime
            VM_BackupDeleteState = $backupItem.DeleteState
            VM_BackupLatestRecoveryPoint = $backupItem.LatestRecoveryPoint
            VM_Id = $vm.Id
            RecoveryVault_ResourceGroupName = $vmBackupVault.ResourceGroupName
            RecoveryVault_Location = $vmBackupVault.Location
            RecoveryVault_SubscriptionId = $vmBackupVault.ID
        })
    }
}

# Function to display menu and handle user choices
function Show-Menu {
    do {
        $choices = @(
            "&E - Exit",
            "&1 - Export vmBackupReport to CSV",
            "&2 - View and Assign BU Policy to all VMs",
            "&3 - View and Assign BU Policy to a single VM"
        )
        $choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]
        for ($i = 0; $i -lt $choices.length; $i++) {
            $choicedesc.Add((New-Object System.Management.Automation.Host.ChoiceDescription $choices[$i]))
        }
        [int]$defchoice = 0
        $action = $host.ui.PromptForChoice($title, $prompt, $choices, $defchoice)

        Switch ($action) {
            0 { 
                Write-Output "Exiting script."
                return $false
            }
            1 { Export-VMBackupReport }
            2 { Assign-BackupPolicyToAllVMs }
            3 { Assign-BackupPolicyToSingleVM }
        }

        $repeat = Read-Host "Repeat? (Y/N)"
    } while ($repeat -eq "Y")

    return $false
}

# Function to export VM backup report to CSV
function Export-VMBackupReport {
    $vmBackupReport | Export-Csv -Path .\vmbackupstatus.csv
    Write-Host "Exported to .\vmbackupstatus.csv!" -ForegroundColor Magenta -BackgroundColor Black
}

# Function to assign backup policy to all VMs without backup
function Assign-BackupPolicyToAllVMs {
    $list | Out-String
    if ($list.VM_Name -eq $null) {
        Write-Host "Filtered VM List is empty" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "There are no VMs that need Backup Policy Assigned..." -ForegroundColor Yellow -BackgroundColor Black
    } else {
        Get-AzRecoveryServicesVault -Name $backupVaults.Name[0] | Set-AzRecoveryServicesVaultContext
        $Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
        $Pol
        Write-Host "Assigning Backup Policy to all VMs" -BackgroundColor DarkBlue
        foreach ($vm in $list) {
            $config = Enable-AzRecoveryServicesBackupProtection -Policy $Pol -Name "$($vm.VM_Name)" -ResourceGroupName "$($vm.VM_ResourceGroupName)" | Select-Object -Property "WorkloadName" 
            Write-Host "$($config.WorkloadName) has backup policy $($pol.Name) assigned!" -BackgroundColor DarkGreen
        }
        Write-Host "Done assigning BU Policy to Resources!" -ForegroundColor Yellow -BackgroundColor Black
    }
}

# Function to assign backup policy to a single VM
function Assign-BackupPolicyToSingleVM {
    $list | Out-String
    $name = Read-Host -Prompt "Name of VM to be backed up:"
    $vmFound = $false
    foreach ($vm in $list) {
        if ($name -eq $vm.VM_Name) {
            Get-AzRecoveryServicesVault -Name $backupVaults.Name[0] | Set-AzRecoveryServicesVaultContext
            $Pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
            $Pol
            $config = Enable-AzRecoveryServicesBackupProtection -Policy $Pol -Name "$($vm.VM_Name)" -ResourceGroupName "$($vm.VM_ResourceGroupName)" | Select-Object -Property "WorkloadName"
            Write-Host "$($config.WorkloadName) has backup policy $($pol.Name) assigned!" -BackgroundColor DarkGreen
            $vmFound = $true
            break
        }
    }
    if (-not $vmFound) {
        Write-Host "Entry does not match any Names in Filtered VM List" -ForegroundColor Yellow -BackgroundColor Black
    }
}

# Main script execution
Connect-AzureEnvironment
Get-AzureResources
Generate-VMBackupReport
$continueScript = Show-Menu

if (-not $continueScript) {
    Write-Host "EXITING... " -ForegroundColor Yellow -BackgroundColor Black
    Disconnect-AzAccount > $null
    Write-Host "ACCOUNT HAS BEEN DISCONNECTED" -ForegroundColor Yellow -BackgroundColor Black
}
