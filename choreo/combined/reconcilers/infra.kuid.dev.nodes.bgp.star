load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("infra.kuid.dev.nodes.star", "getPartition", "getNodeID")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isEBGPEnabled", "isIBGPEnabled", "isBGPEnabled", "getPeerGroups", "isItfceNumbered", "getAddressFamilies")
load("device.network.kubenet.dev.bgpdynamicneighbors.star", getNetworkBGPDynamicNeighbor="getBGPDynamicNeighbor")
load("device.network.kubenet.dev.bgps.star", getNetworkBGP="getBGP")
load("ipam.be.kuid.dev.ipclaims.star", "getIPClaimedAddress")
load("as.be.kuid.dev.asclaims.star", "getASClaimID")

finalizer = "node.infra.kuid.dev/bgp"
conditionType = "BGPReady"

def reconcile(self):
  # self is node
  namespace = getNamespace(self)
  partition = getPartition(self)

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  if is_conditionready(self, "IPClaimReady") != True:
    return reconcile_result(self, True, 0, conditionType, "node ip claim not ready", False)

  networkDesign, err = getNetworkDesign(partition, namespace)
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)

  if isBGPEnabled(networkDesign):
    bgpDynNeighbor = getBGPDynamicNeighbor(self)
    rsp = client_create(bgpDynNeighbor)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

    bgp, err = getBGP(self, networkDesign)
    if err != None:
      return reconcile_result(self, True, 0, conditionType, err, rsp["fatal"])
    rsp = client_create(bgp)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    rsp = client_apply()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
  return reconcile_result(self, False, 0, conditionType, "", False)

def getBGPDynamicNeighbor(self):
  name = getName(self)
  namespace = getNamespace(self)

  nodeID = getNodeID(self)
  spec = {}
  for key, val in nodeID.items():
    spec[key] = val
  
  return getNetworkBGPDynamicNeighbor(name, namespace, spec)

def getBGP(self, networkDesign):
  name = getName(self)
  namespace = getNamespace(self)
  nodeID = getNodeID(self)

  asn, err = getBGPAS(self, networkDesign)
  if err != None:
    return None, err
  
  routerID, err = getRouterID(self, networkDesign)
  if err != None:
    return None, err

  spec = {}
  for key, val in nodeID.items():
    spec[key] = val
  spec["as"] = asn
  spec["routerID"] = get_address(routerID)
  spec["addressFamilies"] = getAddressFamilies(networkDesign)
  spec["peerGroups"] = getPeerGroups(networkDesign)

  return getNetworkBGP(name, namespace, spec), None

def getBGPAS(self, networkDesign):
  partition = getPartition(self)
  namespace = getNamespace(self)
  nodeName = getName(self)

  asClaimName = partition + "." + "ibgp"
  if isEBGPEnabled(networkDesign):
    asClaimName = nodeName
  return getASClaimID(asClaimName, namespace)

def getRouterID(self, networkDesign):
  namespace = getNamespace(self)
  nodeName = getName(self)

  ipClaimName = nodeName + "." + "routerid"
  if isItfceNumbered(networkDesign, "loopback", "ipv4"):
    ipClaimName = nodeName + "." + "ipv4"
  return getIPClaimedAddress(ipClaimName, namespace)
