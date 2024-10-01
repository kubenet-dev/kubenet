load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("topo.kubenet.dev.topologies.star", "getDefaults", "getNodes", "getNodeSpec", "getLinks", "getLinkSpec")
load("id.kuid.dev.id.star", "getNodeKeys", "getNodeID", "genNodeIDString")
load("infra.kuid.dev.nodes.star", getInfraNode="getNode")
load("infra.kuid.dev.links.star", getInfraLink="getLink")

finalizer = "topology.topo.kubenet.dev/node.link"
conditionType = "LinkNodeReady"

def reconcile(self):
  # self is topo

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  nodes = {}
  defaults = getDefaults(self)
  for topoNode in getNodes(self):
    node, err = getNode(self, topoNode, defaults, nodes)
    if err != None:
      return reconcile_result(self, True, 0, conditionType, err, True)
    rsp = client_create(node)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  for topoLink in getLinks(self):
    link, err = getLink(self, topoLink, nodes)
    if err != None:
      return reconcile_result(self, True, 0, conditionType, err, True)
    rsp = client_create(link)
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getNode(self, topoNode, defaults, nodes):
  partition = getName(self)
  namespace = getNamespace(self)

  name, nodeSpec, err = getNodeSpec(partition, topoNode, defaults)
  if err != None:
    return None, err
  nodes[name] = nodeSpec

  nodeName = genNodeIDString(nodeSpec)
  spec = {}
  for key, val in nodeSpec.items():
    spec[key] = val
  return getInfraNode(nodeName, namespace, spec), None

def getLink(self, topoLink, nodes):
  namespace = getNamespace(self)

  name, linkSpec, err = getLinkSpec(topoLink, nodes)
  if err != None:
    return None, err
  return getInfraLink(name, namespace, linkSpec), None