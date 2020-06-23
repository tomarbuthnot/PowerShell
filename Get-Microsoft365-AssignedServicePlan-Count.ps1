
# Connect to Azure AD before running this scipt
# Run with a read only account. Run at your own risk.
# This will drop a CSV with details to the folder it runs in
# Connect-AzureAD 

# Possible Microsoft Teams Service Plans you may wish to count
# Use ServicePlanID

# Teams Licence                                             57ff2da0-773e-42df-b2af-ffb7a2317929
# MCOPSTNC (Old SfB Communications Credits)                 505e180f-f7e0-4b65-91d4-00d670bbd18c 
# Microsoft 365 Phone System (MCOEV)                        4828c8ec-dc2e-4779-b502-87ac9ce28ab7
# Microsoft 365 Audio Conferencing (MCOMEETADV)             3e26ee1f-8a5f-4d52-aee2-b81ce45c8f40
# MCOPSTNPP


# Licence Level (won't work in this script)
#Note MCOMEETADV is also at the licence level as 0c266dff-15dd-4b49-8397-2bb16070ed52
# MCOPSTNC 47794cd0-f0e5-45c5-9033-2eb6b5fc84e0
# MCOPSTN1 0dab259f-bf13-4952-b7f8-7db8f131b28d	



# Put Service Plan ID to collect user count on in this variable
$ServicePlanID = "57ff2da0-773e-42df-b2af-ffb7a2317929"


############# You should not need to edit below this line ######################

# Users with  Service Plan
# Cant filter by just memebers because occassionaly AD members have UserType as blank
$UsersWithServicePlan = get-Azureaduser -all $true | Where-Object {$_.AssignedPlans.ServicePlanId -contains "$($ServicePlanID)"}

$UsersTotalCount = $($UsersWithServicePlan.count)

Write-Host "Matching Users Found $UsersTotalCount"


# Create an output file with details of the Assigned Service Plan and if it is enabled or disabled
$OutputCollection=  @()

$counter = 0

Foreach ($user in $UsersWithServicePlan)
        {
            
            $counter++

            Write-Host "Processing $counter of $UsersTotalCount"

            $ServicePlanDetail = $null

            $ServicePlanDetail = $User.AssignedPlans | Where-Object ServicePlanId -EQ $($ServicePlanID)

            $output = New-Object -TypeName PSobject 

            $output | add-member NoteProperty "ObjectId" -value $User.ObjectId
            $output | add-member NoteProperty "DisplayName" -value $User.DisplayName
            $output | add-member NoteProperty "UserPrincipalName" -value $User.UserPrincipalName
            $output | add-member NoteProperty "UserType" -value $User.UserType
            $output | add-member NoteProperty "ServicePlan" -value $($ServicePlanDetail.service)
            $output | add-member NoteProperty "CapabilityStatus" -value $($ServicePlanDetail.CapabilityStatus)
            $output | add-member NoteProperty "AssignedTimestamp" -value $($ServicePlanDetail.AssignedTimestamp)
            $output | add-member NoteProperty "ServicePlanId" -value $($ServicePlanDetail.ServicePlanId)

    $OutputCollection += $output
    }

    # Output collection
    # $OutputCollection

#Write Output to Excel for Analysis

$OutputCollection | Export-Csv "$((Get-Date).ToString("yyyyMMdd_HHmmss"))_ServicePlanList.csv" -NoTypeInformation

$EnabledCount = $OutputCollection | Where-Object CapabilityStatus -eq Enabled | Measure-Object
$DeletedCount = $OutputCollection | Where-Object CapabilityStatus -eq Deleted | Measure-Object
$date = Get-Date

write-host ""
Write-Host "Current date time is" $date
write-host ""
Write-host "Service Plan Scanned for is $ServicePlanID"
write-host ""
Write-Host "Number of users with Service Plan is" $($OutputCollection.count)
write-host ""
Write-Host "Number of users with Service Plan Enabled is" $($EnabledCount.count)
write-host ""
Write-Host "Number of users with Service Plan Deleted is" $($DeletedCount.count)