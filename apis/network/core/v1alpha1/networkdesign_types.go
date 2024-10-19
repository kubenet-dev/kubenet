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

	//infrabev1alpha1 "github.com/kuidio/kuid/apis/backend/infra/v1alpha1"
	//ipambev1alpha1 "github.com/kuidio/kuid/apis/backend/ipam/v1alpha1"
	condv1alpha1 "github.com/kform-dev/choreo/apis/condition/v1alpha1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	ipambev1alpha1 "github.com/kform-dev/choreo/apis/kuid/backend/ipam/v1alpha1"
)


// NetworkDesignSpec defines the desired state of NetworkDesign
type NetworkDesignSpec struct {
	// Interfaces define the interface parameters of the network design
	Interfaces *NetworkDesignInterfaces `json:"interfaces,omitempty" yaml:"interfaces,omitempty" protobuf:"bytes,2,rep,name=interfaces"`
	// Protocols define the network wide protocol parameters
	Protocols *NetworkDesignProtocols `json:"protocols,omitempty" yaml:"protocols,,omitempty" protobuf:"bytes,4,opt,name=protocols"`
	// Encapsultation define the encapsulation parameters
	Encapsultation *NetworkDesignEncapsulation `json:"encapsulation,omitempty" yaml:"encapsulation,,omitempty" protobuf:"bytes,5,opt,name=encapsulation"`
}

type NetworkDesignInterfaces struct {
	Loopback *NetworkDesignInterfacesLoopback `json:"loopback,omitempty" yaml:"loopback,omitempty" protobuf:"bytes,1,opt,name=loopback"`
	Underlay *NetworkDesignInterfacesUnderlay `json:"underlay,omitempty" yaml:"underlay,omitempty" protobuf:"bytes,2,opt,name=underlay"`
}

type NetworkDesignInterfacesLoopback struct {
	NetworkDesignInterfaceParameters `json:",inline" yaml:",inline" protobuf:"bytes,1,opt,name=parameters"`
}

type NetworkDesignInterfacesUnderlay struct {
	NetworkDesignInterfaceParameters `json:",inline" yaml:",inline" protobuf:"bytes,1,opt,name=parameters"`
	// VLANTagging defines if VLAN tagging should be used or not
	VLANTagging bool `json:"vlanTagging,omitempty" yaml:"vlanTagging,,omitempty" protobuf:"bytes,2,opt,name=vlanTagging"`
	// BFD defines the bfd parameters on the interface
	BFD *BFDLinkParameters `json:"bfd,omitempty" yaml:"bfd,,omitempty" protobuf:"bytes,3,opt,name=bfd"`
}

type NetworkDesignInterfaceParameters struct {
	// Prefixes defines the prefixes belonging to this network config
	// prefixLength would be indicated by a label
	Prefixes []ipambev1alpha1.Prefix `json:"prefixes,omitempty" yaml:"prefixes,omitempty" protobuf:"bytes,1,rep,name=prefixes"`
	// Addressing defines the addressing used in this network
	// +kubebuilder:validation:Enum=dualstack;ipv4only;ipv6only;ipv4unnumbered;ipv6unnumbered
	// +kubebuilder:default=dualstack
	Addressing Addressing `json:"addressing,omitempty" yaml:"addressing,omitempty" protobuf:"bytes,2,opt,name=addressing"`
	// BFD defines if BFD is enabled on the interfaces or not
	//BFD *infrabev1alpha1.BFDLinkParameters `json:"bfd,omitempty" yaml:"bfd,,omitempty" protobuf:"bytes,3,opt,name=bfd"`
}

type NetworkDesignEncapsulation struct {
	VXLAN *NetworkDesignEncapsulationVXLAN `json:"vxlan,omitempty" yaml:"vxlan,omitempty" protobuf:"bytes,1,opt,name=vxlan"`
	MPLS  *NetworkDesignEncapsulationMPLS  `json:"mpls,omitempty" yaml:"mpls,omitempty" protobuf:"bytes,2,opt,name=mpls"`
	SRV6  *NetworkDesignEncapsulationSRv6  `json:"srv6,omitempty" yaml:"srv6,omitempty" protobuf:"bytes,3,opt,name=srv6"`
}

type NetworkDesignEncapsulationVXLAN struct {
}

