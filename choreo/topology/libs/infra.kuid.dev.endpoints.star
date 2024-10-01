load("id.kuid.dev.id.star", "getEndpointID")

def getEndpointSpeed(endpoint):
  epspec = endpoint.get("spec", {})
  return epspec.get("speed", "")

def getEndpoint(name, namespace, spec):
  return {
    "apiVersion": "infra.kuid.dev/v1alpha1",
    "kind": "Endpoint",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }