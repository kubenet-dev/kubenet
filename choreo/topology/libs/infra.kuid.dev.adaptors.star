def getAdaptor(name, namespace, spec):
  return {
    "apiVersion": "infra.kuid.dev/v1alpha1",
    "kind": "Adaptor",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }
