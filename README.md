## S-UI
基于`SagerNet/Sing-Box`构建的高级 Web 面板

**提示：原`alireza0/s-ui`项目被Github官方封禁，本仓库是基于原版的最后一个版本`v 1.4.1`的完整备份，包含完整的前端和后端源码。**

**本仓库仅修改了默认语言和时区为中文，其他都对标原版无改动。你可以直接使用本仓库的脚本，也可以自行fork编译**

Note: The original alireza0/s-ui project has been blocked and removed by GitHub. This repository is a complete backup based on the last version v1.4.1 of the original, containing the full front-end and back-end source code. This repository only modifies the default language and time zone to Chinese, with no other changes compared to the original. You can directly use the scripts from this repository, or fork and compile it yourself.

> **免责声明：** 本项目仅供个人学习与交流使用，请勿用于非法用途。


## 快速概览
| 功能 | 是否支持 |
| -------------------------------------- | :----------------: |
| 多协议 | :heavy_check_mark: |
| 多语言 | :heavy_check_mark: |
| 多客户端/入站 | :heavy_check_mark: |
| 高级流量路由界面 | :heavy_check_mark: |
| 客户端、流量与系统状态 | :heavy_check_mark: |
| 订阅链接（link/json/clash + info） | :heavy_check_mark: |
| 深色/浅色主题 | :heavy_check_mark: |
| API 接口 | :heavy_check_mark: |

## 支持平台
| 平台 | 架构 | 状态 |
|----------|--------------|---------|
| Linux | amd64, arm64, armv7, armv6, armv5, 386, s390x | 支持 |
| Windows | amd64, 386, arm64 | 支持 |
| macOS | amd64, arm64 | 实验性支持 |


## Информация об установке по умолчанию
- Порт панели: 2095
- Путь панели: /app/
- Порт подписки: 2096
- Путь подписки: /sub/
- Имя пользователя/пароль: admin

## Установка или обновление до последней версии

### Linux/macOS
```sh
bash <(curl -Ls https://raw.githubusercontent.com/admin8800/s-ui/main/install.sh)
```

