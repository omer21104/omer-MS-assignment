# AKS deployment with AGIC and a bitcoin tracker app

this project is a home assignment.
it automates the deployment of an AKS cluster, with AGIC for ingress.
it deploys an app that has 2 services, that print the current price of bitcoin each minute.

## prerequisites

- a way to run bash script
- terraform cli
- jq utility

## how to run

run `deploy.sh` script.
it runs all necessary commands for deployment, and in the end verifies the service is up and running.

## further funcional testing

- to checkout bitcoin prices, get the logs of either pod

```shell
kubectl logs bitcoin-tracker-a
```

should look like this:

```
listening on port:  3000
--- Current Bitcoin price (USD) is: $40018.56 ---
--- Current Bitcoin price (USD) is: $40021.73 ---
--- Current Bitcoin price (USD) is: $40024.97 ---
--- Current Bitcoin price (USD) is: $40027.35 ---
--- Current Bitcoin price (USD) is: $40024.29 ---
--- Current Bitcoin price (USD) is: $40024.05 ---
```

- to test network restrictions, exec into `bitcoin-tracker-a` pod, and install curl (excluded from image for size consideration)

```shell
kubectl exec -it bitcoin-tracker-a -- bash
apt update
apt install curl

curl http://bitcoin-tracker-service-a
```

should get the following error: `curl: (6) Could not resolve host: bitcoin-tracker-service-a`
