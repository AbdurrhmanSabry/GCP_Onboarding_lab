#!/bin/bash
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install my-release nginx-stable/nginx-ingress --set controller.image.repository=gcr.io/seraphic-lock-358517/ingress 
sleep 60
export NGINX_INGRESS_IP=$(kubectl get service my-release-nginx-ingress -o jsonpath={.status.loadBalancer.ingress[].ip})
echo $NGINX_INGRESS_IP
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
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: dev
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: "app.$NGINX_INGRESS_IP.nip.io"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: pthyon-app-service
            port:
              number: 8000
EOF
kubectl apply -f ingress-resource.yaml