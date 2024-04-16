## RHTAS Verification - cosign 

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

export USER=agiertli
docker login -u=$USER -p="PASSWORD" quay.io
docker build -t cosign-test-docker-$(date +%m-%d) . -f Containerfile
docker tag cosign-test-docker-$(date +%m-%d) quay.io/$USER/cosign-test-docker-$(date +%m-%d)
docker push  quay.io/$USER/cosign-test-docker-$(date +%m-%d)

# OR
podman build -t cosign-test-docker-$(date +%m-%d) . -f Containerfile
podman tag cosign-test-docker-$(date +%m-%d) quay.io/$USER/cosign-test-docker-$(date +%m-%d)
podman push   -f v2s2 quay.io/$USER/cosign-test-docker-$(date +%m-%d)

cosign sign -y quay.io/$USER/cosign-test-docker-$(date +%m-%d)
cosign verify --certificate-identity=agiertli@redhat.com quay.io/$USER/cosign-test-docker-$(date +%m-%d)
```

## RHTAS Verification - gitsign

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

## RHTAS Verification - Enterprise Contract (ec)


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

export USER=agiertli
export EMAIL=agiertli@redhat.com

docker login -u="agiertli" -p="PASSWORD" quay.io
docker build -t cosign-test-docker-$(date +%m-%d) . -f Containerfile
docker tag cosign-test-docker-$(date +%m-%d) quay.io/$USER/cosign-test-docker-$(date +%m-%d)
docker push  quay.io/$USER/cosign-test-docker-$(date +%m-%d)
cosign sign -y quay.io/$USER/cosign-test-docker-$(date +%m-%d)

cosign attest -y --predicate ./predicate.json --type slsaprovenance quay.io/$USER/cosign-test-docker-$(date +%m-%d)
cosign tree quay.io/$USER/cosign-test-docker-$(date +%m-%d)

#Example output

📦 Supply Chain Security Related artifacts for an image: quay.io/agiertli/cosign-test-docker-03-06
└── 💾 Attestations for an image tag: quay.io/agiertli/cosign-test-docker-03-06:sha256-f8c499b3a2918c735615e36be7c0c58418a5d2e459546e0b0b4ce3de1d5714e3.att
   └── 🍒 sha256:36b63b85e35efc5cc658b01fef8f35e2223c65b03f206d6fe2840f025d2c7f7a
└── 🔐 Signatures for an image tag: quay.io/agiertli/cosign-test-docker-03-06:sha256-f8c499b3a2918c735615e36be7c0c58418a5d2e459546e0b0b4ce3de1d5714e3.sig
   └── 🍒 sha256:4fc0ff175d5c5e09fcf96c3b1964d5371aa59abdc1f8620cc3ed93d989c1ce0c

ec validate image --image quay.io/$USER/cosign-test-docker-$(date +%m-%d) --certificate-identity-regexp 'agiertli@redhat.com' --certificate-oidc-issuer-regexp 'keycloak-keycloak-system' --output yaml --show-successes --info

#Example output
- attestations:
  - predicateBuildType: https://example.com/tekton-pipeline
    predicateType: https://slsa.dev/provenance/v0.2
    signatures:
    - certificate: |
        -----BEGIN CERTIFICATE-----
        MIIDMTCCAtegAwIBAgIUZKwZh5oprgIF1VpOlVdMDJaDAuIwCgYIKoZIzj0EAwIw
        LDEQMA4GA1UEChMHUmVkIEhhdDEYMBYGA1UEAxMPZnVsY2lvLmhvc3RuYW1lMB4X
        DTI0MDMwNjE0NTMwN1oXDTI0MDMwNjE1MDMwN1owADBZMBMGByqGSM49AgEGCCqG
        SM49AwEHA0IABD1ATJGQwegIAOytz+FsSTwd2yX21SRf7kZMTACTyanjOEl/B1Fl
        r1jBJBrOkjGIWpardbCk+el2e+z8UKnJQmSjggIBMIIB/TAOBgNVHQ8BAf8EBAMC
        B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFOtE8n2UHSW7CXMXJVSV
        zYT6RUevMB8GA1UdIwQYMBaAFKI5B+z2Mm+oGuBrbAnQz/pqYKhwMCEGA1UdEQEB
        /wQXMBWBE2FnaWVydGxpQHJlZGhhdC5jb20wcQYKKwYBBAGDvzABAQRjaHR0cHM6
        Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0uYXBwcy5jbHVzdGVyLTlyeGJrLmR5
        bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1dGgvcmVhbG1zL3NpZ3N0b3JlMHMG
        CisGAQQBg78wAQgEZQxjaHR0cHM6Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0u
        YXBwcy5jbHVzdGVyLTlyeGJrLmR5bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1
        dGgvcmVhbG1zL3NpZ3N0b3JlMIGKBgorBgEEAdZ5AgQCBHwEegB4AHYA4Pz+QKMr
        mD3vJ86jBPw00hzm7OBxxmd/m8wkZKQHrGUAAAGOFED8kgAABAMARzBFAiEAsi7T
        KvMHKtNb6bdWu4y7Z93eCmIlFA1x/diiM8fA9/0CIB9Vv6hf78+LRLCwbPP+r/uK
        Z8vYud9J27p6q8vpjzNzMAoGCCqGSM49BAMCA0gAMEUCIQD9Sztkm2ZgLfRbx1ck
        oP3uJ1/wAFkBCd5bdEPAMonRbAIgfsY+BLo5IZsD9/vo3z/Sguij2Hf8wTHRMhsD
        8K4nU2w=
        -----END CERTIFICATE-----
      chain:
      - |
        -----BEGIN CERTIFICATE-----
        MIIBpTCCAUugAwIBAgIBADAKBggqhkjOPQQDAjAsMRAwDgYDVQQKEwdSZWQgSGF0
        MRgwFgYDVQQDEw9mdWxjaW8uaG9zdG5hbWUwHhcNMjQwMzA1MTEwNjE5WhcNMzQw
        MzAzMTEwNjE5WjAsMRAwDgYDVQQKEwdSZWQgSGF0MRgwFgYDVQQDEw9mdWxjaW8u
        aG9zdG5hbWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS6Jz6t2fM+LhMuUXBb
        5tuWloO3/d2NvmTCvnLPosM9nDlP34HXQwgLp+pKzrBAIvEvHk2xwp6JPpPjdP27
        6HIJo14wXDAOBgNVHQ8BAf8EBAMCAgQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
        FgQUojkH7PYyb6ga4GtsCdDP+mpgqHAwGgYDVR0RBBMwEYEPamRvZUByZWRoYXQu
        Y29tMAoGCCqGSM49BAMCA0gAMEUCIEVsLAD7kq2ilRcdeVfuGVglv68S9kkDGLeX
        9vdhieNZAiEAnEiE/iav5MuS3RhteyFDYnQ8Mf12SrLmc0HUhpVOSjM=
        -----END CERTIFICATE-----
      keyid: eb44f27d941d25bb097317255495cd84fa4547af
      metadata:
        Fulcio Issuer: https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
        Fulcio Issuer (V2): https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
        Issuer: CN=fulcio.hostname,O=Red Hat
        Not After: "2024-03-06T15:03:07Z"
        Not Before: "2024-03-06T14:53:07Z"
        Serial Number: 64ac19879a29ae0205d55a4e95574c0c968302e2
        Subject Alternative Name: Email Addresses:agiertli@redhat.com
      sig: MEUCIQDUHIkgd47osD1PJs/01wrQIxq8UfV9j0RQm0XfKjE47gIgDWQzvk+Rv5zsQzDbgX53KuSzdbBuBeIb7jKBrDPtOBo=
    type: https://in-toto.io/Statement/v0.1
  - predicateBuildType: https://example.com/tekton-pipeline
    predicateType: https://slsa.dev/provenance/v0.2
    signatures:
    - certificate: |
        -----BEGIN CERTIFICATE-----
        MIIDMzCCAtigAwIBAgIUVBS1j56s7JTryxd5kuQCi1gxL8IwCgYIKoZIzj0EAwIw
        LDEQMA4GA1UEChMHUmVkIEhhdDEYMBYGA1UEAxMPZnVsY2lvLmhvc3RuYW1lMB4X
        DTI0MDMwNjE0NTYxOFoXDTI0MDMwNjE1MDYxOFowADBZMBMGByqGSM49AgEGCCqG
        SM49AwEHA0IABKyum9bORnUd6f7ttbrkAoNAHW6mVgcL1IaDutWqDD/lsYtNKc4C
        Fe0sbjCee6uSLegtzNFSUGN130nrnmRAAnGjggICMIIB/jAOBgNVHQ8BAf8EBAMC
        B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFFLcnX/FCdkk6YtV3Om5
        rFqm7+HBMB8GA1UdIwQYMBaAFKI5B+z2Mm+oGuBrbAnQz/pqYKhwMCEGA1UdEQEB
        /wQXMBWBE2FnaWVydGxpQHJlZGhhdC5jb20wcQYKKwYBBAGDvzABAQRjaHR0cHM6
        Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0uYXBwcy5jbHVzdGVyLTlyeGJrLmR5
        bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1dGgvcmVhbG1zL3NpZ3N0b3JlMHMG
        CisGAQQBg78wAQgEZQxjaHR0cHM6Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0u
        YXBwcy5jbHVzdGVyLTlyeGJrLmR5bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1
        dGgvcmVhbG1zL3NpZ3N0b3JlMIGLBgorBgEEAdZ5AgQCBH0EewB5AHcA4Pz+QKMr
        mD3vJ86jBPw00hzm7OBxxmd/m8wkZKQHrGUAAAGOFEPqngAABAMASDBGAiEAgJPr
        OE6A1nldGNTe3RAuhe+SIbl5LNGWZbL9tKmbxTwCIQDJ5l0OYtwsk5y+gAyi6O2d
        4HTTJqfmSbPir+SJ1IY3/TAKBggqhkjOPQQDAgNJADBGAiEAtXb0ZT/I4/kLF6jk
        DA7ZzTaF4npdNEYS/mKwyYbusU4CIQCkxhlQmzOBgRcjbNrHsGorcAwHU32sLVZU
        AnVaT4xfQw==
        -----END CERTIFICATE-----
      chain:
      - |
        -----BEGIN CERTIFICATE-----
        MIIBpTCCAUugAwIBAgIBADAKBggqhkjOPQQDAjAsMRAwDgYDVQQKEwdSZWQgSGF0
        MRgwFgYDVQQDEw9mdWxjaW8uaG9zdG5hbWUwHhcNMjQwMzA1MTEwNjE5WhcNMzQw
        MzAzMTEwNjE5WjAsMRAwDgYDVQQKEwdSZWQgSGF0MRgwFgYDVQQDEw9mdWxjaW8u
        aG9zdG5hbWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS6Jz6t2fM+LhMuUXBb
        5tuWloO3/d2NvmTCvnLPosM9nDlP34HXQwgLp+pKzrBAIvEvHk2xwp6JPpPjdP27
        6HIJo14wXDAOBgNVHQ8BAf8EBAMCAgQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
        FgQUojkH7PYyb6ga4GtsCdDP+mpgqHAwGgYDVR0RBBMwEYEPamRvZUByZWRoYXQu
        Y29tMAoGCCqGSM49BAMCA0gAMEUCIEVsLAD7kq2ilRcdeVfuGVglv68S9kkDGLeX
        9vdhieNZAiEAnEiE/iav5MuS3RhteyFDYnQ8Mf12SrLmc0HUhpVOSjM=
        -----END CERTIFICATE-----
      keyid: 52dc9d7fc509d924e98b55dce9b9ac5aa6efe1c1
      metadata:
        Fulcio Issuer: https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
        Fulcio Issuer (V2): https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
        Issuer: CN=fulcio.hostname,O=Red Hat
        Not After: "2024-03-06T15:06:18Z"
        Not Before: "2024-03-06T14:56:18Z"
        Serial Number: 5414b58f9eacec94ebcb177992e4028b58312fc2
        Subject Alternative Name: Email Addresses:agiertli@redhat.com
      sig: MEUCIGdHFjKEEMr/PKfZj9fs5fI97vdMg4keMUn+HNXg7nvkAiEAhjwnvrIxkD2zlvqXFXS34G02LcLVBtYCTwum2ympXTU=
    type: https://in-toto.io/Statement/v0.1
  containerImage: quay.io/agiertli/cosign-test-docker-03-06@sha256:f8c499b3a2918c735615e36be7c0c58418a5d2e459546e0b0b4ce3de1d5714e3
  name: Unnamed
  signatures:
  - certificate: |
      -----BEGIN CERTIFICATE-----
      MIIDMDCCAtagAwIBAgIUTT28+JG+oSp2auzdRTBlrOvC6eEwCgYIKoZIzj0EAwIw
      LDEQMA4GA1UEChMHUmVkIEhhdDEYMBYGA1UEAxMPZnVsY2lvLmhvc3RuYW1lMB4X
      DTI0MDMwNjE0NTE1MFoXDTI0MDMwNjE1MDE1MFowADBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABG3TQ7FNAqVhEq/BGTTXgY/L8iuhpbU+0wTEAV8MeIcAXLjRlm2t
      GsVg7TmN0bq/c+JORfYaQiZzIO0DrOVZmtujggIAMIIB/DAOBgNVHQ8BAf8EBAMC
      B4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFKBn+NZWTAYE8e3P1AQj
      JYn7UF2KMB8GA1UdIwQYMBaAFKI5B+z2Mm+oGuBrbAnQz/pqYKhwMCEGA1UdEQEB
      /wQXMBWBE2FnaWVydGxpQHJlZGhhdC5jb20wcQYKKwYBBAGDvzABAQRjaHR0cHM6
      Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0uYXBwcy5jbHVzdGVyLTlyeGJrLmR5
      bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1dGgvcmVhbG1zL3NpZ3N0b3JlMHMG
      CisGAQQBg78wAQgEZQxjaHR0cHM6Ly9rZXljbG9hay1rZXljbG9hay1zeXN0ZW0u
      YXBwcy5jbHVzdGVyLTlyeGJrLmR5bmFtaWMucmVkaGF0d29ya3Nob3BzLmlvL2F1
      dGgvcmVhbG1zL3NpZ3N0b3JlMIGJBgorBgEEAdZ5AgQCBHsEeQB3AHUA4Pz+QKMr
      mD3vJ86jBPw00hzm7OBxxmd/m8wkZKQHrGUAAAGOFD/RwAAABAMARjBEAiBnWxS7
      vJ06O00WAIRU61wFEPebTrl6UQl4I+q4/tqvAQIgJuOG43rTSTs+jLlVEsvPsgjq
      GTaTLiZ9a0HPweIbFeowCgYIKoZIzj0EAwIDSAAwRQIhAODDTujkxpF6KAreJwHJ
      /2MS6omCJghkABbVmheJNy/zAiAG0L3ApVVdCV43rdC7f8ZmbMbeaAh8RmLsgLTA
      bPq6RA==
      -----END CERTIFICATE-----
    chain:
    - |
      -----BEGIN CERTIFICATE-----
      MIIBpTCCAUugAwIBAgIBADAKBggqhkjOPQQDAjAsMRAwDgYDVQQKEwdSZWQgSGF0
      MRgwFgYDVQQDEw9mdWxjaW8uaG9zdG5hbWUwHhcNMjQwMzA1MTEwNjE5WhcNMzQw
      MzAzMTEwNjE5WjAsMRAwDgYDVQQKEwdSZWQgSGF0MRgwFgYDVQQDEw9mdWxjaW8u
      aG9zdG5hbWUwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS6Jz6t2fM+LhMuUXBb
      5tuWloO3/d2NvmTCvnLPosM9nDlP34HXQwgLp+pKzrBAIvEvHk2xwp6JPpPjdP27
      6HIJo14wXDAOBgNVHQ8BAf8EBAMCAgQwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
      FgQUojkH7PYyb6ga4GtsCdDP+mpgqHAwGgYDVR0RBBMwEYEPamRvZUByZWRoYXQu
      Y29tMAoGCCqGSM49BAMCA0gAMEUCIEVsLAD7kq2ilRcdeVfuGVglv68S9kkDGLeX
      9vdhieNZAiEAnEiE/iav5MuS3RhteyFDYnQ8Mf12SrLmc0HUhpVOSjM=
      -----END CERTIFICATE-----
    keyid: a067f8d6564c0604f1edcfd404232589fb505d8a
    metadata:
      Fulcio Issuer: https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
      Fulcio Issuer (V2): https://keycloak-keycloak-system.apps.cluster-9rxbk.dynamic.redhatworkshops.io/auth/realms/sigstore
      Issuer: CN=fulcio.hostname,O=Red Hat
      Not After: "2024-03-06T15:01:50Z"
      Not Before: "2024-03-06T14:51:50Z"
      Serial Number: 4d3dbcf891bea12a766aecdd453065acebc2e9e1
      Subject Alternative Name: Email Addresses:agiertli@redhat.com
    sig: MEUCIB1J2Qsbknun2F8okK1LbC+1RoWO2X4eDT1D6S4u0odaAiEAjUKk4BT4a6Hd6dlXYhtKcIc4/PMLRSZceZ4ODOKyxqQ=
  source: {}
  success: true
  successes:
  - metadata:
      code: builtin.attestation.signature_check
    msg: Pass
  - metadata:
      code: builtin.attestation.syntax_check
    msg: Pass
  - metadata:
      code: builtin.image.signature_check
    msg: Pass
ec-version: v0.1-alpha-3-296a9cfb
effective-time: "2024-03-06T15:02:23.358911Z"
key: ""
policy: {}
success: true
```