# Solution

1. Dockerfile added
2. Terraform code to create ecr repository and ec2 instance to deploy the app to. It will output ecr repo url, ec2 instance's public ip and save the key pair to local.
  ```bash
  $ cd terraform
  $ terraform init
  $ terraform apply
  ```
3. Create an iam role with ecr access and attach to ec2 instance
3. Build and push docker image
  ```bash
  $ docker build -t <Account_number>.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest .
  $ $(aws ecr get-login --region us-east-1 --no-include-email)
  $ docker push 794878674144.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
  ```
4. To deploy
  ```bash
  $ ssh -i ec2-flask-app.pem ubuntu@<public_ip>
  $ $(aws ecr get-login --region us-east-1 --no-include-email)
  $ docker run -p 80:80 -d <Account_number>.dkr.ecr.us-east-1.amazonaws.com/flask-app:latest
  ```
5. Test

  `curl $(cat ip.txt)`
