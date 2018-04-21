# lazy-connect

Shell function to fuzzy search an IPSec VPN by name and connect to it automatically.

## Prerequisite

1. [fzf](https://github.com/junegunn/fzf)
2. [OATH Toolkit](https://www.nongnu.org/oath-toolkit/index.html)

```
brew install oath-toolkit fzf
```

## Install

```
git clone https://github.com/arunvelsriram/lazy-connect.git ~/.lazy-connect
```

```
# zsh users
echo "[ -f ~/.lazy-connect/lazy-connect.sh ] && source ~/.lazy-connect/lazy-connect.sh" >> ~/.zshrc
source ~/.zshrc
```

```
# bash users
echo "[ -f ~/.lazy-connect/lazy-connect.sh ] && source ~/.lazy-connect/lazy-connect.sh" >> ~/.bashrc
source ~/.bashrc
```

### Usage

```
lazy-connect - Shell function to fuzzy search an IPSec VPN by name
               and connect to it automatically.

-i    - Initialize lazy-connect.
        Stores the secret and VPN list to ~/.config/lazy-connect/
-h    - Show this help
```

### Warning

The secret key to generate TOTP is stored as plain text in `~/.config/lazy-connect/secret`
