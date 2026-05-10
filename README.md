## S-UI
基于`SagerNet/Sing-Box`构建的高级 Web 面板，基于`alireza0/s-ui`的最后一个版本。


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


## 默认安装信息
- 面板端口：2095
- 面板路径：/app/
- 订阅端口：2096
- 订阅路径：/sub/
- 用户名/密码：admin

## 安装或升级到最新版本

### Linux/macOS
```sh
bash <(curl -Ls https://raw.githubusercontent.com/admin8800/s-ui/main/install.sh)
```

### Windows
1. 从 [GitHub Releases](https://github.com/admin8800/s-ui/releases/latest) 下载最新 Windows 版本。
2. 解压 ZIP 文件。
3. 以管理员身份运行 `install-windows.bat`。
4. 按照安装向导操作。

## 安装旧版本

**步骤 1：** 如果要安装指定旧版本，请在安装命令末尾追加带 `v` 的版本标签。例如版本 `v1.0.0`：


## 手动安装

### Linux/macOS
1. 根据你的系统和架构，从 GitHub 获取最新版本 S-UI：[https://github.com/admin8800/s-ui/releases/latest](https://github.com/admin8800/s-ui/releases/latest)
2. **可选：** 获取最新版 `s-ui.sh`：[https://raw.githubusercontent.com/admin8800/s-ui/main/s-ui.sh](https://raw.githubusercontent.com/admin8800/s-ui/main/s-ui.sh)
3. **可选：** 将 `s-ui.sh` 复制到 `/usr/bin/`，并执行 `chmod +x /usr/bin/s-ui`。
4. 将 s-ui tar.gz 文件解压到你选择的目录，并进入解压后的目录。
5. 将 `*.service` 文件复制到 `/etc/systemd/system/`，然后执行 `systemctl daemon-reload`。
6. 使用 `systemctl enable s-ui --now` 启用开机自启并启动 S-UI 服务。
7. 使用 `systemctl enable sing-box --now` 启动 sing-box 服务。

### Windows
1. 从 GitHub 获取最新 Windows 版本：[https://github.com/admin8800/s-ui/releases/latest](https://github.com/admin8800/s-ui/releases/latest)
2. 下载适合的 Windows 包，例如 `s-ui-windows-amd64.zip`。
3. 将 ZIP 文件解压到你选择的目录。
4. 以管理员身份运行 `install-windows.bat`。
5. 按照安装向导操作。
6. 访问面板：http://localhost:2095/app

## 卸载 S-UI

```sh
sudo -i

systemctl disable s-ui  --now

rm -f /etc/systemd/system/sing-box.service
systemctl daemon-reload

rm -fr /usr/local/s-ui
rm /usr/bin/s-ui
```

## 使用 Docker 安装

<details>
   <summary>点击查看详情</summary>

### 使用方式

**步骤 1：** 安装 Docker

```shell
curl -fsSL https://get.docker.com | sh
```

**步骤 2：** 安装 S-UI

> Docker compose 方式

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

> 直接使用 docker

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

> 自行构建镜像

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