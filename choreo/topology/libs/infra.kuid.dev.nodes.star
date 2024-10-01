load("id.kuid.dev.id.star", "getNodeKeys")

def getSpec(self):
  return self.get("spec", {})

def getPartition(self):
  spec = getSpec(self)
  return spec.get("partition", "")

def getProvider(self):
  spec = getSpec(self)
  return spec.get("provider", "")

def getPlatformType(self):
  spec = getSpec(self)
  return spec.get("platformType", "")

def getStatus(self):
  return self.get("status", {})

def getNodeID(self):
  nodeKeys = getNodeKeys()
  spec = getSpec(self)
  nodeID = {}
  for key, val in spec.items():
    if key in nodeKeys:
      nodeID[key] = val
  return nodeID

def getNode(name, namespace, spec):
  return {
    "apiVersion": "infra.kuid.dev/v1alpha1",
    "kind": "Node",
    "metadata": {
      "name": name,
      "namespace": namespace,
    },
    "spec": spec,
  }