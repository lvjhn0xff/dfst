from utils.python.shell import run 
import json
import os


def ip_list(project_full_name, network_name): 
    inspect_results = run(f"docker network inspect {network_name}")
    network_results = json.loads(inspect_results)[0]
    containers = network_results["Containers"]
    network_prefix = project_full_name + "_" 
    ip_mapping = {} 
    for container_id in containers: 
        entry = containers[container_id]
        container_name = entry["Name"] 
        service_name = container_name[len(network_prefix):]
        ip = entry["IPv4Address"][:-3] 
        ip_mapping[service_name] = ip 
    return ip_mapping
    