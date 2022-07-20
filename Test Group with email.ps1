# Get parameter values
$ErrorActionPreference = 'SilentlyContinue'
$groupTypes = $Context.GetParameterValue("param-GroupTypes")
$memberTypes = $Context.GetParameterValue("param-MemberTypes")
$membersPropertyName = $Context.GetParameterValue("param-IndirectMembers")

# Custom column identifiers
$groupColumnID = "{25a8b49d-7864-41b8-aa4c-26e1d17eaa34}"

# IDs of primary groups to exclude from the report
$primaryGroupIDs = @{ 513="Domain Users"; 515="Domain Computers"; 516="Domain Controllers"; 521="RODCs" }

# Search filter
$filter = "(|" + $groupTypes + ")"
$Context.DirectorySearcher.AppendFilter($filter)
$filterMembers = "(|" + $memberTypes + ")"

# Add properties necessary to generate the report
$propertiesForMembers = $Context.DirectorySearcher.GetPropertiesToLoad()
$propertiesForGroups = @("objectClass", "objectGuid", "distinguishedName", "primaryGroupToken")
$Context.DirectorySearcher.SetPropertiesToLoad($propertiesForGroups)

# Create a hash table to map member GUIDs to search results
$guidComparer = $Context.CreatePropertyValueComparer("objectGuid")
$memberGuidToSearchResult = New-Object System.Collections.Hashtable @($guidComparer)

# Generate report
try
{
    $searchIterator = $Context.DirectorySearcher.ExecuteSearch()
    while ($Context.MoveNext($searchIterator))
    {
        $searchResult = $searchIterator.Current
        
        # Exclude well-known primary groups
        $primaryGroupID = $searchResult.GetPropertyByName("primaryGroupToken").Values[0]
        if ($primaryGroupIDs.Contains($primaryGroupID))
        {
            continue
        }
        $groupmail = $searchResult.GetPropertyByName("mail").values[0] -
        if ($groupmail.count -eq 0){
            continue
        }
        $groupDN = $searchResult.GetPropertyByName("distinguishedName").Values[0]
        
        # Get GUIDs of the group members
        $group = $Context.BindToObjectBySearchResult($searchResult)
        try
        {
            $memberGuids = $group.GetEx($membersPropertyName)
        }
        catch  [System.Runtime.InteropServices.COMException]
        {
            if ($_.Exception.ErrorCode -eq 0x8000500D) # E_ADS_PROPERTY_NOT_FOUND
            {
                # The group doesn't have any members
                $columnValues = @{ $groupColumnID = $groupDN; }
                if ($styleNoMembers -eq $NULL)
                {
                    $styleNoMembers = $Context.Items.CreateItemStyle("#3d3d3d", $NULL,
                        "ADM_LISTITEMFONTSTYLE_REGULAR")
                }
                $Context.Items.Add(-1, "<No members>", "Information", $columnValues, $styleNoMembers)
                continue
            }
            else
            {
                throw $_.Exception
            }
        }

        # Add group members to the report

        $guidsToSearch = $NULL
        # Add already found objects
        foreach ($memberGuid in $memberGuids)
        {
            if (-not $memberGuidToSearchResult.Contains($memberGuid))
            {
                if ($guidsToSearch -eq $NULL)
                {
                    $guidsToSearch = New-Object System.Collections.ArrayList
                }
                $guidsToSearch.Add($memberGuid)
            }
            else
            {
                $memberSearchResult = $memberGuidToSearchResult[@(,$memberGuid)][0]
                $clonedSearchResult = $memberSearchResult.Clone($False)
                $columnValues = @{ $groupColumnID = $groupDN; }
                $Context.Items.Add($clonedSearchResult, $columnValues, $NULL)
            }
        }
        
        if ($guidsToSearch -eq $NULL)
        {
            continue
        }

        # Search for members
        $memberSearcher = $Context.CreateGuidBasedSearcher($guidsToSearch)
        $memberSearcher.SetPropertiesToLoad($propertiesForMembers)
        $memberSearcher.AppendFilter($filterMembers)
        try
        {
            $memberSearchIterator = $memberSearcher.ExecuteSearch()
            while ($Context.MoveNext($memberSearchIterator))
            {
                $memberSearchResult = $memberSearchIterator.Current
                
                # Remember the search result
                $memberGuid = $memberSearchResult.GetPropertyByName("objectGuid").Values[0]
                $memberGuidToSearchResult[$memberGuid] = $memberSearchResult.Clone($False)
    
                # Add the object to the report
                $columnValues = @{ $groupColumnID = $groupDN; }
                $Context.Items.Add($memberSearchResult, $columnValues, $NULL)
            }
        }
        finally
        {
            if ($memberSearchIterator) { $memberSearchIterator.Dispose() }
        }
    }
}
finally
{
    if ($searchIterator) { $searchIterator.Dispose() }
}