type NetworkDesignEncapsulationMPLS struct {
	LDP  *NetworkDesignEncapsulationMPLSLDP  `json:"ldp,omitempty" yaml:"ldp,omitempty" protobuf:"bytes,1,opt,name=ldp"`
	SR   *NetworkDesignEncapsulationMPLSSR   `json:"sr,omitempty" yaml:"sr,omitempty" protobuf:"bytes,2,opt,name=sr"`
	RSVP *NetworkDesignEncapsulationMPLSRSVP `json:"rsvp,omitempty" yaml:"rsvp,omitempty" protobuf:"bytes,3,opt,name=rsvp"`
}

type NetworkDesignEncapsulationMPLSLDP struct {
}

type NetworkDesignEncapsulationMPLSSR struct {
}

type NetworkDesignEncapsulationMPLSRSVP struct {
}
type NetworkDesignEncapsulationSRv6 struct {
	MicroSID *NetworkDesignEncapsulationMPLSSRv6MicroSID `json:"ldp,omitempty" yaml:"ldp,omitempty" protobuf:"bytes,1,opt,name=ldp"`
}

type NetworkDesignEncapsulationMPLSSRv6MicroSID struct {
}

type NetworkDesignProtocols struct {
	OSPF                *NetworkDesignProtocolsOSPF                `json:"ospf,omitempty" yaml:"ospf,omitempty" protobuf:"bytes,1,opt,name=ospf"`
	ISIS                *NetworkDesignProtocolsISIS                `json:"isis,omitempty" yaml:"isis,omitempty" protobuf:"bytes,2,opt,name=isis"`
	IBGP                *NetworkDesignProtocolsIBGP                `json:"ibgp,omitempty" yaml:"ibgp,omitempty" protobuf:"bytes,3,opt,name=ibgp"`
	EBGP                *NetworkDesignProtocolsEBGP                `json:"ebgp,omitempty" yaml:"ebgp,omitempty" protobuf:"bytes,4,opt,name=ebgp"`
	BGPEVPN             *NetworkDesignProtocolsBGPEVPN             `json:"bgpEVPN,omitempty" yaml:"bgpEVPN,omitempty" protobuf:"bytes,5,opt,name=bgpEVPN"`
	BGPVPNv4            *NetworkDesignProtocolsBGPVPNv4            `json:"bgpVPNv4,omitempty" yaml:"bgpVPNv4,omitempty" protobuf:"bytes,6,opt,name=bgpVPNv4"`
	BGPVPNv6            *NetworkDesignProtocolsBGPVPNv6            `json:"bgpVPNv6,omitempty" yaml:"bgpVPNv6,omitempty" protobuf:"bytes,7,opt,name=bgpVPNv6"`
	BGPRouteTarget      *NetworkDesignProtocolsBGPRouteTarget      `json:"bgpRouteTarget,omitempty" yaml:"bgpRouteTarget,omitempty" protobuf:"bytes,8,opt,name=bgpRouteTarget"`
	BGPLabeledUnicastv4 *NetworkDesignProtocolsBGPLabeledUnicastv4 `json:"bgpLabeledUnicastv4,omitempty" yaml:"bgpLabeledUnicastv4,omitempty" protobuf:"bytes,9,opt,name=bgpLabeledUnicastv4"`
	BGPLabeledUnicastv6 *NetworkDesignProtocolsBGPLabeledUnicastv6 `json:"bgpLabeledUnicastv6,omitempty" yaml:"bgpLabeledUnicastv6,omitempty" protobuf:"bytes,10,opt,name=bgpLabeledUnicastv6"`
}

