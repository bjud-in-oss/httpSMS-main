# build stage
FROM node:lts-alpine AS build

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# install python
RUN apk add --no-cache python3

COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .

# Set API_BASE_URL for Nuxt generate
ENV API_BASE_URL=https://httpsms-api-ykmdb4to7q-ew.a.run.app

# Generate static files
RUN pnpm run generate

# List files to verify build output location (will show in logs)
RUN ls -la /app/dist

# production stage
FROM nginx:stable-alpine as production

# Remove default nginx static assets and any existing configs
RUN rm -rf /usr/share/nginx/html/* && rm -rf /etc/nginx/conf.d/*

# Copy the custom nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output from the build stage
# We use /app/dist/ here to ensure we copy the content if it's a directory
COPY --from=build /app/dist /usr/share/nginx/html

# Ensure the files are readable and the directory is searchable
RUN chmod -R 755 /usr/share/nginx/html && chown -R nginx:nginx /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
