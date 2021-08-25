@rem docker on windows. reset shit
for /f %%a in ('docker images -qa') do @docker rmi %%a
docker compose down -v --rmi=local
docker builder prune -af
docker system prune -f
