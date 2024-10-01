load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "isEBGPEnabled", "isItfceNumbered")
load("infra.kuid.dev.nodes.star", "getPartition")
load("ipam.be.kuid.dev.ipclaims.star", "getIPClaim")
load("as.be.kuid.dev.asclaims.star", "getASClaim")

finalizer = "node.infra.kuid.dev/ids"
conditionType = "IPClaimReady"

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

  networkDesign, err = getNetworkDesign(partition, namespace)
  if err != None:
    # we dont return the error but wait for the network design retrigger
    return reconcile_result(self, False, 0, conditionType, err, False)
        
  ipClaims = getIPClaims(self, networkDesign)
  for ipClaim in ipClaims:
    rsp = client_create(ipClaim)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  asClaims = getASClaims(self, networkDesign)
  for asClaim in asClaims:
    rsp = client_create(asClaim)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)
  
def getIPClaims(self, networkDesign):
  namespace = getNamespace(self)
  partition = getPartition(self)
  nodeName = getName(self)
  ipIndexName = partition + ".default"
  
  ipClaims = []
  # there is always an ipclaim (if ipv4 is not enabled a routerid is assigned)
  af = "ipv4"
  if isItfceNumbered(networkDesign, "loopback", af):
    ipClaimName = nodeName + "." + af
    ipClaims.append(getIPClaimPerAF(ipClaimName, namespace, ipIndexName, af))
  else:
    ipClaimName = nodeName + "." + "routerid"
    ipClaims.append(getIPClaimPerAF(ipClaimName, namespace, ipIndexName, af))
  
  af = "ipv6"
  if isItfceNumbered(networkDesign, "loopback", af):
    ipClaimName = nodeName + "." + af
    ipClaims.append(getIPClaimPerAF(ipClaimName, namespace, ipIndexName, af))
  return ipClaims

def getIPClaimPerAF(ipClaimName, namespace, ipIndexName, af):
  spec = {
        "index": ipIndexName,
        "prefixType": "pool",
        "selector": {
          "matchLabels": {
            "infra.kuid.dev/purpose": "loopback",
            "ipam.be.kuid.dev/address-family": af,
          },
        }
      }
  return getIPClaim(ipClaimName, namespace, spec)

def getASClaims(self, networkDesign):
  nodeName = getName(self)
  namespace = getNamespace(self)
  partition = getPartition(self)
  asIndexName = partition 

  asClaims = []

  if isEBGPEnabled(networkDesign):
    spec = {
      "index": partition,
      "selector": {
        "matchLabels": {
          "be.kuid.dev/claim-name": partition + "." + "aspool"
        },
      }
    }
    asClaims.append(getASClaim(nodeName, namespace, spec))
  
  return asClaims
