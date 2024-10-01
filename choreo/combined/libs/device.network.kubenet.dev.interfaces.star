load("id.kuid.dev.ids.star", "genEndpointIDString")
load("infra.kuid.dev.endpoints.star", "getEndpointSpeed")

def getInterfaceSpecWithLookup(epID, namespace):
  epName = genEndpointIDString(epID)
  ep = get_resource("infra.kuid.dev/v1alpha1", "Endpoint")
  rsp = client_get(epName, namespace, ep["resource"])
  if rsp["error"] != None:
    return None, rsp["error"]
  speed = getEndpointSpeed(rsp['resource'])
  
  spec = {}
  for key, val in epID.items():
    if key == "port" or key == "endpoint":
      spec[key] = int(val)
    else:
      spec[key] = val
  spec["mtu"] = 9000
  spec["ethernet"] = {"speed": speed}
  return spec, None

def getInterfaceSpec(epID):
  spec = {}
  for key, val in epID.items():
    if key == "port" or key == "endpoint":
      spec[key] = int(val)
    else:
      spec[key] = val
  return spec

def getInterface(name, namespace, spec):
  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "Interface",
    "metadata": {
        "name": name,
        "namespace": namespace,
    },
    "spec": spec,
  }


        

        

           