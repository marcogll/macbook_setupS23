#!/bin/bash

# Script de instalación para MacBook S23
# Configura automáticamente un desarrollo completo de macOS con todas las dependencias necesarias

set -e

# --- Colores y formato ---------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Contador de progreso ---------------------------------------------------------------
TOTAL_STEPS=29
CURRENT_STEP=0

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  local pct=$((CURRENT_STEP * 100 / TOTAL_STEPS))
  local filled=$((pct / 2))
  local empty=$((50 - filled))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  [$CURRENT_STEP/$TOTAL_STEPS] ${GREEN}[$bar] ${pct}%${NC}  $1"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log() {
  echo -e "  ${GREEN}✓${NC} $1"
}

warn() {
  echo -e "  ${YELLOW}→${NC} $1"
}

skip() {
  echo -e "  ${BLUE}⊘${NC} $1 (ya instalado)"
}

error() {
  echo -e "  ${RED}✗${NC} $1" >&2
}

# --- Detección de macOS ---------------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
  error "Este script debe ejecutarse en macOS."
  exit 1
fi

echo -e "${BOLD}${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         MACBOOK S23 - SETUP COMPLETO DE DESARROLLO        ║"
echo "║                    $(date '+%Y-%m-%d %H:%M')                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- 1. Xcode Command Line Tools ------------------------------------------------------
progress "Xcode Command Line Tools (clang, make, git)"
if ! xcode-select -p &>/dev/null; then
  warn "Instalando Xcode Command Line Tools..."
  xcode-select --install 2>/dev/null || true
  echo "  ⏳ Se abrirá un diálogo. Sígalo y vuelva a ejecutar este script después."
  exit 1
else
  skip "Xcode CLT ya presente en $(xcode-select -p)"
fi

# --- 2. Homebrew -----------------------------------------------------------------------
progress "Homebrew (gestor de paquetes)"
if ! command -v brew &>/dev/null; then
  warn "Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  if ! command -v brew &>/dev/null; then
    error "Homebrew no pudo instalarse. Instale manualmente: https://brew.sh"
    exit 1
  fi
  log "Homebrew instalado: $(brew --version | head -1)"
else
  skip "Homebrew $(brew --version | head -1)"
fi

# --- 3. Build essentials (gcc, autoconf, etc.) ----------------------------------------
progress "Build essentials (gcc, autoconf, automake, libtool, pkg-config)"
BUILD_PKGS=(gcc autoconf automake libtool pkg-config)
for pkg in "${BUILD_PKGS[@]}"; do
  if ! brew list "$pkg" &>/dev/null; then
    warn "Instalando $pkg..."
    brew install "$pkg" 2>/dev/null
    log "$pkg instalado"
  else
    skip "$pkg ya instalado"
  fi
done

# --- 4. mise ---------------------------------------------------------------------------
progress "mise (gestor de versiones de lenguajes)"
if ! command -v mise &>/dev/null; then
  warn "Instalando mise..."
  brew install mise
  log "mise $(mise --version)"
else
  skip "mise $(mise --version)"
fi

# --- 5. Oh My Zsh ---------------------------------------------------------------------
progress "Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  warn "Instalando Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log "Oh My Zsh instalado"
else
  skip "Oh My Zsh ya presente"
fi

# --- 6. Oh My Posh + tema catppuccin --------------------------------------------------
progress "Oh My Posh + tema catppuccin"
if ! command -v oh-my-posh &>/dev/null; then
  warn "Instalando Oh My Posh..."
  brew install oh-my-posh
  log "Oh My Posh $(oh-my-posh --version)"
else
  skip "Oh My Posh $(oh-my-posh --version)"
fi

if [ ! -f "$HOME/.poshthemes/catppuccin_mocha.omp.json" ]; then
  warn "Copiando tema catppuccin..."
  mkdir -p "$HOME/.poshthemes"
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [ -f "$SCRIPT_DIR/catppuccin_mocha.omp.json" ]; then
    cp "$SCRIPT_DIR/catppuccin_mocha.omp.json" "$HOME/.poshthemes/"
    log "Tema catppuccin copiado"
  else
    warn "Archivo catppuccin_mocha.omp.json no encontrado en $SCRIPT_DIR"
  fi
fi

# --- 7. Zsh plugins -------------------------------------------------------------------
progress "Plugins zsh (autosuggestions, syntax-highlighting)"
PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$PLUGINS_DIR/$plugin" ]; then
    warn "Clonando $plugin..."
    git clone "https://github.com/zsh-users/$plugin.git" "$PLUGINS_DIR/$plugin" 2>/dev/null
    log "$plugin clonado"
  else
    skip "$plugin ya presente"
  fi
