#! /bin/bash

function _lazy_connect_init() {
  config_dir=~/.config/lazy-connect
  echo -n "Secret Key: "
  read -s secret_key
  echo "**********"
  mkdir -p $config_dir
  echo $secret_key > $config_dir/secret

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
  echo $vpnNames | sed -e "s/Connect //g; s/Disconnect //g;" | tr , "\n" | xargs -I{} echo {} > $config_dir/vpns
  echo "VPN List:"
  cat $config_dir/vpns | nl
}

function _lazy_connect_usage() {
  cat <<EOF

USAGE:

lazy-connect

-i    - Initialize lazy-connect.
        Stores the secret and VPN list to ~/.config/lazy-connect/
-h    - Show this help
EOF
}

function _lazy_connect() {
  vpn_name=$1
  secret_key=$2
  password=$(oathtool --totp --base32 $secret_key)

  osascript <<EOF
    on connectVpn(vpnName, password)
      tell application "System Events"
        tell process "SystemUIServer"
          set vpnMenu to (menu bar item 1 of menu bar 1 where description is "VPN")
          tell vpnMenu to click
          try
            click menu item ("Connect " & vpnName) of menu 1 of vpnMenu
            delay 1
            keystroke password
            keystroke return
          on error errorStr
            if errorStr does not contain "Can’t get menu item" and errorStr does not contain vpnName then
              display dialog errorStr
            end if
          end try
        end tell
      end tell
    end connectVpn

    connectVpn("$vpn_name", "$password")
EOF
}

function lazy-connect() {
  while getopts "ih" opt; do
    case $opt in
      h)
        _lazy_connect_usage
        return 0
        ;;
      i)
        _lazy_connect_init
        return 0
        ;;
      \?)
        echo "Invalid Option: -$OPTARG."
        _lazy_connect_usage
        return 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        _lazy_connect_usage
        return 1
        ;;
    esac
  done

  config_dir=~/.config/lazy-connect
  secret=$(cat $config_dir/secret)
  vpn_name=$(cat $config_dir/vpns \
    | fzf --height=10 --ansi --reverse)
  [ -z "$vpn_name" ] || _lazy_connect $vpn_name $secret
}
