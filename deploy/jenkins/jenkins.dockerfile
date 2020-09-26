FROM jenkins/jenkins:lts
MAINTAINER "Frank Carta <fcarta@vmware.com>"

ENV KUBECTL_VERSION=v1.18.0

USER root

# Install System libraries
RUN echo "Installing System Libraries" \
    && apt-get update \
    && apt-get install -y build-essential python3-pip python3-dev bash-completion git curl unzip wget findutils jq vim

# Install Kubectl
RUN echo "Installing Kubectl" \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv kubectl /usr/local/bin/kubectl \
    && which kubectl \
    && mkdir -p /etc/bash_completion.d \
    && kubectl completion bash > /etc/bash_completion.d/kubectl \
    && kubectl version --short --client

# Install Carvel tools
RUN echo "Installing K14s Carvel tools" \
  && wget -O- https://k14s.io/install.sh | bash \
  && ytt version

USER jenkins

EXPOSE 8080