type NetworkDesignProtocolsOSPF struct {
	// Instance defines the name of the OSPF instance
	Instance *string `json:"instance,omitempty" yaml:"instance,omitempty" protobuf:"bytes,1,opt,name=instance"`
	// Version defines the Version used for ospf
	// +kubebuilder:validation:Enum=v2;v3
	// +kubebuilder:default=v2
	Version OSPFVersion `json:"version" yaml:"version" protobuf:"bytes,2,opt,name=version"`
	// Area defines the default area used if not further refined on the interface.
	Area string `json:"area" yaml:"area" protobuf:"bytes,3,opt,name=area"`
	// MaxECMPPaths defines the maximum ecmp paths used in OSPF
	// +kubebuilder:validation:Maximum=64
	// +kubebuilder:validation:Minimum=1
	// +kubebuilder:default=1
	MaxECMPPaths *uint32 `json:"maxECMPPaths,omitempty" yaml:"maxECMPPaths,omitempty" protobuf:"bytes,4,opt,name=maxECMPPaths"`
	// BFD defines if BFD is enabled globally on OSPF
	BFD bool `json:"bfd,omitempty" yaml:"bfd,,omitempty" protobuf:"bytes,3,opt,name=bfd"`
}
type NetworkDesignProtocolsISIS struct {
	// Instance defines the name of the ISIS instance
	Instance *string `json:"instance,omitempty" yaml:"instance,omitempty" protobuf:"bytes,1,opt,name=instance"`
	// LevelCapability defines the level capability of the ISIS in the topology
	// +kubebuilder:validation:Enum=L2;L2;L1L2
	// +kubebuilder:default=L2
	Level ISISLevel `json:"level,omitempty" yaml:"level,omitempty" protobuf:"bytes,2,opt,name=level"`
	// Areas defines the ISIS areas
	Areas []string `json:"areas" yaml:"areas" protobuf:"bytes,3,rep,name=areas"`
	// MaxECMPPaths defines the maximum ecmp paths used in OSPF
	// +kubebuilder:validation:Maximum=64
	// +kubebuilder:validation:Minimum=1
	// +kubebuilder:default=1
	MaxECMPPaths *uint32 `json:"maxECMPPaths,omitempty" yaml:"maxECMPPaths,omitempty" protobuf:"bytes,4,opt,name=maxECMPPaths"`
	// BFD defines if BFD is enabled globally on ISIS
	BFD bool `json:"bfd,omitempty" yaml:"bfd,,omitempty" protobuf:"bytes,3,opt,name=bfd"`
}

type NetworkDesignProtocolsIBGP struct {
	AS              *uint32  `json:"as,omitempty" yaml:"as,omitempty" protobuf:"bytes,1,opt,name=as"`
	LocalAS         bool     `json:"localAS,omitempty" yaml:"localAS,omitempty" protobuf:"bytes,2,opt,name=localAS"`
	RouteReflectors []string `json:"routeReflectors,omitempty" yaml:"routeReflectors,omitempty" protobuf:"bytes,3,opt,name=routeReflectors"`
}

type NetworkDesignProtocolsEBGP struct {
	ASPool *string `json:"asPool,omitempty" yaml:"asPool,omitempty" protobuf:"bytes,3,opt,name=asPool"`
	// BFD defines if BFD is enabled globally on EBGP
	BFD bool `json:"bfd,omitempty" yaml:"bfd,,omitempty" protobuf:"bytes,3,opt,name=bfd"`
}

type NetworkDesignProtocolsBGPEVPN struct {
}

type NetworkDesignProtocolsBGPVPNv4 struct {
}

type NetworkDesignProtocolsBGPVPNv6 struct {
}

type NetworkDesignProtocolsBGPRouteTarget struct {
}

type NetworkDesignProtocolsBGPLabeledUnicastv4 struct{}

type NetworkDesignProtocolsBGPLabeledUnicastv6 struct{}

// NetworkDesignStatus defines the observed state of NetworkDesign
type NetworkDesignStatus struct {
	// ConditionedStatus provides the status of the NetworkDesign using conditions
	// - a ready condition indicates the overall status of the resource
	condv1alpha1.ConditionedStatus `json:",inline" yaml:",inline" protobuf:"bytes,1,opt,name=conditionedStatus"`
}

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="READY",type="string",JSONPath=".status.conditions[?(@.type=='Ready')].status"
// +kubebuilder:resource:categories={kubenet}
// NetworkDesign is the NetworkDesign for the NetworkDesign API
// +k8s:openapi-gen=true
type NetworkDesign struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`

	Spec   NetworkDesignSpec   `json:"spec,omitempty" protobuf:"bytes,2,opt,name=spec"`
	Status NetworkDesignStatus `json:"status,omitempty" protobuf:"bytes,3,opt,name=status"`
}

// +kubebuilder:object:root=true
// NetworkDesignClabList contains a list of NetworkDesignClabs
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
type NetworkDesignList struct {
	metav1.TypeMeta `json:",inline" yaml:",inline"`
	metav1.ListMeta `json:"metadata,omitempty" yaml:"metadata,omitempty" protobuf:"bytes,1,opt,name=metadata"`
	Items           []NetworkDesign `json:"items" yaml:"items" protobuf:"bytes,2,rep,name=items"`
}

var (
	NetworkDesignKind = reflect.TypeOf(NetworkDesign{}).Name()
)
