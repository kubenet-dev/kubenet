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

// TunnelTunnelInterfaceSpec defines the desired state of TunnelInterface
type TunnelInterfaceSpec struct {
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionNodeID"`
}

type TunnelInterfaceSpecEthernet struct {
	// Speed defines the TunnelInterface speed of the TunnelInterface
	Speed string `json:"speed,omitempty" protobuf:"bytes,1,opt,name=speed"`
	// L2CPTransparancy defines if the TunnelInterface is transparant for L2CP protocols
	//L2CPTransparancy bool `json:"l2cpTransparancy,omitempty" protobuf:"bytes,2,opt,name=l2cpTransparancy"`
}

// TunnelInterfaceStatus defines the observed state of TunnelInterface
type TunnelInterfaceStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:TunnelInterfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}
// TunnelInterface defines the Schema for the TunnelInterface API
type TunnelInterface struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   TunnelInterfaceSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status TunnelInterfaceStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// TunnelInterfaceList contains a list of TunnelInterfaces
// +k8s:deepcopy-gen:TunnelInterfaces=k8s.io/apimachinery/pkg/runtime.Object
type TunnelInterfaceList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []TunnelInterface `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// TunnelInterface type metadata.
var (
	TunnelInterfaceKind = reflect.TypeOf(TunnelInterface{}).Name()
)
