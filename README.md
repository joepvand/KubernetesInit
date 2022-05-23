# KubernetesInit
A initialization script to provision a k8s cluster with Cilium CNI and metalLB

## Usage

curl -s https://raw.githubusercontent.com/joepvand/KubernetesInit/main/create-cluster.sh | sh -


wget https://raw.githubusercontent.com/joepvand/KubernetesInit/main/create-metalLb.sh
chmod +x create-metallb.sh
./create-metallb.sh 192.168.1.1/24 ( VERVANG MET ECHTE IP RANGE)
