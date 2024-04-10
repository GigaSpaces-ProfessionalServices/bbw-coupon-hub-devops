#!/bin/bash

# Function to generate Docker pull command
generate_docker_pull_command() {
    local image=$1
    echo "#--------------------------------------------------------------------------"
    echo "docker pull $image"
}

# Function to generate Docker tag command
generate_docker_tag_command() {
    local source_image=$1
    local target_image=$2
    echo "docker tag $source_image $target_image"
}

# Function to generate Docker push command
generate_docker_push_command() {
    local image=$1
    local harbor_registry="Harbor.hq.bbwcorp"
    local target_image="$harbor_registry/$image"
    echo "#docker push $target_image"
}

# Main script
image_list=(
    "gigaspaces/mcs-query-service:1.0.14"
    "busybox:1.36.0"
    "quay.io/kiwigrid/k8s-sidecar:1.19.2"
    "grafana/grafana:9.2.5"
    "gigaspaces/smart-cache-enterprise:16.4.2"
    "alpine/openssl"
    "gigaspaces/cache-operator:16.4.2"
    "gigaspaces/mcs-service-creator:1.0.13"
    "gigaspaces/mcs-service-operator:1.0.13"
    "gigaspaces/spacedeck:1.1.39"
    "influxdb:1.8.10"
    "gigaspaces/cache-operator-purge-job:16.4.2"
    "bitnami/kubectl"
    "quay.io/minio/operator:5.0.5"
)

# Remove duplicates
unique_images=($(echo "${image_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Generate commands for each unique image
for image in "${unique_images[@]}"; do
    pull_command=$(generate_docker_pull_command "$image")
    tag_command=$(generate_docker_tag_command "$image" "$image")
    push_command=$(generate_docker_push_command "$image")

    echo "$pull_command"
    echo "$tag_command"
    echo "$push_command"
done
