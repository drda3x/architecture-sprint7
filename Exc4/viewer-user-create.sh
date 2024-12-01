kubectl apply -f viewer-role.yaml
kubectl apply -f viewer-role-binding.yaml

openssl genpkey -out viewer.key -algorithm ed25519
openssl req -new -key viewer.key -out viewer.csr -subj '/CN=viewer/O=edit'

BASE64_KEY=$(cat viewer.csr | base64)

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

kubectl certificate approve viewer
kubectl get csr viewer -o jsonpath='{.status.certificate}'| base64 -d > viewer.crt
kubectl config --kubeconfig viewer-kubeconfig set-credentials viewer --client-key=viewer.key --client-certificate=viewer.crt --embed-certs=true
