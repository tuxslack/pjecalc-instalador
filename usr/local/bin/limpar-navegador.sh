#!/bin/bash
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     16/04/2025 as 21:36:36
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  MIT

# Instalação PJeCalc Cidadão

# https://blog.desdelinux.net/pt/verifique-se-um-arquivo-ou-pasta-existe-ou-n%C3%A3o-e-mais-com-if-loop/
# https://www.cyberciti.biz/faq/check-if-a-directory-exists-in-linux-or-unix-shell/

# O script não limpa vários navegadores simultaneamente, apenas um por vez.


clear


# Variáveis iniciais


log="/tmp/limpeza_navegadores.log"

log_detalhado=0


# Ajuste conforme seu ícone preferido

logo="/usr/share/pixmaps/limpar-navegadores.svg"





echo "🧹 Limpando dados de navegadores...


Esses são os principais e mais usados:

Chromium	~/.config/chromium / ~/.cache/chromium
Google Chrome	~/.config/google-chrome / ~/.cache/google-chrome
Microsoft Edge	~/.config/microsoft-edge / ~/.cache/microsoft-edge
Opera	~/.config/opera / ~/.cache/opera
Opera GX	~/.config/opera_gx / ~/.cache/opera_gx
Firefox	~/.mozilla / ~/.cache/mozilla
Brave	~/.config/BraveSoftware / ~/.cache/BraveSoftware
Vivaldi	~/.config/vivaldi / ~/.cache/vivaldi
Falkon	~/.config/falkon / ~/.cache/falkon
Midori	~/.config/midori / ~/.cache/midori
Epiphany (GNOME Web)	~/.config/epiphany / ~/.cache/epiphany


Alguns menos conhecidos ou de nicho:

Navegador	Pasta típica (config ou cache)	Observação

Tor Browser	~/.tor-browser ou ~/tor-browser*	Baseado no Firefox, mas separado
qutebrowser	~/.config/qutebrowser / ~/.cache/qutebrowser	Minimalista, só teclado
Luakit	~/.config/luakit / ~/.cache/luakit	Baseado em Lua
Nyxt	~/.config/nyxt / ~/.cache/common-lisp	Navegador 'programável'
Pale Moon	~/.moonchild productions	Fork do Firefox
Waterfox	~/.waterfox	Firefox focado em privacidade
LibreWolf	~/.librewolf	Firefox hardened
Seamonkey	~/.mozilla/seamonkey	Suite com navegador + email
NetSurf	~/.netsurf	Super leve
Otter Browser	~/.config/otter	Inspirado no Opera antigo
Min	~/.config/Min	Leve, baseado em Electron
Yandex Browser	~/.config/yandex-browser	Chromium russo, raro no Linux
Dooble	~/.config/dooble	Foco em privacidade
Elinks / Lynx	Sem pasta gráfica – navegadores em terminal	Não guardam muito


"

# Restaurar o backup

# Na pasta ~/backup_navegadores/*/BraveSoftware/, deve haver uma pasta chamada Brave-Browser. Copie essa pasta para ~/.config/BraveSoftware/


clear



# ----------------------------------------------------------------------------------------

# Verificação de dependências

which yad &>/dev/null || { echo -e "\nPrograma Yad não está instalado.\n" | tee -a "$log"; exit; }

verificar_programa() {
    if ! which "$1" &>/dev/null; then
        echo -e "\nO programa $1 não está instalado.\n" | tee -a "$log"
        yad --center \
            --title="Dependência ausente" \
            --window-icon="$logo" --image="$logo" \
            --text="O programa <b>$1</b> não está instalado.\n\nInstale-o antes de continuar." \
            --button="OK" --width="400" 2>/dev/null
        exit 1
    fi
}

verificar_programa notify-send

# Função para log condicional

log_info() {
  local msg="$1"
  echo -e "$msg" >> "$log"
  [ "$log_detalhado" -eq 1 ] && echo -e "$msg"
}

# ----------------------------------------------------------------------------------------

# Modo de log detalhado

yad --center \
  --title="Log detalhado" \
  --window-icon="$logo" --image="$logo" \
  --text="Deseja ativar o log detalhado?\n\nIsso irá registrar mensagens completas no terminal e no log." \
  --button="Não":1 --button="Sim":0 \
  --width="500" --height="150" 2>/dev/null

[ $? -eq 0 ] && log_detalhado=1

# Mensagem inicial

# yad --center \
#  --title="Utilitário de Limpeza de Navegadores" \
# --window-icon="$logo" --image="$logo" \
# --text="<b>Este script remove os dados de configuração e cache dos navegadores selecionados.</b>\n\n⚠️ <b>ATENÇÃO:</b> Esta ação é irreversível e pode resultar na perda de histórico, senhas salvas e outras informações.\n\nUse com responsabilidade." \
#  --button="Cancelar":1 --button="Continuar":0 \
#  --width="800" --height="100" 2>/dev/null || exit 1

  
  yad --center \
  --title="Utilitário de Limpeza de Navegadores" \
  --window-icon="$logo" --image="$logo" \
  --text="<b>Bem-vindo ao Utilitário de Limpeza de Navegadores</b>\n\nEste script remove configurações e caches dos navegadores selecionados para liberar espaço e restaurar o desempenho.\n\n⚠️ <b>ATENÇÃO:</b> Esta ação é irreversível e pode apagar histórico, senhas salvas e outras informações.\n\nRecomenda-se criar um backup antes de continuar." \
  --button="Cancelar":1 --button="Continuar":0 \
  --width="800" --height="200" 2>/dev/null || exit 1

