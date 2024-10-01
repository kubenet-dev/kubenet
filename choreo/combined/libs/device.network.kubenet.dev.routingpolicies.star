load("id.kuid.dev.ids.star", "genNodeIDString")

def getRoutingPolicyStatement(id, actionResult, prefixSetRef = None, tagSetRef = None, family = None, protocol = None, bgp = None, isis = None, ospf = None):
  match = {}
  if prefixSetRef != None:
    match["prefixSetRef"] = prefixSetRef
  if tagSetRef != None:
    match["tagSetRef"] = tagSetRef
  if family != None:
    match["family"] = family
  if protocol != None:
    match["protocol"] = protocol
  if bgp != None:
    match["bgp"] = bgp
  if ospf != None:
    match["ospf"] = ospf
  if isis != None:
    match["isis"] = isis
  
  return {
    "id": id,
    "match": match,
    "action": {
        "result": actionResult
    }
  }

def getRoutingPolicy(nodeID, shortName, namespace, statements, defaultAction = None):
  name = genNodeIDString(nodeID) + "." + shortName.lower()

  if defaultAction == None:
    defaultAction = {"result": "reject"}
  
  spec = {}
  for key, val in nodeID.items():
    spec[key] = val
  spec["name"]= name
  spec["defaultAction"] = defaultAction
  if statements != None and len(statements) > 0:
    spec["statements"] = statements

  return {
    "apiVersion": "device.network.kubenet.dev/v1alpha1",
    "kind": "RoutingPolicy",
    "metadata": {
      "name": name,
      "namespace": namespace,
    },
    "spec": spec,
  }