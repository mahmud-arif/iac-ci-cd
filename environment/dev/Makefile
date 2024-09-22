dev-init:
	@terraform init

dev-plan: dev-format dev-validate
	@terraform plan 

dev-destroy: 
	@terraform destroy --auto-approve

dev-apply: dev-format dev-validate
	@terraform apply --auto-approve

dev-format:
	@terraform fmt --recursive

dev-validate:
	@terraform validate || (echo "Validation failed"; exit 1)
