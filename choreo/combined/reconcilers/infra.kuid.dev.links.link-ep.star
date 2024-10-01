load("api.k8s.io.object.star", "getName", "getNamespace", "getDeletionTimestamp", "delFinalizer", "setFinalizer")
load("infra.kuid.dev.links.star", "getEndpoints", "getEndpointIDString")

finalizer = "link.infra.kuid.dev/ep"
conditionType = "Ready"

def reconcile(self):
  # self = link
  namespace = getNamespace(self)

  for endpoint in getEndpoints(self):
    ep = get_resource("infra.kuid.dev/v1alpha1", "Endpoint")
    name = getEndpointIDString(endpoint)
    
    rsp = client_get(name, namespace, ep["resource"])
    if rsp["error"] != None:
      return reconcile_result(self, True, 0, conditionType, "endpoint " + name + " err: " + rsp["error"], False)
    return reconcile_result(self, False, 0, conditionType, "", False)
  return reconcile_result(self, False, 0, conditionType, "link w/o endpoints", False)