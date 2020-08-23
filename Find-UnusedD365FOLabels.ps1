<# Find-UnusedD365FOLabels
 # Will find unused labels in a model.  It does look at all label files in the model.
 # 
 # This command requires no setup, just run it on a computer with F&O code.
 #
 ###############################################
 #                Examples
 ###############################################
 #
 ## Import this function
 #. '.\Find unused labels.ps1'
 #
 # Example 1: Get a list of unused labels
 # Find-UnusedD365FOLabels "C:\VC\Dag\DEV1\Main\Metadata\DagExtensions\DagExtensions" | Format-Table -AutoSize
 #
 # Example 2: Save output as CSV
 # $unusedLabels = Find-UnusedD365FOLabels "C:\VC\Dag\DEV1\Main\Metadata\DagExtensions\DagExtensions"
 # $unusedLabels | Format-Table -AutoSize
 # $unusedLabels | Export-Csv -NoTypeInformation -Path "$env:USERPROFILE\Desktop\Unused Labels.csv"
 # Write-Host "Unused label information saved to $env:USERPROFILE\Desktop\Unused Labels.csv"
 # Write-Host "Be careful that you check all branches before removing a label." -ForegroundColor Gray
 #
 # Future Improvement Ideas:
 #   Check SQL XRef database first, because that query will be fast, then validate using files
 #   for anything which wasn't found in the database (as a double check).
 #>
Function Find-UnusedD365FOLabels {
    [cmdletbinding()]
    Param (
        [Parameter(Position=0, ValueFromPipeline=$False, Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $modelFolder
    )

    Process {

        If (-Not (Test-Path -Path $modelFolder)) {
            Write-Error "Model folder does not exist, or you do not have access to it."
        }
        Else {
            $OutputObjects = @()

            # Get the list of files to search
            cd $modelFolder
            $fileList = ls "*.xml" -Recurse
            
            $gcilabelFilesFound = Get-ChildItem -Path $modelFolder -Include "*.txt" -Recurse
            foreach ($gciLabelFile in $gcilabelFilesFound) {

                $labelFile = $gciLabelFile.FullName
                $matchesLabelFileParsed = ($labelFile | Select-String -Pattern 'LabelResources\\([^\\]+)\\([^\\]+)\.\k<1>\.label\.txt$' -AllMatches)
                $languageId = $matchesLabelFileParsed[0].Matches.Groups[1].Value
                $labelPrefix = $matchesLabelFileParsed[0].Matches.Groups[2].Value

                #Write-Host $labelFile
                #Write-Host $languageId
                #Write-Host $labelPrefix

                $matchesLabelIDs = Select-String -LiteralPath $labelFile -Pattern '^(?! )([^\r\n=]+)=([^\r\n]+)' -AllMatches
            
                $iLabel = 0
                $totalNumLabels = $matchesLabelIDs.Matches.Count

                $obj = foreach ($matchLabelId in $matchesLabelIDs) {
                    # Format @LabelFile:LabelID
                    $LabelID = $matchLabelId.Matches.Groups[1].Value
                    $fullLabelID = "@" + $labelPrefix + ":" + $LabelID
                    $labelWasUsed = $false

                    $iLabel = $iLabel + 1
                    Write-Progress -Activity "Reviewing Labels" -Status "Label $fullLabelID" -PercentComplete ($iLabel/$totalNumLabels * 100)

                    foreach ($fileObject in $fileList) {
                        $matches = (Get-Content $fileObject.FullName -ReadCount 0 | Select-String $fullLabelID -AllMatches).Matches

                        if ($matches.Count -ne 0)
                        {
                            $labelWasUsed = $true
                            Break # Don't need to search more files

                            #$fullName = $_.FullName

                            #$file = $_.Name.Substring(0, $_.Name.Length -4)
                            #foreach ($m in $matches) {
                            #    Write-Host "$($m.Groups[1]) " -NoNewline
                            #    Write-Host "$($file)." -NoNewline -ForegroundColor Gray
                            #    Write-Host "$($m.Groups[2]))"
                            #}
                        }
                    }

                    #If ($iLabel -gt 10) { Break }  #for testing

                    [PSCustomObject]@{
                        FullLabelID   = $fullLabelID
                        LabelFile     = $labelPrefix
                        LabelID       = $LabelID
                        LanguageId    = $languageId
                        Used          = $labelWasUsed
                    }
                }
                $OutputObjects += $obj
            }

            $OutputObjects
        }
    }
}
