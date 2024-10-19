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

// BGPSpec defines the desired state of BGP
type BGPSpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// AS defines the autonomous system
	AS uint32 `json:"as" protobuf:"bytes,2,opt,name=as"`
	// RouterID defines the router ID
	RouterID string `json:"routerID" protobuf:"bytes,3,opt,name=routerID"`
	// +listType=map
	// +listMapKey=name
	// AddressFamilies defines the address families that need to be enabled globally
	AddressFamilies []*BGPAddressFamily `json:"addressFamilies,omitempty" protobuf:"bytes,6,rep,name=addressFamilies"`
	// +listType=map
	// +listMapKey=name
	// PeerGroups define the peer groups for the BGP instance
	PeerGroups []BGPPeerGroup `json:"peerGroups" protobuf:"bytes,3,opt,name=peerGroups"`
}

type BGPPeerGroup struct {
	// Name defines the name of the peer group family
	Name string `json:"name" protobuf:"bytes,1,opt,name=name"`
	// Address families define the address families to be disabled
	AddressFamilies []*BGPAddressFamily `json:"addressFamilies,omitempty"  protobuf:"bytes,2,rep,name=addressFamilies"`
	// RouteReflector defines the RouteReflector parameters
	RouteReflector *BGPRouteReflector `json:"routeReflector,omitempty" protobuf:"bytes,3,opt,name=routeReflector"`
	// BFD defines if BFD is enabled on the BGP peer group
	BFD *bool `json:"bfd,omitempty" protobuf:"bytes,4,opt,name=bfd"`
}

type BGPAddressFamily struct {
	// Name defines the name of the address family
	Name string `json:"name" protobuf:"bytes,1,opt,name=name"`
	// RFC5549 defines if rfc5549 is enabled for this address family
	RFC5549 *bool `json:"rfc5549,omitempty" protobuf:"bytes,2,opt,name=rfc5549"`
}

type BGPRouteReflector struct {
	// ClusterID defines the clusterID of the Router reflector
	ClusterID string `json:"clusterID" protobuf:"bytes,1,opt,name=clusterID"`
}

// BGPStatus defines the observed state of BGP
type BGPStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:BGPs=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// BGP defines the Schema for the BGP API
type BGP struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   BGPSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status BGPStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// BGPList contains a list of BGPs
// +k8s:deepcopy-gen:BGPs=k8s.io/apimachinery/pkg/runtime.Object
type BGPList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []BGP `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// BGP type metadata.
var (
	BGPKind = reflect.TypeOf(BGP{}).Name()
)
