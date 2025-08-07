# Stage 1: Build Vue app with Vite
FROM node:20-alpine AS builder

# Создаём рабочую директорию
WORKDIR /app

# Устанавливаем зависимости
COPY package*.json ./
RUN npm install

# Копируем исходники
COPY . .

# Production build
RUN npm run build

# Stage 2: Export only built files
FROM alpine:3.20 AS export

# Создаём каталог для выгрузки в volume или bind mount
WORKDIR /export

# Копируем только готовую сборку из предыдущего этапа
COPY --from=builder /app/dist ./
