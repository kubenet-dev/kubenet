def getIPClaimedAddress(name, namespace):
  resource = get_resource("ipam.be.kuid.dev/v1alpha1", "IPClaim")
  rsp = client_get(name, namespace, resource["resource"])
  if rsp["error"] != None:
    return None, "ipclaim " + name + " err: " + rsp["error"]
  
  if is_conditionready(rsp["resource"], "Ready") != True:
    return None, "ipclaim " + name + " not ready"
  status = rsp["resource"].get("status", {})
  address = status.get("address", "")
  if address == "":
    return None, "ipclaim " + name + " no address in ip claim"
  return address, None

def getIPClaim(name, namespace, spec):
  return {
    "apiVersion": "ipam.be.kuid.dev/v1alpha1",
    "kind": "IPClaim",
    "metadata": {
        "name": name,
        "namespace": namespace
    },
    "spec": spec,
  }