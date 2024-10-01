load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("device.network.kubenet.dev.bfds.star", getNetworkBFD="getBFD")
load("id.kuid.dev.ids.star", "genEndpointIDString")
load("device.network.kubenet.dev.subinterfaces.star", "getPartition", getsiEPID="getEPID", getsiBFDParams="getBFDParams", getsiID="getID")

finalizer = "subinterface.device.network.kubenet.dev/bfd"
conditionType = "BFDReady"

def reconcile(self):
  # self = si

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)
        
  bfd = getBFD(self)
  rsp = client_create(bfd)
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)


def getBFD(self):
  epID = getsiEPID(self)
  bfdParams = getsiBFDParams(self)
  id = getsiID(self)

  namespace = getNamespace(self)
  name = genEndpointIDString(epID)

  spec = {}
  for key, val in epID.items():
    spec[key] = val
  for key, val in bfdParams.items():
    spec[key] = val
  spec["id"] = id

  return getNetworkBFD(name, namespace, spec)
  