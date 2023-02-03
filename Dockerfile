FROM node:14-alpine AS build-stage

WORKDIR /app

COPY package.json .

RUN npm install


COPY . .

RUN ls 


RUN npm run build

# production stage
FROM nginx AS production-stage

COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]