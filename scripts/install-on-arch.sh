#!/bin/sh

SCRIPT_PATH="$0"

while [ -L "$SCRIPT_PATH" ]; do
    SCRIPT_PATH=$(readlink "$SCRIPT_PATH")
done

SCRIPT_DIR=$(cd "$(dirname "$SCRIPT_PATH")" >/dev/null 2>&1 && pwd)

echo "Script location : $SCRIPT_DIR"

echo "Making a backup of your existing .config."
echo "Moving ~/.config to ~/.config.bak"
mv ~/.config ~/.config.bak/

DISTRO_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

if [ "$DISTRO_ID" != "arch" ]; then
    echo "This script is only for arch linux systems"
    exit 1
fi

echo "Running on Arch"

PACMAN_PIDS=$(pgrep pacman)
if [ -n "$PACMAN_PIDS" ]; then
    echo "Killing existing pacman processes: $PACMAN_PIDS"
    sudo kill -9 $PACMAN_PIDS
fi

if [ -f /var/lib/pacman/db.lck ]; then
    echo "Removing pacman lock file..."
    sudo rm /var/lib/pacman/db.lck
fi

echo "Running sudo pacman -Syu"
sudo pacman -Syu || {
    echo "Failed to update system"
    exit 1
}

if ! command -v yay >/dev/null 2>&1; then
    "Installing git and base-devel"
    sudo pacman -S --needed git base-devel || {
        echo "Failed to install prerequisites. Aborting"
            exit 1
        }
    
    "Cloning yay into ~/.temp/yay"
    git clone https://aur.archlinux.org/yay.git ~/.temp/yay || {
        echo "Failed to clone yay repo"
            exit 1
        }

    cd ~/.temp/yay || exit 1
    
    "Building and installing yay"
    makepkg -si --noconfirm || {
        echo "Failed to build and install yay."
            exit 1
        }

    echo "Installed yay 'AUR helper'"

    cd -
fi

echo "Yay installed"

yay -S --noconfirm hyprland dolphin waybar \
    alacritty eww neovim nodejs \
    npm zsh hyprpicker python-pywal16 blueman \
    bluez networkmanager swaync hyprpaper \
    hyprlock gvfs libnotify wlogout fuzzel \
    stow github-cli fd qt6-svg qt6-declarative qt5-quickcontrols2 \
    sddm-kcm sddm wget zip unzip spotify spicetify-cli polekit-gnome \
    python cargo gcc npm gum inetutils jq hyprshot diff-so-fancy \
    ttf-jetbrains-mono-nerd noto-fonts-*

if ! command -v zsh >/dev/null 2>&1; then
    echo "ZSH not found. installing zsh"
    sudo pacman -S --noconfirm zsh || {
        echo "Failed to install zsh"
        exit 1
    }
fi

CURRENT_USER=$(whoami)

if [ -n "$ZSH_VERSION" ]; then
    echo "Already using zsh"
else
    echo "Changing default shell to zsh for user $CURRENT_USER"
    chsh -s "$(which zsh)"
fi

echo "Changing directory to ../"
cd $SCRIPT_DIR
cd ../

echo "GNU stow for Symlink"
stow --adopt .

cd ~/.config

if [ -d "$HOME/.config/nvim" ]; then
    if [ "$(ls -A $HOME/.config/nvim)" ]; then
        echo "Backing up nvim config"
        mv ~/.config/nvim ~/.config/nvim.bak
    else
        rm -r "$HOME/.config/nvim"
    fi
fi

sudo npm install npm@latest
sudo npm install --global @tailwindcss/language-server

echo "Installing Lazy Neovim Config"
git clone https://github.com/ArcheryLuna/lazy-neovim-config.git ~/.config/nvim

sudo systemctl enable --now bluetooth

echo "Setting SDDM Theme"
REQUIRED_PKGS=("git" "curl" "unzip")

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" &> /dev/null; then
        echo "$pkg is not installed. Installing..."
        sudo pacman -S --noconfirm "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# Download the preferred theme (you can replace the URL with your actual theme URL)
THEME_URL="https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip"
THEME_DIR="/usr/share/sddm/themes"
THEME_NAME="catppuccin-mocha"

# Download the release and unzip it
echo "Downloading $THEME_NAME..."
curl -L "$THEME_URL" -o "/tmp/$THEME_NAME.zip"

echo "Unzipping theme..."
sudo unzip "/tmp/$THEME_NAME.zip" -d "$THEME_DIR"

# Set the theme in the sddm.conf file
echo "Setting the theme in /etc/sddm.conf..."
sudo sed -i "s|^# Current theme=.*|Current theme=$THEME_NAME|" /etc/sddm.conf

# Clean up
rm "/tmp/$THEME_NAME.zip"

echo "SDDM theme has been set to $THEME_NAME."

wal -i ~/wallpapers/JapanNightWallpaper.png

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

spicetify backup apply
spicetify config current_theme Dribbblish color_scheme tokyo-night
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
spicetify apply

eval "$(~/.local/bin shellenv)"
