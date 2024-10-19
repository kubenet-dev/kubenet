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

// TunnelTunnelSubInterfaceSpec defines the desired state of TunnelSubInterface
type TunnelSubInterfaceSpec struct {
	kuididv1alpha1.EndpointID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// ID defines the id of the tunnel subinterface
	ID uint32 `json:"id" yaml:"id" protobuf:"bytes,2,opt,name=id"`
	// Type defines the subinterface type
	// +kubebuilder:validation:Enum=routed;bridged;
	Type corenetworkv1alpha1.SubInterfaceType `json:"type" protobuf:"bytes,3,opt,name=type"`
}

// TunnelSubInterfaceStatus defines the observed state of TunnelSubInterface
type TunnelSubInterfaceStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:TunnelSubInterfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}
// TunnelSubInterface defines the Schema for the TunnelSubInterface API
type TunnelSubInterface struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   TunnelSubInterfaceSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status TunnelSubInterfaceStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// TunnelSubInterfaceList contains a list of TunnelSubInterfaces
// +k8s:deepcopy-gen:TunnelSubInterfaces=k8s.io/apimachinery/pkg/runtime.Object
type TunnelSubInterfaceList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []TunnelSubInterface `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// TunnelSubInterface type metadata.
var (
	TunnelSubInterfaceKind = reflect.TypeOf(TunnelSubInterface{}).Name()
)
