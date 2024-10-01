def getSpec(self):
  return self.get("spec", {})

def getPartition(self):
  spec = getSpec(self)
  return spec.get("partition", "")

def getBGP(name, namespace, spec):
  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "BGP",
    "metadata": {
        "name": name,
        "namespace": namespace
    },
    "spec": spec,
  }