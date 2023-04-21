if [[ "$XDG_CURRENT_DESKTOP" = "" ]]; then
    desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(kde\|gnome\).*/\1/')
else
    desktop=$XDG_CURRENT_DESKTOP
fi
desktop=${desktop,,}

if [[ -z "$1" ]]; then
    if [[ -z "${lite}" ]]; then
        lite=true
    else
        lite="${lite}"
    fi
else
    lite="$1"
fi

# Power Management
# Possible values are 'none', 'power-profiles-daemon', 'tlp', 'auto-cpufreq', 'auto-cpufreq+tlp', 'laptop-mode-tools', and 'powertop'
if [[ -z "$2" ]]; then
    if [[ -z "${power_management}" ]]; then
        power_management="auto-cpufreq+tlp"
    else
        power_management="${power_management}"
    fi
else
    power_management="$2"
fi
if [[ -z "$3" ]]; then
    if [[ -z "${install_thermald}" ]]; then
        install_thermald=true
    else
        install_thermald="${install_thermald}"
    fi
else
    install_thermald="$3"
fi

if [[ -z "$4" ]]; then
    if [[ -z "${parallel_downloads}" ]]; then
        parallel_downloads=7
    else
        parallel_downloads="${parallel_downloads}"
    fi
else
    parallel_downloads="$4"
fi

if [[ -z "$5" ]]; then
    if [[ -z "${ssh_port}" ]]; then
        ssh_port=22
    else
        ssh_port="${ssh_port}"
    fi
else
    ssh_port="$5"
fi

if [[ -z "$6" ]]; then
    if [[ -z "${install_vm}" ]]; then
        install_vm=true
    else
        install_vm="${install_vm}"
    fi
else
    install_vm="$6"
fi

if [[ -z "$7" ]]; then
    if [[ -z "${install_pentablet}" ]]; then
        install_pentablet=true
    else
        install_pentablet="${install_pentablet}"
    fi
else
    install_pentablet="$7"
fi


cd ~
mkdir Code/

sudo sed -i "s/#Color/Color/" /etc/pacman.conf
sudo sed -i "s/#ParallelDownloads = 5/ParallelDownloads = $parallel_downloads/" /etc/pacman.conf

sudo pacman -S --needed git curl base-devel
git clone https://aur.archlinux.org/paru.git
cd paru/
makepkg -si
paru -Syu
cd ..
rm -rf paru/

paru -S --needed bluez bluez-utils
if [[ "$desktop" = "gnome" ]]; then
    paru -S --needed gnome-bluetooth-3.0 nautilus-bluetooth
fi
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

paru -S --needed make jdk-temurin python python-pip tk dart kotlin android-tools typescript npm yarn docker docker-compose usbfluxd
paru -S --needed neovim neofetch pfetch cmatrix starship ffmpeg github-cli cdrkit
paru -S --needed openssh sshuttle tmux openvpn resolvconf iio-sensor-proxy
if [[ "$desktop" = "gnome" ]]; then
    paru -S --needed networkmanager-openvpn
fi
paru -S --needed dconf-editor libappindicator-gtk3 gtk-engine-murrine
if [[ "$desktop" = "gnome" ]]; then
    paru -S --needed extension-manager gdm-tools gnome-browser-connector gnome-themes-standard
fi
paru -S --needed gparted obsidian jetbrains-toolbox brave-beta-bin firefox firefox-extension-arch-search
if [ "$lite" = false ]; then
    paru -S --needed deskreen-bin davinci-resolve krita aseprite
    paru -S --needed gamemode lutris steam steamcmd prismlauncher

    #paru -S --needed keyleds
    modprobe uinput
    cd Code/
    git clone https://github.com/MR-R080T/g910-gkey-macro-support.git
    cd g910-gkey-macro-support/
    chmod +x installer-systemd.sh; sudo ./installer-systemd.sh
    sudo systemctl enable g910-gkeys.service
    sudo systemctl start g910-gkeys.service
fi
if [ "$install_vm" = true ]; then
    paru -S --needed qemu-full virt-manager dnsmasq
fi

sudo sed -i "s/#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
sudo systemctl enable sshd.service
sudo systemctl start sshd.service

paru -S --needed discord
mkdir -p ~/.config/discord
cat << EOT > ~/.config/discord/settings.json
{
  "IS_MAXIMIZED": true,
  "IS_MINIMIZED": false,
  "SKIP_HOST_UPDATE": true
}
EOT

