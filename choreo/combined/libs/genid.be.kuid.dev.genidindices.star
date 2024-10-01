def getGENIDIndex(name, namespace, spec):
  return {
    "apiVersion": "genid.be.kuid.dev/v1alpha1",
    "kind": "GENIDIndex",
    "metadata": {
      "name": name,
      "namespace": namespace
    },
    "spec": spec
  }