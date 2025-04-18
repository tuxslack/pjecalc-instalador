#!/bin/bash
#
# Autores:
#
#   Bruno Goncalves <bigbruno@gmail.com>
#   Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     13/04/2025 as 17:36:18
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  MIT


#    * Trocado kdialog por yad para maior compatibilidade com outras interfaces gráficas.
#    * Tenta localizar o Java, utilizando o diretório mais provável.
#    * Adicionado tratamento de erros.
#    * Baixa o arquivo .exe (versão para Windows) do PJeCalc atualizado, diretamente do site oficial.


# Instalação PJe-Calc
#
# https://www.youtube.com/watch?v=GIqSTTuOBwM
# https://www.trt8.jus.br/pjecalc-cidadao/manuais
# https://forum.biglinux.com.br/d/2315-pje-calc-no-biglinux


logo="/usr/share/pixmaps/icone_calc.ico"


# Versões de limite do Java

VERSAO_MINIMA="11.0.25"

VERSAO_MAXIMA="24.0.1"


# Porta

porta="9257"


# Logs de execução

log="/tmp/pjecalc.log"



clear


# Remove o arquivo de log

rm -Rf "$log" 2>/dev/null


# ----------------------------------------------------------------------------------------

# Garantir que o shell use a codificação correta no início do script.

export LANG=pt_BR.UTF-8

export LC_ALL=pt_BR.UTF-8

# ----------------------------------------------------------------------------------------


INICIO=$(echo "=========== $(date '+%d-%m-%Y %H:%M:%S') - Início da execução do PJe-Calc ==========")

echo  "

$INICIO

" >> "$log"



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
verificar_programa netstat
verificar_programa find
verificar_programa iconv
verificar_programa sed


# find /usr/share/icons/ -iname *gtk-dialog*


# ----------------------------------------------------------------------------------------

# Verificação automática do Java


verifica_java(){

# Tenta encontrar Java na pasta /usr/lib/jvm

jvm_base="/usr/lib/jvm"

java_dir=$(ls "$jvm_base" 2>/dev/null | grep openjdk | head -n1)

if [ -n "$java_dir" ] && [ -x "$jvm_base/$java_dir/bin/java" ]; then

    JAVA_PATH="$jvm_base/$java_dir/bin/java"

else

    # Caso falhe, tenta descobrir via which + readlink

    java_bin=$(which java 2>/dev/null)

    if [ -n "$java_bin" ]; then

        JAVA_PATH=$(readlink -f "$java_bin")

    fi
fi


}


verifica_java


# Caminho para o programa Java (ajuste se necessário)

# Definindo manualmente a variável java:

# ls /usr/lib/jvm/ | grep openjdk
# which java

# JAVA_PATH="/usr/lib/jvm/openjdk11/bin/java"






# Verifica se encontrou

if [ -x "$JAVA_PATH" ]; then

    echo -e "\nJava encontrado em: $JAVA_PATH \n\n"

else

    yad --center \
        --title="Erro ao localizar Java" \
        --window-icon=dialog-warning \
        --image="$logo" \
        --text="Não foi possível localizar uma instalação válida do Java." \
        --buttons-layout="center" \
        --button="OK" --width="300"

    exit 1
fi


# Agora você pode usar $JAVA_PATH normalmente:

"$JAVA_PATH" -version | tee -a "$log"


# ----------------------------------------------------------------------------------------

# Verificando se o caminho existe antes de usar:

if [ -x "$JAVA_PATH" ]; then

    java="$JAVA_PATH"

else

    yad --center --title="Erro" --window-icon=dialog-warning --image="$logo" --text="Java não encontrado em $JAVA_PATH" --buttons-layout="center" --button="OK"  2>/dev/null

    exit 1

fi

# ----------------------------------------------------------------------------------------


# Função para converter versão em número comparável

versao_para_numero() {

    echo "$1" | awk -F. '{ printf("%02d%02d%02d\n", $1, $2, $3) }'

}


# Verifica se Java está disponível

if ! command -v "$JAVA_PATH" &> /dev/null; then
    echo "❌ Java não encontrado no PATH."
    exit 1
fi

# Captura a versão do Java

