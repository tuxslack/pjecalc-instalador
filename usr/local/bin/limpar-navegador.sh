#!/bin/bash
#
# Autor:
#
#   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     16/04/2025 as 21:36:36
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  MIT

# Instalação PJe-Calc

# https://blog.desdelinux.net/pt/verifique-se-um-arquivo-ou-pasta-existe-ou-n%C3%A3o-e-mais-com-if-loop/
# https://www.cyberciti.biz/faq/check-if-a-directory-exists-in-linux-or-unix-shell/


log="/tmp/limpeza_navegadores.log"

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


clear



# ----------------------------------------------------------------------------------------

# Para verificar se os programas estão instalados


which yad           1> /dev/null 2> /dev/null || { echo "Programa Yad não esta instalado." | tee -a  "$log"    ; exit ; }


verificar_programa() {

    if ! which "$1" &> /dev/null; then


        echo  "O programa $1 não está instalado." >> "$log"

        yad --center \
            --title="Dependência ausente" \
            --window-icon="$logo" --image="$logo" \
            --text="O programa <b>$1</b> não está instalado.\n\nInstale-o antes de continuar." \
            --buttons-layout="center" \
            --button="OK" \
            --width="400" 2> /dev/null

        exit 1
    fi

}


# Verificações

verificar_programa notify-send

# ----------------------------------------------------------------------------------------


yad --center \
  --title="Utilitário de Limpeza de Navegadores" \
  --window-icon="$logo" --image="$logo" \
  --text="<b>Este script remove os dados de configuração e cache dos navegadores selecionados.</b>\n\n⚠️ <b>ATENÇÃO:</b> Esta ação é irreversível e pode resultar na perda de histórico, senhas salvas e outras informações.\n\nUse com responsabilidade." \
  --button="Cancelar":1 --button="Continuar":0 \
  --buttons-layout=center \
  --width="800" --height="100" \
  2>/dev/null || exit 1


# Verificar se o retorno é 1 (cancelado).

[ $? -ne 0 ] && exit 1

# ----------------------------------------------------------------------------------------

# Gerando o arquivo de log.


rm -Rf "$log" 2> /dev/null



echo -e "\n🕓 $(date '+%d/%m/%Y %H:%M:%S') - Iniciando limpeza \n\n\n" > "$log"


# ----------------------------------------------------------------------------------------


# Menu com YAD para selecionar múltiplos navegadores

# Quando você usa --radiolist, o primeiro --column precisa ser para o botão de seleção (bool) e depois os dados.


browsers=$(yad --center --list \
  --title="Limpeza de Navegadores" \
  --window-icon="$logo" --image="$logo" \
  --text="Selecione os navegadores que deseja limpar:" \
  --checklist \
  --column="Selecionar" --column="Navegador" \
  TRUE "Firefox" \
  FALSE "Google Chrome" \
  FALSE "Brave" \
  FALSE "Chromium" \
  FALSE "Opera" \
  FALSE "Microsoft Edge" \
  FALSE "Opera GX" \
  FALSE "Vivaldi" \
  FALSE "Falkon" \
  FALSE "Midori" \
  FALSE "Epiphany (GNOME Web)" \
  --separator="|" \
  --buttons-layout="center" \
  --button="Cancelar":1 \
  --button="OK":0 \
  --width="500" --height="700" \
  2>/dev/null)


# Cancelar se nada for selecionado.

[ -z "$browser" ] && exit 1


# Função de limpeza


limpar_navegador() {

  nome="$1"

  dir_config="$2"

  dir_cache="$3"


  if [ -d "$dir_config" ] || [ -d "$dir_cache" ]; then

    echo -e "\n🗑️ Limpando o $nome... \n"

    notify-send "Limpando dados de navegadores" -i "$logo" -t 100000 "\n🗑️ Limpando o $nome... \n"


    if [ "$fazer_backup" -eq 0 ]; then

      echo "🔒 Criando backup de $nome em $backup_dir" >> "$log"

      [ -d "$dir_config" ] && cp -a "$dir_config" "$backup_dir/"

      [ -d "$dir_cache" ] && cp -a "$dir_cache" "$backup_dir/"

    fi

    rm -rf "$dir_config" "$dir_cache" 2 >> "$log"


  else

    echo -e "\n⚠️ $nome não encontrado.\n"

    notify-send "Limpando dados de navegadores" -i "$logo" -t 100000 "\n⚠️ $nome não encontrado. \n"

  fi


}



# Separar os navegadores selecionados por |

IFS="|" read -ra selecionados <<< "$browsers"


# ----------------------------------------------------------------------------------------

backup_dir="$HOME/backup_navegadores/$(date '+%Y-%m-%d_%H-%M-%S')"

yad --center \
  --title="Backup antes da limpeza" \
  --window-icon="$logo" --image="$logo" \
  --text="Deseja criar um backup dos dados antes da limpeza?\n\nOs dados serão salvos em:\n<b>$backup_dir</b>" \
  --buttons-layout=center \
  --button="Não":1 --button="Sim":0 \
  --width="500" --height="150" \
  2>/dev/null

fazer_backup=$?

mkdir -p "$backup_dir"

# ----------------------------------------------------------------------------------------



# Laço para limpar cada navegador

for browser in "${selecionados[@]}"; do
  case "$browser" in

    "Firefox")
      limpar_navegador "Firefox" "$HOME/.mozilla" "$HOME/.cache/mozilla"
      ;;

    "Google Chrome")
      limpar_navegador "Google Chrome" "$HOME/.config/google-chrome" "$HOME/.cache/google-chrome"
      ;;

    "Brave")
      limpar_navegador "Brave" "$HOME/.config/BraveSoftware" "$HOME/.cache/BraveSoftware"
      ;;

    "Chromium")
      limpar_navegador "Chromium" "$HOME/.config/chromium" "$HOME/.cache/chromium"
      ;;

    "Opera")
      limpar_navegador "Opera" "$HOME/.config/opera" "$HOME/.cache/opera"
      ;;

    "Microsoft Edge")
      limpar_navegador "Microsoft Edge" "$HOME/.config/microsoft-edge" "$HOME/.cache/microsoft-edge"
      ;;

    "Opera GX")
      limpar_navegador "Opera GX" "$HOME/.config/opera_gx" "$HOME/.cache/opera_gx"
      ;;

    "Vivaldi")
      limpar_navegador "Vivaldi" "$HOME/.config/vivaldi" "$HOME/.cache/vivaldi"
      ;;

    "Falkon")
      limpar_navegador "Falkon" "$HOME/.config/falkon" "$HOME/.cache/falkon"
      ;;

    "Midori")
      limpar_navegador "Midori" "$HOME/.config/midori" "$HOME/.cache/midori"
      ;;

    "Epiphany (GNOME Web)")
      limpar_navegador "Epiphany (GNOME Web)" "$HOME/.config/epiphany" "$HOME/.cache/epiphany"
      ;;

    *)
      echo "Navegador não reconhecido: $browser"

      notify-send "Limpando dados de navegadores" -i "$logo" -t 100000 "\nNavegador não reconhecido: $browser \n"

      ;;

  esac
done





echo -e "\n✅ Limpeza concluída! \n"

notify-send "Limpando dados de navegadores" -i "$logo" -t 100000 "\n✅ Limpeza concluída! \n"


exit 0

