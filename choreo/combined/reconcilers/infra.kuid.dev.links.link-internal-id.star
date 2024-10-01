load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("core.network.kubenet.dev.networkdesigns.star", "getNetworkDesign", "getIPIndexName", "isItfceNumbered")
load("ipam.be.kuid.dev.ipclaims.star", "getIPClaim")
load("infra.kuid.dev.links.star", "getEndpoints", "getEndpointIDString", "getEndpointPartition")

finalizer = "link.infra.kuid.dev/ids"
conditionType = "IPClaimReady"

def reconcile(self):
  # self is link
  namespace = getNamespace(self)

  # given we only deal with internal links there will only be 1 network design
  networkDesign, err = getNetworkDesignFromLink(self, namespace)
  if err != None:
    return reconcile_result(self, False, 0, conditionType, err, False)
        
  ipClaims = getIPClaims(self, networkDesign)
  for ipClaim in ipClaims:
    rsp = client_create(ipClaim)
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
  
def getIPClaims(self, networkDesign):
  partition = getName(networkDesign)
  ipIndexName = getIPIndexName(networkDesign)
  linkName = getName(self)
  namespace = getNamespace(self)
  
  ipClaims = []

  af = "ipv4"      
  if isItfceNumbered(networkDesign, "underlay", af):
    # link claim
    ipClaimLinkName = linkName + "." + af
    ipClaim = getIPPRefixClaim(ipClaimLinkName, namespace, ipIndexName, af)
    ipClaims.append(ipClaim)

    # given the order is followed we now add the endpoint claims
    # as such the link get claimed and the ips within the link will follow
    for endpoint in getEndpoints(self):
      ipClaimEpName = getEndpointIDString(endpoint) + "." + af
      ipClaim = getIPAddressClaim(ipClaimEpName, namespace, ipIndexName, ipClaimLinkName, af)
      ipClaims.append(ipClaim)
  af = "ipv6"
  if isItfceNumbered(networkDesign, "underlay", af):
    # link claim
    ipClaimLinkName = linkName + "." + af
    ipClaim = getIPPRefixClaim(ipClaimLinkName, namespace, ipIndexName, af)
    ipClaims.append(ipClaim)

    # given the order is followed we now add the endpoint claims
    # as such the link get claimed and the ips within the link will follow
    for endpoint in getEndpoints(self):
      ipClaimEpName = getEndpointIDString(endpoint) + "." + af
      ipClaim = getIPAddressClaim(ipClaimEpName, namespace, ipIndexName, ipClaimLinkName, af)
      ipClaims.append(ipClaim)
  
  return ipClaims

def getIPPRefixClaim(name, namespace, ipIndexName, af):
  prefixLength = 31
  if af == "ipv6":
    prefixLength = 64

  spec = {
      "index": ipIndexName,
      "prefixType": "network",
      "addressFamily": af,
      "prefixLength": prefixLength,
      "createPrefix": True,
      "selector": {
        "matchLabels": {
          "infra.kuid.dev/purpose": "underlay",
          "ipam.be.kuid.dev/address-family": af,
        },
      }
    }
  return getIPClaim(name, namespace, spec)

def getIPAddressClaim(name, namespace, ipIndexName, ipClaimLinkName, af):
  spec = {
      "index": ipIndexName,
      "prefixType": "network",
      "selector": {
        "matchLabels": {
          "be.kuid.dev/claim-name": ipClaimLinkName,
          "ipam.be.kuid.dev/address-family": af,
        },
      }
    }
  return getIPClaim(name, namespace, spec)
  
