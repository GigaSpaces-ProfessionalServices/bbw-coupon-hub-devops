#!/bin/bash
namespace=$1

# Function to get repository, image, and tag for each container
get_container_info() {
    local namespace=$1
    local pods=$(kubectl get pods -n "$namespace" -o json | jq -r '.items[].metadata.name')

    for pod in $pods; do
        local containers=$(kubectl get pod "$pod" -n "$namespace" -o json | jq -r '.spec.containers[].name')

        for container in $containers; do
            local image=$(kubectl get pod "$pod" -n "$namespace" -o json | jq -r --arg container "$container" '.spec.containers[] | select(.name == $container) | .image')
            local repository=$(echo "$image" | cut -d '/' -f 1)
            local tag=$(echo "$image" | cut -d ':' -f 2)

            echo "
            pod: $pod 
            Repository: $repository 
            Image: $image, Tag: $tag
            -------------------------------------
            
            "
        done
    done
}

# Main function
main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <namespace>"
        exit 1
    fi

    #namespace=ingress-external

    # Get repository, image, and tag for each container
    get_container_info "$namespace"
}

# Run main function with provided namespace
main "$(kubectl config view --minify -o 'jsonpath={..namespace}')" # Get current namespace

