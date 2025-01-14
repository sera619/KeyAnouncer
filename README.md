# KeyAnouncer - WoW Addon

## Description:
Keystone Tracker is a simple yet effective addon for World of Warcraft that allows players to share and view Mythic+ keystones within their party. By leveraging the game's addon communication system, Keystone Tracker makes it easy for party members to know who has which keystone, helping the group coordinate Mythic+ runs more effectively.

## Features:
- Automatic Keystone Detection: The addon automatically scans the player's inventory for their Mythic+ keystone.
- Addon Communication: Shares your keystone information with other party members who also have the addon installed.
- Party Keystone Overview: Displays the keystones of all party members who use the addon, allowing for quick decision-making when choosing a Mythic+ dungeon.
- Lightweight and User-Friendly: The addon is lightweight, with minimal impact on performance and requires no manual setup.

## How It Works:
1. Upon joining a party, the addon automatically detects your Mythic+ keystone and shares its details with other party members using the addon.
2. The addon listens for incoming keystone information from other party members and displays the collected data in the chat or on the UI.
3. If a player does not have a keystone or is not using the addon, no data will be displayed for them.

## Requirements:
All party members need to have the addon installed for full functionality.

Compatible with World of Warcraft's latest expansion and patch.

## Screenshots
> Settingsframe
> 
> ![KeyAnouncer Settingswindow](https://github.com/sera619/KeyAnouncer/blob/main/Icons/KeyAnouncer_UI.png?raw=true)


> Chatwindow
>
> ![KeyAnouncer Chat](https://github.com/sera619/KeyAnouncer/blob/main/Icons/KeyAnouncer_Chat.png?raw=true)

## Changelog

Version 1.0.0 - Initial Release

- Added functionality to automatically detect the player's Mythic+ keystone from their inventory.
- Implemented an addon communication system to share keystone information with other party members.
- Displayed keystone details of party members in the chat window.
- Registered the addon with the MyKeystoneAddon communication prefix.


Version 1.1.0- Improved Usability

- Enhanced compatibility with different inventory setups to ensure keystone detection works seamlessly.
- Improved chat output formatting for better readability of shared keystone information.
- Added error handling for scenarios where no keystone is found.


Version 1.1.1- New Features and Fixes

- Fixed a bug where keystone data was not sent to the party after reloading the UI.


Version 1.1.2 - Optimization

- Minor fixes to improve stability and compatibility with the latest WoW patch.
