def getASIndex(name, namespace, spec):
  return {
    "apiVersion": "as.be.kuid.dev/v1alpha1",
    "kind": "ASIndex",
    "metadata": {
      "name": name,
      "namespace": namespace
    },
    "spec": spec
  }