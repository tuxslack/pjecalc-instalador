#!/bin/bash
#
# Autores:
#
#   Bruno Goncalves <bigbruno@gmail.com>
#   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     13/04/2025 as 17:36:18
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  GPL
#
#
#    * Trocado kdialog por yad para maior compatibilidade com outras interfaces gráficas.
#    * Tenta localizar o Java, utilizando o diretório mais provável.
#    * Adicionado tratamento de erros.
#    * Baixa o arquivo .exe (versão para Windows) do PJeCalc atualizado, diretamente do site oficial.
#
#
# Instalação PJe-Calc
#
# https://www.youtube.com/watch?v=GIqSTTuOBwM
# https://www.trt8.jus.br/pjecalc-cidadao/manuais
# https://forum.biglinux.com.br/d/2315-pje-calc-no-biglinux
# https://www.trt8.jus.br/pjecalc-cidadao/manuais
# https://pje.csjt.jus.br/manual/index.php/PJE-Calc
# https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/manual_de_instalacao_-_pje-calc_cidadao_-_2.13.1.pdf
# https://plus.diolinux.com.br/t/dica-pjecalc-no-ubuntu-rodando-nativo-sem-wine-e-nem-virtual-machine/68263/2
# https://plus.diolinux.com.br/t/pjecalc-no-linux/44014
# https://manjariando.com.br/pje-calc/
# https://plus.diolinux.com.br/t/pjecalc-programa-de-calculo-da-justica-do-trabalho/14274
# https://plus.diolinux.com.br/t/pje-office-no-linux/316


titulo="Instalador não oficial do PjeCalc"

logo="/usr/share/pixmaps/icone_calc.ico"


# URL da página de instalação

URL="https://www.trt8.jus.br/pjecalc-cidadao/instalando-o-pje-calc-cidadao"


# Logs de instalação

log="/tmp/pjecalc-instalador.log"


clear


rm -Rf "$log" 2>/dev/null


echo "=========== $(date '+%d-%m-%Y %H:%M:%S') - Início da instalação do PJe-Calc ==========" >> "$log"


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



# find /usr/share/icons/ -iname *gtk-dialog*

# ----------------------------------------------------------------------------------------

# Mensagem sobre o arquivo de log

yad \
--center \
--title="Sobre o arquivo de Log" \
--window-icon="$logo" \
--image="$logo" \
--text="
O arquivo de log será criado em:

<b>$log</b>

Ele será responsável por identificar possíveis problemas com o programa PJeCalc.

Em caso de erro, o arquivo de log deverá ser enviado para análise.

" \
--buttons-layout="center" \
--button=OK:0 \
--width="600" \
--height="100" \
2>/dev/null


# ----------------------------------------------------------------------------------------


verificar_internet(){

echo "
Testando conexão com à internet...
"

if ! ping -c 1 www.google.com.br -q &> /dev/null; then


    echo -e "\nSistema não tem conexão com à internet.\n" >> "$log"

    echo -e "\033[1;31m[ERRO] - Seu sistema não tem conexão com à internet. Verifique os cabos e o modem.\n \033[0m"
    
    sleep 10
    
    yad \
    --center \
    --window-icon "$logo" \
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

}


verificar_internet

# ----------------------------------------------------------------------------------------

clear


# Baixar o conteúdo da página e procurar o link do instalador

if [[ $(uname -m) == x86_64 ]]; then

# Instalador PJe-Calc Cidadão 64bits

echo -e "\nInstalador PJe-Calc Cidadão 64bits \n"

arch="x64"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x64\.exe)' | head -n 1)

else

# Instalador PJe-Calc Cidadão 32bits

echo -e "\nInstalador PJe-Calc Cidadão 32bits \n"

arch="x32"

VERSAO=$(curl -s "$URL" 2> /dev/null | grep -oP 'pjecalc-[0-9]+\.[0-9]+\.[0-9]+(?=-instalador-x32\.exe)' | head -n 1)

fi


# Para verificar se a variavel é nula

if [ -z "$VERSAO" ];then


    echo -e "\033[1;31mVersão do PJe-Calc não identificada...\n \033[0m"

    exit

fi


# Filtrar

VERSAO=$(echo ""$VERSAO | cut -d"-" -f2)


# Exibir a versão do programa

echo -e "\nVersão mais recente do PJe-Calc: $VERSAO \n"


echo "
Versão mais recente do PJe-Calc: $VERSAO

Versão do Java: 

$(`which java` --version)


Arquitetura do processador: $(uname -m)

" >> "$log"


echo "
Sistema:
" >> "$log"

cat /etc/os-release  >> "$log"


sleep 5


# ----------------------------------------------------------------------------------------



