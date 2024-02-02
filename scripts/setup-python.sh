#bin/sh

## Install VSCode extensions
code-server --install-extension amazonwebservices.aws-toolkit-vscode --force
code-server --install-extension ms-azuretools.vscode-docker --force
code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools --force
code-server --install-extension ms-python.python --force

## Install minikube
cd /home/ec2-user/
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
rm minikube-linux-amd64

## Clone Git repository for the App
cd ~/environment
git clone https://github.com/aws-samples/python-fastapi-demo-docker.git /home/ec2-user/environment/python-fastapi-demo-docker/
