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

// InterfaceSpec defines the desired state of Interface
type InterfaceSpec struct {
	kuididv1alpha1.PartitionEndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// Ethernet defines the ethernet properties of the interface
	Ethernet *InterfaceSpecEthernet `json:"ethernet,omitempty" protobuf:"bytes,2,opt,name=ethernet"`
	// VLANTagging defines if the interface is configured for VLAN tagging
	VLANTagging *bool `json:"vlanTagging,omitempty" protobuf:"bytes,3,opt,name=vlanTagging"`
	// MTU defines the max transmission unit size in octets for the physical interface.  If this is not set, the mtu is
	// set to the operational default -- e.g., 1514 bytes on an Ethernet interface.";
	// +kubebuilder:default:=1514
	MTU uint32 `json:"mtu,omitempty" protobuf:"bytes,4,opt,name=mtu"`

	//TBD
	// Loopback 
	// HoldUp - msec
	// HoldDown - msec
}

type InterfaceSpecEthernet struct {
	// Speed defines the interface speed of the interface
	Speed string `json:"speed,omitempty" protobuf:"bytes,1,opt,name=speed"`
	// L2CPTransparancy defines if the interface is transparant for L2CP protocols
	//L2CPTransparancy bool `json:"l2cpTransparancy,omitempty" protobuf:"bytes,2,opt,name=l2cpTransparancy"`
}

// InterfaceStatus defines the observed state of Interface
type InterfaceStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}
// Interface defines the Schema for the Interface API
type Interface struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   InterfaceSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status InterfaceStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// InterfaceList contains a list of Interfaces
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
type InterfaceList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []Interface `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// Interface type metadata.
var (
	InterfaceKind = reflect.TypeOf(Interface{}).Name()
)
