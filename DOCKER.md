# Legado Web Docker 部署指南

本项目提供了将 Legado (阅读) Web 界面容器化部署至 Docker 平台的完整支持。

我们设计了**双端口/三端口服务架构**，支持两种 Web UI 模式：
1. **端口 `4080` (原生全屏 Web UI)：** 提供构建自 `modules/web` 的 Vue 3 电子书网页版界面，已做 Web 适配及默认接口自动映射，拥有极佳的桌面及移动端大屏阅读、书架管理、书源编辑体验。
2. **端口 `4081` (透传原生 Web 服务)：** Nginx 反向代理直接透传您手机端开启的 Legado Web 服务（默认端口为 `1122`），访问此端口与直连手机效果完全一致。

---

## 1. 准备工作

在手机端开启 Legado (阅读) 的 Web 服务：
1. 打开手机端 **阅读 (Legado)** App。
2. 打开侧边栏菜单，找到并开启 **Web服务** 按钮。
3. 开启后，App 界面将显示类似 `http://192.168.1.5:1122` 的地址。
   - **注意：** 默认情况下，Legado 的 HTTP API 运行在端口 `1122`，其相关的 WebSocket 数据通道运行在端口 `1123`。
   - 确保您的手机与运行 Docker 容器的宿主机处于**同一局域网 (Wi-Fi)**。

---

## 2. 使用 Docker Compose 部署 (推荐)

项目根目录中已提供 `docker-compose.yml` 配置文件。

### 步骤一：配置环境变量
编辑根目录下的 `docker-compose.yml`，将 `environment` 中的 `BACKEND_URL` 和 `BACKEND_WS_URL` 修改为您手机上显示的地址：

```yaml
environment:
  - BACKEND_URL=http://192.168.1.5:1122      # 修改为您的手机 Legado Web 服务 IP 端口
  - BACKEND_WS_URL=http://192.168.1.5:1123   # 修改为您的手机 Legado WebSocket 端口 (一般是 HTTP 端口 + 1)
```

### 步骤二：启动容器
在根目录下运行以下命令构建镜像并启动服务：

```bash
docker compose up -d --build
```

---

## 3. 使用 Docker CLI 部署

如果您不想使用 Docker Compose，也可以直接使用 Docker CLI 进行构建和运行：

### 步骤一：构建 Docker 镜像
在项目根目录下运行：

```bash
docker build -t legado-web .
```

### 步骤二：运行 Docker 容器
运行容器并映射对应端口，同时通过 `-e` 传入您手机端的服务地址：

```bash
docker run -d \
  --name legado-web \
  --restart unless-stopped \
  -p 4080:4080 \
  -p 4081:4081 \
  -p 4082:4082 \
  -e BACKEND_URL=http://192.168.1.5:1122 \
  -e BACKEND_WS_URL=http://192.168.1.5:1123 \
  legado-web
```

---

## 4. 访问服务

容器正常运行后，您可以通过浏览器访问以下地址：

*   **全屏 WebUI (推荐)：** `http://localhost:4080`
    *   此端口提供原生的全屏 Web 体验。
    *   在首次打开时，已作 Web 适配，默认会尝试自动连接 `http://localhost:4081`（即当前主机的代理端口）。
    *   您也可以点击界面左侧的连接状态，手动指定任何其他的后台地址。
*   **直连透传 Web 界面：** `http://localhost:4081`
    *   此端口直接透传手机端原生的 Web 页面（包括首页导航、Wi-Fi 传书及原生 Vue 页面）。
    *   如果手机端服务未开启或网络断开，该端口将自动显示排查指南页面。
