# Set current time in a variable
$Now = (Get-Date -format "HH:mm")

# Get current location from system - Location must be turned on in settings
# Reference https://stackoverflow.com/a/46287884
"Getting Location"
# Required to access System.Device.Location namespace
Add-Type -AssemblyName System.Device
# Create the required object
$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
# Begin resolving the current location
$GeoWatcher.Start()

# Wait for discovery
while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
    Start-Sleep -Milliseconds 100
}  

if ($GeoWatcher.Permission -eq 'Denied') {
    "Access Denied for Location, using defaults"
    # Configure these defaults
    $Latitude = 32.715736
    $Longitude = -117.161087
}
else {
    $Latitude = $GeoWatcher.Position.Location.Latitude
    $Longitude = $GeoWatcher.Position.Location.Longitude
}

# TODO - replace API call with formula for approximation https://www.omnicalculator.com/physics/sunrise-sunset
# Retrieve sunrise/sunset time from sunrise-sunset.org API
# Reference https://stackoverflow.com/a/63237047
"Getting Sunrise/Sunset"
try {
    $Request = (Invoke-RestMethod "https://api.sunrise-sunset.org/json?lat=$Latitude&lng=$Longitude&formatted=0" -TimeoutSec 15)
    $Sunrise = ($Request.results.Sunrise | Get-Date -Format "HH:mm")
    $Sunset = ($Request.results.Sunset | Get-Date -Format "HH:mm")
}
catch {
    # If offline or API failure, default to 7am to 7pm (change as desired)
    $Sunrise = "07:00"
    $Sunset = "19:00"
}

"Current time based on location $Latitude $Longitude is $Now"
"Sunrise is $Sunrise and Sunset is $Sunset"

# Set theme based on sunset/sunrise times - if theme is set already, do not attempt to re-set (prevents windows flickering at interval)
# Reference https://stackoverflow.com/a/73734302
$RegKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$AppTheme = (Get-ItemProperty -Path $RegKey -Name AppsUseLightTheme).AppsUseLightTheme
$SystemTheme = (Get-ItemProperty -Path $RegKey -Name SystemUsesLightTheme).SystemUsesLightTheme
$Dark = 0
$Light = 1
if ($Now -gt $Sunrise -and $Now -lt $Sunset) {
    "Check if Light theme is already set"
    if ($AppTheme -eq 0 -or $SystemTheme -eq 0) {
        "Setting Light theme.."
        # set "app" system mode to "light"
        Set-ItemProperty -Path $RegKey -Name AppsUseLightTheme -Value $Light -Type Dword -Force
        # set "OS" system mode to "light"
        Set-ItemProperty -Path $RegKey -Name SystemUsesLightTheme -Value $Light -Type Dword -Force
    }
    else {
        "Already Light"
    }
}
else {
    "Check if Dark theme is already set"
    if ($AppTheme -eq 1 -or $SystemTheme -eq 1) {
        "Setting Dark theme..."
        # set "app" system mode to "dark"
        Set-ItemProperty -Path $RegKey -Name AppsUseLightTheme -Value $Dark -Type Dword -Force
        # set "OS" system mode to "dark"
        Set-ItemProperty -Path $RegKey -Name SystemUsesLightTheme -Value $Dark -Type Dword -Force
    }
    else {
        "Already Dark"
    }
}


# For reference only, command line registry keys
# reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 1 /f
# reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 1 /f
# reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
# reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f