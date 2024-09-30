#!/bin/bash

set -e

# Function to install EFK stack
install_efk() {
    # Check if the logging namespace already exists
    if kubectl get namespace | grep -q "logging"; then
        echo "The 'logging' namespace already exists. Skipping namespace creation."
    else
        # Create namespace
        kubectl create namespace logging
    fi

    # Check if Elastic Helm repo is already added
    if helm repo list | grep -q "https://helm.elastic.co"; then
        echo "Elastic Helm repo is already added. Skipping repo addition."
    else
        # Add Elastic Helm repo
        helm repo add elastic https://helm.elastic.co
    fi

    helm repo update

    # Check if Elasticsearch is already installed
    if helm list -n logging | grep -q "elasticsearch"; then
        echo "Elasticsearch is already installed. Skipping installation."
    else
        # Install Elasticsearch
        helm install elasticsearch elastic/elasticsearch -f config/elasticsearch-values.yml -n logging

        # Wait for Elasticsearch to be ready
        echo "Waiting for Elasticsearch to be ready..."
        kubectl wait --for=condition=ready pod -l app=elasticsearch-master --timeout=300s -n logging
    fi

    # Check if Kibana is already installed
    if helm list -n logging | grep -q "kibana"; then
        echo "Kibana is already installed. Skipping installation."
    else
        # Install Kibana
        helm install kibana elastic/kibana -f config/kibana-values.yml -n logging
    fi

    # Apply Fluent Bit configurations
    kubectl apply -f manifests/fluent-bit-config.yml
    kubectl apply -f manifests/fluent-bit-daemonset.yml
    kubectl apply -f manifests/fluent-bit-rbac.yml

    echo "EFK stack installation complete!"
    echo "To access Kibana, run: kubectl port-forward deployment/kibana-kibana 5601 -n logging"
    echo "Then open http://localhost:5601 in your browser"
}

# Function to destroy EFK stack
destroy_efk() {
    echo "Destroying EFK stack..."

    # Delete Fluent Bit resources
    kubectl delete -f manifests/fluent-bit-config.yml
    kubectl delete -f manifests/fluent-bit-daemonset.yml
    kubectl delete -f manifests/fluent-bit-rbac.yml

    # Uninstall Kibana
    helm uninstall kibana -n logging

    # Uninstall Elasticsearch
    helm uninstall elasticsearch -n logging

    # Delete the logging namespace
    kubectl delete namespace logging

    echo "EFK stack has been destroyed."
}

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm 3 and try again."
    exit 1
fi

# Prompt user for action
while true; do
    read -p "Do you want to install or destroy the EFK stack? (install/destroy): " action
    case $action in
        [Ii]nstall ) install_efk; break;;
        [Dd]estroy ) destroy_efk; break;;
        * ) echo "Please answer install or destroy.";;
    esac
done