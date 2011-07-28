#!/bin/bash

# Verificando se o usuario e root ou esta usando sudo
if [ "$(whoami)" != 'root' ]; then
    echo "Voce nao tem permissoes para rodar \"$0\" com um usuario comum. Use sudo!"
    exit 1
fi

# Constantes
CAMINHO="/etc/apache2/sites-available/"
DOCROOT="/var/www/"
DOMINIO="local"

echo "###############################################"
echo "##  CRIACAO DE VIRTUALHOSTS DEBIAN E UBUNTU  ##"
echo "###############################################"
echo ""

echo "Digite o nome do virtualhost (ex: boltbrasil):"
read vhost
echo ""

# Caso ele queira um dominio personalizado
echo "Deseja criar um dominio personalizado?"
echo "(ex: 'com.br' => 'virtualhost.com.br', o padrao e 'virtualhost.local') [enter para padrao]"
read r_dominio
echo ""

if [[ "${r_dominio}" != "" ]]; then
    $DOMINIO=$r_dominio
fi

echo "Seus hosts estao em algum caminho fora do padrao? [s/n]"
read r_caminho
echo ""

# Verificando se o usuario apenas teclou 'enter'
while [[ "${r_caminho}" != "s" ]] && [[ "${r_caminho}" != "n" ]] && [[ "${r_caminho}" == "" ]] && [[ "${r_caminho}" != "nao" ]] && [[ "${r_caminho}" != "sim" ]]; do
    echo "(Digite 's' ou 'n')"
    echo "Seus hosts estao em algum caminho fora do padrao? [s/n]"
    read r_caminho
    echo ""
done

# Se o caminho for diferente do padrao
if [[ "${r_caminho}" == "s" ]] || [[ "${r_caminho}" == "sim" ]]; then
    echo "Digite o caminho dos hosts (ex: '/home/nome-de-usuario/caminho/' SEMPRE com a barra no final):"
    read caminho
    $CAMINHO=$caminho
fi

# Verificando se o dominio ja existe
if ! grep "${dominio}" $CAMINHO >> /dev/null; then
    echo "O virtualhost \"${vhost}.${dominio}\" sera criado."
    echo "Voce tem certeza que quer fazer isso? [s/n]"
    read q

    # Se tiver tudo certo, comeca a criar o virtualhost
    if [[ "${q}" == "s" ]] || [[ "${q}" == "sim" ]]; then
        #cp /etc/apache2/httpd.conf /etc/apache2/httpd.conf.`date +%Y%m%d%H%M%S`

        echo "Voce deseja criar um diretorio para o seu dominio? [s/n]"
        read r_diretorio
        echo ""

        # Verificando se o usuario apenas teclou 'enter'
        while [[ "${r_diretorio}" != "s" ]] && [[ "${r_diretorio}" != "n" ]] && [[ "${r_diretorio}" == "" ]] && [[ "${r_diretorio}" != "nao" ]] && [[ "${r_diretorio}" != "sim" ]]; do
            echo "(Digite 's' ou 'n')"
            echo "Voce deseja criar um diretorio para o seu dominio? [s/n]"
            read r_diretorio
            echo ""
        done

        # Se o usuario deseja criar o diretorio
        if [[ "${r_diretorio}" == "s" ]] || [[ "${r_diretorio}" == "sim" ]]; then
            echo "Qual o nome do diretorio?"
            read dir
            echo ""

            while [[ "${dir}" == "" ]]; do
                echo "Voce deve especificar o nome do diretorio!"
                echo "Qual o nome do diretorio?"
                read dir
                echo ""
            done

            echo "O DocumentRoot do Apache esta fora do padrao? [s/n]"
            read r_docroot
            echo ""

            while [[ "${r_docroot}" != "s" ]] && [[ "${r_docroot}" != "n" ]] && [[ "${r_docroot}" == "" ]] && [[ "${r_docroot}" != "nao" ]] && [[ "${r_docroot}" != "sim" ]]; do
                echo "(Digite 's' ou 'n')"
                echo "O DocumentRoot do Apache esta fora do padrao? [s/n]"
                read r_docroot
                echo ""
            done

            if [[ "${r_docroot}" == "s" ]] || [[ "${r_docroot}" == "sim" ]]; then
                echo "Digite o caminho do DocumentRoot (ex: '/home/nome-de-usuario/caminho/' SEMPRE com a barra no final):"
                read docroot
                $DOCROOT=$docroot
                echo ""
            fi

            # Verificando se o diretorio ja existe, se nao, cria o diretorio e seta permissoes de escrita pois foi criado como root
            if [[ ! -e $DOCROOT$dir ]]; then
                mkdir $DOCROOT$dir
                chmod 777 -R $DOCROOT$dir
            fi
        fi

        echo "
### ${vhost}.${dominio}
<VirtualHost *:80>
    ServerName ${vhost}.${dominio}
    DocumentRoot $DOCROOT$dir
    SetEnv APPLICATION_ENV development
</VirtualHost>" >> ${CAMINHO}${vhost}.conf

        # Caso o DocumentRoot for o padrao do Ubuntu/Debian, adiciona o site com o comando 'a2ensite'
        if [[ "${r_caminho}" == "s" ]] || [[ "${r_caminho}" == "sim" ]]; then
            a2ensite $vhost
        fi

        echo "Testando a configuracao."
        apache2ctl configtest
        echo ""

        echo "Voce gostaria de reiniciar o Apache? [s/n]"
        read r_reiniciar
        echo ""

        while [[ "${r_reiniciar}" != "s" ]] && [[ "${r_reiniciar}" != "n" ]] && [[ "${r_reiniciar}" == "" ]] && [[ "${r_reiniciar}" != "nao" ]] && [[ "${r_reiniciar}" != "sim" ]]; do
            echo "(Digite 's' ou 'n')"
            echo "Voce gostaria de reiniciar o Apache? [s/n]"
            read r_reiniciar
            echo ""
        done
            
        if [[ "${r_reiniciar}" == "sim" ]] || [[ "${r_reiniciar}" == "s" ]]; then
            apache2ctl restart
        fi
    fi
else
    echo "O \"${dominio}\" ja existe"
fi