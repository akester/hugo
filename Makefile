build:
	packer init .
	packer build .

login:
	echo '${env.DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push akester/hugo:latest
