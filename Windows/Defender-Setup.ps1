Add-MpPreference -ExclusionPath "C:\tools\"
Add-MpPreference -ExclusionPath "C:\payloads\"
$Downloads = Get-ItemPropertyValue 'HKCU:\software\microsoft\windows\currentversion\explorer\shell folders\' -Name '{374DE290-123F-4565-9164-39C4925E467B}'
Add-MpPreference -ExclusionPath $Downloads
Set-MpPreference -MAPSReporting Disabled
Set-MpPreference -SubmitSamplesConsent Never