### Verification 1 - cosign

```bash
oc project rhtas-system
export TUF_URL=$(oc get tuf -o jsonpath='{.items[0].status.url}')
export OIDC_ISSUER_URL=https://$(oc get route keycloak -n keycloak-system | tail -n 1 | awk '{print $2}')/auth/realms/sigstore
export COSIGN_FULCIO_URL=$(oc get fulcio -o jsonpath='{.items[0].status.url}')
export COSIGN_REKOR_URL=$(oc get rekor -o jsonpath='{.items[0].status.url}')
export COSIGN_MIRROR=$TUF_URL
export COSIGN_ROOT=$TUF_URL/root.json
export COSIGN_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_CERTIFICATE_OIDC_ISSUER=$OIDC_ISSUER_URL
export COSIGN_YES="true"
export SIGSTORE_FULCIO_URL=$COSIGN_FULCIO_URL
export SIGSTORE_OIDC_ISSUER=$COSIGN_OIDC_ISSUER
export SIGSTORE_REKOR_URL=$COSIGN_REKOR_URL
export REKOR_REKOR_SERVER=$COSIGN_REKOR_URL

cosign initialize

docker login -u="USERNAME" -p="PASSWORD" quay.io
docker build -t cosign-test-docker-$(date +%m-%d) . -f Containerfile
docker tag cosign-test-docker-$(date +%m-%d) quay.io/USERNAME/cosign-test-docker-$(date +%m-%d)
docker push  quay.io/USERNAME/cosign-test-docker-$(date +%m-%d)
cosign sign -y quay.io/USERNAME/cosign-test-docker-$(date +%m-%d)
cosign verify --certificate-identity=<YOUR_EMAIL> quay.io/USERNAME/cosign-test-docker-$(date +%m-%d)
```