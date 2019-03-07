import os
import sys
import xml.etree.ElementTree as ET

class NetworkService:
    def __init__(self):
        self.proto = ""
        self.port = 0
        self.isOpen = False
        self.serviceName = ""
        self.product = ""
        self.version = ""
        self.description = ""

class NetworkElement:
    def __init__(self):
        self.isUp = False
        # Each network element is uniquely determined by
        # it's IP address; if a host has two addresses,
        # we treat them as separate.
        self.addr = ""
        self.os = ""
        self.services = []
        self.hostnames = []
        self.description = ""
        self.network = ""

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
    print (root)
    for child in root:
        print (child.tag, child.attrib)
    hosts = root.findall("host")
    for host in hosts:
        address_obj = host.findall('address')[0]
        print (host.tag, address_obj.tag, address_obj.attrib)


# Main only for testing
if __name__ == '__main__':
    filename = sys.argv[1]
    parse_file(filename)