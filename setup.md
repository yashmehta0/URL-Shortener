# Creation of AWS resources using Terraform

- Install AWS CLI in your local machine using *https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html*

- Run this command to setup aws environment configuration AWS access key, AWS Secret access key and region name 

    *aws configure*

- Install Terraform in your local machine  using *https://www.terraform.io/downloads.html*

- Update all the zip packages by running *zipper.bat* file

    *.\zipper.bat*

- Run this command to start the terraform initialization

    *terraform init*

    *terraform plan -var-file="default.tfvars"*

    *terraform apply -var-file="default.tfvars" --auto-approve*

- If there is an error based on validation exception after running all three commands then rerun this command

    *terraform apply -var-file="default.tfvars" --auto-approve*

- You can change the name of Lambdas, IAM Roles and APIGateway through *default.tfvars* file

- Update the APIGateway URL in URLShorten request under URLShortener Collection at both places 

    1. URL of Request
    2. JSON input body 

- Try running the "url_short" field value in browser and you'll see the redirection 