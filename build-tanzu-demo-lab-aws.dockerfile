FROM ubuntu:18.04
LABEL maintainer="Frank Carta <fcarta@vmware.com>"

ENV KUBECTL_VERSION=v1.18.0
ENV ARGOCD_CLI_VERSION=v1.7.7
ENV KPACK_VERSION=0.1.2

# Install System libraries
RUN echo "Installing System Libraries" \
  && apt-get update \
  && apt-get install -y build-essential python3.6 python3-pip python3-dev bash-completion git curl unzip wget findutils jq vim

# Copy install yamls
RUN echo "Clone example application repo and copy deploment yaml files" \
  && git clone https://github.com/fcarta29/tanzu-demo-lab-aws-examples.git examples
COPY deploy deploy

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

RUN echo "Get latest ArgoCD install yaml" \
  && curl -sSL -o /deploy/argocd/argo-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Helm3
RUN echo "Installing Helm3" \
  && curl https://get.helm.sh/helm-v3.3.0-rc.2-linux-amd64.tar.gz --output helm.tar.gz \
  && tar -zxvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm \
  && helm version

# Get kpack install yaml install and log utility
RUN echo "Getting kpack installation yaml and installing kpack log utility" \
  && curl -sSL -o /deploy/kpack/release-${KPACK_VERSION}.yaml https://github.com/pivotal/kpack/releases/download/v${KPACK_VERSION}/release-${KPACK_VERSION}.yaml \
  && curl -sSL -o /deploy/kpack/logs-v${KPACK_VERSION}-linux.tgz https://github.com/pivotal/kpack/releases/download/v${KPACK_VERSION}/logs-v${KPACK_VERSION}-linux.tgz \
  && tar -zxvf /deploy/kpack/logs-v${KPACK_VERSION}-linux.tgz \
  && mv logs /usr/local/bin/logs \
  && chmod +x /usr/local/bin/logs

# Install Carvel tools
RUN echo "Installing K14s Carvel tools" \
  && wget -O- https://k14s.io/install.sh | bash \
  && ytt version

# Install Jupyter - TODO[fcarta] make requirements.txt instead of using empty file
RUN echo "Installing Jupyter" \
  && pip3 install -r /deploy/jupyter/requirements.txt \
  && pip3 install jupyter

# Create Aliases
RUN echo "alias k=kubectl" > /root/.profile

# Copy Credentials
RUN echo "Copying K8s Credentials" \
    && mkdir /root/.kube
COPY config/kube.conf /root/.kube/config

# Leave Container Running for SSH Access - SHOULD REMOVE
ENTRYPOINT ["tail", "-f", "/dev/null"]
# Use this if you want to enable/run jupyter notebooks
#CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
