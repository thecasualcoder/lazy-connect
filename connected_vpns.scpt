#!/usr/bin/env osascript

-- could replace refresh with this, passing regex
on getConnectedVpns()
  log "search for connected vpns"
  tell application "System Events"
    tell process "SystemUIServer"
      set vpnMenu to (menu bar item 1 of menu bar 1 where description is "VPN")
      tell vpnMenu to click
      set vpnMenuItems to (menu items of menu 1 of vpnMenu)
      set connectedVpns to {}
      repeat with vpnMenuItem in vpnMenuItems
        set vpnName to name of vpnMenuItem
        if vpnName starts with "Disconnect" then
          set connectedVpns to connectedVpns & {vpnName}
        else if vpnName starts with "Connect" then
          exit repeat
        end if
      end repeat
      get connectedVpns
    end tell
  end tell
end getConnectedVpns

on run argv
  set res to getConnectedVpns()
  if res equal to {} then
    log "No vpn is connected."
    -- ESCAPE
  end if
  tell application "System Events" to key code 53
  return res
end run
