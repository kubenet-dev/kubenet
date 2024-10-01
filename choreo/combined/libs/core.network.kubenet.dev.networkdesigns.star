load("api.k8s.io.object.star", "getName")

def getNetworkDesign(partition, namespace):
    nd = get_resource("core.network.kubenet.dev/v1alpha1", "NetworkDesign")
    rsp = client_get(partition, namespace, nd["resource"])
    if rsp["error"] != None:
        return None, rsp["error"]
    
    if is_conditionready(rsp["resource"], "Ready") != True:
        return None, "network design not ready"
    return rsp["resource"], None
      
# addressing

def getItfce(networkDesign, interface):
  spec = networkDesign.get("spec", {})
  interfaces = spec.get("interfaces", {})
  return interfaces.get(interface, {})

def getItfceAddressing(networkDesign, interface):
  itfce = getItfce(networkDesign, interface)
  return itfce.get("addressing", "")

def isItfceIPv4Enabled(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "dualstack" or addressing == "ipv4numbered" or addressing == "ipv4unnumbered"

def isItfceIPv6Enabled(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "dualstack" or addressing == "ipv6numbered" or addressing == "ipv6unnumbered"

def isItfceUnnumbered(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "ipv4unnumbered" or addressing == "ipv6unnumbered"

def isItfceNumbered(networkDesign, interface, af):
  addressing = getItfceAddressing(networkDesign, interface)
  if af == "ipv4":
    return isItfceIPv4Numbered(networkDesign, interface)
  return isItfceIPv6Numbered(networkDesign, interface)

def isItfceIPv4Numbered(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "dualstack" or addressing == "ipv4numbered"
      
def isItfceIPv6Numbered(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "dualstack" or addressing == "ipv6numbered"

def isItfceIPv4UnNumbered(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "ipv4numbered"
      
def isItfceIPv6UnNumbered(networkDesign, interface):
  addressing = getItfceAddressing(networkDesign, interface)
  return addressing == "ipv6numbered"

def isUnderlayIPv6Only(networkDesign):
  addressing = getItfceAddressing(networkDesign, "underlay")
  return addressing == "ipv6numbered" or addressing == "ipv6unnumbered"

def isUnderlayIPv4Only(networkDesign):
  addressing = getItfceAddressing(networkDesign, "underlay")
  return addressing == "ipv4numbered" or addressing == "ipv4unnumbered"

def getItfcePrefixes(networkDesign, interface):
  spec = networkDesign.get("spec", {})
  interfaces = spec.get("interfaces", {})
  itfce = interfaces.get(interface, {})
  return itfce.get("prefixes", [])

def getUnderlayIPv4Prefixes(networkDesign):
  prefixes = getItfcePrefixes(networkDesign, "loopback")
  ipv4 = []
  for prefix in prefixes:
    if isIPv4(prefix):
      ipv4.append(prefix.get("prefix", ""))
  return ipv4

def getUnderlayIPv6Prefixes(networkDesign):
  prefixes = getItfcePrefixes(networkDesign, "loopback")
  ipv6 = []
  for prefix in prefixes:
    if isIPv6(prefix):
      ipv6.append(prefix.get("prefix", ""))
  return ipv6

def getPrefixPrefix(prefix):
  return prefix.get("prefix", "")

def getPrefixLabels(prefix, purpose):
  labels = prefix.get("labels", {})
  labels["infra.kuid.dev/purpose"] = purpose
  return labels

# protocols
def getProtocols(networkDesign):
  spec = networkDesign.get("spec", {})
  return spec.get("protocols", {})

def getProtocolsISIS(networkDesign):
  protocols =  getProtocols(networkDesign)
  return protocols.get("protocols", "isis")

def getProtocolsOSPF(networkDesign):
  protocols =  getProtocols(networkDesign)
  return protocols.get("protocols", "ospf")

def getProtocolsEBGP(networkDesign):
  protocols =  getProtocols(networkDesign)
  return protocols.get("ebgp", {})

def getProtocolsIBGP(networkDesign):
  protocols =  getProtocols(networkDesign)
  return protocols.get("ibgp", {})

def isEBGPEnabled(networkDesign):
  ebgp = getProtocolsEBGP(networkDesign)
  return ebgp != None

def isIBGPEnabled(networkDesign):
  ibgp = getProtocolsIBGP(networkDesign)
  return ibgp != None

def isBGPEnabled(networkDesign):
  return isEBGPEnabled(networkDesign) or isIBGPEnabled(networkDesign)

def isISISBFDEnabled(networkDesign):
  isis = getProtocolsISIS(networkDesign)
  return isis.get("bfd", None) != None

def isOSPFBFDEnabled(networkDesign):
  ospf = getProtocolsOSPF(networkDesign)
  return ospf.get("bfd", None) != None

def isEBGPBFDEnabled(networkDesign):
  ebgp = getProtocolsEBGP(networkDesign)
  return ebgp.get("bfd", None) != None

def isBFDEnabled(networkDesign):
  if isISISBFDEnabled(networkDesign):
    return True
  if isOSPFBFDEnabled(networkDesign):
    return True
  if isEBGPBFDEnabled(networkDesign):
    return True
  return False

def getBFDParameters(networkDesign, interface):
  itfce = getItfce(networkDesign, interface)
  return itfce.get("bfd", {})

def getIBGPASN(self):
  ibgp = getProtocolsIBGP(self)
  return ibgp.get("as", 0)

def getEBGPASNPool(self):
  ebgp = getProtocolsEBGP(self)
  return ebgp.get("asPool", "")

# address families

def getUnderlayAddressFamilies(networkDesign):
    protocols = getProtocols(networkDesign)

    afs = []
    if isEBGPEnabled(networkDesign):
        if isItfceIPv4Enabled(networkDesign, "underlay"):
            afs.append({"name": "ipv4Unicast"})
        if isItfceIPv6Enabled(networkDesign, "underlay"):
            afs.append({"name": "ipv6Unicast"})
    return afs
       

def getOverlayAddressFamilies(networkDesign):
    protocols = getProtocols(networkDesign)

    afs = []
    if isUnderlayIPv6Only(networkDesign) and isItfceIPv4Enabled(networkDesign, "loopback"):
        afs.append({"name": "ipv4Unicast", "rfc5549": True})  
    # TBD do we need to add a case for underlay v4 only and v6 in overlay ??
    if protocols.get("bgpEVPN", None) != None:
        afs.append({"name": "bgpEVPN"})
    if protocols.get("bgpVPNv4", None) != None:
        afs.append({"name": "bgpVPNv4"})
    if protocols.get("bgpVPNv6", None) != None:
        afs.append({"name": "bgpVPNv6"})
    if protocols.get("bgpVPNv6", None) != None:
        afs.append({"name": "bgpVPNv6"})
    if protocols.get("bgpRouteTarget", None) != None:
        afs.append({"name": "bgpRouteTarget"})
    if protocols.get("bgpLabeledUnicastv4", None) != None:
        afs.append({"name": "bgpLabeledUnicastv4"})
    if protocols.get("bgpLabeledUnicastv6", None) != None:
        afs.append({"name": "bgpLabeledUnicastv6"})
    return afs

def getAddressFamilies(networkDesign):
    afs = getUnderlayAddressFamilies(networkDesign)
    afs.extend(getOverlayAddressFamilies(networkDesign))
    return afs


def getPeerGroups(networkDesign):
    peerGroups = []
    if isEBGPEnabled(networkDesign):
        peerGroups.append(getPeerGroup("underlay", getUnderlayAddressFamilies(networkDesign)))
    peerGroups.append(getPeerGroup("overlay", getOverlayAddressFamilies(networkDesign)))  
    return peerGroups  

def getPeerGroup(name, afs):
    return {
        "name": name,
        "addressFamilies": afs,
    }

def getIPIndexName(self):
  # getName(self) -> returns network design name which is the partition
  return getName(self) + ".default"
