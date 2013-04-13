. "./config.ps1"
. "./cygwin.ps1"

Function wget_require {
    if (!(wget_present)) {
        throw "Requires wget"
    }
}

Function wget_present {
    return (cygwin_has "wget.exe")
}

Function wget_download($from, $to) {
    wget_require

    & (cygwin_path "wget.exe") ("-O", $to, $from)
    return ($LASTEXITCODE -eq 0)
}