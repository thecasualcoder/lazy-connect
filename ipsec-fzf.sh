#! /bin/bash

function _ipsec_fzf_store_vpn_names() {
  vpnNames=$(osascript <<EOF
    tell application "System Events"
  	tell process "SystemUIServer"
  		set vpnMenu to (menu bar item 1 of menu bar 1 where description is "VPN")
  		tell vpnMenu to click
  		set vpnMenuItems to (menu items of menu 1 of vpnMenu)
  		-- Loop till first missing value(that is fisrt menu item seperator) and accumulate VPN Names
  		set vpnNames to {}
  		repeat with vpnMenuItem in vpnMenuItems
  			set vpnName to name of vpnMenuItem
  			if vpnName is equal to missing value then
  				exit repeat
  			end if
  			set vpnNames to vpnNames & {vpnName}
  		end repeat
  		key code 53
  		get vpnNames
  	end tell
    end tell
EOF
)

  echo $vpnNames | sed -e "s/Connect //g; s/Disconnect //g;" | tr , "\n" | xargs -I{} echo {} > ~/.config/ipsec-fzf/vpns
  echo "\nVPNs:"
  cat ~/.config/ipsec-fzf/vpns
}

function connect-vpn() {
  while getopts "iah" opt; do
    case $opt in
      h)
        echo "Usage"
        ;;
      i)
        echo "Secret Key: "
        read -s secret_key
        echo "**********"
        mkdir -p ~/.config/ipsec-fzf
        echo $secret_key > ~/.config/ipsec-fzf/secret
        _ipsec_fzf_store_vpn_names
        ;;
      a)
        echo "Connect all"
        ;;
      \?)
        echo "Invalid Option: -$OPTARG."
        echo "Usage"
        return 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        echo "Usage"
        return 1
        ;;
    esac
  done
}
