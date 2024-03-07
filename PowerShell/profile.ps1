set-psreadlineoption -Colors @{ InlinePrediction = "#9194AC" }

function prompt {
    $p = $executionContext.SessionState.Path.CurrentLocation
    $ansi_escape = [char]27

    # For changing tab title
    Write-Host -NoNewLine "$ansi_escape]0;$p$ansi_escape\";

    # For changing to last path when creating new tab
    $osc7 = ""
    if ($p.Provider.Name -eq "FileSystem") {
        $provider_path = $p.ProviderPath -Replace "\\", "/"
        $osc7 = "$ansi_escape]7;file://${env:COMPUTERNAME}/${provider_path}${ansi_escape}\"
    }
    "${osc7}PS $p$('>' * ($nestedPromptLevel + 1)) ";
}