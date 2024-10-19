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

// PrefixSetSpec defines the desired state of PrefixSet
type PrefixSetSpec struct {
	// PartitionNodeID defines the kuid node ID
	kuididv1alpha1.PartitionNodeID `json:",inline" protobuf:"bytes,1,opt,name=partitionEndpointID"`
	// Name defines the name of the prefix set
	Name string `json:"name" protobuf:"bytes,2,opt,name=name"`
	// Statements defines the routing policy statements
	// +listType=map
	// +listMapKey=prefix
	Prefixes []*PrefixSetPrefix `json:"prefixes,omitempty" protobuf:"bytes,3,rep,name=prefixes"`
}

type PrefixSetPrefix struct {
	// Prefix defines the Prefix in the PrefixSet
	Prefix string `json:"prefix" protobuf:"bytes,1,opt,name=prefix"`
	// MaskLengthRange defines the mask lemgth ir range
	MaskLengthRange string `json:"maskLengthRange" protobuf:"bytes,2,opt,name=maskLengthRange"`
}

// PrefixSetStatus defines the observed state of PrefixSet
type PrefixSetStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:PrefixSets=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// PrefixSet defines the Schema for the PrefixSet API
type PrefixSet struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   PrefixSetSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status PrefixSetStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// PrefixSetList contains a list of PrefixSets
// +k8s:deepcopy-gen:PrefixSets=k8s.io/apimachinery/pkg/runtime.Object
type PrefixSetList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []PrefixSet `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// PrefixSet type metadata.
var (
	PrefixSetKind = reflect.TypeOf(PrefixSet{}).Name()
)
