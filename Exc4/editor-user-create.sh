kubectl apply -f editor-role.yaml
kubectl apply -f editor-role-binding.yaml

openssl genpkey -out developer.key -algorithm ed25519
openssl req -new -key developer.key -out developer.csr -subj '/CN=developer/O=edit'

BASE64_KEY=$(cat developer.csr | base64)

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

kubectl certificate approve developer
kubectl get csr developer -o jsonpath='{.status.certificate}'| base64 -d > developer.crt
kubectl config --kubeconfig developer-kubeconfig set-credentials developer --client-key=developer.key --client-certificate=developer.crt --embed-certs=true
