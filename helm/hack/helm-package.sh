#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Install and initialize helm/tiller
HELM_URL=https://storage.googleapis.com/kubernetes-helm
HELM_TARBALL=helm-v2.7.2-linux-amd64.tar.gz
HELM_PACKAGES=${1}
HELM_BUCKET_NAME="coreos-charts"
HELM_CHARTS_DIRECTORY=${2:-"$(pwd)/helm"}
HELM_CHARTS_PACKAGED_DIR=${3:-"/tmp/helm-packaged"}

wget -q ${HELM_URL}/${HELM_TARBALL}
tar xzfv ${HELM_TARBALL}
export PATH=${PATH}:$(pwd)/linux-amd64/helm

# Clean up tarball
rm -f ${HELM_TARBALL}

# Package helm and dependencies
mkdir -p ${HELM_CHARTS_PACKAGED_DIR}

# check if charts has dependencies,
for chart in ${HELM_PACKAGES}
do 
    # #  update dependencies before package the chart
    # if ls ${HELM_CHARTS_DIRECTORY}/${chart} 
    # do
        cd ${HELM_CHARTS_DIRECTORY}/${chart} 
        helm dep update
        helm package . -d ${HELM_CHARTS_PACKAGED_DIR} 
        cd -
    # done
done

helm repo index ${HELM_CHARTS_PACKAGED_DIR} --url https://s3-eu-west-1.amazonaws.com/${HELM_BUCKET_NAME}/stable/ --debug

