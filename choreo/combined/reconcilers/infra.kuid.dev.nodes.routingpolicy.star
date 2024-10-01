load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("infra.kuid.dev.nodes.star", "getNodeID", "getPartition")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isEBGPEnabled", "getUnderlayIPv4Prefixes", "getUnderlayIPv6Prefixes")
load("device.network.kubenet.dev.routingpolicies.star", "getRoutingPolicy", "getRoutingPolicyStatement")
load("device.network.kubenet.dev.prefixsets.star", "getPrefixSet", "getPrefixSetPrefix")

finalizer = "node.infra.kuid.dev/routing-policy"
conditionType = "RoutingPolicyReady"

loopbackPrefixListIPv4 = "loopbackIPv4"
loopbackPrefixListIPv6 = "loopbackIPv6"
underlayPolicyName = "underlay"
overlayPolicyName = "overlay"

def reconcile(self):
  namespace = getNamespace(self)
  nodeName = getName(self)
  nodeID = getNodeID(self)
  partition = getPartition(self)

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

  rps = getRoutingPolicies(nodeID, namespace, networkDesign)
  for rp in rps:
    rsp = client_create(rp)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  pss = getPrefixSets(nodeID, namespace, networkDesign)
  for ps in pss:
    rsp = client_create(ps)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
  return reconcile_result(self, False, 0, conditionType, "", False)

def getRoutingPolicies(nodeID, namespace, networkDesign):
  rps = []
  rps.append(getUnderlayRoutingPolicy(nodeID, namespace, networkDesign))
  rps.append(getOverlayRoutingPolicy(nodeID, namespace, networkDesign))
  return rps  

def getUnderlayRoutingPolicy(nodeID, namespace, networkDesign):
  statements = []
  if isEBGPEnabled(networkDesign):
    ipv4 = getUnderlayIPv4Prefixes(networkDesign)
    if len(ipv4) > 0:
      statements.append(getRoutingPolicyStatement(10, "accept", loopbackPrefixListIPv4))
    ipv6 = getUnderlayIPv6Prefixes(networkDesign)
    if len(ipv6) > 0:
      statements.append(getRoutingPolicyStatement(20, "accept", loopbackPrefixListIPv6))
  return getRoutingPolicy(nodeID, underlayPolicyName, namespace, statements)

def getOverlayRoutingPolicy(nodeID, namespace, networkDesign):
  return getRoutingPolicy(nodeID, overlayPolicyName, namespace, None)

def getPrefixSets(nodeID, namespace, networkDesign):
  prefixSets = []
  if isEBGPEnabled(networkDesign):
    prefixesIPv4 = getUnderlayIPv4Prefixes(networkDesign)
    if len(prefixesIPv4) > 0:
      prefixes = []
      for prefix in prefixesIPv4:
        prefixes.append(getPrefixSetPrefix(prefix, "32..32"))
      prefixSets.append(getPrefixSet(nodeID, loopbackPrefixListIPv4, namespace, prefixes))

    prefixesIPv6 = getUnderlayIPv6Prefixes(networkDesign)
    if len(prefixesIPv6) > 0:
      prefixes = []
      for prefix in prefixesIPv6:
        prefixes.append(getPrefixSetPrefix(prefix, "128..128"))
      prefixSets.append(getPrefixSet(nodeID, loopbackPrefixListIPv6, namespace, prefixes))
  return prefixSets
