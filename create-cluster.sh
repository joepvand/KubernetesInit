# Script to install a single node K8s cluster 
set -e

# Install Docker
wget -qO- https://get.docker.com/ | sh

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl restart docker

# Install cri-dockerd
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4)
wget https://github.com/Mirantis/cri-dockerd/releases/download/${VER}/cri-dockerd-${VER}-linux-amd64.tar.gz
tar xvf cri-dockerd-${VER}-linux-amd64.tar.gz
sudo mv cri-dockerd /usr/local/bin/
sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.service
sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.socket
sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo mkdir -p /etc/systemd/system/cri-docker.service.d/
cat <<EOF | sudo tee /etc/systemd/system/cri-docker.service.d/cni.conf
[Service]
ExecStart=
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
EOF
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

# Initialize a control plane node
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm
sudo swapoff -a
sudo kubeadm init --cri-socket=unix:///run/cri-dockerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint node --all node-role.kubernetes.io/master-
kubectl taint node --all node-role.kubernetes.io/control-plane-

# Install Cilium
wget https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
cilium install
