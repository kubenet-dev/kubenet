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
	corenetworkv1alpha1 "github.com/kubenet-dev/kubenet/apis/network/core/v1alpha1"
	commonv1alpha1 "github.com/kuidio/kuid/apis/common/v1alpha1"
	infrav1alpha1 "github.com/kuidio/kuid/apis/infra/v1alpha1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// TopologySpec defines the desired state of Topology
type TopologySpec struct {
	// Defaults define the node defaults
	Defaults *TopologyNode `json:"defaults,omitempty" protobuf:"bytes,1,opt,name=defaults"`
	// Nodes define the nodes belonging to the topology
	Nodes []*TopologyNode `json:"nodes,omitempty" protobuf:"bytes,2,rep,name=nodes"`
	// Links define the links interconnecting the nodes in the topology
	Links []*TopologyLink `json:"links,omitempty" protobuf:"bytes,3,rep,name=links"`
}

type TopologyNode struct {
	//Node defines the node name the resource belongs to.
	// Ignored when used in the default section
	Name *string `json:"name,omitempty" protobuf:"bytes,1,opt,name=name"`
	// Region defines the region this resource belongs to
	Region *string `json:"region,omitempty" protobuf:"bytes,2,opt,name=region"`
	// Site defines the site this resource belongs to
	Site *string `json:"site,omitempty" protobuf:"bytes,3,opt,name=site"`
	// Rack defines the rack in which the node is deployed
	// +optional
	Rack *string `json:"rack,omitempty" protobuf:"bytes,4,opt,name=rack"`
	// relative position in the rack
	// +optional
	Position *string `json:"position,omitempty" protobuf:"bytes,5,opt,name=position"`
	// UserDefinedLabels define metadata to the resource.
	// defined in the spec to distingiush metadata labels from user defined labels
	commonv1alpha1.UserDefinedLabels `json:",inline" protobuf:"bytes,6,opt,name=userDefinedLabels"`
	// Location defines the location information where this resource is located
	// in lon/lat coordinates
	// +optional
	Location *infrav1alpha1.Location `json:"location,omitempty" protobuf:"bytes,7,opt,name=location"`
	// Provider defines the provider implementing this resource.
	Provider *string `json:"provider,omitempty" protobuf:"bytes,8,opt,name=provider"`
	// PlatformType define the type of platform implementing the nodespec
	PlatformType *string `json:"platformType,omitempty" protobuf:"bytes,9,opt,name=platformType"`
}

type TopologyLink struct {
	// Endpoints define the 2 endpoint identifiers of the link
	// +kubebuilder:validation:MinItems:=2
	// +kubebuilder:validation:MaxItems:=2
	// +listType:=atomic
	Endpoints []TopologyEndpoint `json:"endpoints" protobuf:"bytes,1,rep,name=endpoints"`
	// BFD defines the BFD parameters for the link
	BFD *corenetworkv1alpha1.BFDLinkParameters `json:"bfd,omitempty" protobuf:"bytes,2,opt,name=bfd"`
	// BGP defines the BGP parameters for the link
	BGP *corenetworkv1alpha1.BGPLinkParameters `json:"bgp,omitempty" protobuf:"bytes,3,opt,name=bgp"`
	// OSPF defines the OSPF parameters for the link
	OSPF *corenetworkv1alpha1.OSPFLinkParameters `json:"ospf,omitempty" protobuf:"bytes,4,opt,name=ospf"`
	// ISIS defines the OSPF parameters for the link
	ISIS *corenetworkv1alpha1.ISISLinkParameters `json:"isis,omitempty" protobuf:"bytes,5,opt,name=isis"`
}

// TopologyEndpoint define the topology endpoint of the node
type TopologyEndpoint struct {
	// ModuleBay defines the moduleBay reference id
	Node string `json:"node" protobuf:"bytes,1,opt,name=node"`
	// ModuleBay defines the moduleBay reference id
	ModuleBay *int `json:"moduleBay,omitempty" protobuf:"bytes,2,opt,name=moduleBay"`
	// Module defines the module reference id
	Module *int `json:"module,omitempty" protobuf:"bytes,3,opt,name=module"`
	// Port defines the id of the port
	Port int `json:"port" protobuf:"bytes,4,opt,name=port"`
	// Adaptor defines the adaptor used in the port, like an sfp, qsfp
	Adaptor string `json:"adaptor" protobuf:"bytes,5,opt,name=adaptor"`
	// Endpoint defines the name of the endpoint
	Endpoint int `json:"endpoint" protobuf:"bytes,6,opt,name=endpoint"`
}

// TopologyStatus defines the observed state of Topology
type TopologyStatus struct {
	// ConditionedStatus provides the status of the Readiness using conditions
	// if the condition is true the other attributes in the status are meaningful
	condv1alpha1.ConditionedStatus `json:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:Topologys=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}

// Topology defines the Schema for the Topology API
type Topology struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   TopologySpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status TopologyStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// TopologyList contains a list of Topologys
// +k8s:deepcopy-gen:Topologys=k8s.io/apimachinery/pkg/runtime.Object
type TopologyList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []Topology `json:"items" protobuf:"bytes,2,rep,name=items"`
}

// Topology type metadata.
var (
	TopologyKind = reflect.TypeOf(Topology{}).Name()
)
