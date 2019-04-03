import os
import sys
import ipaddress as ip
import xml.etree.ElementTree as ET

class NetworkService:
    def __init__(self, service_xml_root=None):
        self.initDefault()
        if service_xml_root != None:
            self.initXml(service_xml_root)

    def initDefault(self):
        self.proto = ""
        self.port = 0
        self.is_open = False
        self.service_name = ""
        self.product = ""
        self.version = ""
        self.description = ""

    # service_root is the port object in the nmap XML
    def initXml(self, service_root):
        self.proto = service_root.attrib.get('protocol', "")
        self.port = int(service_root.attrib.get('portid', "0"))
        state = service_root.find('state')
        if state != None:
            self.is_open = state.attrib.get('state', "closed") == "open"

        service = service_root.find('service')
        if service != None:
            self.service_name = service.attrib.get('name', "None")
            self.product = service.attrib.get('name', "None")
            self.version = service.attrib.get('version', "None")

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return "Service: " + "{" "Protocol: " + self.proto + ", " + "Port: " + str(self.port) + ", " + \
            "Is Open: " + str(self.is_open) + ", " + "Name: " + self.service_name + ", " + \
                "Product: " + self.product + ", " + "Version: " + self.version + "}"

class NetworkElement:
    def __init__(self, host_root=None, netmask="255.255.255.0", gateway=False):
        self.initDefault()
        if host_root != None:
            self.initXml(host_root, netmask, gateway)

    def initDefault(self):
        self.is_up = False
        # Each network element is uniquely determined by
        # it's IP address; if a host has two addresses,
        # we treat them as separate.

        self.network_interface = ip.ip_interface("0.0.0.0/0")
        self.gateway = False
        self.network_config = None
        self.os = ""
        self.services = []
        self.hostnames = []
        self.description = ""

    # host_root corresponds to the host XML element
    def initXml(self, host_root, netmask, gateway):
        address = host_root.find('address')
        # TODO: Consider failure case
        addr_str = address.attrib.get('addr', "")
        self.network_config = ip.ip_interface(addr_str + "/" + netmask)
        status = host_root.find('status')
        self.status = status.attrib.get('state', "")
        # TODO: Verify
        self.hostnames = [hn.attrib.get('name', "") for hn in host_root.find('hostnames')]

        for service in host_root.find('ports').findall('port'):
            new_service = NetworkService(service)
            self.services.append(new_service)

    def getServiceByPort(self, port_num, proto):
        # Should only be one (port, service) per network element, but
        # we return a list for consistency
        service_list = []
        for service in self.services:
            if service.port == port_num and service.proto == proto:
                service_list.append(service)
        return service_list

    def getServiceByName(self, service_name):
        service_list = []
        for service in self.services:
            if service.serviceName == service_name:
                service_list.append(service)
        return service_list

    # Providing a list of service_names filters the results to only include
    # open ports with the corresponding service
    def getAllOpenServices(self, service_names=None):
        service_list = []
        for service in self.services:
            if service.is_open:
                if service_names == None or service.name in service_names:
                    service_list.append(service)
        return service_list

    # Returns stringified version of IP, stripped of subnet specification
    def getAddress(self):
        return str(self.network_interface)[:-3]

    def getNetwork(self):
        return self.network_interface.network

    # Returns ipv4 object of subnet
    def getSubnet(self):
        return self.network_interface.network

    def isGateway(self):
        return self.gateway

    def setGateway(self, gateway):
        self.gateway = gateway

    def makeEntry(self):
        hostname_list = ""
        for i, hostname in enumerate(self.hostnames):
            hostname_list += hostname
            if i < len(self.hostnames) - 1:
                hostname_list += ","
        return "\n".join([hostname_list, self.getAddress(), self.os])

# A single logical network. We assume this network to use either contiguous
# addresses (e.g. 10.0.0.10-10.0.255.255) or CIDR notation (e.g. 10.0.0.0/24)
# Does not support non-contiguous networks.
class Network:
    # We force address and netmask arguments here to be strings
    # Defaults to be the "all" address address (0.0.0.0/0)
    def __init__(self, address="0.0.0.0", netmask="0"):
        self.hosts = []
        self.set_network(address, netmask)

    # Assumes arguments are strings
    # If no arguments are provided, equivalent to giving an address of
    # 0.0.0.0/0.
    def set_network(self, address="0.0.0.0", netmask="0"):
        new_network = ip.ip_network(address + "/" + netmask)

        # Make sure this new network works with all hosts
        for host in self.hosts:
            if not self._check_valid_host(host, new_network):
                return False

        # If no errors, set new network
        self.network = new_network
        return True

    def get_network(self):
        return self.network

    def get_hosts(self):
        return self.hosts

    # Returns an error if the element is not in this network
    def add_element(self, network_element):
        if not self._check_valid_host(network_element, self.network):
            return False
        self.hosts.append(network_element)
        return True

    def _check_valid_host(self, host, network):
        host_network = host.getNetwork()
        # Trivially true if the network is none
        if host_network is None:
            return True
        if network.supernet_of(host_network) != 0:
            return False
        return True

# Exported function
def parse_file(filename):
    tree = ET.parse(filename)
    root = tree.getroot()
    elements = []
    for host in root.findall('host'):
        network_element = NetworkElement(host)
        elements.append(network_element)
    return elements


# Main only for testing
if __name__ == '__main__':
    filename = sys.argv[1]
    elements = parse_file(filename)