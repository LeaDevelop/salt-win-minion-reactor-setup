<#PSScriptInfo
.VERSION 2.0

.DESCRIPTION
Script that checks registry key value for locale and region format
- https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
- https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core-userlocale

.AUTHOR
Lea 'LeaDevelop' Nemec

.TAGS
locale region format status
#>


# Registry path variables
$RegistryPathGeo = 'HKCU:\Control Panel\International\Geo\'
$RegistryPathInt = 'HKCU:\Control Panel\International'

# Get registry key value variables
$GetLocale = gp $RegistryPathInt | select -exp Locale
$GetLocaleName = gp $RegistryPathInt | select -exp LocaleName
$GetGeoName = gp $RegistryPathGeo | select -exp Name
$GetGeoNation = gp $RegistryPathGeo | select -exp Nation

# Create directory if it doesn't exist already
$CreateMonitoredDirectory = "C:\test"

if (-not(Test-Path -PathType Container $CreateMonitoredDirectory))
{
    try
    {
        New-Item -ItemType Directory -Path $CreateMonitoredDirectory -ErrorAction Stop | Out-Null #-Force
    } catch {
        Write-Error - Message "Unable to create directory '$CreateMonitoredDirectory'. Error was: $_" - ErrorAction Stop
    }
    "Successfully created directory '$CreateMonitoredDirectory'."
}
else {
    "Directory '$CreateAgentMonitoringDirectory' already existed."
}

# Start default transcript
$defaultTranscript = Start-Transcript -Path C:\test\locale-region-status\minion-conf-status.log -Append

# Get the values of the keys for Country & region and format
$GetLocale + " - Locale (International)"
$GetLocaleName + " - LocaleName (International)"
$GetGeoName + " - Name (Geo)"
$GetGeoNation + " - Nation (Geo)"
Stop-Transcript


# Start transcript and store it to separate folder for wrong configurations
# TODO set variables for expected intended default values in minion hive
if (($GetLocale -ne '00000409') -or ($GetLocaleName -ne 'en-US') -or ($GetGeoName -ne 'US') -or ($GetGeoNation -ne '244'))
    {
        $missConfiguredCfgTranscript = Start-Transcript -Path C:\test\locale-region-wrong\minion-conf-error.log -Append
		Write-Output "LocaleGeo Error"
        if ($GetLocale -ne '00000409')
            {
                Write-Output "Locale (International) not equal to 00000409"
            }

        if ($GetLocaleName -ne 'en-US')
            {
                Write-Output "LocaleName (International) not equal to en-US"
            }

        if ($GetGeoName -ne 'US')
            {
                Write-Output "Name (Geo) not equal to US"
            }

        if ($GetGeoNation -ne '244')
            {
                Write-Output "Nation (Geo) not equal to 244"
            }
        Stop-Transcript
    }