# Troubleshooting

## Collecting logs from the controller
<a id="gathering-logs"></a>

Retrieve pod logs from the `cartographer-conventions-controller-manager` running in the `cartographer-conventions-system` namespace. 

  ```bash
  kubectl -n cartographer-conventions-system logs -l control-plane=controller-manager
  ```

  For example:

  ```bash
  ...
  {"level":"info","ts":1637073467.3334172,"logger":"controllers.PodIntent.PodIntent.ApplyConventions","msg":"applied convention","diff":"  interface{}(\n- \ts\"&PodTemplateSpec{ObjectMeta:{      0 0001-01-01 00:00:00 +0000 UTC <nil> <nil> map[app.kubernetes.io/component:run app.kubernetes.io/part-of:spring-petclinic-app-db carto.run/workload-name:spring-petclinic-app-db] map[developer.conventions/target-container\"...,\n+ \tv1.PodTemplateSpec{\n+ \t\tObjectMeta: v1.ObjectMeta{\n+ \t\t\tLabels: map[string]string{\n+ \t\t\t\t\"app.kubernetes.io/component\": \"run\",\n+ \t\t\t\t\"app.kubernetes.io/part-of\":   \"spring-petclinic-app-db\",\n+ \t\t\t\t\"carto.run/workload-name\":     \"spring-petclinic-app-db\",\n+ \t\t\t\t\"tanzu.app.live.view\":         \"true\",\n+ \t\t\t\t...\n+ \t\t\t},\n+ \t\t\tAnnotations: map[string]string{\"developer.conventions/target-containers\": \"workload\"},\n+ \t\t},\n+ \t\tSpec: v1.PodSpec{Containers: []v1.Container{{...}}, ServiceAccountName: \"default\"},\n+ \t},\n  )\n","convention":"appliveview-sample"}
  ...
  ```
  
## <a id="no-server-in-cluster"></a>No server in the cluster

### Symptoms

 + When a `PodIntent` is submitted, no `convention` is applied. (for all the symptom statements)

### Cause

When there are no `convention servers` ([ClusterPodConvention](reference/cluster-pod-convention.md)) deployed in the cluster or none of the existing convention servers applied any conventions, then the `PodIntent` is not being mutated.

### Solution

1. Deploy a `convention server` ([ClusterPodConvention](reference/cluster-pod-convention.md)) in the cluster.


## <a id="wrong-certificates-config"></a>Server with wrong certificates configured

