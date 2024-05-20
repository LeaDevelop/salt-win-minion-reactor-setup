<#PSScriptInfo
.VERSION 2.0

.DESCRIPTION
Script that corrects registry key value for locale and region. Run with care!
- https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations
- https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core-userlocale

.AUTHOR
Lea 'LeaDevelop' Nemec

.TAGS
set locale region format
#>


# Registry path variables
$RegistryPathInt = 'HKCU:\Control Panel\International'
$RegistryPathGeo = 'HKCU:\Control Panel\International\Geo\'


# Get registry key value variables
$GetLocale = gp $RegistryPathInt | select -exp Locale
$GetLocaleName = gp $RegistryPathInt | select -exp LocaleName
$GetGeoName = gp $RegistryPathGeo | select -exp Name
$GetGeoNation = gp $RegistryPathGeo | select -exp Nation

# Correct the registry key value variables
$SetLocale = Set-ItemProperty -Path $RegistryPathInt -Name Locale -Value '00000409'
$SetLocaleName = Set-ItemProperty -Path $RegistryPathInt -Name LocaleName -Value 'en-US'
$SetGeoName = Set-ItemProperty -Path $RegistryPathGeo -Name Name -Value 'US'
$SetGeoNation = Set-ItemProperty -Path $RegistryPathGeo -Name Nation -Value '244'

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
        $missConfiguredCfgTranscript = Start-Transcript -Path C:\test\locale-region-correction\minion-conf-corrected.log -Append
		Write-Output "YLocaleGeo Error"
        if ($GetLocale -ne '00000409')
            {
                Write-Output "Locale (International) was not equal to 00000409"
                $SetLocale + " - Locale (International) correction done"
                $GetLocale + " - Locale (International)"
            }

        if ($GetLocaleName -ne 'en-US')
            {
                Write-Output "LocaleName (International) not equal to en-US"
                $SetLocaleName + "LocaleName (International) correction done"
                $GetLocaleName + " - LocaleName (International)"
            }

        if ($GetGeoName -ne 'US')
            {
                Write-Output "Name (Geo) not equal to US"
                $SetGeoName + " - Name (Geo) correction done"
                $GetGeoName + " - Name (Geo)"
            }

        if ($GetGeoNation -ne '244')
            {
                Write-Output "Nation (Geo) not equal to 244"
                $SetGeoNation + " - Nation (Geo) correction done"
                $GetGeoNation + " - Nation (Geo)"
            }
        Stop-Transcript
    }