﻿function Get-JiraIssueType {
    <#
    .Synopsis
        Returns information about the available issue type in JIRA.
    .DESCRIPTION
        This function retrieves all the available IssueType on the JIRA server an returns them as JiraPS.IssueType.

        This function can restrict the output to a subset of the available IssueTypes if told so.
    .EXAMPLE
        Get-JiraIssueType
        This example returns all the IssueTypes on the JIRA server.
    .EXAMPLE
        Get-JiraIssueType -IssueType "Bug"
        This example returns only the IssueType "Bug".
    .EXAMPLE
        Get-JiraIssueType -IssueType "Bug","Task","4"
        This example return the information about the IssueType named "Bug" and "Task" and with id "4".
    .INPUTS
        This function accepts Strings via the pipeline.
    .OUTPUTS
        This function outputs the JiraPS.IssueType object retrieved.
    .NOTES
        This function requires either the -Credential parameter to be passed or a persistent JIRA session. See New-JiraSession for more details.  If neither are supplied, this function will run with anonymous access to JIRA.
    #>
    [CmdletBinding()]
    param(
        # The Issue Type name or ID to search.
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromRemainingArguments = $true
        )]
        [String[]] $IssueType,

        # Credentials to use to connect to JIRA.
        # If not specified, this function will use anonymous access.
        [PSCredential] $Credential
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop

        $uri = "$server/rest/api/latest/issuetype"

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        $allIssueTypes = ConvertTo-JiraIssueType -InputObject (Invoke-JiraMethod -Method Get -URI $uri -Credential $Credential)
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($IssueType) {
            foreach ($i in $IssueType) {
                Write-Debug "[Get-JiraIssueType] Processing issue type [$i]"
                Write-Debug "[Get-JiraIssueType] Searching for issue type (name=[$i])"
                $thisIssueType = $allIssueTypes | Where-Object -FilterScript {$_.Name -eq $i}
                if ($thisIssueType) {
                    Write-Debug "[Get-JiraIssueType] Found results; outputting"
                    Write-Output $thisIssueType
                }
                else {
                    Write-Debug "[Get-JiraIssueType] No results were found for issue type by name. Searching for issue type (id=[$i])"
                    $thisIssueType = $allIssueTypes | Where-Object -FilterScript {$_.Id -eq $i}
                    if ($thisIssueType) {
                        Write-Debug "[Get-JiraIssueType] Found results; outputting"
                        Write-Output $thisIssueType
                    }
                    else {
                        Write-Debug "[Get-JiraIssueType] No results were found for issue type by ID. This issue type appears to be unknown."
                        Write-Verbose "Unable to identify Jira issue type [$i]"
                    }
                }
            }
        }
        else {
            Write-Debug "[Get-JiraIssueType] No IssueType was supplied. Outputting all issues."
            Write-Output $allIssueTypes
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
