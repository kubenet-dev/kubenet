load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getIPIndexName", "isIBGPEnabled", "isEBGPEnabled", "getIBGPASN", "getEBGPASNPool", "getItfcePrefixes", "getPrefixLabels", "getPrefixPrefix")
load("ipam.be.kuid.dev.ipclaims.star", getipamIPClaim="getIPClaim")
load("as.be.kuid.dev.asclaims.star", "getASClaim")

finalizer = "networkdesign.core.network.kubenet.dev/ready"
conditionType = "Ready"

def reconcile(self):
  namespace = getNamespace(self)

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

    setFinalizer(self, finalizer)

  ipIndex = get_resource("ipam.be.kuid.dev/v1alpha1", "IPIndex")
  rsp = client_get(getIPIndexName(self), namespace, ipIndex["resource"])
  if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  ipClaims = getIPClaims(self)
  for ipClaim in ipClaims:
    rsp = client_create(ipClaim)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])    

  asClaims = getASClaims(self)
  for asClaim in asClaims:
    rsp = client_create(asClaim)
    if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getIPClaims(self):
  ipClaims = []

  purpose = "loopback"
  for prefix in getItfcePrefixes(self, purpose):
    ipprefix = getPrefixPrefix(prefix)
    labels = getPrefixLabels(prefix, purpose)
    ipClaims.append(getIPClaim(self, ipprefix, "pool", labels))
  
  purpose = "underlay"
  for prefix in getItfcePrefixes(self, purpose):
    ipprefix = getPrefixPrefix(prefix)
    labels = getPrefixLabels(prefix, purpose)
    ipClaims.append(getIPClaim(self, ipprefix, "network", labels))
  
  return ipClaims

def getIPClaim(self, ipprefix, ipprefixType, labels):
    ipIndexName = getIPIndexName(self)
    namespace = getNamespace(self)
    ipClaimName = ipIndexName + "." + str(get_subnetname(ipprefix))

    spec = {
          "index": ipIndexName,
          "prefixType": ipprefixType,
          "prefix": ipprefix,
          "prefixLength": get_prefixlength(ipprefix),
          "createPrefix": True,
          "labels": labels,
        }
    return getipamIPClaim(ipClaimName, namespace, spec)

def getASClaims(self):
  partition = getName(self)
  namespace = getNamespace(self)
  asClaims = []

  if isIBGPEnabled(self):
    asClaimName = partition + "." + "ibgp"
    spec = {
      "index": partition,
      "id": getIBGPASN(self)
    }
    asClaims.append(getASClaim(asClaimName, namespace, spec))          

  if isEBGPEnabled(self):
    asClaimName = partition + "." + "aspool"
    spec = {
      "index": partition,
      "range": getEBGPASNPool(self)
    }
    asClaims.append(getASClaim(asClaimName, namespace, spec))   
  return asClaims
