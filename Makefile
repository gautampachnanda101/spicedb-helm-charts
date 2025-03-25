prep:
	brew install helmify
build-chart: prep
	sh create-helm-chart.sh