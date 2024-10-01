load("id.kuid.dev.ids.star", "getNodeKeys")

def getSpec(self):
  return self.get("spec", {})

def getPartition(self):
  spec = getSpec(self)
  return spec.get("partition", "")

def getRegion(self):
  spec = getSpec(self)
  return spec.get("region", "")

def getSite(self):
  spec = getSpec(self)
  return spec.get("site", "")

def getNode(self):
  spec = getSpec(self)
  return spec.get("node", "")

def getNodeID(self):
  nodeKeys = getNodeKeys()
  spec = getSpec(self)
  nodeID = {}
  for key, val in spec.items():
    if key in nodeKeys:
      nodeID[key] = val
  return nodeID

def setInterfaces(self, interfaces):
  spec = getSpec(self)
  spec["interfaces"] = interfaces

def getNetworkInstance(name, namespace, spec):
  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "NetworkInstance",
    "metadata": {
      "name": name,
      "namespace": namespace
    },
    "spec": spec
  }