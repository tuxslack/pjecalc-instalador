#!/bin/bash
#
# Autor: Fernando Souza - https://www.youtube.com/@fernandosuporte/
#
# Data:     24/04/2025 as 03:38:11
# Homepage: https://github.com/tuxslack/pjecalc-instalador
# Licença:  MIT


versao="55.0.2"

clear

# ----------------------------------------------------------------------------------------

# Verifica se o script está sendo executado como Root

# Adiciona uma verificação de permissão de superusuário (Root) é uma prática essencial, 
# especialmente porque várias operações usam sudo ou acessam /opt e /usr.


if [[ $EUID -ne 0 ]]; then

  echo -e "\n❌ Este script precisa ser executado como Root. \n"

  echo "🔒 Use: sudo $0"

  exit 1

fi

# ----------------------------------------------------------------------------------------

# 💡 Dica: ao rodar o script com sudo, os downloads e modificações no ~/ vão afetar o diretório home do Root (/root). 

# Adaptar o script para detectar o diretório original do usuário. 


# Detecta home do usuário que chamou o sudo

# Detecta a home do usuário original (não root)

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})


echo "$USER_HOME"

# Isso evita que arquivos como firefox.desktop ou o .tar.bz2 fiquem em /root, e sim na home do usuário que chamou o script, como /home/seunome.

# No script, onde estava ~/, substitua por: "$USER_HOME"


# ----------------------------------------------------------------------------------------

echo "🔍 Verificando dependências..."

# Lista de comandos necessários

REQUIRED_CMDS=(wget sudo tar sed)

# Verifica se cada comando está disponível

for cmd in "${REQUIRED_CMDS[@]}"; do

    if ! command -v $cmd &>/dev/null; then

        echo -e "\n❌ Erro: o comando '$cmd' não está instalado. Instale-o e tente novamente.\n"

        exit 1
    fi

done


# Verifica suporte a .tar.bz2 (via tar + bzip2)

if ! tar --help | grep -q 'bzip2'; then

echo "
❌ Erro: seu sistema não tem suporte para arquivos .tar.bz2 (bzip2).

Você pode instalar usando seu gerenciador de pacotes, buscando por algo como 'bzip2'.
"

    exit 1
fi

echo -e "\n✅ Todas as dependências estão presentes. Prosseguindo... \n"

# ----------------------------------------------------------------------------------------



echo -e "\n🔧 Instalando Firefox $versao Portable no Linux...\n"

echo "

⚠️ Aviso de segurança:

Versões antigas do Firefox, como a $versao, podem não receber mais atualizações de segurança 
e podem ser vulneráveis a ataques. É recomendável usá-las apenas se necessário para compatibilidade 
com sistemas ou aplicativos legados. Para uso geral, considere utilizar versões mais recentes 
ou a versão Extended Support Release (ESR) do Firefox.


Suporte Mozilla


"

# ----------------------------------------------------------------------------------------

# Verifica arquitetura

ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then

    ARCH="x86_64"

else
    ARCH="i686"  # Fallback para 32 bits
fi

# ----------------------------------------------------------------------------------------


# Obs: Firefox Portable 55.0.2 é usado no Windows para abrir o PJeCalc Cidadão versão 2.13.2. 


# 📦 Como instalar:

# ----------------------------------------------------------------------------------------

# Baixe o arquivo correspondente à arquitetura do seu sistema (32 ou 64 bits).


echo "⬇️ Baixando Firefox $versao para Linux ($ARCH)..."

wget --no-check-certificate -O  "$USER_HOME"/firefox-$versao.tar.bz2 -c "https://archive.mozilla.org/pub/firefox/releases/$versao/linux-${ARCH}/pt-BR/firefox-$versao.tar.bz2"
                                                                                                                                   
# ----------------------------------------------------------------------------------------

# Extrai o arquivo compactado na pasta /opt


echo "🧹 Limpando instalações anteriores..."

sudo rm -Rf /opt/firefox

echo "📦 Extraindo para /opt..."

sudo tar xjf "$USER_HOME"/firefox-$versao.tar.bz2 -C /opt

# ----------------------------------------------------------------------------------------

# Renomeia a pasta:


sudo mv /opt/firefox-$versao   /opt/firefox

# ----------------------------------------------------------------------------------------


# Crie um link simbólico para facilitar o acesso:


echo "🔗 Criando link simbólico..."

rm -Rf /usr/local/bin/firefox

sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

# ----------------------------------------------------------------------------------------


# Cria atalho (opcional)

echo "📁 Criando atalho na área de trabalho..."

# Baixe o arquivo .desktop:

wget -O "$USER_HOME"/firefox.desktop -c "https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop"

# Torne-o executável:

chmod +x "$USER_HOME"/firefox.desktop

# Mova para o diretório de aplicativos:

sudo mv "$USER_HOME"/firefox.desktop /usr/share/applications/


# ----------------------------------------------------------------------------------------

# Personalizando o atalho para uso específico do PJeCalc Cidadão.

# Edita o arquivo /usr/share/applications/firefox.desktop usando o sed.

# Personaliza nome e execução

echo "📝 Personalizando atalho..."


sudo sed -i \
-e 's/^Name=.*/Name=Firefox - PJeCalc Cidadão/' \
-e 's|^Exec=.*|Exec=/usr/local/bin/firefox|' \
/usr/share/applications/firefox.desktop

# ----------------------------------------------------------------------------------------

echo -e "\n✅ Firefox $versao instalado e personalizado com sucesso para o PJeCalc Cidadão! \n"


exit 0

