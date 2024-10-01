load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isItfceUnnumbered")
load("device.network.kubenet.dev.bgpdynamicneighbors.star", "getPartition", "getRegion", "getSite", "getNode", "delInterfaces", "setInterfaces")
load("device.network.kubenet.dev.subinterfaces.star", getsiEPID="getEPID", getsiID="getID")

finalizer = "dynamicbgpneighbor.device.network.kubenet.dev/neighbor"
conditionType = "Ready"

def reconcile(self):
  # self is dynBGPNeighbor
  partition = getPartition(self)
  namespace = getNamespace(self)
  dynBGPName = getName(self)

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

  err = updateSubInterfaces(self, networkDesign)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, True)
    
  return reconcile_result(self, False, 0, conditionType, "", False)

def updateSubInterfaces(self, networkDesign):
  if not isItfceUnnumbered(networkDesign, "underlay"):
    delInterfaces(self)
    return None

  fieldSelector = {}
  fieldSelector["spec.partition"] = getPartition(self)
  fieldSelector["spec.region"] = getRegion(self)
  fieldSelector["spec.site"] = getSite(self)
  fieldSelector["spec.node"] = getNode(self)

  silist = get_resource("network.kubenet.dev/v1alpha1", "SubInterface")
  rsp = client_list(silist["resource"], fieldSelector)
  if rsp["error"] != None:
    return rsp["error"]
  
  interfaces = []
  items = rsp["resource"].get("items", [])
  for si in items:
    epID = getsiEPID(si)
    interface = {}
    for key, val in epID.items():
      interface[key] = val
    interface["id"] = getsiID(si)
    interface["peerAS"] = 0
    interface["peerGroup"] = "underlay"
    interfaces.append(interface)

  setInterfaces(self, interfaces)
  return None
