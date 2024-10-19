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
	corenetworkv1alpha1 "github.com/kubenet-dev/kubenet/apis/network/core/v1alpha1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// RoutingPolicySpec defines the desired state of RoutingPolicy
type RoutingPolicySpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// Name defines the name of the routing policy
	Name string `json:"name" protobuf:"bytes,2,opt,name=name"`
	// DefaultAction defines the default action of the route policy
	DefaultAction                  RoutingPolicyStatementAction `json:"defaultAction" protobuf:"bytes,3,opt,name=defaultAction"`
	// Statements defines the routing policy statements
	// +listType=map
	// +listMapKey=id
	Statements []*RoutingPolicyStatement `json:"statements,omitempty" protobuf:"bytes,4,rep,name=statements"`
}

type RoutingPolicyStatement struct {
	ID     uint32                       `json:"id" protobuf:"bytes,1,opt,name=id"`
	Action RoutingPolicyStatementAction `json:"action" protobuf:"bytes,2,opt,name=action"`
	Match  RoutingPolicyStatementMatch  `json:"match" protobuf:"bytes,3,opt,name=match"`
}

type RoutingPolicyStatementAction struct {
	// BGP defines the default bgp policy action
	BGP *RoutingPolicyStatementActionBGP `json:"bgp,omitempty" protobuf:"bytes,1,opt,name=bgp"`
	// Result defines the result of the default routing policy action
	// +kubebuilder:validation:Enum=accept;reject;
	// +kubebuilder:default:=reject
	Result string `json:"result" protobuf:"bytes,2,opt,name=result"`
}

type RoutingPolicyStatementActionBGP struct {
	// TagSetRef define the community tag reference
	TagSetRef string `json:"tagSetRef" protobuf:"bytes,1,opt,name=tagSetRef"`
}

type RoutingPolicyStatementMatch struct {
	// AddressFamily define the matching address family
	// +kubebuilder:validation:Enum=ipv4Unicast;ipv6Unicast;bgpEVPN;bgpVPNv4;bgpVPNv6;bgpRouteTarget;bgpLabeledUnicastv4;bgpLabeledUnicastv6;
	AddressFamily string `json:"addressFamily,omitempty" protobuf:"bytes,1,opt,name=addressFamily"`
	// BGP define the bgp match statements
	BGP *RoutingPolicyStatementMatchBGP `json:"bgp,omitempty" protobuf:"bytes,2,opt,name=bgp"`
	// OSPF define the ospf match statements
	OSPF *RoutingPolicyStatementMatchOSPF `json:"ospf,omitempty" protobuf:"bytes,3,opt,name=ospf"`
	// ISIS define the isis match statements
	ISIS *RoutingPolicyStatementMatchISIS `json:"isis,omitempty" protobuf:"bytes,4,opt,name=isis"`
	// PrefixSetRef define the prefixSetRef match statements
	PrefixSetRef *string `json:"prefixSetRef,omitempty" protobuf:"bytes,5,opt,name=prefixSetRef"`
	// Protocol define the protocol match statements
	// +kubebuilder:validation:Enum=aggregate;arpND;bgp;bgpLabel;bgpEVPN;dhcp;host;isis;local;ospfv2;ospfv3;static;
	Protocol *string `json:"protocol,omitempty" protobuf:"bytes,6,opt,name=protocol"`
	// TagSetRef define the tagRefSet match statements
	TagSetRef *string `json:"tagSetRef,omitempty" protobuf:"bytes,7,opt,name=tagSetRef"`
}

type RoutingPolicyStatementMatchBGP struct {
	// ASPathLength match statement
	ASPathLength *RoutingPolicyStatementMatchBGPASPathLength `json:"asPathLength,omitempty" protobuf:"bytes,1,opt,name=asPathLength"`
	// ASPathSetRef match statement
	ASPathSetRef *string `json:"asPathSetRef,omitempty" protobuf:"bytes,2,opt,name=asPathSetRef"`
	// CommunitySetRef match statement
	CommunitySetRef *string `json:"communitySetRef,omitempty" protobuf:"bytes,3,opt,name=communitySetRef"`
}

type RoutingPolicyStatementMatchBGPASPathLength struct {
	// +kubebuilder:validation:Enum=eq;ge;le;
	Operator *string `json:"operator,omitempty" protobuf:"bytes,1,opt,name=operator"`
	// Count a repeated sequence of the same AS number as just 1 element
	Unique *bool `json:"unique,omitempty" protobuf:"bytes,2,opt,name=unique"`
	// The number of (unique) AS numbers in the AS path
	Value *uint32 `json:"value,omitempty" protobuf:"bytes,3,opt,name=value"`
}

type RoutingPolicyStatementMatchOSPF struct {
	// AreaID match statement
	AreaID string `json:"areaID,omitempty" protobuf:"bytes,1,opt,name=areaID"`
	// InstanceID match statement
	InstanceID uint32 `json:"instanceID,omitempty" protobuf:"bytes,2,opt,name=instanceID"`
	// RouteType (internal/external) match statement
	// +kubebuilder:validation:Enum=internal;external;
	RouteType string `json:"routeType,omitempty" protobuf:"bytes,3,opt,name=routeType"`
}

type RoutingPolicyStatementMatchISIS struct {
	// Level match statement
	// +kubebuilder:validation:Enum=L1;L2;L1L2;
	Level corenetworkv1alpha1.ISISLevel `json:"level,omitempty" protobuf:"bytes,1,opt,name=level"`
	// RouteType (internal/external) match statement
	// An IS-IS IPv4 prefix is external if it is signalled in TLV 130 or TLV135 with RFC 7794 X flag=1.
	// An IS-IS IPv6 prefix is external if the TLV 236/TLV 237 external bit = 1.
	// +kubebuilder:validation:Enum=internal;external;
	RouteType string `json:"routeType,omitempty" protobuf:"bytes,2,opt,name=routeType"`
}

// RoutingPolicyStatus defines the observed state of RoutingPolicy
type RoutingPolicyStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:RoutingPolicys=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// RoutingPolicy defines the Schema for the RoutingPolicy API
type RoutingPolicy struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   RoutingPolicySpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status RoutingPolicyStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// RoutingPolicyList contains a list of RoutingPolicys
// +k8s:deepcopy-gen:RoutingPolicys=k8s.io/apimachinery/pkg/runtime.Object
type RoutingPolicyList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []RoutingPolicy `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// RoutingPolicy type metadata.
var (
	RoutingPolicyKind = reflect.TypeOf(RoutingPolicy{}).Name()
)
