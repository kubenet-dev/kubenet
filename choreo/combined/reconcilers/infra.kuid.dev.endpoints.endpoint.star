finalizer = "endpoint.infra.kuid.dev/ready"
conditionType = "Ready"

def reconcile(endpoint):
  return reconcile_result(endpoint, False, 0, conditionType, "", False)