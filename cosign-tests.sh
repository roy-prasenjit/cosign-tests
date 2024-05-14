#!/bin/sh


###
# Usage: Run this file as is. 
# Populate registry username and password at USERNAME and USERNAME
# Populate IMAGE


###
set -u

USERNAME=
PASSWORD=
IMAGE=
export COSIGN_PASSWORD=1234
docker logout
docker login -u $USERNAME -p $PASSWORD
docker pull $IMAGE
name=$(docker inspect --format='{{index .RepoDigests 0}}' $IMAGE)
echo $name
cosign clean $name
cosign generate-key-pair


# vulnerabilities 
# trivy
trivy -v image --format cosign-vuln  --output ./$USERNAME.trivy.vuln.json $name
cosign attest --key cosign.key --type vuln --predicate ./$USERNAME.trivy.vuln.json $name
cosign verify-attestation --key cosign.pub --type vuln $name

# vulnerabilities 
# grype
grype -o json  royprasenjit93/checkpoint > $USERNAME.grype.vuln.json
cosign attest --key cosign.key --type vuln --predicate $USERNAME.grype.vuln.json $name
cosign verify-attestation --key cosign.pub --type vuln $name

exit 0
# sboms
# sign sbom -> https://docs.sigstore.dev/signing/other_types/#sboms-software-bill-of-materials
# attest sbom
# if( attest sbom ) 
# 	syft -o cyclonedx-json $name > $name.syft.sbom.jso
# 	cosign attest --key cosign.key --type cyclonedx --predicate $name.syft.sbom.json $name
# 	cosign verify-attestation --key cosign.pub --type cyclonedx $name


