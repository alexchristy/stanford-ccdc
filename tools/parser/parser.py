import os
import sys
import xml.etree.ElementTree as ET

class NetworkService:
    def InitDefault(self):
        self.proto = ""
        self.port = 0
        self.is_open = False
        self.service_name = ""
        self.product = ""
        self.version = ""
        self.description = ""

    # service_root is the port object in the nmap XML
    def InitXml(self, service_root):
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

    def __init__(self, service_xml_root=None):
        self.InitDefault()
        if service_xml_root != None:
            self.InitXml(service_xml_root)

    def __repr__(self):
        return self.__str__()

    def __str__(self):
        return "Service: " + "{" "Protocol: " + self.proto + ", " + "Port: " + str(self.port) + ", " + \
            "Is Open: " + str(self.is_open) + ", " + "Name: " + self.service_name + ", " + \
                "Product: " + self.product + ", " + "Version: " + self.version + "}"

class NetworkElement:
    def InitDefault(self):
        self.is_up = False
        # Each network element is uniquely determined by
        # it's IP address; if a host has two addresses,
        # we treat them as separate.
        self.addr = ""
        self.os = ""
        self.services = []
        self.hostnames = []
        self.description = ""
        self.network = ""

    # host_root corresponds to the host XML element
    def InitXml(self, host_root):
        address = host_root.find('address')
        self.addr = address.attrib.get('addr', "")
        self.addrtype = address.attrib.get('addrtype', "")
        status = host_root.find('status')
        self.status = status.attrib.get('state', "")
        # TODO: Verify
        self.hostnames = [hn.attrib.get('name', "") for hn in host_root.find('hostnames')]

        for service in host_root.find('ports').findall('port'):
            new_service = NetworkService(service)
            self.services.append(new_service)
        print (self.addr, self.hostnames, self.services)

    def __init__(self, host_root=None):
        self.InitDefault()
        if host_root != None:
            self.InitXml(host_root)

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