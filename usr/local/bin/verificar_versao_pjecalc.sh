#!/bin/bash
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     15/04/2025 as 06:10:00
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  MIT


# ----------------------------------------------------------------------------------------


# Não funcionou legal no Void Linux com OpenBox


# Execução agendada (cron)

# Adicionar no crontab do usuário:


# Tarefa agendada para verificar atualização diariamente às 10h do PJeCalc Cidadão.

# $ crontab -l
# 0 10 * * * * /usr/local/bin/verificar_versao_pjecalc.sh

# ou

# $ crontab -l
# */01 * * * * /usr/local/bin/verificar_versao_pjecalc.sh



# Recarregar cron

# $ sudo sv restart cronie
# ok: run: cronie: (pid 18856) 0s


# Ver se o cron está rodando a tarefa

# grep CRON /var/log/socklog/cron/current 


# Exclui crontab do usuário

# $ crontab -r


# $ crontab -l
# no crontab for biglinux

# ----------------------------------------------------------------------------------------

# Configurar esse script na pasta /etc/xdg/autostart ou na pasta ~/.config/autostart/


# sudo mkdir -p /etc/xdg/autostart && sudo tee /etc/xdg/autostart/verificar-pjecalc.desktop > /dev/null << 'EOF'
# [Desktop Entry]
# Type=Application
# Name=Verificar atualização do PJeCalc
# Comment=Script para verificar e notificar atualização do PJeCalc.
# Exec=/usr/local/bin/verificar_versao_pjecalc.sh
# Hidden=false
# NoDisplay=false
# X-GNOME-Autostart-enabled=true
# EOF


# Observações:

#  Use sudo porque /etc/xdg/autostart/ precisa de privilégios de Root.

#  Esse .desktop será executado para todos os usuários quando fizerem login gráfico (em ambientes compatíveis).


# ----------------------------------------------------------------------------------------

# Teste se está rodando

# echo "Script iniciado às $(date)" >> /tmp/pjecalc-autostart.log

# ----------------------------------------------------------------------------------------





# Logs de atualização

log="/tmp/pjecalc-update.log"


# URL da página de instalação

URL="https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao"


logo="/usr/share/pixmaps/icone_calc.ico"


# Auto-atualização do PJeCalc Cidadão



clear


# ----------------------------------------------------------------------------------------

# Para uso do cron

# (Cannot autolaunch D-Bus without X11 $DISPLAY)

# (Could not connect: Connection refused)

# (The given address is empty)

# significa que o script que o cron está executando não tem um valor válido na variável DBUS_SESSION_BUS_ADDRESS


# Exporte as variáveis necessárias para D-Bus e DISPLAY

# Exporta as variáveis do ambiente gráfico

# $ echo $DBUS_SESSION_BUS_ADDRESS
# unix:path=/tmp/dbus-J2g8N66URE,guid=d9830275e46fd37b60cf131867fe0ebd


export DBUS_SESSION_BUS_ADDRESS=$(echo $DBUS_SESSION_BUS_ADDRESS)

export DISPLAY=:0.0



# Define o terminal para evitar erro TERM

# (TERM environment variable not set.)

# export TERM=xterm

# ----------------------------------------------------------------------------------------

# Para verificar se os programas estão instalados


which yad           1> /dev/null 2> /dev/null || { echo "Programa Yad não esta instalado."      ; exit ; }


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
verificar_programa grep
verificar_programa curl
verificar_programa 7z
verificar_programa cut
verificar_programa java
verificar_programa wget
verificar_programa cp
verificar_programa ping
verificar_programa pgrep
verificar_programa sort
verificar_programa xdg-open
verificar_programa firefox


# find /usr/share/icons/ -iname *gtk-dialog*


# ----------------------------------------------------------------------------------------

echo "
Testando conexão com à internet...
"

if ! ping -c 1 www.google.com.br -q &> /dev/null; then


    echo  "Sistema não tem conexão com à internet." >> "$log"

    echo -e "\033[1;31m[ERRO] - Seu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n \033[0m"
    
    sleep 10
    
    yad \
    --center \
    --window-icon="$logo" \
    --image=dialog-error \
    --title "Aviso" \
    --fontname "mono 10"  \
    --text="\nSeu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n" \
    --buttons-layout="center" \
    --button="OK"  \
    --width="600" --height="100"  \
    2> /dev/null
    
    
    exit 1
    
    else
    
    echo -e "\033[1;32m[VERIFICADO] - Conexão com à internet funcionando normalmente. \033[0m"
    
    sleep 2
    