### Symptoms
  
  + When a `PodIntent` is submitted, the `conventions` are not applied.
  + The `cartographer-conventions-controller` [logs](#gathering-logs) reports an error `failed to get CABundle` like this.
    ```json
    {"level":"error","ts":1638222343.6839523,"logger":"controllers.PodIntent.PodIntent.ResolveConventions","msg":"failed to get CABundle","ClusterPodConvention":"base-convention","error":"unable to find valid certificaterequests for certificate \"convention-template/webhook-certificate\"","stacktrace":"reflect.Value.Call\n\treflect/value.go:339\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).sync\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:287\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:276\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.Sequence.Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:815\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:146\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:120\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Reconcile\n\tsigs.k8s.io/controller-runtime@v0.10.3/pkg/internal/controller/controller.go:114\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).reconcileHandler\n\tsigs.k8s.io/controller-runtime@v0.10.3/pkg/internal/controller/controller.go:311\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).processNextWorkItem\n\tsigs.k8s.io/controller-runtime@v0.10.3/pkg/internal/controller/controller.go:266\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Start.func2.2\n\tsigs.k8s.io/controller-runtime@v0.10.3/pkg/internal/controller/controller.go:227"}
    ```
### Cause

`convention server` ([ClusterPodConvention](reference/cluster-pod-convention.md)) is configured with wrong certificates. The `cartographer-conventions-controller` cannot figure out the *CA Bundle* to perform the request to the *server*.

### Solution

1. Ensure that the `convention server` ([ClusterPodConvention](reference/cluster-pod-convention.md)) is configured with the correct certificates. To do so, verify the value of annotation `conventions.carto.run/inject-ca-from` which needs to be set to the used *Certificate*, Do not set annotation `conventions.carto.run/inject-ca-from` , if no certificate is used.

## <a id="server-fails"></a>Server fails when processing a request

### Syntoms

  + When a `PodIntent` is submitted, the `convention` is not applied.
  + The `cartographer-conventions-controller` [logs](#gathering-logs) reports `failed to apply convention` error like this.

      ```json
      {"level":"error","ts":1638205387.8813763,"logger":"controllers.PodIntent.PodIntent.ApplyConventions","msg":"failed to apply convention","Convention":{"Name":"base-convention","Selectors":null,"Priority":"Normal","ClientConfig":{"service":{"namespace":"convention-template","name":"webhook","port":443},"caBundle":"..."}},"error":"Post \"https://webhook.convention-template.svc:443/?timeout=30s\": EOF","stacktrace":"reflect.Value.call\n\treflect/value.go:543\nreflect.Value.Call\n\treflect/value.go:339\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).sync\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:287\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:276\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.Sequence.Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:815\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:146\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:120\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Reconcile\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:114\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).reconcileHandler\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:311\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).processNextWorkItem\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:266\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Start.func2.2\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:227"}
      ```
  + When a `PodIntent` status message is updated with `failed to apply convention from source base-convention: Post "https://webhook.convention-template.svc:443/?timeout=30s": EOF`.
### Cause

An unmanaged error occurs in the `convention server` when processing a request.

### Solution

1. Check the `convention server` logs to identify the cause of the error
   1. Use the following commad to retrieve the `convention server` logs:

      ```bash
      kubectl -n convention-template logs deployment/webhook
      ```

      Where:
         + The convention server was deployed as a `Deployment`
         + `webhook`: is the name of the convention server `Deployment`.
         + `convention-template` is the namespace where the convention server is deployed.

2. Identify the error and deploy a `convention server` fixed version.
   + Be aware that the new deployment won't be applied to the existing `PodIntent`s, only for new ones.
   + To apply new deployment to exiting `PodIntent` it needs to be updated so the reconcilier applies if criteria are match. 

## <a id="server-not-secure"></a>Connection refused due to not secured connection

### Symptoms
  + When a `PodIntent` is submitted, the `convention` is not applied.
  + The `cartographer-conventions-controller` [logs](#gathering-logs) reports a connection refused error like the following.
  
    ```json
    {"level":"error","ts":1638202791.5734537,"logger":"controllers.PodIntent.PodIntent.ApplyConventions","msg":"failed to apply convention","Convention":{"Name":"base-convention","Selectors":null,"Priority":"Normal","ClientConfig":{"service":{"namespace":"convention-template","name":"webhook","port":443},"caBundle":"..."}},"error":"Post \"https://webhook.convention-template.svc:443/?timeout=30s\": dial tcp 10.56.13.206:443: connect: connection refused","stacktrace":"reflect.Value.call\n\treflect/value.go:543\nreflect.Value.Call\n\treflect/value.go:339\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).sync\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:287\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*SyncReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:276\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.Sequence.Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:815\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:146\ngithub.com/vmware-labs/reconciler-runtime/reconcilers.(*ParentReconciler).Reconcile\n\tgithub.com/vmware-labs/reconciler-runtime@v0.3.0/reconcilers/reconcilers.go:120\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Reconcile\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:114\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).reconcileHandler\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:311\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).processNextWorkItem\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:266\nsigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller).Start.func2.2\n\tsigs.k8s.io/controller-runtime@v0.10.0/pkg/internal/controller/controller.go:227"}
    ```
+ The `convention server` fails to start due to `server gave HTTP response to HTTPS client`
  + When checking the `convention server` events by running the following command:

    ```bash
    kubectl -n convention-template describe pod webhook-594d75d69b-4w4s8
    ```

    Where:
    + The convention server was deployed as a `Deployment`
    + `webhook-594d75d69b-4w4s8` : is the name of the `convention server` pod.
    + `convention-template` is the namespace where the convention server is deployed.

    For example:

    ```bash
    Name:         webhook-594d75d69b-4w4s8
    Namespace:    convention-template
    ...
    Containers:
      webhook:
    ...
    Events:
    Type     Reason     Age                   From               Message
    ----     ------     ----                  ----               -------
    Normal   Scheduled  14m                   default-scheduler  Successfully assigned convention-template/webhook-594d75d69b-4w4s8 to pool
    Normal   Pulling    14m                   kubelet            Pulling image "awesome-repo/awesome-user/awesome-convention-..."
    Normal   Pulled     14m                   kubelet            Successfully pulled image "awesome-repo/awesome-user/awesome-convention..." in 1.06032653s
    Normal   Created    13m (x2 over 14m)     kubelet            Created container webhook
    Normal   Started    13m (x2 over 14m)     kubelet            Started container webhook
    Warning  Unhealthy  13m (x9 over 14m)     kubelet            Readiness probe failed: Get "https://10.52.2.74:8443/healthz": http: server gave HTTP response to HTTPS client
    Warning  Unhealthy  13m (x6 over 14m)     kubelet            Liveness probe failed: Get "https://10.52.2.74:8443/healthz": http: server gave HTTP response to HTTPS client
    Normal   Killing    13m (x2 over 13m)     kubelet            Container webhook failed liveness probe, will be restarted
    Normal   Pulled     9m13s (x6 over 13m)   kubelet            Container image "awesome-repo/awesome-user/awesome-convention" already present on machine
    Warning  BackOff    4m22s (x32 over 11m)  kubelet            Back-off restarting failed container
    ```

### Cause

When a `convention server` is provided without using TSL but the `Deployment` is configured to use TSL, kubernetes will fail to deploy the `Pod` because of the `liveness probe`.

### Solution

1. Deploy a `convention server` with TLS enabled.
2. Create `ClusterPodConvention` resource for the convention server with annotation `conventions.carto.run/inject-ca-from` as a pointer to the deployed *Certificate* resource