module github.com/vmware-tanzu/cartographer-conventions/samples/dumper-server

go 1.19

replace github.com/vmware-tanzu/cartographer-conventions/webhook => ../../webhook

require (
	github.com/go-logr/logr v1.2.3
	github.com/go-logr/zapr v1.2.3
	github.com/vmware-tanzu/cartographer-conventions/webhook v0.2.0
	go.uber.org/zap v1.23.0
	sigs.k8s.io/yaml v1.3.0
)

require (
	github.com/CycloneDX/cyclonedx-go v0.6.0 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/google/go-containerregistry v0.12.0 // indirect
	github.com/google/gofuzz v1.2.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/rogpeppe/go-internal v1.6.1 // indirect
	go.uber.org/atomic v1.7.0 // indirect
	go.uber.org/multierr v1.6.0 // indirect
	golang.org/x/net v0.1.0 // indirect
	golang.org/x/text v0.4.0 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	k8s.io/api v0.25.3 // indirect
	k8s.io/apimachinery v0.25.3 // indirect
	k8s.io/klog/v2 v2.70.1 // indirect
	k8s.io/utils v0.0.0-20220728103510-ee6ede2d64ed // indirect
	sigs.k8s.io/controller-runtime v0.13.1 // indirect
	sigs.k8s.io/json v0.0.0-20220713155537-f223a00ba0e2 // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.2.3 // indirect
)
