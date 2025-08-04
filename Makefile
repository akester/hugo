build:
	packer init .
	packer build -var "version=${HUGO_VERSION}" .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push akester/hugo:latest
	docker push akester/hugo:${HUGO_VERSION}
