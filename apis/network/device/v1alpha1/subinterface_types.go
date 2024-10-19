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

// SubInterfaceSpec defines the desired state of SubInterface
type SubInterfaceSpec struct {
	kuididv1alpha1.PartitionEndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the subinterface
	ID uint32 `json:"id" protobuf:"bytes,2,opt,name=id"`
	// Enabled defines if bfd is enabled or not
	Enabled *bool `json:"enabled,omitempty" protobuf:"bytes,3,opt,name=enabled"`
	// Type defines the subinterface type
	// +kubebuilder:validation:Enum=routed;bridged;
	Type corenetworkv1alpha1.SubInterfaceType `json:"type" protobuf:"bytes,4,opt,name=type"`
	// IPv4 defines the ipv4 parameters for the subinterface
	IPv4 *SubInterfaceIPv4 `json:"ipv4,omitempty" protobuf:"bytes,5,opt,name=ipv4"`
	// IPv6 defines the ipv6 parameters for the subinterface
	IPv6 *SubInterfaceIPv6 `json:"ipv6,omitempty" protobuf:"bytes,6,opt,name=ipv6"`
	// BFD defines the BFD parameters for the subinterface
	BFD *corenetworkv1alpha1.BFDLinkParameters `json:"bfd,omitempty" protobuf:"bytes,7,opt,name=bfd"`
	// Peer defines the peer subinterface parameters of the subinterface
	Peer *SubInterfacePeer `json:"peer,omitempty" protobuf:"bytes,8,opt,name=peer"`
}

type SubInterfaceIPv4 struct {
	// Addresses define the addresses within the subinterface address family
	Addresses []string `json:"addresses,omitempty" yaml:"addresses,omitempty" protobuf:"bytes,1,opt,name=addresses"`
}

type SubInterfaceIPv6 struct {
	// Addresses define the addresses within the subinterface address family
	Addresses []string `json:"addresses,omitempty" yaml:"addresses,omitempty" protobuf:"bytes,1,opt,name=addresses"`
}

type SubInterfacePeer struct {

	// IPv4 defines the ipv4 parameters for the subinterface
	IPv4 *SubInterfaceIPv4 `json:"ipv4,omitempty" protobuf:"bytes,5,opt,name=ipv4"`
	// IPv6 defines the ipv6 parameters for the subinterface
	IPv6 *SubInterfaceIPv6 `json:"ipv6,omitempty" protobuf:"bytes,6,opt,name=ipv6"`
}

// SubInterfaceStatus defines the observed state of SubInterface
type SubInterfaceStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:SubInterfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// SubInterface defines the Schema for the SubInterface API
type SubInterface struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   SubInterfaceSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status SubInterfaceStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// SubInterfaceList contains a list of SubInterfaces
// +k8s:deepcopy-gen:SubInterfaces=k8s.io/apimachinery/pkg/runtime.Object
type SubInterfaceList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []SubInterface `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// SubInterface type metadata.
var (
	SubInterfaceKind = reflect.TypeOf(SubInterface{}).Name()
)
