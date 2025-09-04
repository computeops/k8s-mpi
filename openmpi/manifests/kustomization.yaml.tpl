apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - mpijob.yaml

namespace: openmpi-cluster

commonLabels:
  app: openmpi
  version: v1

images:
  - name: ${CIUX_IMAGE_NAME}
    newTag: "${CIUX_IMAGE_TAG}"

patches:
  - patch: |-
      - op: replace
        path: /spec/mpiReplicaSpecs/Launcher/template/spec/containers/0/args/2
        value: /home/mpiuser/${PROGRAM}
    target:
      kind: MPIJob
