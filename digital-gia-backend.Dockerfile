FROM node:18-slim
ARG directory=digital-gia-backend
ENV NODE_ENV=production
ENV PORT=3000
WORKDIR /$directory

RUN apt-get update &&\
     apt-get upgrade -y &&\
     apt-get install -y git &&\
     rm -rf /var/lib/apt/lists/*

RUN npm i -g sequelize-cli && npm cache clean --force

COPY $directory/yarn.lock $directory/package.json $directory/.npmrc ./
RUN yarn install --frozen-lockfile --production=false && yarn cache clean
COPY $directory .
RUN yarn run build:prod && yarn cache clean

COPY .git /.git

# CMD ["yarn", "run", "start:prod"]
CMD ["node", "dist/main"]

EXPOSE $PORT