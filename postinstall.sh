#!/usr/bin/env bash
#
# postinstall.sh - Instalar e configura programas no Pop!_OS (20.04 LTS ou superior)
# 
# Base {
#   Website:       https://diolinux.com.br
#   Autor:         Dionatan Simioni
# }
#
# Modificações {
#   Github:       https://github.com/Gabriel-Leao
#   Autor:         Gabriel Leão
# }
#
# ------------------------------------------------------------------------ #
#
# COMO USAR?
# $ ./postinstall.sh
#
# ----------------------------- VARIÁVEIS ----------------------------- #
set -e

##URLS
URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_VS_CODE="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
URL_HYPER="https://releases.hyper.is/download/deb"


##DIRETÓRIOS E ARQUIVOS
DIRETORIO_DOWNLOADS="$HOME/Downloads/programas"


#CORES
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
SEM_COR='\e[0m'


#FUNÇÕES

# Atualizando repositório e fazendo atualização do sistema
apt_update() {
  sudo apt update && sudo apt dist-upgrade -y
}

# -------------------------------------------------------------------------------- #
# -------------------------------TESTES E REQUISITOS------------------------------ #

# Internet conectando?
testes_internet() {
  if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
    echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${SEM_COR}"
    exit 1
  else
    echo -e "${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}"
  fi
}

# ------------------------------------------------------------------------------ #


## Removendo travas eventuais do apt ##
travas_apt() {
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
}

## Atualizando o repositório ##
just_apt_update() {
  sudo apt update -y
}

##DEB SOFTWARES TO INSTALL
PROGRAMAS_PARA_INSTALAR=(
  snapd
  vlc
  git
  wget
  gnome-tweaks
  zsh
)

# ---------------------------------------------------------------------- #

## Download e instalaçao de programas externos ##
install_debs() {

  echo -e "${VERDE}[INFO] - Baixando pacotes .deb${SEM_COR}"

  mkdir "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_GOOGLE_CHROME"       -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_VS_CODE"             -P "$DIRETORIO_DOWNLOADS"
  wget -c "$URL_HYPER"               -P "$DIRETORIO_DOWNLOADS"

  ## Instalando pacotes .deb baixados na sessão anterior ##
  echo -e "${VERDE}[INFO] - Instalando pacotes .deb baixados${SEM_COR}"
  sudo dpkg -i $DIRETORIO_DOWNLOADS/*.deb

  # Instalar programas no apt
  echo -e "${VERDE}[INFO] - Instalando pacotes apt do repositório${SEM_COR}"

for nome_do_programa in ${PROGRAMAS_PARA_INSTALAR[@]}; do
  if ! dpkg -l | grep -q $nome_do_programa; then # Só instala se já não estiver instalado
    sudo apt install "$nome_do_programa" -y
  else
    echo "[INSTALADO] - $nome_do_programa"
  fi
done

}
## Instalando pacotes Flatpak ##
install_flatpaks() {

  echo -e "${VERDE}[INFO] - Instalando pacotes flatpak${SEM_COR}"

  flatpak install flathub org.gimp.GIMP -y
  flatpak install flathub org.qbittorrent.qBittorrent -y
  flatpak install flathub com.spotify.Client -y
  flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community -y
  flatpak install flathub com.discordapp.Discord -y
  flatpak install flathub com.getpostman.Postman -y
  flatpak install flathub com.valvesoftware.Steam -y
  flatpak install flathub com.bitwarden.desktop -y
}

## Instalando pacotes Snap ##

install_snaps() {

  echo -e "${VERDE}[INFO] - Instalando pacotes snap${SEM_COR}"

  sudo snap install authy
}


# -------------------------------------------------------------------------- #
# ----------------------------- PÓS-INSTALAÇÃO ----------------------------- #


## Finalização, atualização e limpeza##
system_clean() {

  apt_update -y
  flatpak update -y
  sudo apt autoclean -y
  sudo apt autoremove -y
  nautilus -q
}


# -------------------------------------------------------------------------- #
# ----------------------------- CONFIGS EXTRAS ----------------------------- #

#Cria pastas e remove alguns apps
extra_config() {

  mkdir /home/$USER/Projects
  mkdir /home/$USER/Torrent

  sudo apt purge firefox
  sudo apt purge geary
}

#Configurações do Git
git_config() {

  git config --global user.name "Gabriel-Leao" 
  git config --global user.email gabriel.leao2507@gmail.com  
  git config --global core.editor vscode  
  git config --global init.defaultBranch main
}

#Instalando tema para personalizar o gnome
install_theme() {

  cd $HOME/Downloads 
  git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git 
  git clone https://github.com/vinceliuice/Colloid-icon-theme 
  cd WhiteSur-gtk-theme-master
  ./install.sh -y
  cd ..
  cd Colloid-icon-theme 
  sudo ./install.sh -y
  cd ..
  rm -r WhiteSur-gtk-theme-master
  rm -r Colloid-icon-theme
  cd
}

# Instalando node version manager
install_nvm() {

  curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install 16.14.0
  npm install -g yarn
}

# -------------------------------------------------------------------------------- #
# -------------------------------EXECUÇÃO----------------------------------------- #

travas_apt
testes_internet
travas_apt
apt_update
travas_apt
just_apt_update
install_debs
install_flatpaks
install_snaps
extra_config
git_config
install_theme
install_nvm
apt_update
system_clean

## finalização
echo -e "${VERDE}[INFO] - Script finalizado, instalação concluída! :)${SEM_COR}"