done

# --- 8. Go -----------------------------------------------------------------------------
progress "Go"
if ! command -v go &>/dev/null; then
  warn "Instalando Go..."
  brew install go
  log "Go $(go version | awk '{print $3}')"
else
  skip "Go $(go version | awk '{print $3}')"
fi

# --- 9. Node.js + npm + pnpm ---------------------------------------------------------
progress "Node.js + npm + pnpm"
if ! command -v node &>/dev/null; then
  warn "Instalando Node.js via mise..."
  mise use --global node@lts
  log "Node.js $(node -v)"
else
  skip "Node.js $(node -v)"
fi
if ! command -v npm &>/dev/null; then
  warn "Instalando npm..."
  brew install npm
  log "npm $(npm -v)"
else
  skip "npm $(npm -v)"
fi
if ! command -v pnpm &>/dev/null; then
  warn "Instalando pnpm..."
  brew install pnpm
  log "pnpm $(pnpm -v)"
else
  skip "pnpm $(pnpm -v)"
fi

# --- 10. Python + pip -----------------------------------------------------------------
progress "Python + pip"
if ! command -v python3 &>/dev/null; then
  warn "Instalando Python..."
  brew install python
  log "Python $(python3 --version | awk '{print $2}')"
else
  skip "Python $(python3 --version | awk '{print $2}')"
fi
if ! command -v pip3 &>/dev/null; then
  warn "Instalando pip..."
  brew install python 2>/dev/null || true
fi

# --- 11. Ruby --------------------------------------------------------------------------
progress "Ruby"
if ! command -v ruby &>/dev/null; then
  warn "Instalando Ruby..."
  brew install ruby
  log "Ruby $(ruby -v | awk '{print $2}')"
else
  skip "Ruby $(ruby -v | awk '{print $2}')"
fi

# --- 12. Java (OpenJDK) ---------------------------------------------------------------
progress "Java (OpenJDK)"
if ! command -v java &>/dev/null; then
  warn "Instalando OpenJDK..."
  brew install openjdk
  log "Java instalado"
else
  skip "Java ya presente"
fi

# --- 13. GitHub CLI -------------------------------------------------------------------
progress "GitHub CLI (gh)"
if ! command -v gh &>/dev/null; then
  warn "Instalando GitHub CLI..."
  brew install gh
  log "gh $(gh --version | head -1 | awk '{print $3}')"
else
  skip "gh $(gh --version | head -1 | awk '{print $3}')"
fi

# --- 14. Docker Desktop ---------------------------------------------------------------
progress "Docker Desktop"
if ! command -v docker &>/dev/null; then
  if [ ! -d "/Applications/Docker.app" ]; then
    warn "Descargando Docker Desktop..."
    curl -L "https://desktop.docker.com/mac/main/arm64/Docker.dmg" -o "/tmp/Docker.dmg"
    hdiutil attach "/tmp/Docker.dmg" -mountpoint /tmp/docker_mnt -nobrowse
    cp -a "/tmp/docker_mnt/Docker.app" "/Applications/"
    hdiutil detach /tmp/docker_mnt
    rm -f "/tmp/Docker.dmg"
    warn "Docker Desktop instalado. Ábralo para completar la configuración."
  else
    skip "Docker Desktop ya en /Applications"
  fi
else
  skip "Docker $(docker --version | awk '{print $3}' | tr -d ',')"
fi

# --- 15. yt-dlp ------------------------------------------------------------------------
progress "yt-dlp"
if ! command -v yt-dlp &>/dev/null; then
  warn "Instalando yt-dlp..."
  brew install yt-dlp
  log "yt-dlp $(yt-dlp --version)"
else
  skip "yt-dlp $(yt-dlp --version)"
fi

# --- 16. wget --------------------------------------------------------------------------
progress "wget"
if ! command -v wget &>/dev/null; then
  warn "Instalando wget..."
  brew install wget
  log "wget instalado"
else
  skip "wget ya presente"
fi

# --- 17. p7zip + unrar ----------------------------------------------------------------
progress "p7zip + unrar"
if ! command -v 7z &>/dev/null; then
  warn "Instalando p7zip..."
  brew install p7zip
  log "p7zip instalado"
else
  skip "p7zip ya presente"
fi
if ! command -v unrar &>/dev/null; then
  warn "Instalando unrar..."
  brew install unrar
  log "unrar instalado"
else
  skip "unrar ya presente"
fi

# --- 18. git ---------------------------------------------------------------------------
progress "git"
if ! command -v git &>/dev/null; then
  warn "Instalando git..."
  brew install git
  log "git $(git --version | awk '{print $3}')"
