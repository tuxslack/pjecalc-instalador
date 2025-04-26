# pjecalc-instalador

![Screenshot do PJeCalc no Void Linux](https://github.com/tuxslack/pjecalc-instalador/blob/c5879228eae8525c088b02cc2b2b65064b4651b5/usr/share/doc/pjecalc-instalador/tela-inicial_2025-04-17_00-10-25.png)  

![Screenshot do PJeCalc no Void Linux](https://github.com/tuxslack/pjecalc-instalador/blob/609bcf435db5059c684de993c7186af9cb26e0d3/usr/share/doc/pjecalc-instalador/PJeCalc_Void%20Linux_2025-04-16.png)  

Script que descompacta o `.exe` do **PJeCalc Cidadão** e o faz funcionar no Linux sem precisar do Wine.

---

## Instalação do PJeCalc Cidadão

1. Instale o pacote `pjecalc-instalador`.  
2. O script ira fazer o download do **PJeCalc Cidadão** no formato `.exe` ou você pode fazer manualmente e salva o arquivo .exe na pasta $HOME.  
3. Abra o instalador pelo menu do sistema.  
4. Selecione o arquivo `.exe` e aguarde.  
   A instalação é rápida.  
5. Após a instalação, abra o **PJeCalc Cidadão** pelo menu.

⚠️ **É necessário remover a versão já instalada para instalar esta versão.**

---

## Verificação do Firewall

Verifique se o firewall não está bloqueando a porta usada pelo **PJeCalc Cidadão**.

---

## Dependências do sistema

- **jre-openjdk11**  
- **p7zip**  
- **yad**  
- **firefox**  
- **Fonte Noto Color Emoji**  
- **gnome-icon-theme**  

---

## Limitações de versão do Java

O **PJeCalc Cidadão** suporta as seguintes versões de Java:
- **java >= "11.0.25"**  
- **java < "24.0.1"**

---

## Configuração da porta do PJeCalc Cidadão

1. Localize o arquivo `~/PjeCalc/tomcat/conf/server.xml` no diretório onde o **PJeCalc Cidadão** está instalado.
2. Na linha 71 (ou procure pelo texto `"9257"`), altere para outra porta, por exemplo `"19257"`.
3. Salve o arquivo, reinicie o computador e inicie o **PJeCalc Cidadão** novamente.

```bash
$ cat -n ~/PjeCalc/tomcat/conf/server.xml | grep "Connector port=" | grep "HTTP/1.1"
71      <Connector port="9257" protocol="HTTP/1.1">
```

### <span style="color:red;">* Para alguns casos específicos, altera-se a porta (de modo geral, isso não é alterado).</span>


## Firewall e comandos úteis

Certifique-se de que o firewall não está bloqueando a porta usada pelo **PJeCalc Cidadão**:

```bash
sudo iptables -F
sudo iptables -X
sudo iptables -Z

sudo iptables -L
```

## Instalando o Firefox

### Para instalar o navegador Firefox no Arch Linux:
```bash
sudo pacman -Sy firefox
```
ou 

Baixe e instale o  Firefox ESR (64 bit) no site oficial: [Download](https://www.mozilla.org/pt-BR/firefox/all/desktop-esr/linux64/pt-BR/).

**Firefox Portable 55.0.2** é usado no Windows para abrir o **PJeCalc Cidadão**.


Usa o script **/usr/local/bin/firefox-portable-install.sh** para instalar o **Firefox 55.0.2** para Linux.


## Configuração de Java

Baixe e instale o Java no site oficial: [Download](https://www.java.com/pt-BR/download/).

### Versões recomendadas:
- **java >= "11.0.25"**
- **java < "24.0.1"**

### Arch Linux:
```bash
sudo pacman -S jre11-openjdk
```


## Suporte a emojis Unicode

### Arch Linux:
```bash
sudo pacman -S noto-fonts-emoji
```

### Debian:
```bash
sudo apt install -y fonts-noto-color-emoji
```
### Fedora:
```bash
sudo dnf install google-noto-emoji-color-fonts
```

### Void Linux:

No Void Linux, o pacote **fonts-noto-color-emoji** não está disponível nos repositórios oficiais. Instale a fonte manualmente:

Baixe a  fonte [Noto Color Emoji](https://fonts.google.com/noto/specimen/Noto+Color+Emoji) diretamente do [Google Fonts](https://fonts.google.com/).

Extrair o arquivo **Noto_Color_Emoji.zip** para o diretório ~/.fonts

sudo apt install -y unzip  # Debian/Ubuntu
sudo pacman -S unzip    # Arch Linux
sudo dnf install unzip     # Fedora


Instale-a:

```bash
mkdir -p ~/.fonts

unzip -o ~/Downloads/Noto_Color_Emoji.zip -d ~/.fonts

ou

mv ~/Downloads/NotoColorEmoji-Regular.ttf ~/.fonts/

fc-cache -f -v

rm -Rf ~/Downloads/Noto_Color_Emoji.zip

```

## Navegadores recomendados

- **Mozilla Firefox**  
- **Mozilla Firefox ESR (Extended Support Release)**  
- **Brave (Use somente este navegador para importar os arquivos para o PJeCalc Cidadão).**  

### 🚫 Navegadores com problemas:
- Google Chrome / Chromium  
- Microsoft Edge  
- Opera  


Acesse o [Sistema de Cálculo Trabalhista](https://www.trt8.jus.br/pjecalc-cidadao) e saiba mais sobre o **PJeCalc Cidadão**, desenvolvido pela Secretaria de Tecnologia da Informação do Tribunal Regional do Trabalho da 8ª Região.
