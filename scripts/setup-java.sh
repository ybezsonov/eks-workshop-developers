#bin/sh

## Go to tmp directory
cd /tmp

## Update OS
sudo yum update

## Install additional dependencies
sudo yum install -y jq

wget https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64.tar.gz -O - |\
  tar xz && sudo mv yq_linux_amd64 /usr/bin/yq
yq --version

## Install docker buildx
export BUILDX_VERSION=$(curl --silent "https://api.github.com/repos/docker/buildx/releases/latest" |jq -r .tag_name)
curl -JLO "https://github.com/docker/buildx/releases/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64"
mkdir -p ~/.docker/cli-plugins
mv "buildx-$BUILDX_VERSION.linux-amd64" ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --use --driver=docker-container

## Install docker compose
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
docker compose version

## Install eksctl
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
# (Optional) Verify checksum
curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

## Install kubectl
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.2/2023-10-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --output=yaml

## Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

## Install additional dependencies
sudo yum install -y npm
sudo npm install -g aws-cdk --force
cdk version
sudo npm install -g artillery

## Install JDK 17
sudo yum -y install java-17-amazon-corretto-devel
sudo update-alternatives --set java /usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/javac
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
echo "export JAVA_HOME=${JAVA_HOME}" | tee -a ~/.bash_profile
echo "export JAVA_HOME=${JAVA_HOME}" | tee -a ~/.bashrc
java -version

## Install Maven
export MVN_VERSION=3.9.4
export MVN_FOLDERNAME=apache-maven-${MVN_VERSION}
export MVN_FILENAME=apache-maven-${MVN_VERSION}-bin.tar.gz
curl -4 -L https://archive.apache.org/dist/maven/maven-3/${MVN_VERSION}/binaries/${MVN_FILENAME} | tar -xvz
sudo mv $MVN_FOLDERNAME /usr/lib/maven
export M2_HOME=/usr/lib/maven
export PATH=${PATH}:${M2_HOME}/bin
sudo ln -s /usr/lib/maven/bin/mvn /usr/local/bin
mvn --version

## Setup Git
git config --global user.email "you@workshops.aws"
git config --global user.name "Your Name"

## Setup environment
cd ~/environment
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
export AWS_REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bashrc
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bashrc
aws configure set default.region ${AWS_REGION}
aws configure get default.region
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set

## Install VSCode extensions
code-server --install-extension amazonwebservices.aws-toolkit-vscode --force
code-server --install-extension ms-azuretools.vscode-docker --force
code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools --force
code-server --install-extension vscjava.vscode-java-pack --force

## Clone Git repository for the App
cd ~/environment
git clone https://github.com/aws-samples/java-on-aws.git /home/ec2-user/environment/java-on-aws/

## Pre-Download Maven dependencies for Unicorn Store
cd ~/environment/java-on-aws/labs/unicorn-store
mvn dependency:go-offline -f infrastructure/db-setup/pom.xml 1> /dev/null
mvn dependency:go-offline -f software/unicorn-store-spring/pom.xml 1> /dev/null

## Setup Infrastructure components
# /home/ec2-user/environment/java-on-aws/labs/unicorn-store/infrastructure/scripts/setup-infrastructure.sh &>> /home/ec2-user/setup-infra.log