else
  skip "git $(git --version | awk '{print $3}')"
fi

# --- 19. make + cmake ------------------------------------------------------------------
progress "make + cmake"
if ! command -v make &>/dev/null; then
  warn "Instalando make..."
  brew install make
  log "make instalado"
else
  skip "make ya presente"
fi
if ! command -v cmake &>/dev/null; then
  warn "Instalando cmake..."
  brew install cmake
  log "cmake $(cmake --version | head -1 | awk '{print $3}')"
else
  skip "cmake $(cmake --version | head -1 | awk '{print $3}')"
fi

# --- 20. curl (actualizado) -----------------------------------------------------------
progress "curl"
if ! command -v curl &>/dev/null; then
  warn "Instalando curl..."
  brew install curl
  log "curl instalado"
else
  skip "curl $(curl --version | head -1 | awk '{print $2}')"
fi

# --- 21. jq + yq -----------------------------------------------------------------------
progress "jq + yq"
if ! command -v jq &>/dev/null; then
  warn "Instalando jq..."
  brew install jq
  log "jq $(jq --version)"
else
  skip "jq $(jq --version)"
fi
if ! command -v yq &>/dev/null; then
  warn "Instalando yq..."
  brew install yq
  log "yq $(yq --version | awk '{print $4}')"
else
  skip "yq ya presente"
fi

# --- 22. gnupg (gpg) ------------------------------------------------------------------
progress "gnupg (gpg)"
if ! command -v gpg &>/dev/null; then
  warn "Instalando gnupg..."
  brew install gnupg
  log "gpg instalado"
else
  skip "gpg ya presente"
fi

# --- 23. fzf ---------------------------------------------------------------------------
progress "fzf"
if ! command -v fzf &>/dev/null; then
  warn "Instalando fzf..."
  brew install fzf
  log "fzf $(fzf --version | awk '{print $1}')"
else
  skip "fzf $(fzf --version | awk '{print $1}')"
fi

# --- 24. tmux --------------------------------------------------------------------------
progress "tmux"
if ! command -v tmux &>/dev/null; then
  warn "Instalando tmux..."
  brew install tmux
  log "tmux $(tmux -V | awk '{print $2}')"
else
  skip "tmux $(tmux -V | awk '{print $2}')"
fi

# --- 25. fastfetch ---------------------------------------------------------------------
progress "fastfetch"
if ! command -v fastfetch &>/dev/null; then
  warn "Instalando fastfetch..."
  brew install fastfetch
  log "fastfetch instalado"
else
  skip "fastfetch ya presente"
fi

# --- 26. GitHub Desktop ---------------------------------------------------------------
progress "GitHub Desktop"
if [ ! -d "/Applications/GitHub Desktop.app" ] && [ ! -d "/Applications/Github Desktop.app" ]; then
  warn "Descargando GitHub Desktop..."
  curl -L "https://central.github.com/download-mac-latest" -o "/tmp/GitHubDesktop.dmg"
  hdiutil attach "/tmp/GitHubDesktop.dmg" -mountpoint /tmp/github_mnt -nobrowse
  cp -a "/tmp/github_mnt/GitHub Desktop.app" "/Applications/"
  hdiutil detach /tmp/github_mnt
  rm -f "/tmp/GitHubDesktop.dmg"
  log "GitHub Desktop instalado"
else
  skip "GitHub Desktop ya presente"
fi

# --- 27. opencode ----------------------------------------------------------------------
progress "opencode"
if ! command -v opencode &>/dev/null; then
  warn "Instalando opencode..."
  mise install opencode@latest 2>/dev/null || {
    warn "Intentando instalar opencode via npm..."
    npm install -g @anomalyco/opencode 2>/dev/null || true
  }
  if ! command -v opencode &>/dev/null; then
    warn "Agregando opencode al PATH..."
    mkdir -p "$HOME/.opencode/bin"
    echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$HOME/.zshrc"
  fi
  log "opencode instalado"
else
  skip "opencode ya presente"
fi

# --- 29. ZeroTier (opcional) -----------------------------------------------------------
progress "ZeroTier (opcional)"
if ! command -v zerotier-cli &>/dev/null; then
  if [ ! -d "/Applications/ZeroTier.app" ]; then
    warn "Instalando ZeroTier..."
    brew install --cask zerotier-one
    log "ZeroTier instalado"
  else
    skip "ZeroTier ya en /Applications"
  fi
else
  skip "ZeroTier ya presente"
fi

