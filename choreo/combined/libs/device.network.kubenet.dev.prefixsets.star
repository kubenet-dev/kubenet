load("id.kuid.dev.ids.star", "genNodeIDString")

def getPrefixSet(nodeID, name, namespace, prefixes):
    name = genNodeIDString(nodeID) + "." + name.lower()
    
    spec = {}
    spec["partition"]= nodeID["partition"]
    spec["region"]= nodeID["region"]
    spec["site"]= nodeID["site"]
    spec["node"]= nodeID["node"]
    spec["name"]= name
    if prefixes != None and len(prefixes) > 0:
        spec["prefixes"] = prefixes

    return {
        "apiVersion": "device.network.kubenet.dev/v1alpha1",
        "kind": "PrefixSet",
        "metadata": {
            "name": name,
            "namespace": namespace,
        },
        "spec": spec,
     }

def getPrefixSetPrefix(prefix, maskLengthRange):
  return {
    "prefix": prefix,
    "maskLengthRange": maskLengthRange,
  }