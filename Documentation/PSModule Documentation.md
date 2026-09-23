# Documentation of PSXelion

## Get-XelionAuthoken
**Current status:** ready for production

**Parameters**
Credentials,
Hostname,
Tennant,
Save

**Summary**
This function will connect to the Xelion tennant. The current function support Xelion accounts with passwords and not SSO accounts(untested).
Credentials for this function should be given by using *$Cred = Get-Credentials* and supplying the variable to the function. 
