load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("id.kuid.dev.ids.star", "genEndpointIDString")
load("infra.kuid.dev.links.star", "getEndpoints", "mergeBFDParameters")
load("ipam.be.kuid.dev.ipclaims.star", "getIPClaimedAddress")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isItfceNumbered")
load("device.network.kubenet.dev.interfaces.star", "getInterfaceSpecWithLookup", "getInterface")
load("device.network.kubenet.dev.subinterfaces.star", "getSubInterface", "getSubInterfaceSpec")

finalizer = "link.infra.kuid.dev/itfce"
conditionType = "InterfaceReady"

def reconcile(self):
  # self = link
  namespace = getNamespace(self)
  linkName = getName(self)

  if is_conditionready(self, "IPClaimReady") != True:
      return reconcile_result(self, True, 0, conditionType, "link ip claims not ready", False)

  # given we only deal with internal links there will only be 1 network design
  networkDesign, err = getNetworkDesignFromLink(self, namespace)
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)

  interfaces, err = getInterfaces(self, namespace)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  for itfce in interfaces:
    rsp = client_create(itfce)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  linkInfo, err = gatherLinkInfo(self, namespace, networkDesign)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
  
  bfdParams = mergeBFDParameters(self, networkDesign)
  subInterfaces = getSubInterfaces(linkInfo, namespace, networkDesign, bfdParams)
  for subItfce in subInterfaces:
    rsp = client_create(subItfce)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"]) 
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getNetworkDesignFromLink(link, namespace):
  for endpoint in getEndpoints(link):
    partition = endpoint.get("partition", "")
    return getNetworkDesign(partition, namespace)
  return None, "not found, no endpoints"

def getInterfaces(link, namespace):
  interfaces = []
  for endpoint in getEndpoints(link):
    ifName = genEndpointIDString(endpoint)
    ifSpec, err = getInterfaceSpecWithLookup(endpoint, namespace)
    if err != None:
      return interfaces, err
    ifSpec["name"] = "interface"
    interfaces.append(getInterface(ifName, namespace, ifSpec))
  return interfaces, None

def gatherLinkInfo(link, namespace, networkDesign):
  linkInfo = []
  for endpoint in getEndpoints(link):
    epInfo = {}
    for key, val in endpoint.items():
      epInfo[key] = val
    epInfo["name"] = "interface"
    epInfo, err = addEPInfoPerAF(epInfo, endpoint, namespace, networkDesign, "ipv4")
    if err != None:
      return None, err
    epInfo, err = addEPInfoPerAF(epInfo, endpoint, namespace, networkDesign, "ipv6")
    if err != None:
      return None, err
    linkInfo.append(epInfo)
  return linkInfo, None

def addEPInfoPerAF(epInfo, endpoint, namespace, networkDesign, af):
  if isItfceNumbered(networkDesign, "underlay", af):
    ipClaimEpName = genEndpointIDString(endpoint) + "." + af
    address, err = getIPClaimedAddress(ipClaimEpName, namespace) 
    if err != None:
      return None, err
    epInfo[af] = address
  return epInfo, None

def getSubInterfaces(linkInfo, namespace, networkDesign, bfdParams):
  subinterfaces = []
  for i in range(len(linkInfo)):
    local = linkInfo[i % 2]
    id = 0
    name = genEndpointIDString(local) + "." + str(id)
    spec = getSubInterfaceSpec(i, linkInfo, networkDesign, bfdParams, id)
    subinterfaces.append(getSubInterface(name, namespace, spec))
  return subinterfaces
