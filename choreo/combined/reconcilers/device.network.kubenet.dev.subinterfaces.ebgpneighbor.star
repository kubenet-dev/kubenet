load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isEBGPEnabled")
load("device.network.kubenet.dev.subinterfaces.star", "getPartition", "getInterfaceName", "getLocalNodeID", "getPeerNodeID", "getLocalAddresses", "getLocalAddress", "getPeerAddress")
load("id.kuid.dev.ids.star", "genNodeIDString")
load("as.be.kuid.dev.asclaims.star", "getASClaimID")
load("device.network.kubenet.dev.bgpneighbors.star", "getBGPNeighbor")

finalizer = "subinterface.kubenet.dev/bgpneighbor"
conditionType = "BGPNeighborReady"

def reconcile(self):
  partition = getPartition(self)
  namespace = getNamespace(self)

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  networkDesign, err = getNetworkDesign(partition, namespace)
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)
  
  bgpNeighbors, err = getBGPNeighbors(self, networkDesign)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  for bgpNeighbor in bgpNeighbors:
    rsp = client_create(bgpNeighbor)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getBGPNeighbors(self, networkDesign):
  if not isEBGPEnabled(networkDesign):
    return [], None

  if getInterfaceName(self) == "interface":
    ipv4Neighbors, ipv4_err = getBGPNeighborsPerAF(self, "ipv4")
    if ipv4_err:
      return None, ipv4_err
    
    ipv6Neighbors, ipv6_err = getBGPNeighborsPerAF(self, "ipv6")
    if ipv6_err:
      return None, ipv6_err

    bgpNeighbors = ipv4Neighbors + ipv6Neighbors
    return bgpNeighbors, None
  return [], None

def getBGPNeighborsPerAF(self, af):
  namespace = getNamespace(self)
  siName = getName(self)
  nodeID = getLocalNodeID(self)

  localNodeName = genNodeIDString(nodeID)
  peerNodeName = genNodeIDString(getPeerNodeID(self))
  
  localAS, err = getASClaimID(localNodeName, namespace)
  if err != None:
    return None, err
  peerAS, err = getASClaimID(peerNodeName, namespace)
  if err != None:
    return None, err
  
  bgpNeighbors = []
  for idx, address in enumerate(getLocalAddresses(self, af)):
    localAddress = getLocalAddress(self, af, idx)
    peerAddress = getPeerAddress(self, af, idx)
    name = siName + "." + af

    spec = {}
    for key, val in nodeID.items():
        spec[key] = val
    spec["localAddress"] = localAddress
    spec["localAS"] = localAS
    spec["peerAddress"] = peerAddress
    spec["peerAS"] = peerAS
    spec["peerGroup"] = "underlay"

    bgpNeighbors.append(getBGPNeighbor(name, namespace, spec))

  return bgpNeighbors, None
