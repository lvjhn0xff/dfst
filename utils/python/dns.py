#!/bin/bash
import os 

from .network import ip_list 

def dns_entries():
    entries = []
    project_network_main = os.environ.get("PROJECT_NETWORK_MAIN")
    project_full_domain = os.environ.get("PROJECT_FULL_DOMAIN")
    ip_mapping = ip_list(
        os.environ.get("PROJECT_FULL_NAME"),
        os.environ.get("PROJECT_NETWORK_MAIN")
    )
    addresses = [] 

    if "router-http" in ip_mapping: 
        router_ip = ip_mapping["router-http"]
        addresses += [
            f"address=/{project_full_domain}/{router_ip}",
            f"address=/*.{project_full_domain}/{router_ip}"
        ]

    if "router-tcp" in ip_mapping: 
        router_ip = ip_mapping["router-http"]
        addresses += [
            f"address=/services.{project_full_domain}/{router_ip}",
            f"address=/*.services.{project_full_domain}/{router_ip}"
        ]

    content = "\n".join(addresses)
    return content

def dns_publish(): 
    entries = dns_entries()
    dns_mappings_dir = os.environ.get("DFST_DATA_DIR") + "/dns/mappings"
    filename = os.environ.get("PROJECT_FULL_NAME") + ".conf"
    output_file = dns_mappings_dir + "/" + filename
    open(output_file, "w").write(entries)

def dns_reload(): 
    os.system(
        "docker compose exec dns sh -c \"s6-svc -r /run/service/dnsmasq\""
    )

def dns_connect(): 
    os.system(f"""
        docker network connect 
    """)

def dns_restart(): 
    os.system("docker compose restart dns")