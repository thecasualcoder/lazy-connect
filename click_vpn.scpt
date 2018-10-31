#!/usr/bin/env osascript

on click(name)
  log "selection: " & {name}
  tell application "System Events"
    tell process "SystemUIServer"
      set vpnMenu to (menu bar item 1 of menu bar 1 where description is "VPN")
      tell vpnMenu to click
      try
        click menu item name of menu 1 of vpnMenu
      on error errorStr
        return "false"
        log "error: " & errorStr
      end try
    end tell
  end tell
  return "true"
end click

on run argv
  set arg to (item 1 of argv)
  set res to click(arg)
  if res equal to "false" then
    -- ESCAPE KEY
    tell application "System Events" to key code 53
  end if
end run