fi


# ----------------------------------------------------------------------------------------


# Baixar o conteúdo da página e procurar o link do instalador

if [[ $(uname -m) == x86_64 ]]; then

# Instalador PJe-Calc Cidadão 64bits

# echo -e "\nPJe-Calc Cidadão 64bits \n"

arch="x64"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x64\.exe)' | head -n 1)

else

# Instalador PJe-Calc Cidadão 32bits

# echo -e "\nPJe-Calc Cidadão 32bits \n"

arch="x32"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x32\.exe)' | head -n 1)

fi


# Para verificar se a variavel é nula

if [ -z "$VERSAO" ];then


    echo -e "\033[1;31mVersão do PJeCalc Cidadão não identificada no site...\n \033[0m"

    exit

fi


# Filtrar

VERSAO=$(echo ""$VERSAO | cut -d"-" -f2)


# Exibir a versão do programa

VERSAO_SITE="$VERSAO"


# ----------------------------------------------------------------------------------------

# VERSAO INSTALADA


versao_instalada(){

# Detectar automaticamente a versão do PJeCalc instalada.


# Caminho do pjecalc.jar (ajuste conforme necessário)

JAR_PATH="$HOME/PJeCalc/bin/pjecalc.jar"

# Verifica se o arquivo existe

if [ ! -f "$JAR_PATH" ]; then

    echo -e "\033[1;31m\n[ERRO] - ❌ Arquivo $JAR_PATH não encontrado. \n\033[0m"

    exit 1
fi

# Tenta extrair a versão do MANIFEST.MF

VERSAO_ATUAL=$(unzip -p "$JAR_PATH" META-INF/MANIFEST.MF 2>/dev/null | grep -iE 'Implementation-Version|version' | head -n1 | awk -F': ' '{print $2}' | tr -d '\r')


# $ pwd
# /home/biglinux/PjeCalc

# $ find . -iname MANIFEST.MF 
# ./tomcat/webapps/pjecalc/META-INF/MANIFEST.MF

# $ cat tomcat/webapps/pjecalc/META-INF/MANIFEST.MF
# Manifest-Version: 1.0



# $ strings pjecalc-2.13.2-instalador-x64.exe | grep -i version
# GetVersionExW
# PA<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
# <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
#   version="1.0.0.0"
#       version="6.0.0.0"
# ; These are two versions of first HTML string. SFX selects an appropriate
# ; version dynamically, depending on presence of "Setup" command. Note that
# 	mimeType: "application/x-java-applet;jpi-version=1.8.0_241",
# <?xml version="1.0"?>
# <?xml version="1.0"?>
#     <em:version>8.0.241</em:version>
#         <em:minVersion>3.0</em:minVersion>
#         <em:maxVersion>15.0+</em:maxVersion>



# Caso não encontre, define mensagem padrão

if [ -z "$VERSAO_ATUAL" ]; then

    echo -e "\033[1;31m[ERRO] - ❌ Não foi possível detectar a versão do PJeCalc Cidadão no $JAR_PATH \033[0m"

    exit 1
fi

# Exibe a versão

echo "Versão instalada do PJeCalc Cidadão: $VERSAO_ATUAL"


}

# versao_instalada


# VERSAO_ATUAL="2.13.2"


# Verificar se tem o arquivo $HOME/PjeCalc/versao_instalada.txt

if [ -e "$HOME/PjeCalc/versao_instalada.txt" ]; then

VERSAO_ATUAL=$(cat $HOME/PjeCalc/versao_instalada.txt)


# Caso não encontre, define mensagem padrão

if [ -z "$VERSAO_ATUAL" ]; then

    echo -e "\033[1;31m[ERRO] - ❌ Não foi possível detectar a versão do PJeCalc Cidadão. \033[0m"

    exit 1
fi


# Exibe a versão

