# pjecalc-instalador

Script que descompacta o .exe do PJeCalc e o faz funcionar no Linux sem precisar do Wine.


Instale o pacote pjecalc-instalador, faça o download do PJe Office no formato .exe, abra o instalador pelo menu do sistema, selecione o arquivo .exe e aguarde — a instalação é rápida. Em seguida, basta abrir o PJeCalc pelo menu.


É necessário remove a versão instalada para instalar essa versão.



Verifique se o firewall está bloqueando a porta usada pelo PJeCalc.



Dependências: jre-openjdk11, p7zip, yad, firefox, Fonte Noto Color Emoji, gnome-icon-theme


Versões de limite do Java:

java >= "11.0.25" e java < "24.0.1"



Porta do PJe-Calc Cidadão

Procure pelo arquivo "~/PjeCalc/tomcat/conf/server.xml" dentro do diretório onde está instalado o PJe-Calc Cidadão. Na linha 71 (ou procure pelo texto "9257"), mude para outro número, por exemplo "19257". Salve o arquivo, reinicie o computador e inicie o PJe-Calc novamente.

❯ cat -n  ~/PjeCalc/tomcat/conf/server.xml | grep "Connector port=" | grep "HTTP/1.1"
    71      <Connector port="9257" protocol="HTTP/1.1"




Servidor Apache

Arch Linux:

sudo pacman -Sy tomcat10

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl restart httpd


sudo pacman -Ss tomcat


❯ sudo iptables -F
❯ sudo iptables -X
❯ sudo iptables -Z


❯ sudo iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         



Para instalar o netstat no Arch Linux (usando o gerenciador de pacotes pacman)

sudo pacman -S net-tools

netstat -tuln | grep 9257

netstat -a -n


Instalar Firefox

Arch Linux:

sudo pacman -Sy firefox

ou

Firefox ESR (64 bit)

https://www.mozilla.org/pt-BR/firefox/all/desktop-esr/linux64/pt-BR/



Java

https://www.java.com/pt-BR/download/


Verifica se sua distribuição Linux tem suporte completo a emojis Unicode.

Arch Linux:

sudo pacman -S noto-fonts-emoji

Debian:

sudo apt install fonts-noto-color-emoji

Fedora:

sudo dnf install google-noto-emoji-color-fonts


Void Linux:

No Void Linux, o pacote fonts-noto-color-emoji não está disponível nos repositórios oficiais. No entanto, você pode instalar o Noto Color Emoji, que oferece suporte a emojis coloridos, seguindo os passos abaixo:

Baixar a fonte Noto Color Emoji

Acesse o repositório oficial do projeto no GitHub para obter a fonte:

https://github.com/DeeDeeG/noto-color-emoji-font

Instalar a fonte no sistema

mkdir -p ~/.fonts

mv ~/Downloads/NotoColorEmoji.ttf ~/.fonts/

Atualizar o cache de fontes

fc-cache -f -v


Reiniciar aplicativos ou o sistema

Feche e reabra os aplicativos nos quais deseja utilizar os emojis coloridos. Em alguns casos, pode ser necessário reiniciar o sistema para que as alterações tenham efeito completo.



Instala o pacote gnome-icon-theme


No Arch Linux e derivados, o pacote gnome-icon-theme está disponível no AUR (Arch User Repository), não nos repositórios oficiais. Para instalá-lo, você pode usar um auxiliar de AUR como o yay.

sudo pacman -S yay

yay -S gnome-icon-theme


Debian:

sudo apt update

sudo apt install -y adwaita-icon-theme


Fedora:

sudo dnf install adwaita-icon-theme


Void Linux

sudo xbps-install -S adwaita-icon-theme



Nota:

Compatível com diversas interfaces gráficas no Linux (GNOME, KDE, XFCE etc.) e também com gerenciadores de janelas como OpenBox, FluxBox, i3WM, entre outros.

Evita o uso de comandos específicos de um ambiente de desktop (DE), como konsole, kdialog, zenity, entre outros.


Navegadores recomendados para o PJeCalc

    Mozilla Firefox

    Mozilla Firefox ESR (Extended Support Release)

Esses são os mais estáveis e compatíveis com o PJeCalc.


🚫 Navegadores que costumam dar problemas

    Google Chrome / Chromium

    Microsoft Edge / Opera / Brave

    Em geral, qualquer navegador baseado no Chromium pode apresentar problemas de compatibilidade.


Acesse www.trt8.jus.br/pjecalc-cidadao e saiba mais sobre Sistema de Cálculo Trabalhista desenvolvido pela Secretaria de Tecnologia da Informação do Tribunal Regional do Trabalho da 8ª Região.


