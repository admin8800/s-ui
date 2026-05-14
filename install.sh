#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# Проверка прав root
[[ $EUID -ne 0 ]] && echo -e "${red}Критическая ошибка:${plain} запустите этот скрипт с правами root \n " && exit 1

# Проверка системы и установка переменной release
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Не удалось определить систему, обратитесь к автору!" >&2
    exit 1
fi
echo "Текущий дистрибутив системы: $release"

arch() {
    case "$(uname -m)" in
    x86_64 | x64 | amd64) echo 'amd64' ;;
    i*86 | x86) echo '386' ;;
    armv8* | armv8 | arm64 | aarch64) echo 'arm64' ;;
    armv7* | armv7 | arm) echo 'armv7' ;;
    armv6* | armv6) echo 'armv6' ;;
    armv5* | armv5) echo 'armv5' ;;
    s390x) echo 's390x' ;;
    *) echo -e "${green}Архитектура CPU не поддерживается!${plain}" && rm -f install.sh && exit 1 ;;
    esac
}

echo "Архитектура: $(arch)"

install_base() {
    case "${release}" in
    centos | almalinux | rocky | oracle)
        yum -y update && yum install -y -q wget curl tar tzdata
        ;;
    fedora)
        dnf -y update && dnf install -y -q wget curl tar tzdata
        ;;
    arch | manjaro | parch)
        pacman -Syu && pacman -Syu --noconfirm wget curl tar tzdata
        ;;
    opensuse-tumbleweed)
        zypper refresh && zypper -q install -y wget curl tar timezone
        ;;
    *)
        apt-get update && apt-get install -y -q wget curl tar tzdata
        ;;
    esac
}

config_after_install() {
    echo -e "${yellow}Выполняется миграция... ${plain}"
    /usr/local/s-ui/sui migrate

    echo -e "${yellow}Установка/обновление завершены. Из соображений безопасности рекомендуется изменить настройки панели ${plain}"
    read -p "Продолжить изменение настроек [y/n]? " config_confirm
    if [[ "${config_confirm}" == "y" || "${config_confirm}" == "Y" ]]; then
        echo -e "Введите ${yellow}порт панели${plain} (оставьте пустым, чтобы использовать текущее/стандартное значение):"
        read config_port
        echo -e "Введите ${yellow}путь панели${plain} (оставьте пустым, чтобы использовать текущее/стандартное значение):"
        read config_path

        # Настройки подписки
        echo -e "Введите ${yellow}порт подписки${plain} (оставьте пустым, чтобы использовать текущее/стандартное значение):"
        read config_subPort
        echo -e "Введите ${yellow}путь подписки${plain} (оставьте пустым, чтобы использовать текущее/стандартное значение):"
        read config_subPath

        # Применение настроек
        echo -e "${yellow}Инициализация, подождите...${plain}"
        params=""
        [ -z "$config_port" ] || params="$params -port $config_port"
        [ -z "$config_path" ] || params="$params -path $config_path"
        [ -z "$config_subPort" ] || params="$params -subPort $config_subPort"
        [ -z "$config_subPath" ] || params="$params -subPath $config_subPath"
        /usr/local/s-ui/sui setting ${params}

        read -p "Изменить логин и пароль администратора [y/n]? " admin_confirm
        if [[ "${admin_confirm}" == "y" || "${admin_confirm}" == "Y" ]]; then
            # Данные первого администратора
            read -p "Задайте имя пользователя: " config_account
            read -p "Задайте пароль: " config_password

            # Настройка логина и пароля
            echo -e "${yellow}Инициализация, подождите...${plain}"
            /usr/local/s-ui/sui admin -username ${config_account} -password ${config_password}
        else
            echo -e "${yellow}Текущие учетные данные администратора:${plain}"
            /usr/local/s-ui/sui admin -show
        fi
    else
        echo -e "${red}Отменено...${plain}"
        if [[ ! -f "/usr/local/s-ui/db/s-ui.db" ]]; then
            local usernameTemp=$(head -c 6 /dev/urandom | base64)
            local passwordTemp=$(head -c 6 /dev/urandom | base64)
            echo -e "Это новая установка. Из соображений безопасности будут сгенерированы случайные данные для входа:"
            echo -e "###############################################"
            echo -e "${green}Имя пользователя: ${usernameTemp}${plain}"
            echo -e "${green}Пароль: ${passwordTemp}${plain}"
            echo -e "###############################################"
            echo -e "${red}Если вы забыли данные для входа, введите ${green}s-ui${red}, чтобы открыть меню настроек${plain}"
            /usr/local/s-ui/sui admin -username ${usernameTemp} -password ${passwordTemp}
        else
            echo -e "${red}Это обновление. Старые настройки будут сохранены. Если вы забыли данные для входа, введите ${green}s-ui${red}, чтобы открыть меню настроек${plain}"
        fi
    fi
}

prepare_services() {
    if [[ -f "/etc/systemd/system/sing-box.service" ]]; then
        echo -e "${yellow}Останавливается служба sing-box... ${plain}"
        systemctl stop sing-box
        rm -f /usr/local/s-ui/bin/sing-box /usr/local/s-ui/bin/runSingbox.sh /usr/local/s-ui/bin/signal
    fi
    if [[ -e "/usr/local/s-ui/bin" ]]; then
        echo -e "###############################################################"
        echo -e "${green}/usr/local/s-ui/bin${red} каталог уже существует!"
        echo -e "Проверьте его содержимое и удалите вручную после миграции ${plain}"
        echo -e "###############################################################"
    fi
    systemctl daemon-reload
}

install_s-ui() {
    cd /tmp/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/admin8800/s-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}Не удалось получить версию s-ui. Возможно, сработало ограничение GitHub API. Повторите попытку позже${plain}"
            exit 1
        fi
        echo -e "Получена последняя версия s-ui: ${last_version}. Начинается установка..."
        wget -N --no-check-certificate -O /tmp/s-ui-linux-$(arch).tar.gz https://github.com/admin8800/s-ui/releases/download/${last_version}/s-ui-linux-$(arch).tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Не удалось скачать s-ui. Убедитесь, что сервер имеет доступ к GitHub ${plain}"
            exit 1
        fi
    else
        last_version=$1
        [[ "${last_version}" != v* ]] && last_version="v${last_version}"
        url="https://github.com/admin8800/s-ui/releases/download/${last_version}/s-ui-linux-$(arch).tar.gz"
        echo -e "Начинается установка s-ui ${last_version}"
        wget -N --no-check-certificate -O /tmp/s-ui-linux-$(arch).tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Не удалось скачать s-ui ${last_version}. Проверьте, существует ли эта версия${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/s-ui/ ]]; then
        systemctl stop s-ui
    fi

    tar zxvf s-ui-linux-$(arch).tar.gz
    rm s-ui-linux-$(arch).tar.gz -f

    chmod +x s-ui/sui s-ui/s-ui.sh
    cp s-ui/s-ui.sh /usr/bin/s-ui
    cp -rf s-ui /usr/local/
    cp -f s-ui/*.service /etc/systemd/system/
    rm -rf s-ui

    config_after_install
    prepare_services

    systemctl enable s-ui --now

    echo -e "${green}s-ui ${last_version}${plain} установлен, запущен и работает..."
    echo -e "Панель доступна по следующему URL:${green}"
    /usr/local/s-ui/sui uri
    echo -e "${plain}"
    echo -e ""
    s-ui help
}

echo -e "${green}Выполняется...${plain}"
install_base
install_s-ui $1
