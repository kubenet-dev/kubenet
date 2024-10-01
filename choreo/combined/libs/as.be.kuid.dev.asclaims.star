def getASClaimID(name, namespace):
  resource = get_resource("as.be.kuid.dev/v1alpha1", "ASClaim")
  rsp = client_get(name, namespace, resource["resource"])
  if rsp["error"] != None:
    return None,  "asclaim " + name + " err: " + rsp["error"]
    
  if is_conditionready(rsp["resource"], "Ready") != True:
    return None, "asclaim " + name + " not ready"
  status = rsp["resource"].get("status", {})
  return status.get("id", 0), None

def getASClaim(name, namespace, spec):
  return {
    "apiVersion": "as.be.kuid.dev/v1alpha1",
    "kind": "ASClaim",
    "metadata": {
        "name": name,
        "namespace": namespace
    },
    "spec": spec,
  }