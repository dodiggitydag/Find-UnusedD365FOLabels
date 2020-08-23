# Find-UnusedD365FOLabels
Finds unused F&amp;O labels by searching the code files themselves.  It does not rely on the cross reference because it may be outdated.

## Usage
```powershell
$unusedLabels = Find-UnusedD365FOLabels "C:\VC\Dag\DEV1\Main\Metadata\DagExtensions\DagExtensions"
$unusedLabels | Format-Table -AutoSize
$unusedLabels | Export-Csv -NoTypeInformation -Path "$env:USERPROFILE\Desktop\Unused Labels.csv"
Write-Host "Unused label information saved to $env:USERPROFILE\Desktop\Unused Labels.csv"
Write-Host "Be careful that you check all branches before removing a label." -ForegroundColor Gray
```

## Contributions are Encouraged
There are several ways to contribute or give thanks:

A. Fork this repository, commit the necessary changes to your forked repository, then issue a pull request.  This will notify me to review the changes, test them, and incorporate them into the main script.

B. Tweet me at [@dodiggitydag](https://twitter.com/dodiggitydag).
