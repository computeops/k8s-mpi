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
  - name: k8sschool/mpich-pi
    newName: ${CIUX_IMAGE_NAME}
    newTag: "${CIUX_IMAGE_TAG}"