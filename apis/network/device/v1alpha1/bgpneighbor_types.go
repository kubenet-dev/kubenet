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

// BGPNeighborSpec defines the desired state of BGPNeighbor
type BGPNeighborSpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// LocalAS defines the local autonomous system of the bgp neighbor
	LocalAS uint32 `json:"localAS" protobuf:"bytes,2,opt,name=localAS"`
	// LocalAddress defines the local address of the bgp neighbor
	LocalAddress string `json:"localAddress" protobuf:"bytes,3,opt,name=localAddress"`
	// PeerAS defines the peer autonomous system of the bgp neighbor
	PeerAS uint32 `json:"peerAS" protobuf:"bytes,4,opt,name=peerAS"`
	// PeerAddress defines the peer address of the bgp neighbor
	PeerAddress string `json:"peerAddress" protobuf:"bytes,5,opt,name=peerAddress"`
	// PeerGroup defines the peer group of the bgp neighbor
	PeerGroup string `json:"peergroup" protobuf:"bytes,6,opt,name=peergroup"`
	// BFD defines if BFD is enabled on the BGP peer group
	BFD *bool `json:"bfd,omitempty" protobuf:"bytes,7,opt,name=bfd"`
}


// BGPNeighborStatus defines the observed state of BGPNeighbor
type BGPNeighborStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:BGPNeighbors=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// BGPNeighbor defines the Schema for the BGPNeighbor API
type BGPNeighbor struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   BGPNeighborSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status BGPNeighborStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// BGPNeighborList contains a list of BGPNeighbors
// +k8s:deepcopy-gen:BGPNeighbors=k8s.io/apimachinery/pkg/runtime.Object
type BGPNeighborList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []BGPNeighbor `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// BGPNeighbor type metadata.
var (
	BGPNeighborKind = reflect.TypeOf(BGPNeighbor{}).Name()
)
