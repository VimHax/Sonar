FROM node:20

WORKDIR /app

RUN apt-get update
RUN apt-get install -y ffmpeg

COPY package.json package.json
COPY package-lock.json package-lock.json
RUN npm ci

COPY . .

RUN npm run build

CMD [ "npm", "start" ]
