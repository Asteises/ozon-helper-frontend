# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Важно: явно указываем лог сборки
RUN npm run build && ls -lah dist/

# Stage 2: Export dist
FROM alpine:3.20 AS export

WORKDIR /export
COPY --from=builder /app/dist/ ./
