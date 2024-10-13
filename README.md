# k8s-efk-easy-setup
A one-click Kubernetes EFK (Elasticsearch, Fluentbit, Kibana) stack setup for easy log management.

## Prerequisites

Before you begin, ensure you have the following:

- A running Kubernetes cluster
- `kubectl` installed and configured to communicate with your cluster
- Helm 3 installed

## Repository Structure

```
k8s-efk-easy-setup/
├── README.md
├── install.sh
├── config/
│   ├── elasticsearch-values.yml
│   └── kibana-values.yml
└── manifests/
    ├── fluent-bit-config.yml
    ├── fluent-bit-daemonset.yml
    └── fluent-bit-rbac.yml
```

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/code4mk/k8s-efk-easy-setup.git
   cd k8s-efk-easy-setup
   ```

2. Run the installation script:
   ```
   ./install.sh
   ```

3. Choose whether to install or destroy the EFK stack when prompted.

## Installation Details

The installation script performs the following actions:

1. Creates a `logging` namespace in your Kubernetes cluster
2. Adds the Elastic Helm repository
3. Installs Elasticsearch using Helm
4. Installs Kibana using Helm
5. Deploys Fluent Bit as a DaemonSet

## Accessing Kibana

After installation, you can access Kibana by following these steps:

1. Run the following command to set up port forwarding:
   ```
   kubectl port-forward deployment/kibana-kibana 5601 -n logging
   ```

2. Open a web browser and navigate to `http://localhost:5601`

## Customization

You can customize the EFK stack by modifying the following configuration files:

- `config/elasticsearch-values.yml`: Elasticsearch Helm values
- `config/kibana-values.yml`: Kibana Helm values
- `manifests/fluent-bit-config.yml`: Fluent Bit configuration
- `manifests/fluent-bit-daemonset.yml`: Fluent Bit DaemonSet specification

## Uninstallation

To uninstall the EFK stack, run the installation script and choose the "destroy" option when prompted:

```
./install.sh
```

This will remove all components of the EFK stack from your Kubernetes cluster.

## Troubleshooting

If you encounter any issues:

1. Ensure all pods in the `logging` namespace are running:
   ```
   kubectl get pods -n logging
   ```

2. Check the logs of the problematic pod:
   ```
   kubectl logs <pod-name> -n logging
   ```

3. Verify that Elasticsearch is healthy:
   ```
   kubectl port-forward svc/elasticsearch-master 9200 -n logging
   curl localhost:9200/_cluster/health?pretty
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
