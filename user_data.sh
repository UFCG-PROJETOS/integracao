#!/bin/bash
# user_data.sh

# Atualiza os pacotes e instala o Docker
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# Instala o Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Puxa as imagens mais recentes para agilizar o 'up'
docker pull mecqema/app:latest
docker pull jramonalves/app:latest
docker pull postgres:16-alpine

# Obtém o IP público da própria instância EC2 para injetar no frontend
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4)

# Cria o arquivo docker-compose.yml na home do usuário padrão
# Note as adaptações: VITE_API_URL dinâmica, porta 80 para o frontend e remoção da porta do BD
cat <<EOF > /home/ec2-user/docker-compose.yml
services:
  backend:
    image: mecqema/app:latest
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://sqibidi_dev:sqibidi_pwd_bd@postgres-db:5432/sqibidi_questions_bd
    depends_on:
      - postgres-db
    networks:
      - sqibidi-network

  frontend:
    image: jramonalves/app:latest
    restart: unless-stopped
    ports:
      - "80:5173" # <-- Mapeando a porta 80 para a porta do seu app
    environment:
      - VITE_API_URL=http://${PUBLIC_IP}:8000 # <-- IP público injetado aqui!
    depends_on:
      - backend
    networks:
      - sqibidi-network

  postgres-db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=sqibidi_dev
      - POSTGRES_PASSWORD=sqibidi_pwd_bd
      - POSTGRES_DB=sqibidi_questions_bd
    # A porta não precisa ser exposta publicamente
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - sqibidi-network

networks:
  sqibidi-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
EOF

# Sobe os containers em modo detached (background)
cd /home/ec2-user
docker-compose up -d