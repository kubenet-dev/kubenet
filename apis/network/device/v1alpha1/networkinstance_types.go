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

// NetworkInstanceSpec defines the desired state of NetworkInstance
type NetworkInstanceSpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the NetworkInstance
	ID uint32 `json:"id" protobuf:"bytes,2,opt,name=id"`
	// Name defines the name of the NetworkInstance
	Name string `json:"name" protobuf:"bytes,3,opt,name=name"`
	// Type defines the network instance type
	// +kubebuilder:validation:Enum=default;mac-vrf;ip-vrf;
	Type corenetworkv1alpha1.NetworkInstanceType `json:"type" protobuf:"bytes,4,opt,name=type"`
	// Interfaces defines interfaces belonging to the network instance
	// +listType=map
	// +listMapKey=partition
    // +listMapKey=region
	// +listMapKey=site
	// +listMapKey=node
	// +listMapKey=port
	// +listMapKey=endpoint
	// +listMapKey=id
	Interfaces []*NetworkInstanceInterface `json:"interfaces,omitempty" protobuf:"bytes,5,rep,name=interfaces"`
	// VXLANInterface define the vxlan interface belonging to the network instance
	VXLANInterface *NetworkInstanceVXLANInterface `json:"vxlanInterface,omitempty" protobuf:"bytes,6,opt,name=vxlanInterface"`
}

type NetworkInstanceInterface struct {
	// PartitionEndpointID defines the kuid endpoint id
	kuididv1alpha1.PartitionEndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the subinterface
	ID uint32 `json:"id" protobuf:"bytes,2,opt,name=id"`
}

type NetworkInstanceVXLANInterface struct {
	// PartitionEndpointID defines the kuid endpoint id
	kuididv1alpha1.PartitionEndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the subinterface
	ID uint32 `json:"id" protobuf:"bytes,2,opt,name=id"`
}


// NetworkInstanceStatus defines the observed state of NetworkInstance
type NetworkInstanceStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:NetworkInstances=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// NetworkInstance defines the Schema for the NetworkInstance API
type NetworkInstance struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   NetworkInstanceSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status NetworkInstanceStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// NetworkInstanceList contains a list of NetworkInstances
// +k8s:deepcopy-gen:NetworkInstances=k8s.io/apimachinery/pkg/runtime.Object
type NetworkInstanceList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []NetworkInstance `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// NetworkInstance type metadata.
var (
	NetworkInstanceKind = reflect.TypeOf(NetworkInstance{}).Name()
)
