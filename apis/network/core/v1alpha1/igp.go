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

type NetworkType string

const (
	NetworkTypeP2P       NetworkType = "pointToPoint"
	NetworkTypeBroadcast NetworkType = "broadcast"
	NetworkTypeUnknown   NetworkType = "unknown"
)

type ISISLevel string

const (
	ISISLevelL1      ISISLevel = "L1"
	ISISLevelL2      ISISLevel = "L2"
	ISISLevelL1L2    ISISLevel = "L1L2"
	ISISLevelUnknown ISISLevel = "unknown"
)

type ISISMetricStyle string

const (
	ISISMetricStyleNarrow ISISMetricStyle = "narrow"
	ISISMetricStyleWide   ISISMetricStyle = "wide"
)

type OSPFVersion string

const (
	OSPFVersionV2      OSPFVersion = "v2"
	OSPFVersionV3      OSPFVersion = "v3"
	OSPFVersionUnknown OSPFVersion = "unknown"
)

type IGPLinkParameters struct {
	// Type defines the type of network
	//+kubebuilder:validation:Enum=`pointToPoint`;`broadcast`;
	// +kubebuilder:default=pointToPoint
	// +optional
	NetworkType *NetworkType `json:"networkType,omitempty" yaml:"networkType,,omitempty" protobuf:"bytes,1,opt,name=networkType"`
	// Passive defines if this interface is passive
	// +optional
	Passive *bool `json:"passive,omitempty" yaml:"passive,omitempty" protobuf:"bytes,2,opt,name=passive"`
	// BFD defines if BFD is enabled for the IGP on this interface
	// +kubebuilder:default:=true
	// +optional
	BFD *bool `json:"bfd,omitempty" yaml:"bfd,omitempty" protobuf:"bytes,3,opt,name=bfd"`
	// Metric defines the interface metric associated with the native routing topology
	// +optional
	Metric *uint32 `json:"metric,omitempty" yaml:"metric,omitempty" protobuf:"bytes,4,opt,name=metric"`
}

type OSPFLinkParameters struct {
	// Generic IGP Link Parameters
	// +optional
	IGPLinkParameters `json:",inline" yaml:",inline" protobuf:"bytes,1,opt,name=igpLinkParameters"`
	// Defines the OSPF area the link is assocaited with
	// +optional
	Area *string `json:"area,omitempty" yaml:"area,omitempty" protobuf:"bytes,2,opt,name=area"`
}

type ISISLinkParameters struct {
	// Generic IGP Link Parameters
	// +optional
	IGPLinkParameters `json:",inline" yaml:",inline" protobuf:"bytes,1,opt,name=igpLinkParameters"`
	// Defines the ISIS level the link is assocaited with
	// +optional
	Level *ISISLevel `json:"area,omitempty" yaml:"area,omitempty" protobuf:"bytes,2,opt,name=area"`
}
