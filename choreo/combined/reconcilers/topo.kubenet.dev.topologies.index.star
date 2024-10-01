load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("as.be.kuid.dev.asindices.star", "getASIndex")
load("genid.be.kuid.dev.genidindices.star", getgenidGENIDIndex="getGENIDIndex")

finalizer = "topology.topo.kubenet.dev/index"
conditionType = "IndexReady"

def reconcile(self):
  partition = getName(self)
  namespace = getNamespace(self)

  if getDeletionTimestamp(self) != None:
    rsp = client_delete()
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
    
    delFinalizer(self, finalizer)
    return reconcile_result(self, False, 0, conditionType, "", False)

  setFinalizer(self, finalizer)

  genidindex = getGENIDIndex(partition, namespace)
  rsp = client_create(genidindex)
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])

  asindex = getASIndex(partition, namespace, {})
  rsp = client_create(asindex)
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  
  rsp = client_apply()
  if rsp["error"] != None:
    return reconcile_result(self, True, 0, conditionType, rsp["error"], rsp["fatal"])
  return reconcile_result(self, False, 0, conditionType, "", False)

def getGENIDIndex(partition, namespace):
  spec = {
    "minID": 0,
    "maxID": 4095,
    "type": "16bit",
  }
  return getgenidGENIDIndex(partition, namespace, spec)


