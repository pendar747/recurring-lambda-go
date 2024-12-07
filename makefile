build:
	GOOS=linux GOARCH=amd64 go build -tags lambda.norpc -o ./bin/bootstrap src/main.go	
	zip -j ./bin/bootstrap.zip ./bin/bootstrap

clean:
	rm -rf ./bin/bootstrap ./bin/bootstrap.zip

deploy:
	cd infra && terraform init && terraform apply

terraform-destroy:
	cd infra && terraform init && terraform destroy

terraform-apply:
	make deploy

terraform-plan:
	cd infra && terraform init && terraform plan
