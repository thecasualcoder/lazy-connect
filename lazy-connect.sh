#!/bin/bash

TOTP_MODE=${LAZY_CONNECT_TOTP_GENERATOR:-oathtool}

_lazy_connect_config_dir=~/.config/lazy-connect
_lazy_connect_project_dir=~/.lazy-connect

function _lazy_connect_init() {
  case $TOTP_MODE in
  oathtool)
    echo -n "Secret Key: "
    read -s secret_key
    echo "**********"

    echo 'Storing secret in keychain...'
    old_secret=~/.config/lazy-connect/secret
    [ -f "$old_secret" ] && rm "$old_secret"
    security delete-generic-password -a lazy-connect -s lazy-connect &> /dev/null
    security add-generic-password -a lazy-connect -p "$secret_key" -s lazy-connect
    ;;
  esac
  _lazy_connect_vpn_refresh
}

function _lazy_connect_vpn_refresh() {
  local backup_file=/tmp/lazy-connect-vpns-`date +%-H-%M-%S-%F`
  [ -f $_lazy_connect_config_dir/vpns ] && cp $_lazy_connect_config_dir/vpns $backup_file
  osascript <<EOF |
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
tr ',' '\n' | sed 's/^[[:space:]]//g' > $_lazy_connect_config_dir/vpns

  echo "Storing the VPN list..."
  if [ -f $backup_file ]; then
    echo -e "\nDiff:\n$(diff -y $backup_file $_lazy_connect_config_dir/vpns)"
  else
    echo -e "\nVPN List:"
    cat $_lazy_connect_config_dir/vpns | nl
  fi
}

function _lazy_connect_usage() {
  cat <<EOF

USAGE:

lazy-connect - Shell function to fuzzy search an IPSec VPN by name
               and connect to it automatically.

-i    - Initialize lazy-connect. Stores the TOTP secret and VPN list
-u    - Update lazy-connect
-r    - Refresh vpn list in ~/.config/lazy-connect
-h    - Show this help
EOF
}

function _lazy_connect_get_totp() {
  secret_key=$1
  case $TOTP_MODE in
  oathtool)
    password=$(oathtool --totp --base32 $secret_key)
    return 0
    ;;
  yubikey)
    if ! [ -x "$(command -v ykman)" ]; then
      echo 'Error: ykman tool not installed.' >&2
      exit 1
    fi
    if [ -z "$LAZY_CONNECT_TOTP_QUERY" ]; then
      echo "Error: LAZY_CONNECT_TOTP_QUERY not set."
      exit 1
    else
      password=$(ykman oath code $LAZY_CONNECT_TOTP_QUERY 2>/dev/null | awk '{print $2}')
    fi
    ;;
  esac
}

function _lazy_connect() {
  vpn_name=$1
  _lazy_connect_get_totp $2

  if [ -z "$password" ]; then
    case $TOTP_MODE in
    oathtool)
      echo "Error: Unable to generate otp using oathtool."
      return 1
      ;;
    yubikey)
      echo "Error: No YubiKey found."
      return 1
      ;;
    esac
  fi

  osascript <<EOF
    on connectVpn(vpnName, password)
      tell application "System Events"
        tell process "SystemUIServer"
          set vpnMenu to (menu bar item 1 of menu bar 1 where description is "VPN")
          tell vpnMenu to click
          try
            click menu item vpnName of menu 1 of vpnMenu
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

function _lazy_connect_update() {
  git -C $_lazy_connect_project_dir pull origin master
  echo -e "\n\nRun the below command or restart your shell."
  echo "$ source $_lazy_connect_project_dir/lazy-connect.sh"
}

function lazy-connect() {
  local OPTIND
  mkdir -p $_lazy_connect_config_dir

  while getopts "iruh" opt; do
    case $opt in
      h)
        _lazy_connect_usage
        return 0
        ;;
      i)
        _lazy_connect_init
        return 0
        ;;
      r)
        echo "Refreshing VPN list..."
        _lazy_connect_vpn_refresh
        return 0
        ;;
      u)
        _lazy_connect_update
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

  local secret=$(security find-generic-password -a lazy-connect -w 2> /dev/null | tr -d '\n')
  if [ -z "$secret" ];
  then
    echo "Secret not found in keychain. Initialize lazy-connect and try again."
    return 1
  fi

  vpn_name=$(cat $_lazy_connect_config_dir/vpns \
    | fzf --height=10 --ansi --reverse --query "$*" --select-1)
  [ -z "$vpn_name" ] || _lazy_connect "$vpn_name" "$secret"
}
