# Golang lambda running on a recurring schedule

## Installation

1. [Install terraform](https://developer.hashicorp.com/terraform/install)
On mac you can install via homebrew:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. [Install aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
```
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

3. Create aws access key and secret key if you don't have one already
For this go to the [security credentials](https://us-east-1.console.aws.amazon.com/iam/home?region=eu-north-1#/security_credentials) 
section in the aws console and create a new access key.
Note that it's recommended to create and use an IAM role instead however for simplicity we will use the root account.

4. Set up your access key and secret key environment variables
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```
You'll need to append this to your `.bashrc` or `.zshrc` file to make it permanent.

5. Configure aws cli
```bash
aws configure
```
Enter your access key, secret key, region and output format.
The access key and secret are the same as what you set in the environment variables.
The default region will be the region that you'd like to use create your resources in.

6. You need to have the `zip` utility installed on your system. To be able to create a zip archive of the lambda function.
On linux:
```bash
sudo apt-get install zip
```

On mac:
```bash
brew install zip
```

On windows:
```bash
choco install zip
```

2. Build the lambda
```bash
GOOS=linux go build -o main main.go
```

## Building and deploying the lambda

- To build the lambda run the following command:
```bash
make build
```

This will create a binary in `bin/bootstrap` and a `bin/bootstrap.zip` zip archive that can be uploaded to aws lambda.

- To check the terraform plan run the following command:
```bash
make terraform-plan
```

- To apply the terraform plan run the following command:
```bash
make terraform-apply
```
or 
```bash
make deploy
```

