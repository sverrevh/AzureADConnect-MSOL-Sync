# AzureADConnect-MSOL-Sync

Hacky way to get access to the MSOL-account and Sync-account used by Azure AD Connect to sync changes between on premise AD and Azure AD. For more information about the accounts used see: https://docs.microsoft.com/en-us/azure/active-directory/hybrid/reference-connect-accounts-permissions

This tool builds on https://gist.github.com/xpn/f12b145dba16c2eebdd1c6829267b90c but is also able to extract the Sync account password by writing to disk to bypass the 8000 chars limit for xp_cmd_shell used to execute commands as the ADSync user.

These powershell scripts need to run on the system that has Azure AD Connect installed. This is most of the times a Domain Controller.


