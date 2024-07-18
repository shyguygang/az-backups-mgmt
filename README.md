# ✨ Azure VM Backup Management Script ✨

A PowerShell script to manage Azure VM backups, generate reports, and assign backup policies.

## 📋 Prerequisites

Before you begin, ensure you have:

1. PowerShell 5.1 or later installed on your system.
2. Azure PowerShell module.
3. An active Azure subscription with appropriate permissions.

## 🚀 Installation

1. Verify your PowerShell version (5.1 or later).
2. Install the Azure PowerShell module by running:
   ```powershell
   Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
   ```

## 🔧 Usage

1. Open PowerShell as an administrator.
2. Navigate to the directory containing the script.
3. Run the script with your Azure subscription ID as a parameter:
   ```powershell
   .\AzureVMBackupManagement.ps1 -subscriptionId "your-subscription-id"
   ```

Log in to your Azure account when prompted.

Choose from the following options:

1. Export VM backup report to CSV
2. View and assign backup policy to all VMs without backup
3. View and assign backup policy to a single VM
4. Exit the script

## 🌟 Features

1. Collect Azure VM and Recovery Services Vault information
2. Generate VM backup report
3. Export VM backup status to CSV
4. Assign backup policies to VMs without backup (individually or in bulk)

## 📝 Notes

1. The script uses the "DefaultPolicy" for backup policy assignments. Ensure this policy exists in your Recovery Services Vault or modify the script to use a different policy.
2. The script will disconnect from the Azure account upon exiting.
3. For more detailed information about the script's functionality, please refer to the comments within the script file.

## 👤 Author
(c) g0hst 2022

📄 License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.
