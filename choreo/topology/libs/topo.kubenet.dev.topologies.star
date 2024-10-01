load("id.kuid.dev.id.star", "getNodeKeys", "getNodeID")

def getSpec(self):
  return self.get("spec", {})

def getNodes(self):
  spec = getSpec(self)
  return spec.get("nodes", [])

def getLinks(self):
  spec = getSpec(self)
  return spec.get("links", [])

def getDefaults(self):
  spec = getSpec(self)
  return spec.get("defaults", {})

def getNodeName(topoNode):
  nodeName = topoNode.get("name", "")
  if nodeName == "":
    return None, "node name is missing"
  return nodeName, None

def getNodeProvider(topoNode, defaults):
  return getValueWithKey("provider", topoNode, defaults)

def getNodeRegion(topoNode, defaults):
  return getValueWithKey("region", topoNode, defaults)

def getNodeSite(topoNode, defaults):
  return getValueWithKey("site", topoNode, defaults)

def getNodePlatformType(topoNode, defaults):
  return getValueWithKey("platformType", topoNode, defaults)

def getValueWithKey(key, node, defaults):
  if key in node:
      return node[key], None
  if key in defaults:
      return defaults[key], None
  return None, key + "not found"

def getNodeSpec(partition, topoNode, defaults):
  node, err = getNodeName(topoNode)
  if err != None:
    return None, None, err
  region, err = getNodeRegion(topoNode, defaults)
  if err != None:
    return None, None, "nodeName" + node + "err" + err
  site, err = getNodeSite(topoNode, defaults)
  if err != None:
    return None, None, "nodeName" + node + "err" + err
  provider, err = getNodeProvider(topoNode, defaults)
  if err != None:
    return None, None, "nodeName" + node + "err" + err
  platformType, err = getNodePlatformType(topoNode, defaults)
  if err != None:
    return None, None, "nodeName" + node + "err" + err
  
  nodeSpec = getNodeID(partition, region, site, node)
  nodeSpec["platformType"] = platformType
  nodeSpec["provider"] = provider

  return node, nodeSpec, None

def getLinkEndpoints(topoLink):
  return topoLink.get("endpoints", [])

def getEndpointNode(topoEndpoint):
  return topoEndpoint.get("node", "")

def getEndpointPort(topoEndpoint):
  return topoEndpoint.get("port", 0)

def getEndpointEndpoint(topoEndpoint):
  return topoEndpoint.get("endpoint", 0)

def getEndpointAdaptor(topoEndpoint):
  return topoEndpoint.get("adaptor", "")

def getEndpointModuleBay(topoEndpoint):
  return topoEndpoint.get("moduleBay", "")

def getEndpointModule(topoEndpoint):
  return topoEndpoint.get("module", 0)

def getLinkSpec(topoLink, nodes):
  linkName = ""
  endpoints = []
  for topoEndpoint in getLinkEndpoints(topoLink):
    nodeName = topoEndpoint.get("node")
    if nodeName == "":
      return None, None, "node name not present in link endpoint"
    node = nodes.get(nodeName)
    if not node:
      return None, None,  nodeName + " not found in nodes"
        
    endpoint = {}
    nodeKeys = getNodeKeys()
    for key, val in node.items():
      if key in nodeKeys:
        endpoint[key] = val
    endpoint["port"] = getEndpointPort(topoEndpoint)
    endpoint["endpoint"] = getEndpointEndpoint(topoEndpoint)
    endpoint["adaptor"] = getEndpointAdaptor(topoEndpoint)
    if getEndpointModule(topoEndpoint) != "":
      endpoint["module"] = getEndpointModule(topoEndpoint)
    if getEndpointModuleBay(topoEndpoint) != "":
      endpoint["moduleBay"] = getEndpointModuleBay(topoEndpoint)
    endpoints.append(endpoint)
    if linkName == "":
      linkName += node["partition"] + "." + node["region"] + "." + node["site"] + "."
    else:
      linkName += "."
    linkName += topoEndpoint["node"] + "." + str(int( topoEndpoint["port"])) + "." + str(int( topoEndpoint["endpoint"]))
  
  spec = {
    "internal": True,
    "endpoints": endpoints
  }
  return linkName, spec, None
    