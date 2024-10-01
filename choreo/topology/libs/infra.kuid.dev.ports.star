def getPort(name, namespace, spec):
  return {
    "apiVersion": "infra.kuid.dev/v1alpha1",
    "kind": "Port",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }