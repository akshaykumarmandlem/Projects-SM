from kubernetes import client, config

def analyze_kubernetes_threats():
    try:
        # Try to load in-cluster configuration (for when running inside the cluster)
        config.load_incluster_config()
    except config.ConfigException:
        # If not in-cluster, load the local kube-config (used when running locally or in Docker)
        config.load_kube_config()

    # Get API instances
    v1 = client.CoreV1Api()

    try:
        # Fetch all pods from all namespaces
        pods = v1.list_pod_for_all_namespaces(watch=False)
    except Exception as e:
        print(f"Error fetching Kubernetes pods: {e}")
        return []

    threats = []
    for pod in pods.items:
        if pod.status.phase == "Failed":
            threat = {
                "id": pod.metadata.name,
                "namespace": pod.metadata.namespace,
                "status": pod.status.phase,
                "reason": pod.status.reason,
                "message": pod.status.message
            }
            threats.append(threat)

    print("Detected Kubernetes Threats: ", threats)
    return threats