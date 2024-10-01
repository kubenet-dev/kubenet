load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("device.network.kubenet.dev.subinterfaces.star", getsiEPID="getEPID", getsiID="getID")
load("device.network.kubenet.dev.networkinstances.star", "getPartition", "getRegion", "getSite", "getNode", "setInterfaces")

finalizer = "networkinstance.device.network.kubenet.dev/subinterface"
conditionType = "Ready"

def reconcile(self):
  namespace = getNamespace(self)
  niName = getName(self)

  err = updateSubInterfaces(self, namespace)
  if err != None:
    return reconcile_result(self, True, 0, conditionType, err, True)

  return reconcile_result(self, False, 0, conditionType, "", False)

def updateSubInterfaces(self, namespace):
  fieldSelector = {}
  fieldSelector["spec.partition"] = getPartition(self)
  fieldSelector["spec.region"] = getRegion(self)
  fieldSelector["spec.site"] = getSite(self)
  fieldSelector["spec.node"] = getNode(self)

  silist = get_resource("device.network.kubenet.dev/v1alpha1", "SubInterface")
  rsp = client_list(silist["resource"], fieldSelector)
  if rsp["error"] != None:
    return rsp["error"]
  
  interfaces = []
  items = rsp["resource"].get("items", [])
  for si in items:
    epID = getsiEPID(si)
    interface = {}
    for key, val in epID.items():
      interface[key] = val
    interface["id"] = getsiID(si)

    interfaces.append(interface)
  
  # Sort interfaces by multiple keys
  interfaces = insertion_sort(interfaces, lambda x: (x.get('id'), x.get('endpoint'), x.get('port'), x.get('name')))

  setInterfaces(self, interfaces)
  return None

def insertion_sort(arr, key_func):
  for i in range(1, len(arr)):
    key_item = arr[i]
    key_value = key_func(key_item)
    # Insert key_item into the sorted sequence arr[0 ... i-1]
    inserted = False
    for j in range(i - 1, -1, -1):
      if key_func(arr[j]) > key_value:
        arr[j + 1] = arr[j]
      else:
        arr[j + 1] = key_item
        inserted = True
        break
    if not inserted:
      arr[0] = key_item
  return arr


