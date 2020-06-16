
# Connect to Azure AD before running this scipt
# Run with a read only account. Run at your own risk
# Connect-AzureAD 


# Users with TeamspaceAPI Service Plan
$UsersWithServicePlan = get-Azureaduser -all $true | Where-Object {$_.AssignedPlans.Service -contains "TeamspaceAPI"}


# Create an output file with details of the Assigned Service Plan and if it is enabled or disabled
$OutputCollection=  @()

Foreach ($user in $UsersWithServicePlan)
        {

            $TeamsServicePlan = $null

            $TeamsServicePlan = $User.AssignedPlans | Where-Object Service -EQ "TeamspaceAPI"

            $output = New-Object -TypeName PSobject 

            $output | add-member NoteProperty "ObjectId" -value $User.ObjectId
            $output | add-member NoteProperty "DisplayName" -value $User.DisplayName
            $output | add-member NoteProperty "UserPrincipalName" -value $User.UserPrincipalName
            $output | add-member NoteProperty "UserType" -value $User.UserType
            $output | add-member NoteProperty "ServicePlan" -value $($TeamsServicePlan.service)
            $output | add-member NoteProperty "CapabilityStatus" -value $($TeamsServicePlan.CapabilityStatus)
            $output | add-member NoteProperty "AssignedTimestamp" -value $($TeamsServicePlan.AssignedTimestamp)
            $output | add-member NoteProperty "ServicePlanId" -value $($TeamsServicePlan.ServicePlanId)

    $OutputCollection += $output
    }

    # Output collection
    # $OutputCollection

$EnabledCount = $OutputCollection | Where-Object CapabilityStatus -eq Enabled | Measure-Object
$DeletedCount = $OutputCollection | Where-Object CapabilityStatus -eq Deleted | Measure-Object
$date = Get-Date

write-host ""
Write-Host "Current date time is" $date
write-host ""
Write-Host "Number of users with TeamspaceAPI (Microsoft Teams) Service Plan is" $($OutputCollection.count)
write-host ""
Write-Host "Number of users with TeamspaceAPI (Microsoft Teams) Service Plan Enabled is" $($EnabledCount.count)
write-host ""
Write-Host "Number of users with TeamspaceAPI (Microsoft Teams) Service Plan Deleted is" $($DeletedCount.count)
