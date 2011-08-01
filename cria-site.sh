#!/bin/bash

# Verificando se o usuario e root ou esta usando sudo
if [ "$(whoami)" != "root" ]; then
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
echo "(ex: 'com.br' => '${vhost}.com.br', o padrao e '${vhost}.local') [enter para padrao]"
read r_dominio
echo ""

if [[ "${r_dominio}" != "" ]]; then
    DOMINIO=${r_dominio}
fi

# Verificando se o usuario apenas teclou 'enter'
while [[ "${r_caminho}" != "s" ]] && [[ "${r_caminho}" != "n" ]] && [[ "${r_caminho}" == "" ]] && [[ "${r_caminho}" != "nao" ]] && [[ "${r_caminho}" != "sim" ]]; do
    echo "Seus hosts estao no caminho padrao? [Digite 's' ou 'n']"
    read r_caminho
    echo ""
done

# Se o caminho for diferente do padrao
if [[ "${r_caminho}" == "n" ]] || [[ "${r_caminho}" == "nao" ]]; then
    echo "Digite o caminho dos hosts (ex: '/home/nome-de-usuario/caminho/' SEMPRE com a barra no final):"
    read caminho
    echo ""
    CAMINHO=${caminho}
fi

# Verificando se o dominio ja existe
if ! grep "${dominio}" ${CAMINHO} >> /dev/null; then
    echo "O virtualhost \"${vhost}.${DOMINIO}\" sera criado."
    echo "Voce tem certeza que quer fazer isso? [s/n]"
    read q
    echo ""

    # Se tiver tudo certo, comeca a criar o virtualhost
    if [[ "${q}" == "s" ]] || [[ "${q}" == "sim" ]]; then
        # Verificando se o usuario apenas teclou 'enter'
        while [[ "${r_diretorio}" != "s" ]] && [[ "${r_diretorio}" != "n" ]] && [[ "${r_diretorio}" == "" ]] && [[ "${r_diretorio}" != "nao" ]] && [[ "${r_diretorio}" != "sim" ]]; do
            echo "Voce deseja criar um diretorio para o seu dominio? [Digite 's' ou 'n']"
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

            while [[ "${r_docroot}" != "s" ]] && [[ "${r_docroot}" != "n" ]] && [[ "${r_docroot}" == "" ]] && [[ "${r_docroot}" != "nao" ]] && [[ "${r_docroot}" != "sim" ]]; do
                echo "(Digite 's' ou 'n')"
                echo "O DocumentRoot do Apache esta fora do padrao? [Digite 's' ou 'n']"
                read r_docroot
                echo ""
            done

            if [[ "${r_docroot}" == "s" ]] || [[ "${r_docroot}" == "sim" ]]; then
                echo "Digite o caminho do DocumentRoot (ex: '/home/nome-de-usuario/www/' SEMPRE com a barra no final):"
                read docroot
                DOCROOT=${docroot}
                echo ""
            fi

            # Verificando se o diretorio ja existe, se nao, cria o diretorio,
            # seta permissoes de escrita pois foi criado como root, e cria o index.html
            # com uma mensagem de boas vindas
            if [[ ! -e ${DOCROOT}${dir} ]]; then
                mkdir ${DOCROOT}${dir}
                chmod 777 -R ${DOCROOT}${dir}
                
                touch ${DOCROOT}${dir}/index.html
                chmod 777 ${DOCROOT}${dir}/index.html
                
                echo "OLA MUNDO! <br /><br />" > $DOCROOT$dir/index.html
                echo "Este e o virtualhost '${vhost}.${DOMINIO}'!" >> ${DOCROOT}${dir}/index.html
            fi
        fi

        echo "
### ${vhost}.${DOMINIO}
<VirtualHost *:80>
    ServerName ${vhost}.${DOMINIO}
    DocumentRoot ${DOCROOT}${dir}
    SetEnv APPLICATION_ENV development
</VirtualHost>" >> ${CAMINHO}${vhost}.conf

        # Caso o DocumentRoot for o padrao do Ubuntu/Debian, adiciona o site com o comando 'a2ensite'
        if [[ "${r_caminho}" == "s" ]] || [[ "${r_caminho}" == "sim" ]]; then
            a2ensite ${vhost}.conf
        fi

        echo "Testando a configuracao."
        apache2ctl configtest
        echo ""

        # Adicionando entrada no hosts
        echo "127.0.0.1 ${vhost}.${DOMINIO}" >> /etc/hosts

        while [[ "${r_reiniciar}" != "s" ]] && [[ "${r_reiniciar}" != "n" ]] && [[ "${r_reiniciar}" == "" ]] && [[ "${r_reiniciar}" != "nao" ]] && [[ "${r_reiniciar}" != "sim" ]]; do
            echo "(Digite 's' ou 'n')"
            echo "Voce gostaria de reiniciar o Apache? [Digite 's' ou 'n']"
            read r_reiniciar
            echo ""
        done
            
        if [[ "${r_reiniciar}" == "sim" ]] || [[ "${r_reiniciar}" == "s" ]]; then
            apache2ctl restart
        fi
    fi
else
    echo "O virtualhost '${vhost}.${DOMINIO}' ja existe"
fi
