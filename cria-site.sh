#!/bin/bash

# Check if the user is logged as root or using sudo
if [ "$(whoami)" != "root" ]; then
    echo "You don't have enough permissions to run \"$0\" as a normal user. Use sudo or root!"
    exit 1
fi

# Constants
APACHE_PATH="/etc/apache2/sites-available/"
DOCROOT="/var/www/"
DOMAIN="local"

echo "####################################"
echo "##  CREATING APACHE VIRTUALHOSTS  ##"
echo "####################################"
echo ""

echo "Type the virtualhost name (ie: testsite):"
read vhost
echo ""

echo "Do you wish to create a custom domain?"
echo "(ie: 'com' => '${vhost}.com', the default is '${vhost}.local') [enter for default]"
read r_domain
echo ""

if [[ "${r_domain}" != "" ]]; then
    DOMAIN=${r_domain}
fi

# If the user just typed 'enter'
while [[ "${r_path}" != "y" ]] && [[ "${r_path}" != "n" ]] && [[ "${r_path}" == "" ]] && [[ "${r_path}" != "no" ]] && [[ "${r_path}" != "yes" ]]; do
    echo "Your virtualhosts files are on the default path? [y/n]"
    read r_path
    echo ""
done

# If the virtualhosts path is differently than the default
if [[ "${r_path}" == "n" ]] || [[ "${r_path}" == "no" ]]; then
    echo "Type the path of the virtualhosts files (ie: '/home/username/path/' ALWAYS with the slash at the end):"
    read vhost_path
    echo ""
    APACHE_PATH=${vhost_path}
fi

# Check if the domain already exists in the virtualhosts path
if ! grep "${domain}" ${APACHE_PATH} >> /dev/null; then
    echo "The virtualhost \"${vhost}.${DOMAIN}\" will be created."
    echo "Are you sure? [y/n]"
    read q
    echo ""

    # Se tiver tudo certo, comeca a criar o virtualhost
    if [[ "${q}" == "y" ]] || [[ "${q}" == "yes" ]]; then
        # Verificando se o usuario apenas teclou 'enter'
        while [[ "${r_dir}" != "y" ]] && [[ "${r_dir}" != "n" ]] && [[ "${r_dir}" == "" ]] && [[ "${r_dir}" != "no" ]] && [[ "${r_dir}" != "yes" ]]; do
            echo "Do you want to create a directory for your domain? [y/n]"
            read r_dir
            echo ""
        done

        # Se o usuario deseja criar o diretorio
        if [[ "${r_dir}" == "y" ]] || [[ "${r_dir}" == "yes" ]]; then
            echo "Wich is the name of the directory?"
            read dir
            echo ""

            while [[ "${dir}" == "" ]]; do
                echo "You must specify the directory name!"
                echo "Wich is the directory name?"
                read dir
                echo ""
            done

            # Verificando se o DocumentRoot do Apache no esta no padrao
            echo "Wich is the path of the Apache DocumentRoot?"
            echo "(ie: '/home/www/' => default, '/home/htdocs/' ALWAYS with the slash at the end) [enter for default]"
            read r_docroot
            echo ""

            if [[ "${r_docroot}" != "" ]]; then
                DOCROOT=${r_docroot}
            fi

            # Verificando se o diretorio ja existe, se no, cria o diretorio,
            # seta permissoes de escrita pois foi criado como root, e cria o index.html
            # com uma mensagem de boas vindas
            if [[ ! -e ${DOCROOT}${dir} ]]; then
                mkdir ${DOCROOT}${dir}
                chmod 777 -R ${DOCROOT}${dir}

                touch ${DOCROOT}${dir}/index.html
                chmod 777 ${DOCROOT}${dir}/index.html

                echo "HELLO WORLD! <br /><br />" > $DOCROOT$dir/index.html
                echo "This is the virtualhost created: '${vhost}.${DOMAIN}'!" >> ${DOCROOT}${dir}/index.html
            fi
        fi

        echo "
### ${vhost}.${DOMAIN}
<VirtualHost *:80>
    ServerName ${vhost}.${DOMAIN}
    DocumentRoot ${DOCROOT}${dir}
    SetEnv APPLICATION_ENV development
</VirtualHost>" >> ${APACHE_PATH}${vhost}.conf

        # Caso o DocumentRoot for o padrao do Ubuntu/Debian, adiciona o site com o comando 'a2ensite'
        if [[ "${r_path}" == "y" ]] || [[ "${r_path}" == "yes" ]]; then
            a2ensite ${vhost}.conf
        fi

        echo "Checking the configuration."
        apache2ctl configtest
        echo ""

        # Adicionando entrada no hosts
        echo "127.0.0.1 ${vhost}.${DOMAIN}" >> /etc/hosts

        while [[ "${r_reload}" != "y" ]] && [[ "${r_reload}" != "n" ]] && [[ "${r_reload}" == "" ]] && [[ "${r_reload}" != "no" ]] && [[ "${r_reload}" != "yes" ]]; do
            echo "Do hyou want to reload the Apache? [y/n]"
            read r_reload
            echo ""
        done

        if [[ "${r_reload}" == "yes" ]] || [[ "${r_reload}" == "y" ]]; then
            apache2ctl restart
        fi
    fi
else
    echo "The '${vhost}.${DOMAIN}' virtualhost already exists!"
fi