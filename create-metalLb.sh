# MetalLB, Ensure firewall does not block port 7946 TCP and UDP

if kubectl -n kube-system describe cm kube-proxy | grep -q 'mode: "ipvs"';
then
        echo "Cannot install metalLB when kube proxy mode is IPVS"; exit 0;
fi
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

cat <<EOF >values.yaml
configInline:
  address-pools:
   - name: default
     protocol: layer2
     addresses:
     - $1
EOF

helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb -f values.yaml

rm values.yaml
