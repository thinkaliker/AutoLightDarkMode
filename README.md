# Auto Light/Dark Mode

## About

I made this because f.lux isn't arm64 ready, and I wanted auto light/dark mode on my Surface. And Windows doesn't have that function built in for some reason, even though it already turns on Night Light at Sunset/Sunrise.

## Prerequisites

- Location Services turned on - if you don't want to, manually configure Latitude and Longitude
- PowerShell Execution Policy configured to Bypass or Unrestricted
- Internet access - if none, manually configure Sunrise and Sunset time
- Launcher file - required unless you don't mind a window popping up on every run (not recommended)

## Setting up Task Scheduler

- Create a new Task
- General Tab
  - Select "Run whether user is logged on or not"
  - Select "Do not store password."
- Triggers Tab
  - Create a trigger "On workstation unlock", "Any user", Enabled
  - Create a second trigger "On a schedule", "One time", Repeat task every 5 minutes for a duration of Indefinitely, Stop task if it runs longer than 3 days, Enabled
- Actions Tab
  - Start a program
  - Program/script: WScript.exe
  - Arguments: //B "C:\<location>\Launcher.VBS" powershell.exe -ExecutionPolicy ByPass -file "C:\<location>\AutoLightDarkMode.ps1"
- Settings Tab
  - (Uncheck everything except these)
  - Allow task to be run on demand
  - Stop the task if it runs longer than 3 days
  - If the running task does not end when requested, force it to stop
  - If the task is already running, then the following rule applies: Do not start a new instance

## Acknowledgements

- [StackOverflow | Powershell: Getting GPS Coordinates in Windows 10 - Using Windows Location API?](https://stackoverflow.com/a/46287884)
- [StackOverflow | Powershell return only sunrise/sunset time](https://stackoverflow.com/a/63237047)
- [StackOverflow | Toggle Dark/Light Mode in Windows 10 automatically by time of day (without modifying or changing theme!)](https://stackoverflow.com/a/73734302)
- [StackOverflow | PowerShell in Task Manager Shows Window](https://stackoverflow.com/a/51007810)
- [sunrise-sunset.org API](https://sunrise-sunset.org/)

## To-Do

- [ ] Add pictures of Task Schedule setup
- [ ] Implement local sunrise/sunset calculation using trigonometric calculations
