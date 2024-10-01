load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isItfceNumbered")
load("infra.kuid.dev.nodes.star", "getPartition", "getNodeID")
load("id.kuid.dev.ids.star", "getEndpointID", "genEndpointIDString")
load("device.network.kubenet.dev.interfaces.star", "getInterfaceSpec", "getInterface")
load("device.network.kubenet.dev.subinterfaces.star", "getSubInterface")
load("device.network.kubenet.dev.networkinstances.star", getniNetworkInstance="getNetworkInstance")
load("ipam.be.kuid.dev.ipclaims.star", "getIPClaimedAddress")

finalizer = "node.infra.kuid.dev/itfce"
conditionType = "InterfaceReady"

def reconcile(self):
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
    return reconcile_result(self, True, 0, conditionType, "ip claim not ready", False)

  networkDesign, err = getNetworkDesign(partition, namespace)
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)

  interfaces = getInterfaces(self)
  for itfce in interfaces:
    rsp = client_create(itfce)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  subInterfaces, err = getSubInterfaces(self, networkDesign)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  for subItfce in subInterfaces:
    rsp = client_create(subItfce)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"]) 
  
  ni = getNetworkInstance(self)
  rsp = client_create(ni)
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"]) 
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getInterfaces(self):
  nodeID = getNodeID(self)
  namespace = getNamespace(self)

  interfaces = []
  systemEPID = getEndpointID(nodeID, 0, 0, "system")
  systemEPName = genEndpointIDString(systemEPID)
  systemSpec = getInterfaceSpec(systemEPID)   
  interfaces.append(getInterface(systemEPName, namespace, systemSpec))   

  irbEPID = getEndpointID(nodeID, 0, 0, "irb")
  irbEPName = genEndpointIDString(irbEPID)
  irbSpec = getInterfaceSpec(irbEPID)      
  interfaces.append(getInterface(irbEPName, namespace, irbSpec))   
  
  ## todo vxlan or other
  return interfaces


def getSubInterfaces(self, networkDesign):
  nodeID = getNodeID(self)
  nodeName = getName(self)
  namespace = getNamespace(self)

  subinterfaces = []

  ipv4, err = getAddressesPerAF(nodeName, namespace, networkDesign, "ipv4")
  if err != None:
    return None, err
  ipv6, err = getAddressesPerAF(nodeName, namespace, networkDesign, "ipv6")
  if err != None:
    return None, err

  id = 0
  epID = getEndpointID(nodeID, 0, 0, "system")
  siName = genEndpointIDString(epID) + "." + str(id)

  spec = {}
  for key, val in epID.items():
    if key == "port" or key == "endpoint":
      spec[key] = int(val)
    else:
      spec[key] = val
  spec["type"] = "routed"
  spec["id"] = id
  spec["ipv4"] = ipv4
  spec["ipv6"] = ipv6
  
  subinterfaces.append(getSubInterface(siName, namespace, spec))
  return subinterfaces, None

def getAddressesPerAF(nodeName, namespace, networkDesign, af):
  afaddrs = None
  if isItfceNumbered(networkDesign, "loopback", af):
    ipClaimName = nodeName + "." + af
    address, err = getIPClaimedAddress(ipClaimName, namespace) 
    if err != None:
      return None, err
    
    afaddrs = {}
    afaddrs["addresses"] = []
    afaddrs["addresses"].append(address)
  return afaddrs, None

def getNetworkInstance(self):
  nodeName = getName(self)
  namespace = getNamespace(self)
  nodeID = getNodeID(self)

  niShortName = "default"
  niName = nodeName + "." + niShortName

  spec = {}
  for key, val in nodeID.items():
    spec[key] = val
  spec["id"] = 0
  spec["type"] = niShortName
  spec["name"] = niShortName

  return getniNetworkInstance(niName, namespace, spec)
  
