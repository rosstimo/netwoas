import requests
import json
import time
import os
import subprocess
import socket

def get_ip_details(ip):
    print(f"Getting details on {ip}")
    try:
        response = requests.get(f'http://ip-api.com/json/{ip}')
        if response.status_code == 200:
            return response.json()
    except requests.RequestException:
        return None

def ping_ip(ip):
    print(f"Running Ping on {ip}")
    try:
        result = subprocess.run(['ping', '-U', '-n', '-i', '0.2', '-c', '4', ip], stdout=subprocess.PIPE, text=True)
        return result.stdout
    except subprocess.CalledProcessError:
        return None

def traceroute_ip(ip):
    print(f"Running Traceroute on {ip}")
    try:
        result = subprocess.run(['traceroute', '-n', '-w', '3', '-q', '1', ip], stdout=subprocess.PIPE, text=True)
        return result.stdout
    except subprocess.CalledProcessError:
        return None

def dns_lookup(ip):
    print(f"Running DNS look up on {ip}")
    try:
        host = socket.gethostbyaddr(ip)
        return host[0] if host else None
    except socket.herror:
        return None

def update_ips_with_details(json_file, ips_file):
    # Initialize ip_data as an empty dictionary
    ip_data = {}

    # Check if json file exists, and read it if it does
    if os.path.exists(json_file):
        with open(json_file, 'r') as file:
            ip_data = json.load(file)

    # Read new IPs from the ips.txt file
    with open(ips_file, 'r') as file:
        new_ips = file.read().splitlines()

    # Process each IP
    for ip in new_ips:
        if ip not in ip_data:
            details = get_ip_details(ip)
            if details:
                details['ping'] = ping_ip(ip)
                details['traceroute'] = traceroute_ip(ip)
                details['dns_lookup'] = dns_lookup(ip)
                ip_data[ip] = details
                # Delay to respect the rate limit of 45 requests per minute
                time.sleep(1.50)

    # Save updated data back to the json file
    with open(json_file, 'w') as file:
        json.dump(ip_data, file, indent=4)

# Example usage
json_file = 'ip_data.json'  # Path to your JSON file
ips_file = 'ips.txt'             # Path to your text file with new IPs

update_ips_with_details(json_file, ips_file)