# ----------------------------------------------------------------------------------------

rm -Rf "$log" 2>/dev/null

log_info "\n🕓 $(date '+%d/%m/%Y %H:%M:%S') - Iniciando limpeza\n"

# Menu de seleção

browsers=$(yad --center --list \
  --title="Limpeza de Navegadores" \
  --window-icon="$logo" --image="$logo" \
  --text="Selecione os navegadores que deseja limpar:" \
  --checklist \
  --column="Selecionar" --column="Navegador" \
  TRUE "firefox" \
  FALSE "chrome" \
  FALSE "brave" \
  FALSE "chromium" \
  FALSE "opera" \
  FALSE "edge" \
  FALSE "opera-gx" \
  FALSE "vivaldi" \
  FALSE "falkon" \
  FALSE "midori" \
  FALSE "epiphany" \
  --separator="|" \
  --button="Cancelar":1 --button="OK":0 \
  --width="500" --height="700" 2>/dev/null)

[ -z "$browsers" ] && exit 1

IFS="|" read -ra selecionados <<< "$browsers"


# Remove o valor "TRUE" ou "FALSE" da seleção

for i in "${!selecionados[@]}"; do
  selecionados[$i]=$(echo "${selecionados[$i]}" | sed 's/TRUE\|FALSE//g')
done

# Isso garante que apenas os nomes dos navegadores sejam interpretados.


# Pergunta sobre backup

backup_dir="$HOME/backup_navegadores/$(date '+%Y-%m-%d_%H-%M-%S')"

yad --center \
  --title="Backup antes da limpeza" \
  --window-icon="$logo" --image="$logo" \
  --text="Deseja criar um backup dos dados antes da limpeza?\n\nOs dados serão salvos em:\n<b>$backup_dir</b>" \
  --button="Não":1 --button="Sim":0 \
  --width="500" --height="150" 2>/dev/null

fazer_backup=$?

mkdir -p "$backup_dir"


# Função de limpeza

limpar_navegador() {
  nome="$1"
  dir_config="$2"
  dir_cache="$3"

  log_info "DEBUG: limpando navegador '$nome'"

  if [ -d "$dir_config" ] || [ -d "$dir_cache" ]; then
    notify-send -i "$logo" -t 10000 "🧹 Limpando $nome..."
    log_info "\n🗑️ Limpando o $nome...\n"

    if [ "$fazer_backup" -eq 0 ]; then
      log_info "🔒 Criando backup de $nome em $backup_dir"
      [ -d "$dir_config" ] && cp -a "$dir_config" "$backup_dir/"
      [ -d "$dir_cache" ] && cp -a "$dir_cache" "$backup_dir/"
    fi

    rm -rf "$dir_config" "$dir_cache" 2>> "$log"
  else
    log_info "\n⚠️ $nome não encontrado.\n"
    notify-send -i "$logo" -t 10000 "⚠️ $nome não encontrado."
  fi
}


# Loop para limpar os navegadores selecionados

for browser in "${selecionados[@]}"; do

  case "$browser" in
    "firefox") limpar_navegador "Firefox" "$HOME/.mozilla" "$HOME/.cache/mozilla" ;;
    "chrome") limpar_navegador "Google Chrome" "$HOME/.config/google-chrome" "$HOME/.cache/google-chrome" ;;
    "brave") limpar_navegador "Brave" "$HOME/.config/BraveSoftware" "$HOME/.cache/BraveSoftware" ;;
    "chromium") limpar_navegador "Chromium" "$HOME/.config/chromium" "$HOME/.cache/chromium" ;;
    "opera") limpar_navegador "Opera" "$HOME/.config/opera" "$HOME/.cache/opera" ;;
    "edge") limpar_navegador "Microsoft Edge" "$HOME/.config/microsoft-edge" "$HOME/.cache/microsoft-edge" ;;
    "opera-gx") limpar_navegador "Opera GX" "$HOME/.config/opera_gx" "$HOME/.cache/opera_gx" ;;
    "vivaldi") limpar_navegador "Vivaldi" "$HOME/.config/vivaldi" "$HOME/.cache/vivaldi" ;;
    "falkon") limpar_navegador "Falkon" "$HOME/.config/falkon" "$HOME/.cache/falkon" ;;
    "midori") limpar_navegador "Midori" "$HOME/.config/midori" "$HOME/.cache/midori" ;;
    "epiphany") limpar_navegador "Epiphany" "$HOME/.config/epiphany" "$HOME/.cache/epiphany" ;;
    *) 

      log_info "\n❓ Navegador não reconhecido: $browser\n"

      notify-send -i "$logo" -t 10000 "❓ Navegador não reconhecido: $browser"

      ;;

  esac

done

log_info "\n✅ Limpeza concluída!\n"

notify-send -i "$logo" -t 10000 "✅ Limpeza concluída!"

exit 0