echo -e "\nVersão instalada do PJeCalc Cidadão: $VERSAO_ATUAL"

fi



# ----------------------------------------------------------------------------------------

# Se a versão instalada for maior que a versão do site não mostra o aviso.

# Se a versão instalada for menor do que o site mostra o aviso.


# Pega a menor versão entre as duas (compara versões)
# 
# Como funciona sort -V?
# 
#     Ele compara cada "pedaço" da versão como número:
# 
#     Ex:
# 
#     4.11.0 → 4, 11, 0
# 
#     2.13.2 → 2, 13, 2
# 
#     E faz a ordenação correta, como se fossem versões de software mesmo.


MENOR_VERSAO=$(printf '%s\n' "$VERSAO_ATUAL" "$VERSAO_SITE" | sort -V | head -n1)


# Lógica de verificação

if [ "$MENOR_VERSAO" != "$VERSAO_SITE" ]; then

        echo -e "\n🔔 Sua versão do PJeCalc Cidadão está desatualizada.\n"



erro_cron(){

# ----------------------------------------------------------------------------------------

# Causa real do problema

# Mesmo com DISPLAY e DBUS_SESSION_BUS_ADDRESS definidos, o cron não consegue interagir com o usuário, porque ele não tem um terminal nem uma sessão interativa.

# A yad precisa de uma sessão gráfica ativa + foco + ambiente do usuário atual, que o cron não consegue simular completamente, mesmo quando você injeta as variáveis.

# Por isso, o yad falha silenciosamente (com 2> /dev/null), e o script segue para o else.

# Ex: [ERRO] - ❌ Usuário optou por não atualizar.


    if yad --center --window-icon=dialog-warning --image="$logo" --title="Atualização disponível" --text="Nova versão do PJeCalc Cidadão disponível.\n\nVersão instalada: $VERSAO_ATUAL\nVersão disponível: $VERSAO_SITE\n\nDeseja atualizar?" --buttons-layout="center" --button=Não:1 --button=Sim:0 --width="400"  2> /dev/null ; then


# Sem o 2> /dev/null

# (Unable to parse command line: Invalid byte sequence in conversion input)
# (biglinux) CMDOUT (The given address is empty)


# ----------------------------------------------------------------------------------------

echo "Processo de atualização..."


# Verificar se tem o arquivo /usr/local/bin/pjecalc-instalar-remover.sh

if [ -e "/usr/local/bin/pjecalc-instalar-remover.sh" ]; then

        echo -e "\nAtualizando para versão $VERSAO_SITE..."

/usr/local/bin/pjecalc-instalar-remover.sh

else

    echo -e "\033[1;31m[ERRO] - ❌ Desculpe, não foi possível encontrar o atualizador do PJeCalc Cidadão.\n\nVerifique a instalação... \033[0m"

notify-send  \
-i "$logo" \
-t 200000 \
"Atualização do PJeCalc Cidadão..." "\nDesculpe, não foi possível encontrar o atualizador do PJeCalc Cidadão.\n\nVerifique a instalação..."

exit


fi

# ----------------------------------------------------------------------------------------


else

notify-send  \
-i "$logo" \
-t 200000 \
"Atualização disponível do PJeCalc Cidadão..." "🔔 Sua versão do PJeCalc Cidadão está desatualizada."



        echo "
Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"
    
    sleep 2

    # No cron cai sempre aqui e não abre o yad.

    echo -e "\033[1;31m[ERRO] - ❌ Usuário optou por não atualizar. \033[0m"

fi

# ----------------------------------------------------------------------------------------


}

# erro_cron


echo "
Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"


notify-send  \
-i "$logo" \
-t 200000 \
"Atualização disponível do PJeCalc Cidadão..." "🔔 Sua versão do PJeCalc Cidadão está desatualizada.

Versão instalada:  $VERSAO_ATUAL 
Versão disponível: $VERSAO_SITE
"



else

      echo -e "\033[1;32m\n✅ PJeCalc Cidadão está na versão mais recente.\n \033[0m"


# notify-send  \
# -i "$logo" \
# -t 200000 \
# "PJeCalc Cidadão atualizado..." "\n✅ PJeCalc Cidadão está na versão mais recente.\n"


fi


sleep 10


exit 0