paru -S --needed tilix
mkdir -p ~/.config/tilix/schemes
wget  -qO $HOME"/.config/tilix/schemes/afterglow.json" https://git.io/v7QVD
wget  -qO $HOME"/.config/tilix/schemes/adventuretime.json" https://git.io/v7QVg
wget  -qO $HOME"/.config/tilix/schemes/argonaut.json" https://git.io/v7QV5
wget  -qO $HOME"/.config/tilix/schemes/arthur.json" https://git.io/v7QV1
wget  -qO $HOME"/.config/tilix/schemes/atom.json" https://git.io/v7Q27
wget  -qO $HOME"/.config/tilix/schemes/birds-of-paradise.json" https://git.io/v7Q2x
wget  -qO $HOME"/.config/tilix/schemes/blazer.json" https://git.io/v7Q2N
wget  -qO $HOME"/.config/tilix/schemes/broadcast.json" https://git.io/v7QaU
wget  -qO $HOME"/.config/tilix/schemes/brogrammer.json" https://git.io/v7Qa3
wget  -qO $HOME"/.config/tilix/schemes/chalk.json" https://git.io/v7Q2A
wget  -qO $HOME"/.config/tilix/schemes/chalkboard.json" https://git.io/v7Q2h
wget  -qO $HOME"/.config/tilix/schemes/ciapre.json" https://git.io/v7Qae
wget  -qO $HOME"/.config/tilix/schemes/darkside.json" https://git.io/v7QVV
wget  -qO $HOME"/.config/tilix/schemes/dimmed-monokai.json" https://git.io/v7QaJ
wget  -qO $HOME"/.config/tilix/schemes/dracula.json" https://git.io/v7QaT
wget  -qO $HOME"/.config/tilix/schemes/hardcore.json" https://git.io/v7QaY
wget  -qO $HOME"/.config/tilix/schemes/oceanic-next.json" https://git.io/v7QaA

sudo gpasswd -a $USER flutterusers

# none, power-profiles-daemon, tlp, auto-cpufreq, auto-cpufreq+tlp
if [[ $power_management = "power-profiles-daemon" ]]; then
    paru -S --needed power-profiles-daemon
    sudo systemctl enable power-profiles-daemon.service
    sudo systemctl start power-profiles-daemon.service
elif [[ $power_management = "tlp" ]]; then
    paru -S --needed tlp tlpui
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service
    sudo tlp start
elif [[ $power_management = "auto-cpufreq" ]]; then
    cd Code/
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq/
    sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
    cd ~
elif [[ $power_management = "auto-cpufreq+tlp" ]]; then
    paru -S --needed tlp tlpui
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service
    sudo tlp start

    cd Code/
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq/
    sudo ./auto-cpufreq-installer
    sudo auto-cpufreq --install
    cd ~
elif [[ $power_management = "laptop-mode-tools" ]]; then
    paru -S --needed laptop-mode-tools
    sudo systemctl enable laptop-mode.service
    sudo systemctl start laptop-mode.service
elif [[ $power_management = "powertop" ]]; then
    paru -S --needed powertop
    sudo sh -c "echo -e '[Unit]\nDescription=PowerTop\n\n[Service]\nType=oneshot\nRemainAfterExit=true\nExecStart=/usr/bin/powertop --auto-tune\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/powertop.service"
    sudo systemctl enable powertop.service
    sudo systemctl start powertop.service
fi
if [ "$install_thermald" = true ]; then
    paru -S --needed thermald
    sudo systemctl enable thermald.service
    sudo systemctl start thermald.service
fi

paru -S --needed distrobox
xhost +si:localuser:$USER
xhost -

pip install Pillow
if [[ "$desktop" = "gnome" ]]; then
    pip install gnome-extensions-cli
fi

