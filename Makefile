prep:
	brew install helmify
build-chart: prep
	sh create-helm-chart.sh
install-traefik: prep
install-mkcert:
	brew install mkcert
	sudo mkcert -install && sudo mkcert spicedb.localhost "*.localhost" localhost 127.0.0.1 ::1
deploy-chart: prep build-chart
	sh deploy-helm-chart.sh