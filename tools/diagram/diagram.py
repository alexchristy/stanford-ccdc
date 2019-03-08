from graphviz import *
from ipaddress import *


### PAUL'S CLASS DEFINITIONS ###

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


### MY CLASS DEFINTIONS ###

class Box(NetworkElement):
	def __init__(self):
		NetworkElement.__init__(self)

	def getAddress(self):
		return([self.addr, int(ip_address(unicode(self.addr,"utf-8"))), int(ip_address(u"255.255.255.0"))])

	def makeEntry(self):
		hostnames = "\n".join(name for name in self.hostnames)
		services = "\n".join(self.getServiceByName("ssh"))
		entry = "\n".join([hostnames, self.addr, self.os, services])
		return(entry)

	def getSubnet(self):
		return(self.getAddress()[1] & self.getAddress()[2])

	def isGateway(self):
		return(self.getAddress()[1] == self.getSubnet()+1)

class Network():
	def __init__(self):
		self.boxes = []
		self.subnetDict = {}

	def getSubnets(self):
		s = []
		for box in self.boxes:
			s.append(box.getSubnet())
		subnets = list(frozenset(s))

		return subnets

	def groupBySubnet(self):
		subnets = self.getSubnets()

		for subnet in subnets:
			boxes_in_subnet = []
			for box in self.boxes:
				if box.getSubnet() == subnet:
					boxes_in_subnet.append(box)
			self.subnetDict[subnet] = boxes_in_subnet

		return self.subnetDict

class NetworkGraph(Graph):
	def __init__(self):
		Graph.__init__(self)

	def graphNetwork(self, networkDict):
		self.attr(splines = 'ortho')
		for subnet in networkDict:
			self.attr('node', shape='ellipse')
			self.node(str(subnet), 'Subnet: '+str(ip_address(subnet)))
			self.attr('node', shape='box')

			i = 0
			for box in networkDict[subnet]:
				self.node(str(subnet)+"_"+str(i), box.makeEntry())
				self.edge(str(subnet), str(subnet)+"_"+str(i))
				i+=1

		self.render('test_output', view=True)


### DEMO CODE ###

test_box = Box()
test_box.addr="192.168.10.1"
test_box.os="Solaris 11.3"
test_box.hostnames=["solarbox"]

test_box2 = Box()
test_box2.addr="192.168.10.4"
test_box2.os="Windows 7"
test_box2.hostnames=["smb_share"]

test_box3 = Box()
test_box3.addr="10.0.0.5"
test_box3.os="FreeBSD 10"
test_box3.hostnames=["joxerboi"]

test_net = Network()
test_net.boxes = [test_box, test_box2, test_box3]

test_graph = NetworkGraph()
test_graph.graphNetwork(test_net.groupBySubnet())