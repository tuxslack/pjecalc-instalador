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


# Porta

porta="9257"


# Logs de execução

log="/tmp/pjecalc.log"



clear


rm -Rf "$log" 2>/dev/null


echo "=========== $(date '+%d-%m-%Y %H:%M:%S') - Início da execução do PJe-Calc ==========" >> "$log"


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

# Mensagem sobre o arquivo de log


echo "
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

" \
| yad \
--center \
--title="Sobre o arquivo de Log" \
--image="$logo" \
--window-icon=dialog-warning \
--text-info \
--buttons-layout="center" \
--button=OK:0 \
--width="1200" \
--height="800" \
2>/dev/null



# ----------------------------------------------------------------------------------------

# Verificar se o Firefox esta instalado.

if command -v firefox > /dev/null 2>&1; then


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


# Verificar se a porta 9257 no localhost está aberta e ouvindo (ou seja, se o programa no http://localhost:9257 está ativo).


if curl -s --head http://localhost:$porta | grep "HTTP/" > /dev/null; then

    echo -e "\nO programa está ativo na porta $porta.\n"

    # yad --center --title="PjeCalc" --window-icon="$logo" --image="$logo" --text="O PjeCalc está ativo na porta $porta." --button=OK 2>/dev/null

else

    echo -e "\033[1;31m\n❌ A porta $porta não está respondendo como esperado.\n \033[0m"

    yad --center --title="PjeCalc" --window-icon=dialog-warning --image="$logo" --text="O PjeCalc não está acessível em http://localhost:$porta \n\nVerifique se ele está em execução." --button="OK" --width="500" 2>/dev/null
fi


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

	exec "$JAVA_PATH" -Duser.timezone=GMT-3 -Dfile.encoding=ISO-8859-1 -Dseguranca.pjecalc.tokenServicos=pW4jZ4g9VM5MCy6FnB5pEfQe -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -jar bin/pjecalc.jar  2>> "$log" &

fi


ESPERAR=1

while [  $ESPERAR = 1 ]; do

    curl http://localhost:$porta/pjecalc

    if [ "$?" = 0 ]; then

        ESPERAR=0

        # exec xdg-open http://localhost:$porta/pjecalc 2>> "$log"


        # O PJe Office é homologado oficialmente só para o Firefox.

        exec firefox http://localhost:$porta/pjecalc 2>> "$log"

    fi

    sleep 1

done

# ----------------------------------------------------------------------------------------


exit 0

