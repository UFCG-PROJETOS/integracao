# Sqibidi - Daily SQL practice game

## Subindo o sistema

Para subir o sistema disponibilizamos dois arquivos docker-compose:

- docker-compose.yml - Sobe o sistema a partir dos repositórios locais (útil para o desenvolvimento)
- docker-compose.deploy.yml - Sobe o sistema a partir das imagens mais recentes do sistema no dockerhub (útil para a produção)
  
Como subir o sistema localmente:
```bash
sudo docker compose -f <arquivo_docker_compose> up -d
```

Como encerrar o sistema localmente:
```bash
sudo docker compose -f <arquivo_docker_compose> down -v
```

## Ambiente de produção
Consiste de 3 serviços:
 - O SGBD, postgres guardando as questões e as pontuações.
 - A api do backend, um ambiente com python gerenciado pelo UV rodando FastApi.
 - O frontend, aplicação de React com o Vite.
