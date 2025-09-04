# Sqibidi - Daily SQL practice game
Rodar localmente com `sudo docker compose -f docker-compose.deploy.yml up -d`

## Ambiente de produção
Consiste de 3 serviços:
 - O SGBD, postgres guardando as questões e as pontuações.
 - A api do backend, um ambiente com python gerenciado pelo UV rodando FastApi.
 - O frontend, aplicação de React com o Vite.
