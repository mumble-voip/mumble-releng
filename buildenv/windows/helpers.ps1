Function download($from, $to) {
<#
    .SYNOPSIS
        Downloads a file to a given location.
    .EXAMPLE
        download("http://something/somefile.txt", "somelocaltargetfile.txt")
#>
    echo_neutral "Downloading $to from $from ..."
    $wc = New-Object System.Net.WebClient
    try {
        $wc.downloadFile($from, $to)
    }
    catch {
        echo_red Failed
        echo_red $_.Exception.ToString()
        return 0
    }
   
    echo_green Done
    return 1
}

Function am_i_admin {
<#
    .SYNOPSIS
        Returns true if the program is running with administrator priviledges.
#>
    $identity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal=new-object System.Security.Principal.WindowsPrincipal($identity)
    $admin=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    return $principal.IsInRole($admin)
}

Function require_admin {
<#
    .SYNOPSIS
        Throws an exception if the program isn't running with administrator priviledges.
#>
    if(!(am_i_admin)) {
        throw "Requires admin priviledges"
    }
}

Function echo_neutral($what) {
<#
    .SYNOPSIS
        Echo in neutral color
#>
    write-host $what
}

Function echo_green($what) {
<#
    .SYNOPSIS
        Echo in green color
#>
    write-host -ForegroundColor Green $what
}

Function echo_red($what) {
<#
    .SYNOPSIS
        Echo in red color
#>
    write-host -ForegroundColor Red $what
}

