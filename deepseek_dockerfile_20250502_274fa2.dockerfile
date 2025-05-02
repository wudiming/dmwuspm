# ----------------------------
# —— 多阶段构建：Build 阶段 ——  
# ----------------------------
FROM node:20-alpine as builder

# 定义所有构建参数 (参数默认值与原.env.example一致)
ARG MAIN_VITE_TITLE="SPlayer"
ARG MAIN_VITE_MAIN_PORT=7899
ARG MAIN_VITE_DEV_PORT=6944
ARG MAIN_VITE_SERVER_HOST="127.0.0.1"
ARG MAIN_VITE_SERVER_PORT=11451
ARG RENDERER_VITE_SERVER_URL="https://api.example.com"
ARG VITE_UNM_API="https://unm.example.com"
ARG RENDERER_VITE_SITE_URL="https://player.example.com"
ARG VITE_TTML_API=""
ARG RENDERER_VITE_SITE_ROOT="false"
ARG RENDERER_VITE_SITE_TITLE="SPlayer"
ARG RENDERER_VITE_SITE_ANTHOR="Furina"
ARG RENDERER_VITE_SITE_KEYWORDS="云音乐,播放器,在线音乐,在线播放器,音乐播放器"
ARG RENDERER_VITE_SITE_DES="一个简约的在线音乐播放器，具有音乐搜索、播放、每日推荐、私人FM、歌词显示、歌曲评论、网易云登录与云盘等功能, 而且新增了解灰功能, 接触无法播放的灰色歌曲或者VIP歌曲"
ARG MAIN_VITE_MIGU_COOKIE=""
ARG RENDERER_VITE_ANN_TYPE="info"
ARG RENDERER_VITE_ANN_TITLE="🎉新版本推出"
ARG RENDERER_VITE_ANN_CONTENT="本网站基于Imsyy的SPlayer二次开发, 新增了Web解灰功能, 可以播放无法播放的灰色歌曲以及VIP歌曲"
ARG RENDERER_VITE_ANN_DURATION=8000

RUN apk update && apk add --no-cache git
WORKDIR /app

# 安装依赖 & 拷贝源码
COPY package*.json ./
RUN npm install
COPY . .

# 动态生成.env文件
RUN cp .env.example .env && \
    sed -i "s|MAIN_VITE_TITLE = .*|MAIN_VITE_TITLE = \"${MAIN_VITE_TITLE}\"|g" .env && \
    sed -i "s|MAIN_VITE_MAIN_PORT = .*|MAIN_VITE_MAIN_PORT = ${MAIN_VITE_MAIN_PORT}|g" .env && \
    sed -i "s|MAIN_VITE_DEV_PORT = .*|MAIN_VITE_DEV_PORT = ${MAIN_VITE_DEV_PORT}|g" .env && \
    sed -i "s|MAIN_VITE_SERVER_HOST = .*|MAIN_VITE_SERVER_HOST = ${MAIN_VITE_SERVER_HOST}|g" .env && \
    sed -i "s|MAIN_VITE_SERVER_PORT = .*|MAIN_VITE_SERVER_PORT = ${MAIN_VITE_SERVER_PORT}|g" .env && \
    sed -i "s|RENDERER_VITE_SERVER_URL = .*|RENDERER_VITE_SERVER_URL = \"${RENDERER_VITE_SERVER_URL}\"|g" .env && \
    sed -i "s|VITE_UNM_API = .*|VITE_UNM_API = \"${VITE_UNM_API}\"|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_URL = .*|RENDERER_VITE_SITE_URL = \"${RENDERER_VITE_SITE_URL}\"|g" .env && \
    sed -i "s|VITE_TTML_API = .*|VITE_TTML_API = \"${VITE_TTML_API}\"|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_ROOT = .*|RENDERER_VITE_SITE_ROOT = ${RENDERER_VITE_SITE_ROOT}|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_TITLE = .*|RENDERER_VITE_SITE_TITLE = \"${RENDERER_VITE_SITE_TITLE}\"|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_ANTHOR = .*|RENDERER_VITE_SITE_ANTHOR = \"${RENDERER_VITE_SITE_ANTHOR}\"|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_KEYWORDS = .*|RENDERER_VITE_SITE_KEYWORDS = \"${RENDERER_VITE_SITE_KEYWORDS}\"|g" .env && \
    sed -i "s|RENDERER_VITE_SITE_DES = .*|RENDERER_VITE_SITE_DES = \"${RENDERER_VITE_SITE_DES}\"|g" .env && \
    sed -i "s|MAIN_VITE_MIGU_COOKIE = .*|MAIN_VITE_MIGU_COOKIE = \"${MAIN_VITE_MIGU_COOKIE}\"|g" .env && \
    sed -i "s|RENDERER_VITE_ANN_TYPE = .*|RENDERER_VITE_ANN_TYPE = \"${RENDERER_VITE_ANN_TYPE}\"|g" .env && \
    sed -i "s|RENDERER_VITE_ANN_TITLE = .*|RENDERER_VITE_ANN_TITLE = \"${RENDERER_VITE_ANN_TITLE}\"|g" .env && \
    sed -i "s|RENDERER_VITE_ANN_CONTENT = .*|RENDERER_VITE_ANN_CONTENT = \"${RENDERER_VITE_ANN_CONTENT}\"|g" .env && \
    sed -i "s|RENDERER_VITE_ANN_DURATION = .*|RENDERER_VITE_ANN_DURATION = ${RENDERER_VITE_ANN_DURATION}|g" .env

# 执行构建
RUN npm run build

# ----------------------------
# —— 运行阶段：Production 阶段 ——  
# ----------------------------
FROM nginx:stable-alpine AS production

COPY --from=builder /app/out/renderer /usr/share/nginx/html
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]