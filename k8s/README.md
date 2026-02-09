# Kubernetes Deployment Guide

This guide explains how to deploy the Stablecoin SCS application using Kubernetes configurations found in this directory.

## Architecture Overview

The deployment consists of three main services:

- **Graph Node**: The Graph Protocol indexing service that indexes blockchain events
- **PostgreSQL**: Database service for storing indexed data
- **IPFS**: InterPlanetary File System for distributed storage

These services work together to provide blockchain data indexing and retrieval capabilities for the Sony Bank Stablecoin application.

## Prerequisites

- Kubernetes cluster (v1.20+)
- `kubectl` configured to access your cluster
- A Docker registry (if deploying from custom images)

## Directory Structure

```
k8s/
├── graph-deployment.yaml      # Graph Node deployment configuration
├── graph-svc.yaml             # Graph Node service
├── postgres-sts.yaml          # PostgreSQL StatefulSet
├── postgres-svc.yaml          # PostgreSQL service
├── postgres-pvc.yaml          # PostgreSQL persistent volume claim
├── postgres-secret.yaml       # PostgreSQL credentials secret
├── ipfs-sts.yaml              # IPFS StatefulSet
├── ipfs-svc.yaml              # IPFS service
├── ipfs-pvc.yaml              # IPFS persistent volume claim
└── README.md                  # This file
```

## Services Configuration

### PostgreSQL

**StatefulSet**: `postgres-sts.yaml`
- Image: `postgres:16`
- Port: `5432`
- Default User: `graph-node`
- Database: `graph-node`
- Storage: Persistent Volume Claim (`postgres-pvc`)

### IPFS

**StatefulSet**: `ipfs-sts.yaml`
- Image: `ipfs/kubo:v0.29.0`
- Port: `5001` (API)
- Storage: Persistent Volume Claim (`ipfs-pvc`)

### Graph Node

**Deployment**: `graph-deployment.yaml`
- Image: `graphprotocol/graph-node`
- Ports:
  - `8000`: HTTP RPC server
  - `8001`: GraphQL WebSocket server
  - `8020`: JSON-RPC admin server
  - `8030`: Subgraph server
  - `8040`: Metrics server
- Network: Polygon Amoy testnet (`https://polygon-amoy.drpc.org`)

## Deployment Steps

### 1. Create Namespace

```bash
kubectl create namespace stablecoin
```

### 2. Create PostgreSQL Secret

Update `postgres-secret.yaml` with your desired password and apply:

```bash
kubectl apply -f postgres-secret.yaml
```

**Note**: The secret should contain the `POSTGRES_PASSWORD` value. Update the base64 encoded value in the YAML file if needed:

```bash
echo -n "your-password" | base64
```

### 3. Create Persistent Volumes (if required)

If your cluster doesn't automatically provision volumes, you may need to create PersistentVolumes first. Otherwise, skip this step.

### 4. Deploy PostgreSQL

```bash
kubectl apply -f postgres-pvc.yaml
kubectl apply -f postgres-sts.yaml
kubectl apply -f postgres-svc.yaml
```

### 5. Deploy IPFS

```bash
kubectl apply -f ipfs-pvc.yaml
kubectl apply -f ipfs-sts.yaml
kubectl apply -f ipfs-svc.yaml
```

### 6. Deploy Graph Node

```bash
kubectl apply -f graph-deployment.yaml
kubectl apply -f graph-svc.yaml
```

### Deploy Everything at Once

Alternatively, deploy all resources at once:

```bash
kubectl apply -f .
```

## Verification

### Check Pod Status

```bash
kubectl get pods -n stablecoin
```

Wait for all pods to reach `Running` status:

```bash
kubectl get pods -n stablecoin -w
```

### View Pod Logs

```bash
# Graph Node logs
kubectl logs -n stablecoin deployment/graph-node -f

# PostgreSQL logs
kubectl logs -n stablecoin statefulset/postgres -f

# IPFS logs
kubectl logs -n stablecoin statefulset/ipfs -f
```

### Check Service Status

```bash
kubectl get svc -n stablecoin
```

### Access Services

#### Port Forward to Graph Node

```bash
kubectl port-forward -n stablecoin svc/graph-node 8020:8020
```

Access GraphQL interface: `http://localhost:8020`

#### Port Forward to PostgreSQL

```bash
kubectl port-forward -n stablecoin svc/postgres 5432:5432
```

#### Port Forward to IPFS

```bash
kubectl port-forward -n stablecoin svc/ipfs 5001:5001
```

## Graph Subgraph Deployment

After the Graph Node is running, deploy the subgraph using npm scripts:

### Compile Subgraph for Amoy

```bash
npm run graph:compile:amoy
```

### Deploy Subgraph to Graph Node

```bash
npm run graph:deploy:amoy
```

These scripts will:
1. Generate code from the subgraph schema (`subgraph/schema.graphql`)
2. Build the subgraph
3. Create a subgraph instance on the Graph Node
4. Deploy with versioning

**Note**: The Graph Node must be accessible at `http://0.0.0.0:8020` and IPFS at `http://0.0.0.0:5001/api/v0` as configured in `package.json`.

## Environment Configuration

The Graph Node is configured to:
- Connect to **Polygon Amoy** testnet via DRPC
- Use PostgreSQL for data persistence
- Use IPFS for subgraph file storage

To modify these settings, edit `graph-deployment.yaml` and update the environment variables under `spec.template.spec.containers[0].env`.

## Troubleshooting

### PostgreSQL Pod Not Starting

Check if the PVC is properly provisioned:

```bash
kubectl get pvc -n stablecoin
kubectl describe pvc postgres-pvc -n stablecoin
```

### Graph Node Cannot Connect to Database

Verify PostgreSQL is running and the secret is correctly configured:

```bash
kubectl exec -it -n stablecoin statefulset/postgres -- psql -U graph-node -d graph-node
```

### IPFS Pod Issues

Check IPFS logs for connectivity issues:

```bash
kubectl logs -n stablecoin statefulset/ipfs -f
```

### Subgraph Deployment Fails

Ensure the Graph Node is fully initialized and accessible:

```bash
kubectl port-forward -n stablecoin svc/graph-node 8020:8020
curl http://localhost:8020/graphql
```

## Cleanup

To remove all resources:

```bash
kubectl delete namespace stablecoin
```

Or delete individual resources:

```bash
kubectl delete -f . -n stablecoin
```

## Production Considerations

- **High Availability**: Increase replicas for Graph Node and use StatefulSet
- **Resource Limits**: Add resource requests and limits to prevent resource exhaustion
- **Persistence**: Ensure proper backup strategies for PostgreSQL and IPFS data
- **Security**: Use role-based access control (RBAC) and network policies
- **Monitoring**: Implement Prometheus and Grafana for metrics collection
- **Secrets Management**: Use a proper secrets management solution (e.g., HashiCorp Vault)
- **Container Registry**: Use private container registries and image scanning

## Additional Resources

- [The Graph Documentation](https://thegraph.com/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [PostgreSQL on Kubernetes](https://www.postgresql.org/docs/)
- [IPFS Documentation](https://docs.ipfs.tech/)
