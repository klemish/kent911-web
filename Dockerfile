# develop stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install -g @quasar/cli
COPY . .
RUN npm install
RUN quasar build
# production stage
FROM nginx:alpine as production-stage
# Copy SPA
COPY --from=build-stage /app/dist/spa /usr/share/nginx/html
# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose HTTP Port 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
