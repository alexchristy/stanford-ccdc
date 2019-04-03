import configparser
import xml.etree.ElementTree as ET
from network import Network, NetworkElement

# This file constructs a list of Networks from an nmap XML file, building
# and parsing each host for a given Network

def build_networks(config_list, hosts):
    networks = []
    for config in config_list:
        network = Network(config.network, config.netmask)
        # List of hosts to remove
        remove_list = []
        for host in hosts:
            if network.add_element(host):
                remove_list.append(host)
        hosts.remove_all(remove_list)

        networks.append(network)
    return networks

def build_hosts(nmap_xml_files, config_list):
    gateways = []
    for config in config_list:
        for gateway in config.gateways:
            gateways.append(gateway)

    hosts = []
    for xml_file in nmap_xml_files:
        # TODO: Does this work on strings?
        tree = ET.parse(xml_file)
        root = tree.getroot()
        for xml_host in root.findall('host'):
            host = NetworkElement(xml_host)
            if host.getAddress() in gateways:
                host.setGateway(True)
            hosts.append(host)
    return hosts

def build_all(nmap_xml_files, config_list):
    hosts = build_hosts(nmap_xml_files, config_list)
    networks = build_networks(config_list, hosts)
    return networks