if [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then


yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="O PjeCalc já está instalado.\n\nDeseja reinstalar/atualizar o PjeCalc ou removê-lo?" \
    --buttons-layout="center" \
    --button="Reinstalar ou atualizar o PjeCalc":0 \
    --button="REMOVER o PjeCalc!":1 \
    --width="800" --height="200"  2>/dev/null


    if [ "$?" = 1 ]; then


yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Confirma que deseja REMOVER o PjeCalc e os dados presentes no mesmo?" \
    --buttons-layout="center" \
    --button="Manter o PjeCalc instalado":0 \
    --button="Confirmo, REMOVA o PjeCalc!":1 \
    --width="800" --height="200"  2>/dev/null


            if [ "$?" = 1 ]; then

                rm -R "$HOME/PjeCalc" 2>> "$log"

                yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --text="PjeCalc removido!"  --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

            fi

            exit 0
    fi

fi




yad \
--center \
--title="$titulo" \
--window-icon="$logo" \
--image="$logo" \
--text="Esse é um instaldor não oficial para o programa PjeCalc.

O PjeCalc, oficialmente, possui instalador apenas para Windows, porém, é um
programa feito em java e funciona no Linux.

Para prosseguir, faça o download do PjeCalc para Windows, e pressione 'Continuar'.



Na tela a seguir selecione o arquivo .exe do PjeCalc.
Pode utilizar tanto a versão de 32 quanto a 64 bits.

" \
--buttons-layout="center" \
--button="Continuar":0 \
--button="Cancelar":1 \
--width="800" --height="200" \
2>/dev/null



if [ "$?" != 0 ]; then
	exit
fi


# Pergunta ao usuário com yad

yad --center \
    --title="Instalador do PjeCalc" \
    --window-icon="$logo" --image="$logo" \
    --text=$"Deseja baixar a versão mais recente do PjeCalc?\n\nArquivo: pjecalc-$VERSAO-instalador-$arch.exe" \
    --buttons-layout="center" \
    --button="Sim, baixar agora":0 \
    --button="Cancelar":1 \
    --width="400" \
    2>/dev/null


# Verifica resposta do usuário

if [ $? -eq 0 ]; then


    # Baixa o arquivo com wget (salvar o arquivo pjecalc-$VERSAO-instalador-$arch.exe na pasta $HOME)

    echo -e "\033[1;32m\nBaixando o arquivo pjecalc-$VERSAO-instalador-$arch.exe na pasta $HOME \n\n\033[0m"
    
    sleep 2

    # Salvando em: "/home/biglinux/pjecalc-2.13.2-instalador-x64.exe" 269M

    wget -O "$HOME/pjecalc-$VERSAO-instalador-$arch.exe" -c "https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/pjecalc-$VERSAO-instalador-$arch.exe" && \
    yad --center --title="Download concluído" --window-icon="$logo" --image="$logo" --text="Download concluído com sucesso!" --buttons-layout="center" --button="OK"  --width="400" --height="100" 2>/dev/null

else

    yad --center --title="Download cancelado" --window-icon="$logo" --image="$logo" --text="O download foi cancelado pelo usuário." --buttons-layout="center" --button="OK"  --width="400" --height="100" 2>/dev/null

fi



# Fecha o PjeCalc se ele estiver aberto

# kill $(ps -aux| grep java | grep pjecalc.jar | awk '{print $2}')


# Verificar se o PJeCalc já está em execução

if pgrep -f "pjecalc.jar" &>/dev/null; then


# Pega o PID do processo Java que roda o pjecalc.jar e o finaliza com kill -9 se o processo for teimoso.

ps aux | grep pjecalc.jar | grep java | awk '{print $2}' | xargs -r kill -9



echo -e "\033[1;31m\nO PJeCalc já está em execução....\n \033[0m"

yad \
--center  \
--title="Aviso" \
--window-icon="dialog-error" \
--image="dialog-error" \
--text="O PJeCalc já está em execução." \
--buttons-layout="center" \
--button="OK":0 \
--width="300" --height="100" \
2>/dev/null


fi



rm -Rf "$HOME/.pjecalc-instalando/" 2>> "$log"

mkdir -p ~/.pjecalc-instalando  2>> "$log" || echo -e "\033[1;31m\nFalha ao criar a pasta $HOME/.pjecalc-instalando. \n \033[0m"





# Abre o gerenciador de arquivos, define a pasta $HOME como padrão e filtra apenas arquivos .exe.

ARQUIVO=$(yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --file --filename="$HOME/" --file-filter="Arquivos .exe | *.exe" --buttons-layout="center" --width="1200" --height="800"  2>/dev/null)


# Verificar se o arquivo .exe do PJeCalc foi fornecido

if [ -n "$ARQUIVO" ]; then

    cp -f "$ARQUIVO" "$HOME/.pjecalc-instalando/pjecalc.exe" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar o arquivo $ARQUIVO para a pasta $HOME/.pjecalc-instalando/  \n \033[0m"

fi



# Verificar se o arquivo .exe existe

if ! [ -e "$HOME/.pjecalc-instalando/pjecalc.exe" ]; then


    echo -e "\033[1;31m\nO arquivo $HOME/.pjecalc-instalando/pjecalc.exe não existe. \n \033[0m"


yad \
--center  \
--title="Aviso" \
--window-icon="dialog-error" \
--image="dialog-error" \
--text="O arquivo $HOME/.pjecalc-instalando/pjecalc.exe não existe." \
--buttons-layout="center" \
--button="OK":0 \
--width="600" --height="100" \
2>/dev/null

    exit

fi


# ----------------------------------------------------------------------------------------

# Descompactar o arquivo .exe


cd "$HOME/.pjecalc-instalando/" 2>> "$log" || echo -e "\033[1;31m\nFalha ao acessar o diretório de instalação $HOME/.pjecalc-instalando/. \n \033[0m"

7z x pjecalc.exe 2>> "$log" || echo -e "\033[1;31m\nFalha ao descompactar o arquivo pjecalc.exe. com 7z \n \033[0m"

# ----------------------------------------------------------------------------------------

# Remoção do arquivo pjecalc.exe


# Janela de confirmação

yad \
--center \
--title="Confirmar Remoção" \
--window-icon="$logo" --image="$logo" \
--text="Deseja remover o arquivo <b>pjecalc.exe</b>?" \
--width=300 \
--buttons-layout="center" \
--button=Não:1 --button=Sim:0 --width="400" --height="100" 2>/dev/null


# Verifica a escolha do usuário

if [ $? -eq 0 ]; then

    rm pjecalc.exe 2>> "$log" && \
    yad --center --title="Removido" --window-icon="$logo" --image="$logo" --text="Arquivo <b>pjecalc.exe</b> removido com sucesso!" --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

else

    yad --center --title="Cancelado" --window-icon="$logo" --image="$logo" --text="Ação cancelada pelo usuário." --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

fi


# ----------------------------------------------------------------------------------------


rm -Rf pjecalc-*/navegador 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove os arquivos... \n \033[0m"

rm -Rf pjecalc-*/bin/jre   2>> "$log" || echo -e "\033[1;31m\nFalha ao remove os arquivos... \n \033[0m"


# Criar diretório de instalação

mkdir -p ~/PjeCalc 2>> "$log" ||  echo -e "\033[1;31m\nFalha ao criar diretório de instalação $HOME/PjeCalc.\n \033[0m"


# Copiar o arquivo .exe para o diretório de instalação

cp -Rf pjecalc-*/* "$HOME/PjeCalc" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc \n \033[0m"


if [ -e "$HOME/PjeCalc/.dados" ]; then



yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Detectei que já existe uma base de dados do PjeCalc nesse computador,\ndeseja manter os dados atuais ou efetuar uma instalação limpa?" \
    --buttons-layout="center" \
    --button="MANTER MEUS DADOS":0 \
    --button="APAGAR MEUS DADOS":1 \
    --width="800" --height="200"  2>/dev/null


    if [ "$?" = 1 ]; then


yad --center \
    --title="$titulo" \
    --window-icon="$logo" --image="$logo" \
    --text="Confirma que deseja apagar os dados preenchidos no PjeCalc?" \
    --buttons-layout="center" \
    --button="Não apague os dados":0 \
    --button="Confirmo, apague os dados!":1 \
    --width="800" --height="200"  2>/dev/null


            if [ "$?" = 1 ]; then

                rm -R "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove a pasta $HOME/PjeCalc/.dados \n \033[0m"

                cp -Rf pjecalc-*/.dados "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc/.dados \n \033[0m"

            fi
    fi


else

    cp -Rf pjecalc-*/.dados "$HOME/PjeCalc/.dados" 2>> "$log" || echo -e "\033[1;31m\nFalha ao copiar os arquivos para pasta $HOME/PjeCalc/.dados \n \033[0m"

fi


rm -Rf "$HOME/.pjecalc-instalando/" 2>> "$log" || echo -e "\033[1;31m\nFalha ao remove a pasta $HOME/.pjecalc-instalando \n \033[0m"


if [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then


# Versão mais recente do PJe-Calc: 

echo "$VERSAO" > $HOME/PjeCalc/versao_instalada.txt



echo -e "\033[1;32m\nPJeCalc instalado com sucesso! \n\033[0m"


yad \
--center \
--title="Instalação concluída"  \
--window-icon="$logo" \
--image="$logo" \
--text="
O <b>PjeCalc</b> foi instalado na pasta <b>$HOME/PjeCalc</b> se você apagar ou modificar o nome dessa 
pasta o <b>PjeCalc</b> não irá funcionar.

Para utilizar o <b>PjeCalc</b>, abra-o no menu do sistema na categoria <b>Escritório</b>.


Foi adicionado um atalho para <b>documentação online do PJeCalc</b>.

Menu iniciar => Internet => Manual do PJe
" \
--buttons-layout="center" \
--button=OK  \
--width="800" --height="200"  \
2>/dev/null


else

    yad --center --title="$titulo" --window-icon="$logo" --image="$logo" --text="A instalação não foi cancelada."  --buttons-layout="center" --button=OK --width="400" --height="100" 2>/dev/null

fi


exit 0

