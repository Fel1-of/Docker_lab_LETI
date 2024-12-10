ARG directory=digital-gia-frontend

FROM node:16-slim AS builder
ARG directory
ENV NODE_ENV=production
WORKDIR /$directory

RUN apt-get update &&\
     apt-get upgrade -y &&\
     apt-get install -y git &&\
     rm -rf /var/lib/apt/lists/*

COPY $directory/yarn.lock $directory/package.json $directory/.npmrc ./
RUN yarn install --frozen-lockfile --production=false
COPY .git /.git
COPY $directory .
RUN yarn run prod-build && yarn cache clean

FROM nginx:1.27.3-alpine
ARG directory

RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /$directory/dist-deployed /usr/share/nginx/html/gia
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    location /gia/ { \
      alias /usr/share/nginx/html/gia/; \
      try_files $uri $uri/ /gia/index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

EXPOSE 80