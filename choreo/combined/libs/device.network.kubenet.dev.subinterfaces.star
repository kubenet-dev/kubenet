load("id.kuid.dev.ids.star", "getNodeKeys", "getEndpointKeys", "genEndpointIDString")
load("core.network.kubenet.dev.networkdesigns.star", "isItfceIPv6Numbered", "isItfceIPv4Numbered", "isItfceIPv6UnNumbered", "isItfceIPv4UnNumbered")
load("device.network.kubenet.dev.bfds.star", "getBFDParamsKeys")

def getSpec(self):
  return self.get("spec", {})

def getInterfaceName(self):
  spec = getSpec(self)
  return spec.get("name", "")

def getLocalAF(self, af):
  spec = getSpec(self)
  return spec.get(af, {})

def getLocalAddresses(self, af):
  af = getLocalAF(self, af)
  return  af.get("addresses", [])

def getLocalAddress(self, af, idx):
  addresses = getLocalAddresses(self, af)
  return get_address(addresses[idx])

def getPeerAF(self, af):
  spec = getSpec(self)
  peer = spec.get("peer", {})
  return peer.get(af, {})

def getPeerAddresses(self, af):
  af = getPeerAF(self, af)
  return  af.get("addresses", [])

def getPeerAddress(self, af, idx):
  addresses = getPeerAddresses(self, af)
  return get_address(addresses[idx])

def getLocalNodeID(self):
  nodeKeys = getNodeKeys()
  spec = getSpec(self)
  nodeID = {}
  for key, val in spec.items():
    if key in nodeKeys:
      nodeID[key] = val
  return nodeID

def getPeer(self):
  spec = getSpec(self)
  return spec.get("peer", {})

def getPeerNodeID(self):
  nodeKeys = getNodeKeys()
  peer = getPeer(self)
  nodeID = {}
  for key, val in peer.items():
    if key in nodeKeys:
      nodeID[key] = val
  return nodeID

def getPartition(self):
  spec = getSpec(self)
  return spec.get("partition", "")

def getSubInterfaceSpec(idx, linkInfo, networkDesign, bfdParams, id):
  local = linkInfo[idx % 2]
  remote = linkInfo[(idx + 1) % 2]
       
  localIPv4 = {"addresses": []}
  remoteIPv4 = {"addresses": []}
  if isItfceIPv4Numbered(networkDesign, "underlay"):
    localIPv4["addresses"].append(local.get("ipv4", ""))
    remoteIPv4["addresses"].append(remote.get("ipv4", ""))
  elif isItfceIPv4UnNumbered(networkDesign, "underlay"):
    pass
  else:
    localIPv4 = None
    remoteIPv4 = None
        

  localIPv6 = {"addresses": []}
  remoteIPv6 = {"addresses": []}
  if isItfceIPv6Numbered(networkDesign, "underlay"):
    localIPv6["addresses"].append(local.get("ipv6", ""))
    remoteIPv6["addresses"].append(remote.get("ipv6", ""))
  elif isItfceIPv6UnNumbered(networkDesign, "underlay"):
    pass
  else:
    localIPv6 = None
    remoteIPv6 = None

  spec = {
    "id": id,
    "type": "routed",
    "ipv4": localIPv4,
    "ipv6": localIPv6,
  }
  for key, val in bfdParams.items():
    spec[key] = val
  for key, val in local.items():
    if key == "ipv4" or key == "ipv6":
      continue
    spec[key] = val

  peer = {
    "ipv4": remoteIPv4,
    "ipv6": remoteIPv6,
  }
  for key, val in remote.items():
    if key == "ipv4" or key == "ipv6":
      continue
    peer[key] = val
  spec["peer"] = peer

  return spec

def getspec(si):
  return si.get("spec", {})

def getEPID(si):
  epID = {}
  epKeys = getEndpointKeys()
  spec = getspec(si)
  for key, val in spec.items():
    if key in epKeys:
      epID[key] = val
  return epID

def getBFDParams(si):
  bfdParams = {}
  bfdParamsKeys = getBFDParamsKeys()
  spec = getspec(si)
  for key, val in spec.items():
    if key in bfdParamsKeys:
      bfdParams[key] = val
  return bfdParams

def getID(si):
  spec = getspec(si)
  return spec.get("id", 0)

def getSubInterface(name, namespace, spec):
  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "SubInterface",
    "metadata": {
        "name": name,
        "namespace": namespace
    },
    "spec": spec,
  }