# --- Configurar .zshrc ----------------------------------------------------------------
progress "Configurar .zshrc"
if ! grep -q "oh-my-posh init" "$HOME/.zshrc" 2>/dev/null; then
  warn "Agregando configuración de oh-my-posh a .zshrc..."
  cat >> "$HOME/.zshrc" << 'ZSHEOF'

# --- Oh My Posh ------------------------------------------------------
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f "$HOME/.poshthemes/catppuccin_mocha.omp.json" ]; then
    eval "$(oh-my-posh init zsh --config "$HOME/.poshthemes/catppuccin_mocha.omp.json")"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi
ZSHEOF
  log "oh-my-posh agregado a .zshrc"
else
  skip "oh-my-posh ya configurado en .zshrc"
fi

# Backup de .zshrc
mkdir -p "$HOME/.config/zsh"
cp "$HOME/.zshrc" "$HOME/.config/zsh/" 2>/dev/null || true

# --- Resumen final ---------------------------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗"
echo "║                  INSTALACIÓN COMPLETADA                   ║"
echo -e "╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Resumen:${NC}"
echo "  • Xcode CLT      $(xcode-select -p 2>/dev/null && echo '✓' || echo '✗')"
echo "  • Homebrew        $(command -v brew &>/dev/null && echo "✓ $(brew --version | head -1)" || echo '✗')"
echo "  • mise            $(command -v mise &>/dev/null && echo "✓ $(mise --version)" || echo '✗')"
echo "  • Go              $(command -v go &>/dev/null && echo "✓ $(go version | awk '{print $3}')" || echo '✗')"
echo "  • Node.js         $(command -v node &>/dev/null && echo "✓ $(node -v)" || echo '✗')"
echo "  • Python          $(command -v python3 &>/dev/null && echo "✓ $(python3 --version | awk '{print $2}')" || echo '✗')"
echo "  • Ruby            $(command -v ruby &>/dev/null && echo "✓ $(ruby -v | awk '{print $2}')" || echo '✗')"
echo "  • Java            $(command -v java &>/dev/null && echo '✓' || echo '✗')"
echo "  • gcc             $(command -v gcc &>/dev/null && echo "✓ $(gcc --version | head -1 | awk '{print $3}')" || echo '✗')"
echo "  • autoconf        $(command -v autoconf &>/dev/null && echo '✓' || echo '✗')"
echo "  • pkg-config      $(command -v pkg-config &>/dev/null && echo '✓' || echo '✗')"
echo "  • Docker          $(command -v docker &>/dev/null && echo "✓" || echo '○ pendiente')"
echo "  • GitHub CLI      $(command -v gh &>/dev/null && echo "✓ $(gh --version | head -1 | awk '{print $3}')" || echo '✗')"
echo "  • opencode        $(command -v opencode &>/dev/null && echo '✓' || echo '✗')"
echo "  • ZeroTier        $(command -v zerotier-cli &>/dev/null && echo '✓' || ( [ -d "/Applications/ZeroTier.app" ] && echo '✓ (app)' || echo '○ pendiente' ))"
echo ""

# --- Configurar ZeroTier (network ID) -------------------------------------------------
if command -v zerotier-cli &>/dev/null || [ -d "/Applications/ZeroTier.app" ]; then
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  CONFIGURAR ZEROTIER (opcional)${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ZeroTier está instalado. ¿Quieres unirte a una red ahora?"
  echo -e "  Ingresa tu ${BOLD}Network ID${NC} (16 caracteres hexadecimales), o presiona ${BOLD}Enter${NC} para omitir."
  echo ""
  read -r -p "  Network ID: " ZT_NETWORK_ID
  if [ -n "$ZT_NETWORK_ID" ]; then
    # Iniciar servicio si no está corriendo
    if ! pgrep -x "ZeroTier" >/dev/null 2>&1; then
      warn "Iniciando ZeroTier..."
      open -a ZeroTier 2>/dev/null || true
      sleep 3
    fi
    warn "Uniéndose a la red $ZT_NETWORK_ID..."
    sudo zerotier-cli join "$ZT_NETWORK_ID" 2>/dev/null && log "Uniéndose a la red $ZT_NETWORK_ID" || error "No se pudo unir a la red. Verifica el Network ID."
    echo ""
    echo -e "  ${YELLOW}Nota: Debes aprobar el dispositivo en https://my.zerotier.com/network/${NC}"
  else
    echo -e "  ${BLUE}Omitido. Para unirte después ejecuta: sudo zerotier-cli join <network-id>${NC}"
  fi
  echo ""
fi

echo -e "${YELLOW}Reinicie la terminal para aplicar todos los cambios.${NC}"
echo -e "${CYAN}Si Docker no está listo, ábralo manualmente desde /Applications/.${NC}"
