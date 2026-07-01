# =============================================================================
#               Configuracion Zsh - Marco Gallegos  (v2.2 macOS)
# =============================================================================
# Basada en v2.1 de Arch Linux, adaptada para macOS Tahoe.
# Historial de cambios:
#   v2.2 - Adaptacion para macOS: brew, comandos sistema, ZeroTier app.
#   v2.1 - Aliases y funciones para Hyprland / hyprctl.
#   v2.0 - Aliases ZeroTier completos, funcion zt-status mejorada,
#          lazy-loading NVM/mise, limpieza de PATH duplicados,
#          funcion sysinfo, aliases SSH extendidos, mejoras generales.

# --- Historial y opciones -----------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt CORRECT

# Deshabilita el bloqueo de la terminal con CTRL+S.
stty -ixon 2>/dev/null

# Habilita colores en `man` y `less`.
export LESS='-R'
export MANPAGER="less -R"

# --- PATH ---------------------------------------------------------------------
typeset -U PATH path              # typeset -U deduplica automaticamente

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PNPM_HOME="$HOME/.local/share/pnpm"

path=(
  "$HOME/.opencode/bin"
  "$PNPM_HOME"
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.npm-global/bin"
  "$GOBIN"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  $path
)

# --- Oh My Zsh ----------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Oh My Posh gestiona el prompt.

plugins=(
  git
  sudo
  history
  colorize
  docker
  docker-compose
  npm
  node
  python
  pip
  golang
  copypath
  copyfile
  command-not-found
  safe-paste
)

export ZSH_DISABLE_COMPFIX=true

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
if [ -n "${LS_COLORS:-}" ]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

source_zsh_plugin() {
  local plugin_name="$1"
  local plugin_file="$2"
  local custom_path="${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin_name/$plugin_file"
  local system_path="/usr/share/zsh/plugins/$plugin_name/$plugin_file"

  if [ -r "$custom_path" ]; then
    source "$custom_path"
  elif [ -r "$system_path" ]; then
    source "$system_path"
  fi
}

source_zsh_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"

# --- Prompt -------------------------------------------------------------------
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f "$HOME/.poshthemes/catppuccin_mocha.omp.json" ]; then
    eval "$(oh-my-posh init zsh --config "$HOME/.poshthemes/catppuccin_mocha.omp.json")"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi

# --- Aliases ------------------------------------------------------------------

# Generales
alias cls='clear'
alias c='clear'
alias t='tmux'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias mkdir='mkdir -pv'

