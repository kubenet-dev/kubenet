/*
Copyright 2024 Nokia.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1alpha1

import (
	"reflect"

	condv1alpha1 "github.com/kform-dev/choreo/apis/condition/v1alpha1"
	kuididv1alpha1 "github.com/kform-dev/choreo/apis/kuid/id/v1alpha1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// BGPDynamicNeighborSpec defines the desired state of BGPDynamicNeighbor
type BGPDynamicNeighborSpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// Prefixes define the prefix list
	// +listType=set
	Prefixes []string `json:"prefixes,omitempty" protobuf:"bytes,2,rep,name=localAS"`
	// Interfaces define the interfaces on which the dynamic BGP neighbor are associated
	// +listType=map
	// +listMapKey=partition
    // +listMapKey=region
	// +listMapKey=site
	// +listMapKey=node
	// +listMapKey=port
	// +listMapKey=endpoint
	// +listMapKey=id
	Interfaces []BGPDynamicNeighborInterface `json:"interfaces,omitempty" protobuf:"bytes,3,rep,name=interfaces"`
}

type BGPDynamicNeighborInterface struct {
	// PartitionEndpointID defines the kuid endpoint ID
	kuididv1alpha1.PartitionEndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the NetworkInstance
	ID uint32 `json:"id" protobuf:"bytes,2,opt,name=id"`
	// PeerAS defines the peer autonomous system of the bgp neighbor
	PeerAS uint32 `json:"peerAS" protobuf:"bytes,3,opt,name=peerAS"`
	// PeerGroup defines the peer group of the bgp neighbor
	PeerGroup string `json:"peerGroup" protobuf:"bytes,4,opt,name=peerGroup"`

}


// BGPDynamicNeighborStatus defines the observed state of BGPDynamicNeighbor
type BGPDynamicNeighborStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:BGPDynamicNeighbors=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// BGPDynamicNeighbor defines the Schema for the BGPDynamicNeighbor API
type BGPDynamicNeighbor struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   BGPDynamicNeighborSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status BGPDynamicNeighborStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// BGPDynamicNeighborList contains a list of BGPDynamicNeighbors
// +k8s:deepcopy-gen:BGPDynamicNeighbors=k8s.io/apimachinery/pkg/runtime.Object
type BGPDynamicNeighborList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []BGPDynamicNeighbor `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// BGPDynamicNeighbor type metadata.
var (
	BGPDynamicNeighborKind = reflect.TypeOf(BGPDynamicNeighbor{}).Name()
)