if [ "$install_pentablet" = true ]; then
    # Install drivers for my drawing tablet
    # TODO: Maybe find a solution for updates
    wget https://www.xp-pen.com/download/file/id/1936/pid/300/ext/gz.html -O xp-pen-pentablet.tar.gz
    tar -xvf xp-pen-pentablet.tar.gz --one-top-level
    cd xp-pen-pentablet/*
    sudo ./install.sh
    cd ../../
    rm -rf xp-pen-pentablet/
    rm xp-pen-pentablet.tar.gz
    sudo rm /etc/xdg/autostart/xppentablet.desktop
fi

git clone https://github.com/DaRubyMiner360/nvim.git ~/.config/nvim
nvim +PlugInstall +q2

if [[ "$desktop" = "gnome" ]]; then
    gext enable windowsNavigator@gnome-shell-extensions.gcampax.github.com
    gext enable user-theme@gnome-shell-extensions.gcampax.github.com
    gext enable drive-menu@gnome-shell-extensions.gcampax.github.com
    # Download AATWS - Advanced Alt-Tab Window Switcher
    gext install advanced-alt-tab@G-dH.github.com
    gext disable advanced-alt-tab@G-dH.github.com
    # Download AppIndicator and KStatusNotifierItem Support
    gext install appindicatorsupport@rgcjonas.gmail.com
    gext enable appindicatorsupport@rgcjonas.gmail.com
    # Download Aylur's Widgets
    gext install widgets@aylur
    gext enable widgets@aylur
    # Download Blur my Shell
    gext install blur-my-shell@aunetx
    gext enable blur-my-shell@aunetx
    # Download Click to close overview
    gext install click-to-close-overview@l3nn4rt.github.io
    gext enable click-to-close-overview@l3nn4rt.github.io
    # Download Clipboard Indicator
    gext install clipboard-indicator@tudmotu.com
    gext enable clipboard-indicator@tudmotu.com
    # Download Compiz alike magic lamp effect
    gext install compiz-alike-magic-lamp-effect@hermes83.github.com
    gext disable compiz-alike-magic-lamp-effect@hermes83.github.com
    # Download Compiz windows effect
    gext install compiz-windows-effect@hermes83.github.com
    gext disable compiz-windows-effect@hermes83.github.com
    # Download Coverflow Alt-Tab
    gext install CoverflowAltTab@palatis.blogspot.com
    gext enable CoverflowAltTab@palatis.blogspot.com
    # Download Desktop Cube
    gext install desktop-cube@schneegans.github.com
    gext disable desktop-cube@schneegans.github.com
    # Download Fly-Pie
    gext install flypie@schneegans.github.com
    gext disable flypie@schneegans.github.com
    # Download Gesture Improvements
    gext install gestureImprovements@gestures
    gext enable gestureImprovements@gestures
    # Download Gnome 4x UI Improvements
    gext install gnome-ui-tune@itstime.tech
    gext enable gnome-ui-tune@itstime.tech
    # Download GSConnect
    gext install gsconnect@andyholmes.github.io
    gext disable gsconnect@andyholmes.github.io
    # Download Gtk4 Desktop Icons NG
    gext install gtk4-ding@smedius.gitlab.com
    gext disable gtk4-ding@smedius.gitlab.com
    # Download Just Perfection
    gext install just-perfection-desktop@just-perfection
    gext enable just-perfection-desktop@just-perfection
    # Download Lock Keys
    gext install lockkeys@vaina.lt
    gext enable lockkeys@vaina.lt
    # Download Looking Glass Button
    gext install lgbutton@glerro.gnome.gitlab.io
    gext disable lgbutton@glerro.gnome.gitlab.io
    # Download Native Window Placement
    gext install native-window-placement@gnome-shell-extensions.gcampax.github.com
    gext disable native-window-placement@gnome-shell-extensions.gcampax.github.com
    # Download Night Theme Switcher
    gext install nightthemeswitcher@romainvigier.fr
    gext disable nightthemeswitcher@romainvigier.fr
    # Download Quick Close in Overview
    gext install middleclickclose@paolo.tranquilli.gmail.com
    gext enable middleclickclose@paolo.tranquilli.gmail.com
    # Download Space Bar
    gext install space-bar@luchrioh
    gext enable space-bar@luchrioh
    # Download Status Area Horizontal Spacing
    gext install status-area-horizontal-spacing@mathematical.coffee.gmail.com
    gext enable status-area-horizontal-spacing@mathematical.coffee.gmail.com
    # Download Tray Icons: Reloaded
    gext install trayIconsReloaded@selfmade.pl
    gext disable trayIconsReloaded@selfmade.pl
    # Download Vitals
    gext install Vitals@CoreCoding.com
    gext disable Vitals@CoreCoding.com
    # Download V-Shell (Vertical Workspaces)
    gext install vertical-workspaces@G-dH.github.com
    gext disable vertical-workspaces@G-dH.github.com

    # TODO: Something went wrong during the first test that required a hard reset, so confirm that it was just a random issue that shouldn't happen again
    cd Code/
    git clone https://github.com/pop-os/shell.git pop-shell
    cd pop-shell/
    make local-install
    gsettings --schemadir ~/.local/share/gnome-shell/extensions/pop-shell@system76.com/schemas set org.gnome.shell.extensions.pop-shell activate-launcher "['<Super>space']"
    gext disable pop-shell@system76.com
    cd ~

    cd Code/
    git clone https://github.com/DaRubyMiner360/soft-brightness.git
    cd soft-brightness/
    meson build
    ninja -C build install
    gext enable soft-brightness@fifi.org
    cd ~/Code/
    rm -rf soft-brightness/
    cd ~

    cd Code/
    git clone https://github.com/DaRubyMiner360/dash2dock-lite.git
    cd dash2dock-lite/
    make
    gext enable dash2dock-lite@icedman.github.com
    cd ~/Code/
    rm -rf dash2dock-lite/
    cd ~

    cd Code/
    git clone https://github.com/lofilobzik/gdm-auto-blur.git
    cd gdm-auto-blur/
    mkdir -p ~/.local/bin/
    cp gdm-auto-blur.py ~/.local/bin/gdm-auto-blur
    cd ~/.local/bin/
    chmod +x gdm-auto-blur
    cd ~/Code/
    rm -rf gdm-auto-blur/
    cd ~

    git clone https://github.com/DaRubyMiner360/AutoGDMWallpaper.git ~/.local/share/gnome-shell/extensions/autogdmwallpaper@darubyminer360.github.com/

    git clone https://github.com/DaRubyMiner360/GNOME-LockdownMode.git ~/.local/share/gnome-shell/extensions/lockdown-mode@darubyminer360.github.com/
    cd ~/.local/share/gnome-shell/extensions/lockdown-mode@darubyminer360.github.com/
    sudo ./compile_schemas.sh
    gext enable lockdown-mode@darubyminer360.github.com
    cd ~

    cd Code/
    git clone https://github.com/vinceliuice/Colloid-icon-theme
    cd Colloid-icon-theme/
    ./install.sh
    cd ~/Code/
    rm -rf Colloid-icon-theme/
    cd ~

    cd Code/
    git clone https://github.com/vinceliuice/Lavanda-gtk-theme
    cd Lavanda-gtk-theme/
    ./install.sh
    cd ~/Code/
    rm -rf Lavanda-gtk-theme/
    cd ~

    cd Code/
    git clone https://github.com/4e6anenk0/Rowaita-icon-theme
    cd Rowaita-icon-theme/
    cp -r Rowaita/ ~/.local/share/icons/
    cp -r Rowaita-Default-Dark/ ~/.local/share/icons/
    cp -r Rowaita-Default-Light/ ~/.local/share/icons/
    cp -r Rowaita-Adw-Dark/ ~/.local/share/icons/
    cp -r Rowaita-Adw-Light/ ~/.local/share/icons/
    cp -r Rowaita-Manjaro-Dark/ ~/.local/share/icons/
    cp -r Rowaita-Manjaro-Light/ ~/.local/share/icons/
    cd ~/Code/
    rm -rf Rowaita-icon-theme/
    cd ~

    cd Code/
    git clone https://github.com/imarkoff/Marble-shell-theme.git
    cd Marble-shell-theme/
    python install.py -a
    cd ~/Code/
    rm -rf Marble-shell-theme/
    cd ~

    sudo cp -r ~/.themes/* /usr/share/themes/
    sudo cp -r ~/.local/share/icons/* /usr/share/icons/
fi

cd Code/
# TODO: Fork grub2-themes and make a custom theme based on Tela
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes/
sudo ./install.sh -t tela -i color -s 1080p
cd ~

cd Code/
git clone https://github.com/DaRubyMiner360/PrettyBash.git
cd PrettyBash/
yes | ./setup-arch.sh
cd ~


if ! grep -q "source $HOME/rubyarch.bashrc" ~/.bashrc; then
  cat <<EOT >> ~/.bashrc
source $HOME/rubyarch.bashrc
EOT
fi
cat <<EOT > ~/rubyarch.bashrc
EOT
if [ "$install_pentablet" = true ]; then
    cat <<EOT >> ~/rubyarch.bashrc
alias pentablet="/usr/lib/pentablet/pentablet"
alias xppentablet="pentablet"

EOT
fi
cat <<EOT >> ~/rubyarch.bashrc
alias ls='ls --color=auto -I . -I ..'
alias grep='grep --color=auto'

alias parrotdance="curl parrot.live"
alias rick="curl -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash"

echo ""
#neofetch
pfetch
EOT

mkdir ~/.fonts
cd ~/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Meslo.zip
unzip Meslo.zip
rm Meslo.zip
fc-cache -vf
cd ~

if [[ "$desktop" = "gnome" ]]; then
    wget https://gist.githubusercontent.com/DaRubyMiner360/cc707b5ba7ed68e31f7fb8fc99def457/raw/full-backup
    dconf load / < full-backup
    bash ~/.local/share/gnome-shell/extensions/autogdmwallpaper@darubyminer360.github.com/switch.sh
    rm full-backup
fi

echo "Done!"
echo "Don't worry if the terminal font's spacing is acting up."
echo "You should probably reboot now to fix some potential issues."