prep:
	brew install helmify
build-chart: prep
	sh create-helm-chart.sh
deploy-chart: prep build-chart
	sh deploy-helm-chart.sh