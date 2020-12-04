FROM ubuntu:18.04
LABEL maintainer="Frank Carta <fcarta@vmware.com>"

ENV KUBECTL_VERSION=v1.18.0
ENV ARGOCD_CLI_VERSION=v1.7.7
ENV KPACK_VERSION=0.1.3
ENV TBS_VERSION=1.0.3
ENV TBS_DESCRIPTOR_VERSION=100.0.34
ENV ISTIO_VERSION=1.7.4

# Install System libraries
RUN echo "Installing System Libraries" \
  && apt-get update \
  && apt-get install -y build-essential python3.6 python3-pip python3-dev bash-completion git curl unzip wget findutils jq vim tree docker.io

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

#Install Kustomize
RUN echo "Installing Kustomize" \
  && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash \
  && mv kustomize /usr/local/bin/kustomize \
  && kustomize version

# Install ArgoCD CLI
# ARGOCD_CLI_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
RUN echo "ArgoCD CLI" \
  && curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_CLI_VERSION/argocd-linux-amd64 \
  && chmod +x /usr/local/bin/argocd

#RUN echo "Get latest ArgoCD install yaml" \
#  && curl -sSL -o /deploy/argocd/argo-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Helm3
RUN echo "Installing Helm3" \
  && curl https://get.helm.sh/helm-v3.3.0-rc.2-linux-amd64.tar.gz --output helm.tar.gz \
  && tar -zxvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/helm \
  && helm version

#Install Tanzu Build Service
#COPY /deploy/tbs/build-service-${TBS_VERSION}.tar /tmp
#COPY /deploy/tbs/descriptor-${TBS_DESCRIPTOR_VERSION}.yaml /tmp

# Install KPACK CLI
COPY bin/kp-linux-${KPACK_VERSION} .
RUN echo "Installing kpack CLI" \
  && chmod +x kp-linux-${KPACK_VERSION} \
  && mv kp-linux-${KPACK_VERSION} /usr/local/bin/kp \
  && which kp \
  && kp version

# Get kpack install yaml install and log utility
RUN echo "Installing kpack log utility" \
  && mkdir /opt/kpack \
  && curl -sSL -o /opt/kpack/logs-v${KPACK_VERSION}-linux.tgz https://github.com/pivotal/kpack/releases/download/v${KPACK_VERSION}/logs-v${KPACK_VERSION}-linux.tgz \
  && tar -zxvf /opt/kpack/logs-v${KPACK_VERSION}-linux.tgz \
  && mv logs /usr/local/bin/logs \
  && chmod +x /usr/local/bin/logs

# Install Carvel tools
RUN echo "Installing K14s Carvel tools" \
  && wget -O- https://k14s.io/install.sh | bash 

# Install Jupyter - TODO[fcarta] make requirements.txt instead of using empty file
#RUN echo "Installing Jupyter" \
#  && pip3 install -r /deploy/jupyter/requirements.txt \
#  && pip3 install jupyter

# Install Istioctl
RUN echo "Installing Istioctl" \
  && curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh - \
  && cd istio-${ISTIO_VERSION} \
  && export PATH=$PWD/bin:$PATH \
  && istioctl version

# Create Aliases
RUN echo "alias k=kubectl" > /root/.profile

# Leave Container Running for SSH Access - SHOULD REMOVE
ENTRYPOINT ["tail", "-f", "/dev/null"]
# Use this if you want to enable/run jupyter notebooks
#CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
