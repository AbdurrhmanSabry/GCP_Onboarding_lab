# Ingress using nginx on GKE cluster


## Getting the Chart Sources
1. Clone the Ingress Controller repo:
```bash
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v2.3.0
cd kubernetes-ingress/deployments/helm-chart
helm install my-release .
```

## Installing via Helm Repository
1. Adding the Helm Repository

```bash
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
```

2. Install the chart

```bash
helm install my-release nginx-stable/nginx-ingress
```

If you have pushed the image to a private repo
```bash
helm install my-release nginx-stable/nginx-ingress --set controller.image.repository=myregistry.example.com/nginx-plus-ingress --set controller.nginxplus=true
```


Make sure everything is running smoothly

```bash
kubectl get deployment my-release-nginx-ingress
kubectl get service my-release-nginx-ingress
```

The output should be like this 

```bash
# Deployment
NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
my-release-nginx-ingress                  1/1     1            1           13m

# Service
NAME                                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
my-release-nginx-ingress                LoadBalancer   10.7.255.93   <pending>       80:30381/TCP,443:32105/TCP   13m
```

Wait a few moments while the Google Cloud L4 load balancer gets deployed, and then confirm that the nginx-ingress-nginx-ingress Service has been deployed and that you have an external IP address associated with the service:
```bash
NAME                                     TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
my-release-nginx-ingress     LoadBalancer   10.7.255.93   34.122.88.204   80:30381/TCP,443:32105/TCP   13m
```

1. Export the EXTERNAL-IP of the NGINX ingress controller in a variable to be used later:

```bash
export NGINX_INGRESS_IP=$(kubectl get service my-release-nginx-ingress -o jsonpath={.status.loadBalancer.ingress[].ip})
```

2. Ensure that you have the correct IP address value stored in the $NGINX_INGRESS_IP variable:

```bash
echo $NGINX_INGRESS_IP
```

## Configure Ingress Resource to use NGINX Ingress Controller

An Ingress Resource object is a collection of L7 rules for routing inbound traffic to Kubernetes Services. Multiple rules can be defined in one Ingress Resource, or they can be split up into multiple Ingress Resource manifests. The Ingress Resource also determines which controller to use to serve traffic. This can be set with an annotation, kubernetes.io/ingress.class, in the metadata section of the Ingress Resource. 

1. For the NGINX controller, use the value nginx:
```bash
annotations: kubernetes.io/ingress.class: nginx
```

2. Create a simple Ingress Resource YAML file that uses the NGINX Ingress Controller and has one path rule defined:

```bash
cat <<EOF > ingress-resource.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-resource
  namespace: shared-services
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: "$NGINX_INGRESS_IP.nip.io"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: jenkins-svc
            port:
              number: 8080
  - host: "nexus.$NGINX_INGRESS_IP.nip.io"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nexus-svc
            port:
              number: 8081
EOF
```
The kind: Ingress line dictates that this is an Ingress Resource object. This Ingress Resource defines an inbound L7 rule for path /hello to service hello-app on port 8080.

The host specification of the Ingress resource should match the FQDN of the Service. The NGINX Ingress Controller requires the use of a Fully Qualified Domain Name (FQDN) in that line, so you can't use the contents of the $NGINX_INGRESS_IP variable directly. Services such as nip.io return an IP address for a hostname with an embedded IP address (i.e., querying [IP_ADDRESS].nip.io returns [IP_ADDRESS]), so you can use that instead. In production, you can replace the host specification in the Ingress resource with your real FQDN for the Service.

3. Apply the configuration:

```bash
kubectl apply -f ingress-resource.yaml
```
4. Verify that Ingress Resource has been created:

```bash
kubectl get ingress ingress-resource
```

5. Test the ingress
```bash
curl http://$NGINX_INGRESS_IP.nip.io/
curl http://nexus.$NGINX_INGRESS_IP.nip.io/
```

## Links
For ingress controller helm chart:
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/  
For configuring the ingress resource:
https://cloud.google.com/community/tutorials/nginx-ingress-gke