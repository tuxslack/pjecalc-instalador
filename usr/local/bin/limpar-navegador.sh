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


clear


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


# --------------------------------------------------------------------------------------

# Firefox

# Verificar se o diretório existe

if [ -d "$HOME/.mozilla" ]; then

echo -e "\n🗑️ Limpando o Firefox... \n"

rm -Rf \
~/.mozilla \
~/.cache/mozilla

fi


# --------------------------------------------------------------------------------------

# Google Chrome

# Verificar se o diretório existe

if [ -d "$HOME/.config/google-chrome" ]; then

echo -e "\n🗑️ Limpando o Google Chrome... \n"

rm -Rf \
~/.config/google-chrome \
~/.cache/google-chrome

fi


# --------------------------------------------------------------------------------------

# Brave


# Verificar se o diretório existe

if [ -d "$HOME/.config/BraveSoftware" ]; then

echo -e "\n🗑️ Limpando o Brave... \n"

rm -Rf \
~/.config/BraveSoftware \
~/.cache/BraveSoftware

fi

# --------------------------------------------------------------------------------------

# Chromium


# Verificar se o diretório existe

if [ -d "$HOME/.config/chromium" ]; then

echo -e "\n🗑️ Limpando o Chromium... \n"

rm -Rf \
~/.config/chromium \
~/.cache/chromium

fi

# --------------------------------------------------------------------------------------

# Opera


# Verificar se o diretório existe

if [ -d "$HOME/.config/opera" ]; then

echo -e "\n🗑️ Limpando o Opera... \n"

rm -Rf \
~/.config/opera \
~/.cache/opera

fi

# --------------------------------------------------------------------------------------

# Microsoft Edge


# Verificar se o diretório existe

if [ -d "$HOME/.config/microsoft-edge" ]; then

echo -e "\n🗑️ Limpando o Microsoft Edge... \n"

rm -Rf \
~/.config/microsoft-edge \
~/.cache/microsoft-edge


fi

# --------------------------------------------------------------------------------------

# Opera GX


# Verificar se o diretório existe

if [ -d "$HOME/.config/opera_gx" ]; then

echo -e "\n🗑️ Limpando o Opera GX... \n"

rm -Rf \
~/.config/opera_gx \
~/.cache/opera_gx


fi

# --------------------------------------------------------------------------------------

# Vivaldi

# Verificar se o diretório existe

if [ -d "$HOME/.config/vivaldi" ]; then

echo -e "\n🗑️ Limpando o Vivaldi... \n"

rm -Rf \
~/.config/vivaldi \
~/.cache/vivaldi


fi


# --------------------------------------------------------------------------------------

# Falkon

# Verificar se o diretório existe

if [ -d "$HOME/.config/falkon" ]; then

echo -e "\n🗑️ Limpando o Falkon... \n"

rm -Rf \
~/.config/falkon \
~/.cache/falkon


fi

# --------------------------------------------------------------------------------------

# Midori

# Verificar se o diretório existe

if [ -d "$HOME/.config/midori" ]; then

echo -e "\n🗑️ Limpando o Midori... \n"

rm -Rf \
~/.config/midori \
~/.cache/midori


fi

# --------------------------------------------------------------------------------------

# Epiphany (GNOME Web)

# Verificar se o diretório existe

if [ -d "$HOME/.config/epiphany" ]; then

echo -e "\n🗑️ Limpando o Epiphany (GNOME Web)... \n"

rm -Rf \
~/.config/epiphany \
~/.cache/epiphany


fi

# --------------------------------------------------------------------------------------



echo -e "\n✅ Limpeza concluída! \n"

exit 0

