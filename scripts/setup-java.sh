#bin/sh

## Install VSCode extensions
code-server --install-extension amazonwebservices.aws-toolkit-vscode --force
code-server --install-extension ms-azuretools.vscode-docker --force
code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools --force
code-server --install-extension vscjava.vscode-java-pack --force

## Go to tmp directory
cd /tmp

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

## Clone Git repository for the App
cd ~/environment
git clone https://github.com/aws-samples/java-on-aws.git /home/ec2-user/environment/java-on-aws/

## Pre-Download Maven dependencies for Unicorn Store
cd ~/environment/java-on-aws/labs/unicorn-store
mvn dependency:go-offline -f infrastructure/db-setup/pom.xml 1> /dev/null
mvn dependency:go-offline -f software/unicorn-store-spring/pom.xml 1> /dev/null

## Setup Infrastructure components
# /home/ec2-user/environment/java-on-aws/labs/unicorn-store/infrastructure/scripts/setup-infrastructure.sh &>> /home/ec2-user/setup-infra.log
