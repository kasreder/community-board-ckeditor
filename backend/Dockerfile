FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY src ./src
COPY .env.example ./.env.example
COPY uploads ./uploads
EXPOSE 4000
CMD ["node", "src/server.js"]
