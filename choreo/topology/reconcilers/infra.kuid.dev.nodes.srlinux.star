load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("infra.kuid.dev.nodes.star", "getNodeID", "getPlatformType", "getProvider")
load("infra.kuid.dev.ports.star", getInfraPort="getPort")
load("infra.kuid.dev.adaptors.star", getInfraAdaptor="getAdaptor")
load("infra.kuid.dev.endpoints.star", getInfraEndpoint="getEndpoint")
load("srlinux.nokia.vendor.kubenet.dev.nodetemplates.star", "getNodeTemplate", "getPorts", "getPortIDsStart", "getPortIDsEnd", "getPortIDsAdaptor",  "getPortIDsAdaptorConnector")

finalizer = "node.infra.kuid.dev/nokia.srlinux"
conditionType = "VendorReady"

def reconcile(self):
  # self = node
  name = getPlatformType(self)
  namespace = getNamespace(self)

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  nodeTemplate, err = getNodeTemplate(name, namespace)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, False)
          
  for port in getPorts(nodeTemplate):
    for portID in range(int(getPortIDsStart(port)), int(getPortIDsEnd(port)) + 1):
      rsp = client_create(getPort(self, portID))
      if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

      adaptor = getAdaptor(self, portID, getPortIDsAdaptor(port))
      rsp = client_create(adaptor)
      if rsp["error"] != None:
        return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

      for connectorID in range(int(1), int(getPortIDsAdaptorConnector(port)) + 1):
        ep = getEndpoint(self, portID, getPortIDsAdaptor(port), connectorID)
        rsp = client_create(ep)
        if rsp["error"] != None:
          return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)
    
def getPort(node, portID):
  namespace = getNamespace(node)
  name = getName(node) + "." + str(portID)
  nodeID = getNodeID(node)
  spec = {}
  for key, val in nodeID.items():
    spec[key] = val 
  spec["port"] = int(portID)
  return getInfraPort(name, namespace, spec)

def getAdaptor(node, portID, adaptor):
  namespace = getNamespace(node)
  name = getName(node) + "." + str(portID) + "." + adaptor["name"]
  nodeID = getNodeID(node)
  spec = {}
  for key, val in nodeID.items():
    spec[key] = val 
  spec["port"] = int(portID)
  spec["adaptor"] = adaptor["name"]
  return getInfraAdaptor(name, namespace, spec)

def getEndpoint(node, portID, adaptor, connectorID):
  namespace = getNamespace(node)
  name = getName(node) + "." + str(portID) + "." + str(connectorID)
  nodeID = getNodeID(node)
  spec = {}
  for key, val in nodeID.items():
    spec[key] = val 
  spec["port"] = int(portID)
  spec["adaptor"] = adaptor["name"]
  spec["endpoint"] = int(connectorID)
  spec["speed"] = adaptor["speed"]
  return getInfraEndpoint(name, namespace, spec)
