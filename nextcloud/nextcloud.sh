# Credentials for the website
USER="user"
USER_PASSWORD="password"

# Credentials for the database
DB_USER="db_user"
DB_PASSWORD="db_password"

# The port to run on
NEXTCLOUD_PORT="9000"

# The subdirectory to access the website in 
# Leave blank for it to be put at the top-level directory
SUBDIRECTORY="nextcloud"

# The interface that's IP will be used to connect to the website
INTERFACE="eth0"

NEXTCLOUD_URL="https://download.nextcloud.com/server/releases/nextcloud-28.0.2.tar.bz2"
NEXTCLOUD_OFFICE_URL="https://github.com/nextcloud/richdocuments/releases/download/v8.3.1/richdocuments.tar.gz"
COLLABORA_ONLINE_URL="https://github.com/CollaboraOnline/richdocumentscode/releases/download/23.5.705/richdocumentscode.tar.gz"

# Path to the CLI (Don't modify)
OCC="/var/www/nextcloud/occ"

set -e

info() {
    echo -e "\n$1"
}

install_packages() {
    info "Installing needed packages"
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections
    apt update && apt install --yes \
        apache2 git mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring \
        php-intl php-gmp php-bcmath php-xml php-imagick php-zip ttf-mscorefonts-installer
}

set_php_memory_limit() {
    php_dir="$(dirname "$(php --ini | head -1 | cut -d' ' -f5)")"
    php_file="$php_dir/apache2/php.ini"
    mem_limit_conf="memory_limit = 512M"
    info "Configuring PHP memory limit at $php_file"
    if [[ -f $php_file ]]; then
        sed --in-place "s/^memory_limit = .*/$mem_limit_conf/" "$php_file"
    else
        info "!!! WARNING !!!"
        echo "php.ini file not found at $php_file"
        echo -e "Add '$mem_limit_conf' to Apache's php.ini file\n"
    fi
}

configure_database() {
    info "Configuring database"
    mysql <<EOF
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD'; 
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; 
GRANT ALL PRIVILEGES ON nextcloud.* TO '$DB_USER'@'localhost'; 
FLUSH PRIVILEGES;
EOF
}

_install_nextcloud_app() {
    app_download_path="/var/www/nextcloud/apps/$1.tar.gz"
    download_url="$2"
    curl -k -L --output "$app_download_path" "$download_url"
    tar --extract --file "$app_download_path"
}

_get_ip() {
    ip -4 -br addr show "$INTERFACE" | awk '{print $3}' | cut -d/ -f1
}

install_nextcloud() {
    info "Installing Nextcloud"
    curl -k "$NEXTCLOUD_URL" --output nextcloud-server.tar.bz2
    tar --extract --bzip2 --file nextcloud-server.tar.bz2
    cp --recursive nextcloud /var/www
    chown --recursive www-data:www-data /var/www/nextcloud
    chmod +x "$OCC"
    sudo -u www-data "$OCC" maintenance:install \
        --database="mysql" --database-name="nextcloud" \
        --database-user="$DB_USER" --database-pass="$DB_PASSWORD" \
        --admin-user="$USER" --admin-pass="$USER_PASSWORD"
    info "Installing Nextcloud Office"
    _install_nextcloud_app "richdocuments" "$NEXTCLOUD_OFFICE_URL"
    info "Installing Collabora Online"
    _install_nextcloud_app "richdocumentscode" "$COLLABORA_ONLINE_URL"
    chown --recursive www-data:www-data /var/www/nextcloud/apps
    sudo -u www-data "$OCC" app:enable richdocuments richdocumentscode
    info "Configuring Nextcloud"
    sudo -u www-data "$OCC" config:system:set has_internet_connection --value="false" --type=boolean
    sudo -u www-data "$OCC" config:system:set appstoreenabled --value="false" --type=boolean
    sudo -u www-data "$OCC" config:system:set trusted_domains 1 --value="$(_get_ip)" --type=string
}

configure_apache() {
    echo -e "\nConfiguring Apache"
    [[ $NEXTCLOUD_PORT != "80" ]] && echo "Listen $NEXTCLOUD_PORT" >>/etc/apache2/ports.conf
    if [[ -n $SUBDIRECTORY ]]; then
        directory_config="Alias /$SUBDIRECTORY /var/www/nextcloud/"
    else
        directory_config="DocumentRoot /var/www/nextcloud/"
    fi
    cat <<EOF >/etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:$NEXTCLOUD_PORT>
    $directory_config

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymLinks MultiViews

        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>
</VirtualHost>
EOF
    a2ensite nextcloud
    systemctl enable apache2 && systemctl restart apache2
}

if [[ $EUID != "0" ]]; then
    echo "This script must run be run as root!"
    exit
fi

install_packages
set_php_memory_limit
configure_database

install_nextcloud
configure_apache

info "Successfully installed Nextcloud!"
