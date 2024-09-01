./k8s/kind/kind delete cluster
docker system prune -f

sudo chmod -R 777 k8s/kind/static/jira_data
sudo chmod -R 777 k8s/kind/static/postgresqldata
rm ./k8s/kind/kind