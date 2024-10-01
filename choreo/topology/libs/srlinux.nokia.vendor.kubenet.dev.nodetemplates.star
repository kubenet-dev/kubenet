def getNodeTemplate(name, namespace):
  r = get_resource("srlinux.nokia.vendor.kubenet.dev/v1alpha1", "NodeTemplate")
  rsp = client_get(name, namespace, r["resource"])
  if rsp["error"] != None:
    return None, rsp["error"]
  return rsp["resource"], None

def getSpec(self):
  return self.get("spec", {})

def getProvider(self):
  spec = getSpec(self)
  return spec.get("provider", "")

def getPlatformType(self):
  spec = getSpec(self)
  return spec.get("platformType", "")

def getPorts(self):
  spec = getSpec(self)
  return spec.get("ports", [])

def getModuleBays(self):
  spec = getSpec(self)
  return spec.get("moduleBays", [])

def getPortIDs(port):
  return port.get("ids", {})

def getPortIDsStart(port):
  portids = port.get("ids", {})
  return portids.get("start", 0)

def getPortIDsEnd(port):
  portids = port.get("ids", {})
  return portids.get("end", 0)

def getPortIDsAdaptor(port):
  portids = port.get("ids", {})
  return port.get("adaptor", {})

def getPortIDsAdaptorConnector(port):
  portids = port.get("ids", {})
  adaptor = port.get("adaptor", {})
  return adaptor.get("connectors", 1)