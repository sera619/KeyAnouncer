KeyAnnouncerUtils = {}


function KeyAnnouncerUtils.PrintRed(text)
    return "|cffff0000"..text.."|r"
end

function KeyAnnouncerUtils.PrintGreen(text)
    return "|cff00ff00"..text.."|r"
end

KeyAnnouncerUtils.PatchNotes = {
    ['1.0.0'] = {
        "Version 1.0.0 - Initial Release",
        "- Added functionality to automatically detect the player's Mythic+ keystone from their inventory.",
        "- Implemented an addon communication system to share keystone information with other party members.",
        "- Displayed keystone details of party members in the chat window.",
        "- Registered the addon with the MyKeystoneAddon communication prefix."
    },
    ['1.1.0'] = {
        "Version 1.1.0 - Improved Usability",
        "- Enhanced compatibility with different inventory setups to ensure keystone detection works seamlessly.",
        "- Improved chat output formatting for better readability of shared keystone information.",
        "- Added error handling for scenarios where no keystone is found.",
    },
    ['1.1.1'] = {
        "Version 1.1.1 - New Features and Fixes",
        "- Fixed a bug where keystone data was not sent to the party after reloading the UI.",
    },
    ['1.1.2'] = {
        "Version 1.1.2 - Optimization",
        "- Minor fixes to improve stability and compatibility with the latest WoW patch.",
    },
    ['1.1.4'] = {
        "Version 1.1.4 - Bugfix",
        "- Set correct current WoW interface number.",
    },
    ['1.2.3'] = {
        "Version 1.2.3 - Improved Usability",
        "- Setup a moveable minimap icon.",
        "- Add cooldown to prevent chat spam.",
        "- Code refactoring.",
    },
    ['1.2.4'] = {
        "Version 1.2.4 - Bugfix",
        "- Fixing bug where settings window still showing if you log into another character.",
    },
    ['1.2.5'] = {
        "Version 1.2.5 - Improved Usability",
        "- Fixing some typos.",
        "- Add addon icon in addon list.",
    },
    ['1.2.6'] = {
        "Version 1.2.6 - Bugfix",
        "- Fixing bug where key is not posted if English client is active.",
    },
    ['1.2.7'] = {
        "Version 1.2.7 - Improved Usability",
        "- Change find keystone from item name to itemID.",
    },
    ['1.2.8'] = {
        "Version 1.2.8 - Hotfix",
        "- Fixed misspelled variable name.",
        "- Setup get dynamic keystone ID.",
    },
    ['1.3.0'] = {
        "Version 1.3.0 - Improved Usability",
        "- Add a party frame to display all keys in group (beta).",
        "- Fix misspells.",
        "- Make UI frames moveable.",
    },
    ['1.3.1'] = {
        "Version 1.3.1 - Bugfix",
        "- Fix not posting key after update.",
    },
    ['1.3.2'] = {
        "Version 1.3.2 - Bugfix",
        "- Disable dev outputs.",
    },
    ['1.3.3'] = {
        "Version 1.3.3 - Improved Usability",
        "- Refactoring code to make sure event vars are valid and accessible.",
        "- Create utils file for util functions.",
        "- Add an active-status message on minimap tooltip.",
        "- Fix an issue where minimap button position is not restored correctly after relog.",
    },
    ['1.3.4'] = {
        "Version 1.3.4 - Bugfix",
        "- Fix missing utils file in .toc.",
    },
}
