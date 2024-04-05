#!/bin/bash

# Function to execute command inside a pod
# Function to execute command inside a pod
execute_command() {
    local namespace="$1"
    local pod_name="$2"
    local command_to_execute="$3"
    echo "Executing command in pod $pod_name in namespace $namespace"
    start_time=$(date +%s)
    oc exec -n "$namespace" "$pod_name" -- bash -c "$command_to_execute" >/dev/null 2>&1
    end_time=$(date +%s)
    echo "Execution in pod $pod_name in namespace $namespace completed in $((end_time - start_time)) seconds"
}


# Main function
main() {
    # Specify the label selector
    label_selector="$1"

    # Specify the command to execute
    command_to_execute="$2"

    # Get list of pods across all namespaces
    pod_info=$(oc get pods -A --selector="$label_selector" --no-headers)

    # Execute commands in each pod
    while IFS= read -r line; do
        namespace=$(echo "$line" | awk '{print $1}')
        pod_name=$(echo "$line" | awk '{print $2}')
        if [[ -n "$namespace" && -n "$pod_name" ]]; then
            execute_command "$namespace" "$pod_name" "$command_to_execute" &
        fi
    done <<< "$pod_info"

    # Wait for all background jobs to finish
    wait
}

main "$@"
