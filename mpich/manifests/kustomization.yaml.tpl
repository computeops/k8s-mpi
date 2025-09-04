apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - mpijob.yaml

namespace: mpich-cluster

commonLabels:
  app: mpich
  version: v1

images:
  - name: ${CIUX_IMAGE_NAME}
    newTag: "${CIUX_IMAGE_TAG}"
