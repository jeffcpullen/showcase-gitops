### RHTAS Verification - cosign

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

### RHTAS Verification - gitsign

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

git config --local commit.gpgsign true
git config --local tag.gpgsign true
git config --local gpg.x509.program gitsign
git config --local gpg.format x509
git config --local gitsign.fulcio $SIGSTORE_FULCIO_URL
git config --local gitsign.rekor $SIGSTORE_REKOR_URL
git config --local gitsign.issuer $SIGSTORE_OIDC_ISSUER

git commit --allow-empty -S -m "Test of a signed commit"

cosign initialize

gitsign verify --certificate-identity=USER_EMAIL --certificate-oidc-issuer=$SIGSTORE_OIDC_ISSUER HEAD

### Example Output
tlog index: 1
gitsign: Signature made using certificate ID 0x212276de3c287e44d983629949de4a22d7625e98 | CN=fulcio.hostname,O=Red Hat
gitsign: Good signature from [agiertli@redhat.com](https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore)
Validated Git signature: true
Validated Rekor entry: true
Validated Certificate claims: true
```


