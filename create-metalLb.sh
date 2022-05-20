# MetalLB, Ensure firewall does not block port 7946 TCP and UDP

if kubectl -n kube-system describe cm kube-proxy | grep -q 'mode: "ipvs"';
then
        echo "Cannot install metalLB when kube proxy mode is IPVS"; exit 0;
fi

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
