# lazy-connect

Shell function to fuzzy search an IPSec VPN by name and connect to it automatically.

## Prerequisite

1.  [fzf](https://github.com/junegunn/fzf)
2.  [OATH Toolkit](https://www.nongnu.org/oath-toolkit/index.html)

```
brew install oath-toolkit fzf
```

## Install

### Using Homebrew

```
brew tap arunvelsriram/stable
brew install lazy-connect
```

### Manual

```
git clone https://github.com/arunvelsriram/lazy-connect.git ~/.lazy-connect
sudo ln -s ~/.lazy-connect/lazy-connect /usr/local/bin/lazy-connect
```

### Usage

```
lazy-connect - Shell function to fuzzy search an IPSec VPN by name
               and connect to it automatically.

-i    - Initialize lazy-connect.
        Stores the secret and VPN list to ~/.config/lazy-connect/
-r    - refresh vpn list in ~/.config/lazy-connect
-h    - Show this help
```

## Configuration

* The connection to VPN could be made with filling password automatically. To enable autofill set `LAZY_CONNECT_AUTOFILL` variable to true.

```
export LAZY_CONNECT_AUTOFILL="true"
```
When disabled, the password is copied to clipboard, and you can use it manually when it prompts for password.

### YubiKey Support

#### Prerequisite

1.  [yubikey-manager](https://github.com/Yubico/yubikey-manager)

To use `TOTP` from YubiKey set the following environment variable

```sh
export LAZY_CONNECT_TOTP_GENERATOR=yubikey
export LAZY_CONNECT_TOTP_QUERY=<name of the issuer>
```

### Note

- The secret key to generate TOTP is stored in Keychain on Mac under default `login` keychain. You may need to
  enter your login password to allow access to Keychain.
- You need to add your Termainal emulator app that invokes the function to `Security & Privacy -> Accessibility`. It is
  necesssary because the script interacts with the UI. There are other ways via CLI to avoid UI interaction but
  they are all broken in OS X 10.12+.
