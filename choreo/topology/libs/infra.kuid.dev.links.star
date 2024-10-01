load("id.kuid.dev.id.star", "getNodeKeys", getidEndpointID="getEndpointID", "genEndpointIDString")

def getSpec(self):
  return self.get("spec", {})

def getEndpoints(self):
  spec = getSpec(self)
  return spec.get("endpoints", [])

def getBFDParameters(self):
  spec = getSpec(self)
  return spec.get("bfd", {})
    
def union_of_keys(dict1, dict2):
  temp_dict = {}
  for key in dict1.keys():
    temp_dict[key] = True
  for key in dict2.keys():
    temp_dict[key] = True
  return list(temp_dict.keys())

def getEndpointPartition(endpoint):
  return endpoint.get("partition", "")

def getEndpointRegion(endpoint):
  return endpoint.get("region", "")

def getEndpointSite(endpoint):
  return endpoint.get("site", "")

def getEndpointNode(endpoint):
  return endpoint.get("node", "")

def getEndpointPort(endpoint):
  return endpoint.get("port", 0)

def getEndpointEndpoint(endpoint):
  return endpoint.get("endpoint", 0)

def getEndpointModule(endpoint):
  return endpoint.get("module", 0)

def getEndpointModuleBay(endpoint):
  return endpoint.get("moduleBay", 0)

def getEndpointNodeID(endpoint):
  nodeKeys = getNodeKeys()
  nodeID = {}
  for key, val in endpoint.items():
    if key in nodeKeys:
      nodeID[key] = val
  return nodeID

def getEndpointID(endpoint):
  return getidEndpointID(getEndpointNodeID(endpoint), int(getEndpointPort(endpoint)), int(getEndpointEndpoint(endpoint)), "interface")


def getEndpointIDString(endpoint):
  epID = getEndpointID(endpoint)
  return genEndpointIDString(epID)


def getLink(name, namespace, spec):
  return {
      "apiVersion": "infra.kuid.dev/v1alpha1",
      "kind": "Link",
      "metadata": {
          "name": name,
          "namespace": namespace
      },
      "spec": spec,
  }