# Informacion del sistema
alias ff='fastfetch'
alias nf='fastfetch'
alias df='df -h'
alias du='du -sh'
alias mem='vm_stat | perl -e '\''
  $/ = undef; $_ = <STDIN>;
  while (/^(\w+):\s+(\d+)/mg) {
    $stats{$1} = $2;
  }
  $ps = 4096;
  printf "Memoria usada  : %.1f MB\n", ($stats{"Pages active"} + $stats{"Pages wired down"}) * $ps / 1024 / 1024;
  printf "Memoria libre  : %.1f MB\n", $stats{"Pages free"} * $ps / 1024 / 1024;
  printf "Total instalada: %.1f MB\n", ($stats{"Pages free"} + $stats{"Pages active"} + $stats{"Pages inactive"} + $stats{"Pages speculative"} + $stats{"Pages wired down"} + ($stats{"Pages purgeable"} // 0)) * $ps / 1024 / 1024;
'\'''

# Homebrew (reemplaza pacman/yay de Arch Linux)
alias brewu='brew update && brew upgrade'
alias brewi='brew install'
alias brewr='brew uninstall'
alias brews='brew search'
alias brewinfo='brew info'
alias brewlist='brew list'
alias brewclean='brew cleanup'
alias brewdoctor='brew doctor'
alias brewoutdated='brew outdated'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gfa='git fetch --all'
alias gfr='git fetch origin'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'
alias glog='git log --oneline --graph --decorate'
alias glog2='git log --oneline --graph --decorate --all'
alias greset='git reset --soft HEAD~1'
gac() { git add . && git commit -m "$1"; }
gacp() { git add . && git commit -m "$1" && git push; }

# Docker
dc() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}
alias d='docker'
alias dps='docker ps -a'
alias dpsq='docker ps -q'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -af --volumes'
alias dnet='docker network ls'

# NPM
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrl='npm run lint'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nci='npm ci'
alias nou='npm outdated'

# OpenCode Web
alias ocw='nohup opencode web > /dev/null 2>&1 & echo "OpenCode Web iniciado en background"'
alias ocws='pkill -f "opencode web" && echo "OpenCode Web detenido" || echo "No se encontro proceso de OpenCode Web"'

# Python
alias pip='pip3'
alias python='python3'
alias py='python'
alias pir='pip install -r requirements.txt'
alias pipi='pip install'
alias pipf='pip freeze > requirements.txt'
alias pipup='pip list --outdated'

# =============================================================================
#                          Z E R O T I E R
# =============================================================================
# Aliases y funciones para gestion de redes ZeroTier.
# En macOS ZeroTier se instala como app (DMG), el daemon corre automaticamente.
# -----------------------------------------------------------------------------

# --- Informacion y estado -----------------------------------------------------
alias zt='sudo zerotier-cli'
alias zti='sudo zerotier-cli info'
alias ztstatus='sudo zerotier-cli listnetworks'
alias ztpeers='sudo zerotier-cli listpeers'
alias ztmoons='sudo zerotier-cli listmoons'

# --- Gestion de redes ---------------------------------------------------------
alias ztjoin='sudo zerotier-cli join'
alias ztleave='sudo zerotier-cli leave'

# --- Control del servicio (macOS: via app/launchd, no systemctl) --------------
# ZeroTier en macOS se gestiona desde la app en la barra de menu o:
#   sudo launchctl start/stop com.zerotier.one
alias ztstart='sudo launchctl start com.zerotier.one && echo "ZeroTier iniciado"'
alias ztstop='sudo launchctl stop com.zerotier.one && echo "ZeroTier detenido"'
alias ztlog='log show --predicate "subsystem == \"com.zerotier.one\"" --last 1h'

# --- Funciones avanzadas ------------------------------------------------------

zt-info() {
  echo "ZeroTier -- Informacion del nodo"
  sudo zerotier-cli info | awk '{
    printf "  ID del nodo : %s\n", $3
    printf "  Version     : %s\n", $4
    printf "  Estado      : %s\n", $5
  }'
}

zt-nets() {
  echo "Redes ZeroTier conectadas:"
  echo ""
  sudo zerotier-cli listnetworks | tail -n +2 | awk '{
    printf "  %-20s  IP: %-18s  Estado: %s\n", $3, $9, $6
  }'
}

zt-peers() {
  local peers
  peers="$(sudo zerotier-cli listpeers 2>/dev/null | tail -n +2)"
  if [ -z "$peers" ]; then
    echo "No se encontraron peers ZeroTier activos."
    return 0
  fi
  echo "Peers ZeroTier:"
  echo ""
  echo "$peers" | awk '{
    role = ($4 == "LEAF") ? "Nodo" : ($4 == "PLANET") ? "Planeta" : "Moon"
    printf "  %-42s  Latencia: %-8s  Rol: %s\n", $1, $3"ms", role
  }'
}

zt-dashboard() {
  echo ""
  echo "========================================"
  echo "   ZeroTier -- Dashboard"
  echo "========================================"
  echo ""
  zt-info
  echo ""
  zt-nets
  echo ""
  local n_peers
  n_peers="$(sudo zerotier-cli listpeers 2>/dev/null | tail -n +2 | wc -l)"
  echo "  Peers activos : $n_peers"
  echo ""
  local svc_status
  svc_status="$(sudo launchctl list | grep com.zerotier.one >/dev/null 2>&1 && echo "active" || echo "inactive")"
  if [ "$svc_status" = "active" ]; then
    echo "  Servicio        : Activo"
  else
    echo "  Servicio        : Inactivo"
  fi
  echo ""
}

