kubectl apply -f admin-role.yaml
kubectl apply -f admin-role-binding.yaml

openssl genpkey -out devops.key -algorithm ed25519
openssl req -new -key devops.key -out devops.csr -subj '/CN=devops/O=edit'

BASE64_KEY=$(cat devops.csr | base64)

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: yuriy
spec:
  request: $BASE64_KEY
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
client auth
EOF

kubectl certificate approve devops
kubectl get csr devops -o jsonpath='{.status.certificate}'| base64 -d > devops.crt
kubectl config --kubeconfig devops-kubeconfig set-credentials devops --client-key=devops.key --client-certificate=devops.crt --embed-certs=true
