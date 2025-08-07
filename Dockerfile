# Stage 1: Base image с Node.js
FROM node:20-alpine

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и устанавливаем зависимости
COPY package*.json ./
RUN npm ci

# Копируем исходники
COPY . .

# Открываем порт, на котором будет слушать Vite
EXPOSE 5173

# Запускаем Vite Dev Server
CMD ["npm", "run", "dev"]
