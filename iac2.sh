#!/usr/bin/env bash
#
# iac2_dio.sh - Atomatizando a criação de infraetrutura para servidores Web.
#
# E-mail:     liralc@gmail.com
# Autor:      Anderson Lira
# Manutenção: Anderson Lira
#
# ************************************************************************** #
#  Atuomatizando crião de infraetrutura para sevidor Apache.
#
#  Exemplos de execução:
#      $ ./iac2.sh
#
# ************************************************************************** #
# Histórico:
#
#   v1.0 02/08/2022, Anderson Lira:
#       - Início do programa.
#
# ************************************************************************** #
# Testado em:
#   bash 5.0.3
#   Ubuntu 20.1
# ************************************************************************** #
#
# ======== VARIAVEIS ============================================================== #
export DIA_LOG=$(date +%d%m%Y-%H%M%S)
FILE_LOG="/dados/Logs/iacl_$DIA_LOG.log"
DIR_LOCAL="/mnt/driver"
USERS_SYSTEM="userList"
VERDE="\033[32;1m]"
VERMELHOP="\033[31;1;5m]"
DIR_INSTALL="$(mkdir /tmp/$RANDOM)"
DIR_APACHE="/var/www/html"
# ================================================================================ #

# ======== TESTES ================================================================ #
if [ $(echo $UID) -ne 0 ]
then
    echo -e "${VERMELHOP}Você deve está com privilégios de ROOT para continuar com esse programa." | tee -a "$FILE_LOG"
    exit 1
fi

if [ ! $(ping www.google.com -c 3) > /dev/null ]
then
    echo -e "${VERDE}Para a instalação do VNC, a sua máquina precisa está conectada na internet. " | tee -a "$FILE_LOG"
    exit 1
fi

echo "Verificando a existência do diretório para os logs." | tee -a "$FILE_LOG"
if [ -d /dados/Logs ]; then
    echo "Diretório de logs existente." | tee -a "$FILE_LOG"
else
    echo "Criando diretório para logs..." | tee -a "$FILE_LOG"
    mkdir -p  /dados/Logs
fi
# ================================================================================ #

# ======== FUNCOES ================================================================== #
function updateSystem () {
    apt-get update ; apt-get upgrade -y ; apt-get dist-upgrade -y ; apt autoremove
}

# ================================================================================ #

# ======== EXECUCAO DO PROGRAMA ===================================================== #

echo "Atualizando servidor..." | tee -a "$FILE_LOG"
updateSystem
echo "Verificando se o apache2 já está instalado..." | tee -a "$FILE_LOG"
dpkg -L "apache2"
if [ $(echo "$?") -ne 0 ]; then
    echo "Pacote apache não instalado." | tee -a "$FILE_LOG"
else
    echo "Iremos realizar a instalação do pacote apache2 e pacotes necessários para a sua configuração..." | tee -a "$FILE_LOG"
    apt-get install apache2 unzip -y
fi


cd "$DIR_INSTALL"
echo "Baixando e copiando os arquivos da aplicação..." | tee -a "$FILE_LOG"
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip 
unzip main.zip && rm -f main.zip
if [ $(echo "$?") -ne 0 ]; then
    echo "Houve algums erro na descompactação do arquivo..." | tee -a "$FILE_LOG"
    exit 1
else
    echo "Copiando os arquivos de configuração para o diretório $DIR_APACHE..." | tee -a "$FILE_LOG"
    DIR=$(ls -lh | tr -s ' ' | cut -f 9 -d " " -s)
    cd "$DIR"
    cp -R * "$DIR_APACHE"
fi
 echo "FIM..." | tee -a "$FILE_LOG"