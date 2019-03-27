FROM nginx

RUN mkdir /etc/nginx/ssl

# In swarm can be replaced with loaded secrets: https://docs.docker.com/engine/swarm/secrets/#use-secrets-in-compose
COPY ./certs/carter.crt /etc/nginx/ssl/carter.crt
COPY ./certs/carter.key /etc/nginx/ssl/carter.key

COPY nginx.conf /etc/nginx/nginx.conf
COPY locations /etc/nginx/locations

COPY bin/wait-for-it.sh wait-for-it.sh

CMD ["nginx", "-g", "daemon off;"]
