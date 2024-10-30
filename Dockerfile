FROM ubuntu:latest

WORKDIR /app

RUN apt-get update
RUN apt install snapd
RUN snap install jsonnet

RUN apt-get install -y apt-transport-https ca-certificates curl gnupg

RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

RUN echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
RUN chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

RUN apt-get update
RUN apt-get install -y kubectl

COPY . .

CMD bash