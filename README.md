# managed-prometheus-exporter-initcontainer

This is designed to be an [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) to populate various files for later use in Prometheus exporter containers.

The operations are related to writing cluster ID, AWS region name, and AWS API credentials to various files.

## Background and Requirements

Various exporters need to make AWS API calls and while the [cloud-credential-operator](https://github.com/openshift/cloud-credential-operator) can provide the access and secret keys, the operator doesn't have any knowledge of the region in which the various AWS resources reside. In order to perform those API calls, that region ID must be provided. Additionally, some of those exporters need to know the cluster ID where it's running. Having the exporter code/containers determine the region and cluster ID is out of scope for them, and so an init container makes sense (determining the information at deploy-time is not feasible).

Luckily, the `Machine` object(s) from the `openshift-machine-api` namespace contain both the region ID and cluster ID.

There's a side effect of using an init container: We can transform the AWS credentials into a format the exporters can use more easily. The reasoning is that since there's already code running to write files out to disk, why not write one more file to disk and save lines of code in the exporter?

### Accessing Cluster Information

To get access to the cluster information we could change our main container to access this information, but those initialization tasks are best suited to init containers. To that end, the [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) for the Pod must be granted access to the aforementioned objects by [ClusterRole and RoleBinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/). A sample one follows:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-sa
  namespace: deployment-ns
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: access-machine-info-cr
rules:
- apiGroups: ["machine.openshift.io"]
  resources: ["machines"]
  verbs: ["get", "list"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: allow-deploy-access-to-machine-info
  namespace: openshift-machine-api
subjects:
- kind: ServiceAccount
  name: pod-sa
  namespace: deployment-ns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: access-machine-info-cr
```

### AWS Credentials

The [cloud-credential-operator](https://github.com/openshift/cloud-credential-operator) creates a Secret in the specified namespace that has two keys, `aws_secret_access_key` and `aws_access_key_id`, each for the purpose one would expect. Most consumers of those credentials will want them in an ini-file format, and so this init container will handle that as well.

An example request for credentials looks like this:

```yaml
apiVersion: cloudcredential.openshift.io/v1beta1
kind: CredentialsRequest
metadata:
  name: deployment-aws-credentials
  namespace: openshift-monitoring
spec:
  secretRef:
    name: my-credentials-secret
    namespace: openshift-monitoring
  providerSpec:
    apiVersion: cloudcredential.openshift.io/v1beta1
    kind: AWSProviderSpec
    statementEntries:
    - effect: Allow
      action:
      - cloudwatch:ListMetrics
      - cloudwatch:GetMetricData
      resource: "*"
```

## Usage

An example deployment might look like this

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deploy
  namespace: deployment-ns
spec:
  selector:
    matchLabels:
      app: test-deploy
spec:
  selector:
    matchLabels:
      app: test-deploy
  template:
    metadata:
      labels:
        app: test-deploy
    spec:
      serviceAccountName: pod-sa
      initContainers:
      - name: setupcreds
        image: quay.io/lseelye/yq-kubectl:stable
        command: [ "/usr/local/bin/init.py" ]
        volumeMounts:
        - name: awsrawcreds
          mountPath: /rawsecrets
          readOnly: true
        - name: secrets
          mountPath: /secrets
        - name: envfiles
          mountPath: /config
      containers:
      - name: main
        image: quay.io/openshift/origin-cli:v4.0.0
        command: [ "/bin/sleep", "86400" ]
        volumeMounts:
        - name: secrets
          mountPath: /secrets
          readOnly: true
        - name: envfiles
          mountPath: /config
          readOnly: true
      volumes:
      - name: awsrawcreds
        secret:
          secretName: my-credentials-secret
      - name: secrets
        emptyDir: {}
      - name: envfiles
        emptyDir: {}
```

Once the `main` container runs, it will have the AWS configuration (`config.ini` and `credentials.ini`) populated with information from the configmap and secret. Additional usage is to write the cluster ID to a file, which the `main` container will need to `source` as part of its command, to expose `CLUSTERID` as an environment variable, if so desired.