### Windows
1. Скачайте последнюю версию для Windows из [GitHub Releases](https://github.com/admin8800/s-ui/releases/latest).
2. Распакуйте ZIP-файл.
3. Запустите `install-windows.bat` от имени администратора.
4. Следуйте инструкциям мастера установки.

## Установка старой версии

**Шаг 1:** Чтобы установить определенную старую версию, добавьте тег версии с `v` в конец команды установки. Например, версия `v1.0.0`:

```sh
bash <(curl -Ls https://raw.githubusercontent.com/admin8800/s-ui/main/install.sh) v1.0.0
```


## Ручная установка

### Linux/macOS
1. Скачайте последнюю версию S-UI для вашей системы и архитектуры из GitHub: [https://github.com/admin8800/s-ui/releases/latest](https://github.com/admin8800/s-ui/releases/latest)
2. **Необязательно:** скачайте последнюю версию `s-ui.sh`: [https://raw.githubusercontent.com/admin8800/s-ui/main/s-ui.sh](https://raw.githubusercontent.com/admin8800/s-ui/main/s-ui.sh)
3. **Необязательно:** скопируйте `s-ui.sh` в `/usr/bin/` и выполните `chmod +x /usr/bin/s-ui`.
4. Распакуйте tar.gz-архив s-ui в выбранный каталог и перейдите в распакованную папку.
5. Скопируйте файлы `*.service` в `/etc/systemd/system/`, затем выполните `systemctl daemon-reload`.
6. Выполните `systemctl enable s-ui --now`, чтобы включить автозапуск и запустить службу S-UI.
7. Выполните `systemctl enable sing-box --now`, чтобы запустить службу sing-box.

### Windows
1. Скачайте последнюю версию для Windows из GitHub: [https://github.com/admin8800/s-ui/releases/latest](https://github.com/admin8800/s-ui/releases/latest)
2. Скачайте подходящий пакет для Windows, например `s-ui-windows-amd64.zip`.
3. Распакуйте ZIP-файл в выбранный каталог.
4. Запустите `install-windows.bat` от имени администратора.
5. Следуйте инструкциям мастера установки.
6. Откройте панель: http://localhost:2095/app

## Удаление S-UI

```sh
sudo -i

systemctl disable s-ui  --now

rm -f /etc/systemd/system/sing-box.service
systemctl daemon-reload

rm -fr /usr/local/s-ui
rm /usr/bin/s-ui
```

## Установка с помощью Docker

<details>
   <summary>Показать подробности</summary>

### Использование

**Шаг 1:** Установите Docker

```shell
curl -fsSL https://get.docker.com | sh
```

**Шаг 2:** Установите S-UI

> Вариант с Docker Compose

```shell
services:
  s-ui:
    image: ghcr.io/admin8800/s-ui
    container_name: s-ui
    hostname: "s-ui"
    network_mode: host
    volumes:
      - "./db:/app/db"
      - "./cert:/app/cert"
    tty: true
    restart: unless-stopped
    entrypoint: "./entrypoint.sh"
```
`docker compose up -d`

> Прямой запуск через Docker

```shell
mkdir s-ui && cd s-ui

docker run -itd \
    --network host \
    -v $PWD/db/:/app/db/ \
    -v $PWD/cert/:/root/cert/ \
    --name s-ui \
    --restart=unless-stopped \
    ghcr.io/admin8800/s-ui
```

> Самостоятельная сборка образа

```shell
git clone https://github.com/admin8800/s-ui
docker build -t s-ui .
```

</details>

## 手动运行（贡献开发）

<details>
   <summary>点击查看详情</summary>

### 构建并运行完整项目
```shell
./runSUI.sh
```

### 克隆仓库
```shell
# 克隆仓库
git clone https://github.com/admin8800/s-ui
```

### - 前端

前端代码请查看 [frontend](frontend)

### - 后端
> 请先至少构建一次前端。

构建后端：
```shell
# 删除旧的前端编译文件
rm -fr web/html/*
# 应用新的前端编译文件
cp -R frontend/dist/ web/html/
# 构建
go build -o sui main.go
```

运行后端（在仓库根目录执行）：
```shell
./sui
```

</details>

## 语言

- 英语
- 波斯语
- 越南语
- 简体中文
- 繁体中文
- 俄语

## 功能

- 支持的协议：
  - 通用协议：Mixed、SOCKS、HTTP、HTTPS、Direct、Redirect、TProxy
  - 基于 V2Ray 的协议：VLESS、VMess、Trojan、Shadowsocks
  - 其他协议：ShadowTLS、Hysteria、Hysteria2、Naive、TUIC
- 支持 XTLS 协议。
- 提供高级流量路由界面，支持 PROXY Protocol、External、透明代理、SSL 证书和端口配置。
- 提供高级入站和出站配置界面。
- 支持客户端流量上限和到期时间。
- 显示在线客户端、入站、出站流量统计和系统状态监控。
- 订阅服务支持添加外部链接和订阅。
- Web 面板和订阅服务支持 HTTPS 安全访问（需自行提供域名和 SSL 证书）。
- 深色/浅色主题。

## 环境变量

<details>
  <summary>点击查看详情</summary>

### 使用方式

| 变量 | 类型 | 默认值 |
| -------------- | :--------------------------------------------: | :------------ |
| SUI_LOG_LEVEL | `"debug"` \| `"info"` \| `"warn"` \| `"error"` | `"info"` |
| SUI_DEBUG | `boolean` | `false` |
| SUI_BIN_FOLDER | `string` | `"bin"` |
| SUI_DB_FOLDER | `string` | `"db"` |
| SINGBOX_API | `string` | - |

</details>

## SSL 证书

<details>
  <summary>点击查看详情</summary>

### Certbot

```bash
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

certbot certonly --standalone --register-unsafely-without-email --non-interactive --agree-tos -d <你的域名>
```

</details>

#### 鸣谢原作者：alireza0
