def getMetadata(self):
  return self.get("metadata", {})

def getName(self):
  metadata = getMetadata(self)
  return metadata.get("name", "")

def getNamespace(self):
  metadata = getMetadata(self)
  return metadata.get("namespace", "default")

def getDeletionTimestamp(self):
  metadata = getMetadata(self)
  return metadata.get("deletionTimestamp", None)

def getLabels(self):
  metadata = getMetadata(self)
  return metadata.get("labels", {})

def getAnnotations(self):
  metadata = getMetadata(self)
  return metadata.get("annotations", {})

def getFinalizers(self):
  metadata = getMetadata(self)
  return metadata.get("finalizers", [])

def setFinalizers(self, finalizers):
  metadata = getMetadata(self)
  metadata["finalizers"] = finalizers

def setFinalizer(self, finalizer):
  found = False
  finalizers = getFinalizers(self)
  for finalizerstr in finalizers:
    if finalizerstr == finalizer:
      found = True
      break
  if not found:
    finalizers.append(finalizer)

def delFinalizer(self, finalizer):
  found = False
  idx = 0
  finalizers = getFinalizers(self)
  for i, finalizerstr in finalizers:
    if finalizerstr == finalizer:
      found = True
      idx = i
      break
  if found:
    finalizers = finalizers[:idx] + finalizers[idx + 1:]
    setFinalizers(self, finalizers)
