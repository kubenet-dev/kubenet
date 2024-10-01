def getBFD(name, namespace, spec):
  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "BFD",
    "metadata": {
      "name": name,
      "namespace": namespace,
    },
    "spec": spec,
  }

def getBFDParamsKeys():
  return {
    "enabled": True,
    "minTx": True,
    "minRx": True,
    "minEchoRx": True,
    "multiplier": True,
    "ttl": True,
  }