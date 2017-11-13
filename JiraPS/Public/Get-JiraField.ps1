﻿function Get-JiraField {
    <#
    .Synopsis
       This function returns information about JIRA fields
    .DESCRIPTION
       This function provides information about JIRA fields, or about one field in particular.  This is a good way to identify a field's ID by its name, or vice versa.

       Typically, this information is only needed when identifying what fields are necessary to create or edit issues. See Get-JiraIssueCreateMetadata for more details.
    .EXAMPLE
       Get-JiraField
       This example returns information about all JIRA fields visible to the current user (or using anonymous access if a JiraPS session has not been defined).
    .EXAMPLE
       Get-JiraField IssueKey
       This example returns information about the IssueKey field.
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       This function outputs the JiraPS.Field object(s) that represent the JIRA field(s).
    .NOTES
       This function requires either the -Credential parameter to be passed or a persistent JIRA session. See New-JiraSession for more details.  If neither are supplied, this function will run with anonymous access to JIRA.
    #>
    [CmdletBinding()]
    param(
        # The Field name or ID to search.
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromRemainingArguments = $true
        )]
        [String[]] $Field,

        # Credentials to use to connect to JIRA.
        # If not specified, this function will use anonymous access.
        [PSCredential] $Credential
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop

        $uri = "$server/rest/api/latest/field"

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        $allFields = ConvertTo-JiraField -InputObject (Invoke-JiraMethod -Method Get -URI $uri -Credential $Credential)
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Field) {
            foreach ($f in $Field) {
                Write-Debug "[Get-JiraField] Processing field [$f]"
                Write-Debug "[Get-JiraField] Searching for field (name=[$f])"
                $thisField = $allFields | Where-Object -FilterScript {$_.Name -eq $f}
                if ($thisField) {
                    Write-Debug "[Get-JiraField] Found results; outputting"
                    Write-Output $thisField
                }
                else {
                    Write-Debug "[Get-JiraField] No results were found for issue type by name. Searching for issue type (id=[$i])"
                    $thisField = $allFields | Where-Object -FilterScript {$_.Id -eq $f}
                    if ($thisField) {
                        Write-Debug "[Get-JiraField] Found results; outputting"
                        Write-Output $thisField
                    }
                    else {
                        Write-Debug "[Get-JiraField] No results were found for issue type by ID. This issue type appears to be unknown."
                        Write-Verbose "Unable to identify Jira field [$f]"
                    }
                }
            }
        }
        else {
            Write-Debug "[Get-JiraField] No Field was supplied. Outputting all fields."
            Write-Output $allFields
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