# =============================================================================
#                            S S H
# =============================================================================
alias ssh-list='ssh-add -l'
alias ssh-clear='ssh-add -D'
alias ssh-reload='
  ssh-add -D 2>/dev/null
  for key in ~/.ssh/*; do
    if [ -f "$key" ] && [[ ! "$key" =~ \.pub$ ]] && ssh-keygen -l -f "$key" &>/dev/null; then
      ssh-add "$key" 2>/dev/null && echo "Agregada: $(basename "$key")"
    fi
  done
'
alias ssh-hosts='grep "^Host " ~/.ssh/config 2>/dev/null | awk "{print \$2}"'

alias sz='ssh zima_os'
alias sc='ssh claudia'
alias ss='ssh soul23'
alias sgh='ssh -T git@github.com'

# =============================================================================
#                       H Y P R L A N D
# =============================================================================
# Bloque Hyprland: solo se activa si hyprctl existe (no disponible en macOS).
# Se conserva por si usas esta config en una maquina Linux en el futuro.
# -----------------------------------------------------------------------------

if command -v hyprctl >/dev/null 2>&1; then

  alias hypr='hyprctl'
  alias hypr-info='hyprctl version'
  alias hypr-monitors='hyprctl monitors'
  alias hypr-workspaces='hyprctl workspaces'
  alias hypr-clients='hyprctl clients'
  alias hypr-active='hyprctl activewindow'
  alias hypr-devices='hyprctl devices'

  alias hypr-kill='hyprctl dispatch killactive'
  alias hypr-float='hyprctl dispatch togglefloating'
  alias hypr-fullscreen='hyprctl dispatch fullscreen 0'
  alias hypr-maximize='hyprctl dispatch fullscreen 1'
  alias hypr-pseudo='hyprctl dispatch pseudo'
  alias hypr-pin='hyprctl dispatch pin'

  alias hypr-reload='hyprctl reload && echo "Hyprland config recargada"'
  alias hypr-exit='hyprctl dispatch exit'
  alias hypr-kill-all='hyprctl kill'

  hypr-ws() {
    if [ -z "$1" ]; then
      echo "Workspaces activos:"
      hyprctl workspaces -j 2>/dev/null \
        | python3 -c "
import json, sys
ws = json.load(sys.stdin)
for w in sorted(ws, key=lambda x: x['id']):
    print(f\"  [{w['id']:>2}] {w['name']:<20} ventanas: {w['windows']}\")
" 2>/dev/null || hyprctl workspaces
    else
      hyprctl dispatch workspace "$1" && echo "Workspace $1 activo"
    fi
  }

  hypr-move() {
    [ -z "$1" ] && echo "Uso: hypr-move <workspace>" && return 1
    hyprctl dispatch movetoworkspace "$1" && echo "Ventana movida al workspace $1"
  }

  hypr-dispatch() {
    [ -z "$1" ] && echo "Uso: hypr-dispatch <accion> [args]" && return 1
    hyprctl dispatch "$@"
  }

  hypr-dashboard() {
    echo ""
    echo "========================================"
    echo "   Hyprland -- Dashboard"
    echo "========================================"
    echo ""
    echo "  $(hyprctl version | head -1)"
    echo ""
    echo "  Monitores:"
    hyprctl monitors -j 2>/dev/null \
      | python3 -c "
import json, sys
ms = json.load(sys.stdin)
for m in ms:
    print(f\"    {m['name']}: {m['width']}x{m['height']}@{m['refreshRate']:.0f}Hz  escala: {m['scale']}\")
" 2>/dev/null || hyprctl monitors | grep -E "Monitor|resolution"
    echo ""
    echo "  Workspaces activos : $(hyprctl workspaces -j 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo '?')"
    echo "  Ventanas abiertas  : $(hyprctl clients -j 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo '?')"
    echo ""
    echo "  Ventana activa:"
    hyprctl activewindow 2>/dev/null | grep -E "class|title" | sed 's/^/    /'
    echo ""
  }

fi

# --- Utilidades ---------------------------------------------------------------
alias clima='curl wttr.in/Saltillo'
alias myip='curl -s ifconfig.me && echo'
alias localip='ifconfig | grep "inet " | grep -v 127.0.0.1 | awk "{print \$2}"'
alias ports='lsof -i -P -n | grep LISTEN'

# yt-dlp
alias ytv='noglob _ytv'
alias ytm='noglob _ytm'

# =============================================================================
#                         F U N C I O N E S
# =============================================================================

venv() {
  case "$1" in
    create)
      python -m venv .venv && echo "Entorno virtual creado en ./.venv"
      ;;
    on|activate)
      if [ -f ".venv/bin/activate" ]; then
        . .venv/bin/activate
        echo "Entorno virtual activado"
      else
        echo "Entorno virtual no encontrado en ./.venv"
      fi
      ;;
    off|deactivate)
      if command -v deactivate >/dev/null 2>&1; then
        deactivate 2>/dev/null
        echo "Entorno virtual desactivado"
      else
        echo "No hay un entorno virtual activo para desactivar"
      fi
      ;;
    *)
      echo "Uso: venv [create|on|off|activate|deactivate]"
      ;;
  esac
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  [ ! -f "$1" ] && echo "No es un archivo" && return 1

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.rar)     unrar e "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.tar)     tar xf "$1" ;;
    *.tbz2)    tar xjf "$1" ;;
    *.tgz)     tar xzf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.Z)       uncompress "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "No se puede extraer '$1': formato no reconocido." ;;
  esac
}

killport() {
  [ $# -eq 0 ] && echo "Uso: killport <puerto>" && return 1

  local pid
  pid="$(lsof -ti:"$1" 2>/dev/null)"

  if [ -n "$pid" ]; then
    kill -9 "$pid" && echo "Proceso en puerto $1 eliminado (PID: $pid)"
  else
    echo "No se encontro ningun proceso en el puerto $1"
  fi
}

serve() {
  python -m http.server "${1:-8000}"
}

# resumen del sistema adaptado para macOS
sysinfo() {
  echo ""
  echo "  Host     : $(hostname)"
  echo "  Usuario  : $USER"
  echo "  Shell    : $SHELL"
  echo "  Kernel   : $(uname -r)"
  echo "  OS       : $(sw_vers -productName) $(sw_vers -productVersion)"
  echo "  Uptime   : $(uptime -p 2>/dev/null || uptime)"
  echo "  RAM      : $(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{printf "%.1f GB disponibles", (100-$5)*('"$(sysctl -n hw.memsize)"')/100/1024/1024/1024}' || vm_stat | perl -e '$/ = undef; $_ = <STDIN>; if (/Pages free:\s+(\d+)/) { printf "%.1f GB libres", $1 * 4096 / 1024 / 1024 / 1024 }')"
  echo "  Paquetes : $(brew list 2>/dev/null | wc -l | tr -d ' ') (brew)"
  echo ""
}

# busca texto en archivos del directorio actual recursivamente
buscar() {
  [ $# -eq 0 ] && echo "Uso: buscar <texto> [directorio]" && return 1
  grep -rn --color=auto "$1" "${2:-.}"
}

# crea un backup rapido de un archivo con timestamp
backup() {
  [ ! -f "$1" ] && echo "Archivo no encontrado: $1" && return 1
  local dest="${1}.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$1" "$dest" && echo "Backup creado: $dest"
}

# --- yt-dlp -------------------------------------------------------------------
export YTDLP_DIR="$HOME/Videos/YouTube"

ensure_ytdlp_dirs() {
  mkdir -p "$YTDLP_DIR/Music" "$YTDLP_DIR/Videos" 2>/dev/null
}

_ytm() {
  case "$1" in
    -h|--help|'')
      echo "ytm <URL|busqueda> - Descarga audio (MP3 320kbps) a $YTDLP_DIR/Music/"
      echo "Ejemplos:"
      echo "  ytm https://youtu.be/dQw4w9WgXcQ"
      echo "  ytm 'Never Gonna Give You Up'"
      return 0
      ;;
  esac

  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "yt-dlp no esta instalado. Por favor, instalalo para usar esta funcion."
    return 1
  fi

  ensure_ytdlp_dirs

  local out="$YTDLP_DIR/Music/%(title).180s.%(ext)s"
  local opts=(
    --extract-audio --audio-format mp3 --audio-quality 320K
    --embed-metadata --embed-thumbnail --convert-thumbnails jpg
    --no-playlist --retries 10 --fragment-retries 10
    --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    --extractor-args "youtube:player_client=android,web"
    --progress --newline -o "$out"
  )

  if [[ "$1" == http* ]]; then
    echo "Descargando audio..."
    yt-dlp "${opts[@]}" "$@"
  else
    echo "Buscando: $*"
    yt-dlp "${opts[@]}" "ytsearch1:$*"
  fi

  [ $? -eq 0 ] && echo "Audio descargado en: $YTDLP_DIR/Music/" || echo "Fallo la descarga de audio."
}

_ytv() {
  case "$1" in
    -h|--help|'')
      echo "ytv <URL|busqueda> [calidad] - Descarga video a $YTDLP_DIR/Videos/"
      echo "Calidades disponibles: 1080, 720, 480 (por defecto: mejor disponible MP4)"
      echo "Ejemplos:"
      echo "  ytv https://youtu.be/dQw4w9WgXcQ 1080"
      echo "  ytv 'Rick Astley - Never Gonna Give You Up' 720"
      return 0
      ;;
  esac

  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "yt-dlp no esta instalado. Por favor, instalalo para usar esta funcion."
    return 1
  fi

  ensure_ytdlp_dirs

  local quality="${2:-best}"
  local out="$YTDLP_DIR/Videos/%(title).180s.%(ext)s"
  local fmt

  case "$quality" in
    1080) fmt='bv*[height<=1080][ext=mp4]+ba/b[height<=1080]' ;;
    720)  fmt='bv*[height<=720][ext=mp4]+ba/b[height<=720]' ;;
    480)  fmt='bv*[height<=480][ext=mp4]+ba/b[height<=480]' ;;
    *)    fmt='bv*[ext=mp4]+ba/b[ext=mp4]/b' ;;
  esac

  local opts=(
    -f "$fmt" --embed-metadata --embed-thumbnail
    --embed-subs --sub-langs "es.*,en.*" --convert-thumbnails jpg
    --no-playlist --retries 10 --fragment-retries 10
    --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    --extractor-args "youtube:player_client=android,web"
    --progress --newline -o "$out"
  )

  if [[ "$1" == http* ]]; then
    echo "Descargando video..."
    yt-dlp "${opts[@]}" "$1"
  else
    echo "Buscando: $1"
    yt-dlp "${opts[@]}" "ytsearch1:$1"
  fi

  [ $? -eq 0 ] && echo "Video descargado en: $YTDLP_DIR/Videos/" || echo "Fallo la descarga de video."
}

yls() {
  ensure_ytdlp_dirs

  echo "Ultimos 5 audios descargados en Music:"
  ls -1t "$YTDLP_DIR/Music" 2>/dev/null | head -5 | sed 's/^/  /' || echo "  (vacio)"
  echo ""
  echo "Ultimos 5 videos descargados en Videos:"
  ls -1t "$YTDLP_DIR/Videos" 2>/dev/null | head -5 | sed 's/^/  /' || echo "  (vacio)"
}

# --- Herramientas externas ----------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias zz='z -'
  alias zi='zi'
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  alias mise-list='mise list'
  alias mise-current='mise current'
  alias mise-install='mise install'
  alias mise-use='mise use'
fi

# --- Funciones y configuraciones locales --------------------------------------
[ -d "$HOME/.zsh_functions" ] || mkdir -p "$HOME/.zsh_functions"
for func_file in "$HOME/.zsh_functions"/*.zsh(N); do
  source "$func_file"
done

[ -f "$HOME/.zshrc.help" ]  && source "$HOME/.zshrc.help"
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# zsh-syntax-highlighting debe cargarse al final.
source_zsh_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"

# --- SSH (Keychain de macOS) --------------------------------------------------
ssh-add -A 2>/dev/null

# Added by Antigravity
export PATH="/Users/marco/.antigravity/antigravity/bin:$PATH"
export EDITOR="$HOME/bin/coteditor-wrapper.sh"

# Iniciar túnel SSH automáticamente si no está corriendo
# COMENTADO - servidor formateado, pendiente de reconfigurar
# if ! lsof -i :19111 2>/dev/null | grep -q LISTEN; then
#     autossh -M 0 -N -L 19111:localhost:19111 -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -o BatchMode=yes umbrel >/dev/null 2>&1 &
#     echo "[Túnel SSH iniciado en puerto 19111]"
# fi


# Added by Antigravity CLI installer
export PATH="/Users/marco/.local/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/marco/.antigravity-ide/antigravity-ide/bin:$PATH"


