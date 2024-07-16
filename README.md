# Azure VM Backup Management Script

A PowerShell script to manage Azure VM backups, generate reports, and assign backup policies.

## Prerequisites

- PowerShell 5.1 or later
- Azure PowerShell module
- Azure subscription with appropriate permissions

## Installation

1. Ensure you have PowerShell 5.1 or later installed on your system.
2. Install the Azure PowerShell module by running:
   ```powershell
   Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
3. Download the script file (AzureVMBackupManagement.ps1) to your local machine.

## Usage

1. Open PowerShell as an administrator.
2. Navigate to the directory containing the script.
3. Run the script with your Azure subscription ID as a parameter:
   .\AzureVMBackupManagement.ps1 -subscriptionId "your-subscription-id"

4. The script will prompt you to log in to your Azure account.
5. Once connected, you can choose from the following options:

    <li>Export VM backup report to CSV
    <li>View and assign backup policy to all VMs without backup
    <li>View and assign backup policy to a single VM
    <li>Exit the script



## Features

     <li>Collect Azure VM and Recovery Services Vault information
     <li>Generate VM backup report
     <li>Export VM backup status to CSV
     <li>Assign backup policies to VMs without backup (individually or in bulk)

## Notes

    <li>The script uses the "DefaultPolicy" for backup policy assignments. Ensure this policy exists in your Recovery Services Vault or modify the script to use a different policy.
    <li>The script will disconnect from the Azure account upon exiting.

For more detailed information about the script's functionality, please refer to the comments within the script file.
Copyright g0hst 2022
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
