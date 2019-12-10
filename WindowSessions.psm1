<#
 .Synopsis
  Manage Windows user sessions on a computer.

 .Description
  With this module you can view what user sessions exist on a Windows machine and manage those sessions.

 .Parameter Computername
  The computername of the machine you want to manage Windows user sessions for.

 .Parameter Id
  The user session ID of a particular user you want to take an action on.

 .Example
   # Get user sessions
   Get-UserSessions -ComputerName remoteserver.int -Credentials Get-Credential
   Get-UserSessions

 .Example
   # Logoff user sessions
   Remove-Usersession -ComputerName remotecomputer.int -Id 2 -Credentials Get-Credential
   Remove-Usersession -Id 2

#>

function Get-UserSessions{
    Param(
        $ComputerName = "localhost",
        $Credentials
    )
    if($ComputerName -eq 'localhost'){
        $Sessions = &query user | select -skip 1
    } else {
        $Sessions = Invoke-Command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock { &query user | select -skip 1 }
    }
    $SessionsCollection = New-Object System.Collections.ArrayList

    foreach($Session in $Sessions) { 
        $Session = -split $Session
        $SessionItem = "" | select "username","sessioname","id","state","idleTime","logonTime","computername"
        $SessionItem.username = $Session[0]
        $SessionItem.computername = $ComputerName

        if($Session.Count -eq 8){
            $SessionItem.sessioname = $Session[1]
            $SessionItem.id = $Session[2]
            $SessionItem.state = $Session[3]
            $SessionItem.idleTime = $Session[4]
            $SessionItem.logonTime = $Session[5]
        }else{
            $SessionItem.sessioname = $null
            $SessionItem.id = $Session[1]
            $SessionItem.state = $Session[2]
            $SessionItem.idleTime = $Session[3]
            $SessionItem.logonTime = $Session[4]
        }

        $SessionsCollection.add($SessionItem) | Out-Null
    }

    return $SessionsCollection
}

function Remove-Usersession{
    Param(
        $ComputerName = "localhost",
        $Id,
        $Credentials
    )
    if($ComputerName -eq 'localhost'){
        &logoff $Id /v
    } else {
        Invoke-Command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock { &logoff $Id /v }
    }
}