JAVA_VERSION_RAW=$("$JAVA_PATH" -version 2>&1 | awk -F\" '/version/ { print $2 }')

# Verifica se conseguiu pegar a versão

if [ -z "$JAVA_VERSION_RAW" ]; then

    echo "❌ Não foi possível detectar a versão do Java."

    notify-send "PjeCalc" -i "$logo" -t 100000 "❌ Não foi possível detectar a versão do Java."

    exit 1
fi

echo "🔍 Versão do Java detectada: $JAVA_VERSION_RAW"

# notify-send "PjeCalc" "🔍 Versão do Java detectada: $JAVA_VERSION_RAW"


# Converte para formato numérico

JAVA_NUM=$(versao_para_numero "$JAVA_VERSION_RAW")
MIN_NUM=$(versao_para_numero "$VERSAO_MINIMA")
MAX_NUM=$(versao_para_numero "$VERSAO_MAXIMA")

# Compara versões

if [ "$JAVA_NUM" -lt "$MIN_NUM" ]; then

    echo "❌ Versão do Java menor que a mínima exigida ($VERSAO_MINIMA)."

    notify-send "PjeCalc" -i "$logo" -t 100000 "❌ Java menor que a versão mínima exigida ($VERSAO_MINIMA)."

    exit 1

elif [ "$JAVA_NUM" -ge "$MAX_NUM" ]; then

    echo "❌ Versão do Java maior ou igual à máxima permitida ($VERSAO_MAXIMA)."

    notify-send "PjeCalc" -i "$logo" -t 100000 "❌ Java maior ou igual à versão máxima permitida ($VERSAO_MAXIMA)."

    exit 1

else

    echo "✅ Versão do Java é compatível com o PjeCalc."

    notify-send "PjeCalc" -i "$logo" "✅ Versão do Java é compatível. Iniciando o programa..."

    echo "🚀 Iniciando o programa..."

fi


# ----------------------------------------------------------------------------------------


if ! [ -e "$HOME/PjeCalc/bin/pjecalc.jar" ]; then


yad --center \
    --title="PjeCalc não instalado!" \
    --window-icon=dialog-warning --image="$logo" \
    --text="O PjeCalc ainda não está instalado." \
    --buttons-layout="center" \
    --button="OK" \
    --width="400" \
    2>/dev/null

    clear

    exit 1

fi

# ----------------------------------------------------------------------------------------

# Verificar acesso a pasta $HOME/PjeCalc

verificar_acesso(){


PASTA="$HOME/PjeCalc"

# Cores
VERDE="\033[0;32m"
VERMELHO="\033[0;31m"
AMARELO="\033[1;33m"
RESET="\033[0m"

# Verifica se a pasta existe

if [ ! -d "$PASTA" ]; then

    echo -e "${VERMELHO}❌ Pasta não encontrada: $PASTA${RESET}"

    notify-send "PjeCalc" -i "$logo" -t 100000 "\nPasta não encontrada: $PASTA\n"

    exit 1
fi

# Verifica permissões na pasta

if [ -r "$PASTA" ] && [ -w "$PASTA" ]; then

    echo -e "${VERDE}✅ Você tem permissão de leitura e escrita na pasta: $PASTA${RESET}"

else

    echo -e "${AMARELO}⚠️  Sem permissão total na pasta: $PASTA${RESET}"

    notify-send "PjeCalc" -i "$logo" -t 100000 "\nSem permissão total na pasta: $PASTA\n"

fi


# Verifica arquivos dentro da pasta

# ACESSO_OK=true
# for ARQ in "$PASTA"/*; do
#    [ -e "$ARQ" ] || continue  # Pula se não existir arquivos

#    if [ ! -r "$ARQ" ] || [ ! -w "$ARQ" ]; then
#        echo -e "${VERMELHO}❌ Sem acesso total ao arquivo: $ARQ${RESET}"
#        ACESSO_OK=false
#    else
#        echo -e "${VERDE}✔️  Acesso OK: $ARQ${RESET}"
#    fi
# done


# Resultado final

# if [ "$ACESSO_OK" = true ]; then
#    echo -e "\n${VERDE}✅ Você tem acesso total a todos os arquivos.${RESET}"
# else
#    echo -e "\n${AMARELO}⚠️  Alguns arquivos não têm permissão de leitura e/ou escrita.${RESET}"
# fi


}


verificar_acesso


# ----------------------------------------------------------------------------------------

# Mensagem sobre o arquivo de log


echo "

O que é PJe-Calc?

O PJe-Calc Cidadão é o sistema desenvolvido pela Secretaria de Tecnologia da Informação do Tribunal Regional do Trabalho 
da 8ª Região (PA/AP), a pedido do Conselho Superior da Justiça do Trabalho (CSJT), para utilização em toda a Justiça do Trabalho 
como ferramenta padrão de elaboração de cálculos trabalhistas e liquidação de sentenças, visando à uniformidade de procedimentos 
e à confiabilidade nos resultados apurados.



O arquivo de log será criado em:

$log

Ele será responsável por identificar possíveis problemas com o programa PJeCalc.

Em caso de erro, o arquivo de log deverá ser enviado para análise.

----------------------------------------------------
PJe Office + PJeCalc + Navegador = Tudo se conecta.
----------------------------------------------------


Obs: Oficialmente o PJeCalc é compatível apenas com o Firefox - pelo menos quando integrado com o PJe Office e o sistema de cálculo da 
Justiça do Trabalho.

O PJeCalc em si é uma aplicação Java independente, usada para fazer cálculos trabalhistas e gerar documentos. No entanto, ele frequentemente 
depende do PJe Office, que é o módulo de autenticação com certificado digital, necessário para funcionar em conjunto com o sistema PJe 
(Processo Judicial Eletrônico).

Por que Firefox?

   - O PJe Office é homologado oficialmente só para o Firefox.

   - O Firefox ainda permite (em parte) o uso de integrações por socket (ex: via localhost:9999) que outros navegadores como Chrome e Edge 
bloqueiam ou restringem.

   - Os tribunais, como o TRT, normalmente só testam e dão suporte oficial ao Firefox.


E se usar outro navegador?

   - Pode até conseguir abrir o PJeCalc.

   - Mas a comunicação com o PJe Office e a assinatura digital geralmente não funciona.

   - Vai falhar na hora de validar certificado, assinar documentos ou transmitir os dados de volta ao sistema PJe.

Se você quiser rodar o PJeCalc de forma offline, sem ligação com navegador ou certificado, aí qualquer navegador serve — ou nenhum! Só o Java.


O que funciona no modo offline:

✔️ Criar cálculos
✔️ Gerar PDFs
✔️ Exportar XML
✔️ Ver históricos
❌ Assinar com certificado digital (sem PJe Office)
❌ Enviar para o sistema PJe automaticamente



Consultar o suporte técnico: 

Se o problema persistir, é aconselhável entrar em contato com o suporte técnico do PJe-Calc Cidadão ou 
com o setor de tecnologia da informação do TRT da sua região para assistência adicional.


" \
| yad \
--center \
--title="Sobre o PJe-Calc" \
--image="$logo" \
--window-icon=dialog-warning \
--text-info \
--buttons-layout="center" \
--button=OK:0 \
--width="1200" \
--height="800" \
2>/dev/null



# https://pjecalccalculos.com.br/


# ----------------------------------------------------------------------------------------

# Verificar se o Firefox esta instalado.

if command -v firefox > /dev/null 2>&1; then


# ----------------------------------------------------------------------------------------

# Vamos matar o Firefox se ele estiver aberto.

if pgrep -x firefox > /dev/null; then


    echo -e "\033[1;31m\n[ERRO] - ❌ Firefox está rodando. Matando o processo... \n\033[0m"

    yad --center --title="Encerrando Firefox" \
        --text="O Firefox está em execução e será encerrado para abrir o PJeCalc." \
        --image=dialog-warning --buttons-layout="center" --button="OK" --width="700" 2>/dev/null

    pkill -x firefox


else

    echo -e "\033[1;32m\nFirefox não está em execução.... \n\033[0m"

fi


# ----------------------------------------------------------------------------------------


    echo -e "\033[1;32m\nFirefox encontrado. Abrindo PJeCalc... \n\033[0m"
    
else

    echo -e "\033[1;31m[ERRO] - ❌ Firefox não está instalado para abrir o PJeCalc.\n\nPor favor, instale. \033[0m"

        yad \
        --center \
        --title="Firefox não encontrado" \
        --window-icon=dialog-warning \
        --text="❌ O navegador Firefox não está instalado para abrir o PJeCalc.\n\nPor favor, instale-o <b>usando o gerenciador de pacotes da sua distribuição Linux.</b>" \
        --buttons-layout="center" \
        --button="OK" \
        --width="640" \
        2>/dev/null




    exit 1

fi

# ----------------------------------------------------------------------------------------

# Para finalizar o processo associado ao pjecalc.jar.

pkill -f pjecalc.jar 2>/dev/null

sleep 1

# ----------------------------------------------------------------------------------------

# Verificar se existe algum programa usando a porta 9257.


# 2) O sistema inicia, mas quando o Firefox abre é apresentado 
# "This service requires use of the WebSocket protocol". O que fazer? 

# O problema ocorre quando algum outro programa está utilizando a mesma porta utilizada 
# pelo PJe-Calc Cidadão (a porta 9257). O que deve ser feito é identificar qual o programa 
# e verificar se é um programa necessário, se não for, você pode desinstalar. Caso seja 
# necessário, você deve pará-lo antes de iniciar o PJe-Calc Cidadão.
# 
# Para identificar quem está utilizando a porta 9257, você pode utilizar o comando 
# "netstat" do windows. Veja o link: http://solucoesms.com.br/como-verificar-qual-aplicativo-esta-usando-uma-porta/
# Após identificar o processo, você pode finalizá-lo com o comando "killall -9".
#
# Uma alternativa à solução acima é mudar a porta do próprio PJe-Calc Cidadão. Para isso, 
# procure pelo arquivo "/tomcat/conf/server.xml" dentro do diretório onde está instalado 
# o PJe-Calc Cidadão. Na linha 71 (ou procure pelo texto "9257"), mude para outro número, 
# por exemplo "19257". Salve o arquivo, reinicie o computador e inicie o PJe-Calc novamente. 
# Após iniciar, deverá ser informado manualmente no seu navegador a URL com a porta 
# alterada: http://localhost:19257/pjecalc



# Verifica se a porta está em uso.

OCUPADA=$(netstat -tuln 2>/dev/null | grep ":$porta ")

if [ -n "$OCUPADA" ]; then

    echo -e "\033[1;31m\n⚠️  A porta $porta está em uso:\n$OCUPADA \n \033[0m"

    yad --center --window-icon=dialog-warning --image="$logo" --title="PjeCalc" --text="\nA porta $porta está em uso:\n$OCUPADA \n" --buttons-layout="center" --button="OK" --width="500" 2>/dev/null


    # Descobre o PID usando a porta.

    PID=$(fuser $porta/tcp 2>/dev/null)

    if [ -n "$PID" ]; then

        echo -e "\033[1;31m\n🔍 Processo usando a porta: PID $PID \n \033[0m"


        # Diálogo com yad para confirmação

        yad \
            --center \
            --title="Porta em Uso" \
            --text="⚠️ A porta $porta está em uso pelo processo PID $PID.\n\nDeseja finalizar esse processo?" \
            --buttons-layout="center" \
            --button="Finalizar Processo:0" --button="Cancelar:1" \
            --width="500" \
            --height="200" \
            2>/dev/null


        # Verifica o código de saída do yad (0 = botão 1 foi clicado)

        if [ $? -eq 0 ]; then

            # kill -9 $PID 2>/dev/null

            killall -9 $PID 2>/dev/null

            # yad --center --info --title="Sucesso" --text="✅ Processo $PID que estava usando a porta $porta foi finalizado com sucesso." --buttons-layout="center" --button="OK" 2>/dev/null

            notify-send "PjeCalc" -i "$logo" -t 100000 "\n✅ Processo $PID que estava usando a porta $porta foi finalizado com sucesso.\n"

        else

            yad --center --info --title="Cancelado" --text="ℹ️ Processo $PID não foi finalizado." --buttons-layout="center" --button="OK" --width="300" 2>/dev/null

        fi

    else

        # yad --center --warning --title="Erro" --text="❌ Não foi possível identificar o processo com fuser." --buttons-layout="center" --button="OK" --width="400" 2>/dev/null

        notify-send "PjeCalc" -i "$logo" -t 100000 "\n❌ Não foi possível identificar o processo com fuser.\n"


    fi

else

    # yad --center --info --title="Porta Livre" --text="✅ A porta $porta está livre." --buttons-layout="center" --button="OK" --width="300" 2>/dev/null

    notify-send "Porta Livre" -i "$logo" -t 100000 "\n✅ A porta $porta está livre para ser usada no PjeCalc...\n"
fi


# Fonte:

# https://www.trt8.jus.br/pjecalc-cidadao/perguntas-frequentes-duvidas-tecnicas



# ----------------------------------------------------------------------------------------

cd "$HOME/PjeCalc/" 2>> "$log" || exit


# Esse trecho do script está verificando se o pjecalc.jar não está rodando. Se não estiver, ele inicia o programa usando Java.

# https://www.youtube.com/watch?v=GIqSTTuOBwM


if [ "$(ps -aux | grep -i pjecalc.jar | grep java)" = "" ]; then


    # Iniciar o PJeCalc

    echo -e "\033[1;32m\nIniciando o PJeCalc... \n\033[0m"

    echo "
Iniciando o PJeCalc...

" >> "$log"



   # exec "$JAVA_PATH" -Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1 -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -jar bin/pjecalc.jar  2>> "$log" &


   # Redirecionamento de erros (tudo (stdout + stderr) vá para o log)

  exec "$JAVA_PATH" \
  -splash:pjecalc_splash.gif \
  -Duser.timezone=GMT-3 \
  -Dfile.encoding=ISO-8859-1 \
  -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe \
  -Dseguranca.pjekz.servico.contexto="https://pje.trtXX.jus.br/pje-seguranca" \
  -Xms1024m \
  -Xmx2048m \
  -jar bin/pjecalc.jar 2>> "$log" &


# >> "$log" 2>&1 &


# ----------------------------------------------------------------------------------------


# Erro gerado no terminal realacionado ao PJeCalc (programa java) na area de notificação.

# $ console.error: ({})
# console.error: "Given tab is not restoring."

# $ console.error: ({})
# console.error: "update.locale" " file doesn't exist in either the application or GRE directories"


# console.error: ({}) — Isso apenas está registrando um objeto vazio no console. Provavelmente 
# faz parte de uma cadeia de logs maior.


# O PJe-Calc Cidadão utiliza um arquivo chamado update.locale como parte de sua estrutura 
# de localização e internacionalização. Esse arquivo é crucial para o correto funcionamento 
# do sistema, pois contém informações de idioma e configurações regionais.


# "update.locale" file doesn't exist in either the application or GRE directories — O
# PJeCalc está tentando encontrar um arquivo chamado update.locale, mas ele não está em 
# nenhum dos diretórios esperados (nem no do aplicativo, nem no diretório do GRE — Gecko Runtime Environment).


# Atualizar as tabelas auxiliares: Após a instalação, é fundamental atualizar as tabelas auxiliares do sistema.


# update.locale ainda está ausente	Refaça a atualização de tabelas

# Problema de idioma ou menus em branco	Verifique se update.locale contém pt-BR

# echo "pt-BR" > /PjeCalc/update.locale



# Para finalizar o processo associado ao pjecalc.jar.

# pkill -f pjecalc.jar


# ----------------------------------------------------------------------------------------


# $JAVA_PATH -jar ~/PjeCalc/bin/pjecalc.jar &
# [TRT8] Caminho da instalacao : /home/biglinux/PjeCalc/bin
# [TRT8] Configurando variaveis basicas.
# [TRT8] Buscando porta HTTP.
# [TRT8] Buscando url correta.
# [TRT8] Porta HTTP: 9257
# [TRT8] URL HTTP: http://localhost:9257/pjecalc
# [TRT8] Validando a existencia do banco H2.

fi


ESPERAR=1

while [  $ESPERAR = 1 ]; do

    curl http://localhost:$porta/pjecalc 2> /dev/null

    if [ "$?" = 0 ]; then

        ESPERAR=0

        # exec xdg-open http://localhost:$porta/pjecalc 2>> "$log"


        # O PJe Office é homologado oficialmente só para o Firefox.

        exec firefox http://localhost:$porta/pjecalc 2>> "$log" &

    fi

    sleep 1

done


# ----------------------------------------------------------------------------------------


# Verificar se a porta 9257 no localhost está aberta e ouvindo (ou seja, se o programa no http://localhost:9257 está ativo).


if curl -s --head http://localhost:$porta | grep "HTTP/" ; then


# $ curl -s --head http://localhost:9257
# HTTP/1.1 200 OK
# Server: Apache-Coyote/1.1
# Accept-Ranges: bytes
# ETag: W/"403-1734035909850"
# Last-Modified: Thu, 12 Dec 2024 20:38:29 GMT
# Content-Type: text/html
# Content-Length: 403
# Date: Fri, 18 Apr 2025 02:22:11 GMT


    echo -e "\nO programa está ativo na porta $porta.\n"

    # yad --center --title="PjeCalc" --window-icon="$logo" --image="$logo" --text="O PjeCalc está ativo na porta $porta." --button=OK 2>/dev/null

else

# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# curl: (7) Failed to connect to localhost port 9257 after 0 ms: Could not connect to server
# console.error: ({})
# console.error: "update.locale" " file doesn't exist in either the application or GRE directories"


    echo -e "\033[1;31m\n❌ A porta $porta não está respondendo como esperado.\n \033[0m"

    yad --center --title="PjeCalc" --window-icon=dialog-warning --image="$logo" --text="O PjeCalc não está acessível em http://localhost:$porta \n\nVerifique se ele está em execução." --buttons-layout="center"  --button="OK" --width="500" 2>/dev/null
    
    # exit
    
fi

# ----------------------------------------------------------------------------------------



# Buscar arquivos .IDC dentro de $HOME/PjeCalc/

# find "$HOME/PjeCalc/" -type f -iname "*.IDC"


# 6) Não consigo importar as tabelas auxiliares. Sempre aparece mensagem de erro, indicando 
# que o arquivo é inválido. O que fazer? 
# 
# Esse tipo de erro costuma acontecer quando o usuário descompacta o arquivo das tabelas 
# auxiliares antes de importá-lo no PJe-Calc Cidadão. Se este for o seu caso, basta 
# importar no sistema o arquivo das tabelas auxiliares compactado, exatamente da forma 
# que ele é disponibilizado no portal do TRT. Além disso, certifique-se de estar acessando 
# o menu correto para importação das tabelas auxiliares (Tabelas > Atualização de Tabelas 
# e Índices).
# 
# A partir da versão 2.5.1 do sistema, o arquivo compactado de tabelas auxiliares vêm com 
# a extensão ".IDC" e deve ser importado diretamente neste formato. Isso foi feito para 
# que o windows não associe o arquivo a um programa de descompactação e leve o usuário a 
# extrai-lo.
# 
# 
# https://www.trt8.jus.br/pjecalc-cidadao/perguntas-frequentes-duvidas-tecnicas
# https://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8


# Arquivo compactado de tabelas auxiliares


ARQUIVO_IDC=$(find "$HOME/PjeCalc/" -type f -iname "*.IDC" 2>/dev/null)

if [ -n "$ARQUIVO_IDC" ]; then

    echo -e "\033[1;32m\n✅ Arquivo(s) .IDC encontrado(s): \n\033[0m"

    echo "$ARQUIVO_IDC"

else

    echo -e "\033[1;31m\n❌ Nenhum arquivo .IDC encontrado em $HOME/PjeCalc/ \n\nhttps://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8 \n\033[0m"

    notify-send "PjeCalc" -i "$logo" -t 100000 "\n❌ Nenhum arquivo .IDC encontrado em $HOME/PjeCalc/ \n\nhttps://www.trt8.jus.br/pjecalc-cidadao/tabelas-auxiliares-trt8 \n"


    # Baixa o arquivo .idc e salva com o nome tabelas.idc dentro da pasta $HOME/PjeCalc/.  (Padrão no nome: tabelasnacionaisregionais$(date +%Y%m%d)0201.idc)

    # wget -P $HOME/PjeCalc/ -O tabelas.idc -c "https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/tabelasnacionaisregionais202504020201.idc"


    # Diferença entre -P e -O:

    # -P → define o diretório onde o arquivo será salvo.

    # -O → define o nome do arquivo que será salvo.


    # O wget não suporta curingas (*) em URLs da web como faria no terminal com arquivos locais. 

    # Não vai funcionar, porque o * não é interpretado pelo wget como "qualquer coisa" — ele precisa de um link completo para o arquivo.

    # Ex: https://www.trt8.jus.br/sites/portal/files/roles/pje-calc/tabelasnacionaisregionais*.idc



    # exit

fi


# ----------------------------------------------------------------------------------------


notify-send "PjeCalc" -i "$logo" -t 100000 "\nEm caso de problemas, verifique o arquivo de log: $log. \n"


# ----------------------------------------------------------------------------------------

# Problema:

# =========== 18-04-2025 01:06:22 - InÃ­cio da execuÃ§Ã£o do PJe-Calc ==========


# Converter o arquivo pjecalc.log para UTF-8 sem gerar um novo arquivo

iconv -f ISO-8859-1 -t UTF-8 /tmp/pjecalc.log -o /tmp/pjecalc-temp.log && mv /tmp/pjecalc-temp.log /tmp/pjecalc.log


sed -i "s/^==========.*/$INICIO/g" "$log"


# O que esse comando faz:

#     ^==========: só substitui se a linha começa com ==========.

#     /$INICIO/: troca pelo conteúdo da variável INICIO.

#     "$log": o arquivo que será editado.

#     -i: modifica o arquivo original.


# ----------------------------------------------------------------------------------------


exit 0

