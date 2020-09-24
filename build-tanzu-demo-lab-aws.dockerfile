FROM ubuntu:18.04
MAINTAINER "Frank Carta <fcarta@vmware.com>"

ENV KUBECTL_VERSION=v1.18.0

# Install libraries
RUN echo "Installing Libraries" \
    && apt-get update \
    && apt-get install -y git python3-pip bash-completion curl unzip wget findutils jq vim

# Install TMC CLI
COPY bin/tmc .
RUN echo "Installing TMC CLI" \
  && chmod +x tmc \
  && mv tmc /usr/local/bin/tmc \
  && which tmc \
  && tmc version

# Install Kubectl
RUN echo "Installing Kubectl" \
  && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && which kubectl \
  && mkdir -p /etc/bash_completion.d \
  && kubectl completion bash > /etc/bash_completion.d/kubectl \
  && kubectl version --short --client

# Install ArgoCD CLI
# ARGOCD_CLI_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
RUN echo "ArgoCD CLI" \
  && curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_CLI_VERSION/argocd-linux-amd64 \
  && chmod +x /usr/local/bin/argocd

# Install Helm3
RUN echo "Installing Helm3" \
  && curl https://get.helm.sh/helm-v3.3.0-rc.2-linux-amd64.tar.gz --output helm.tar.gz \
  && tar -zxvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm \
  && helm version

# Create Aliases
RUN echo "alias k=kubectl" > /root/.profile

# Copy Credentials
RUN echo "Copying K8s Credentials" \
    && mkdir /root/.kube
COPY config/kube.conf /root/.kube/conf

# Leave Container Running for SSH Access - SHOULD REMOVE
ENTRYPOINT ["tail", "-f", "/dev/null"]
