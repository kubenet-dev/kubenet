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

type BFDLinkParameters struct {
	// Disabled defines if bfd is disabled or not
	// +optional
	Enabled *bool `json:"enabled,omitempty" yaml:"enabled,,omitempty" protobuf:"bytes,1,opt,name=enabled"`
	// MinTx defines the desired minimal interval for sending BFD packets, in msec.
	// +optional
	MinTx *uint32 `json:"minTx,omitempty" yaml:"minTx,,omitempty" protobuf:"bytes,2,opt,name=minTx"`
	// MinTx defines the required minimal interval for receiving BFD packets, in msec.
	// +optional
	MinRx *uint32 `json:"minRx,omitempty" yaml:"minRx,,omitempty" protobuf:"bytes,3,opt,name=minRx"`
	// MinEchoRx defines the echo function timer, in msec.
	// +optional
	MinEchoRx *uint32 `json:"minEchoRx,omitempty" yaml:"minEchoRx,,omitempty" protobuf:"bytes,4,opt,name=minEchoRx"`
	// Multiplier defines the number of missed packets before the session is considered down
	// +optional
	Multiplier *uint32 `json:"multiplier,omitempty" yaml:"multiplier,,omitempty" protobuf:"bytes,5,opt,name=multiplier"`
	// TTL defines the time to live on the outgoing BFD packet
	// +kubebuilder:validation:Maximum:=255
	// +kubebuilder:validation:Minimum:=2
	// +optional
	TTL *uint32 `json:"ttl,omitempty" yaml:"ttl,,omitempty" protobuf:"bytes,6,opt,name=ttl"`
}
