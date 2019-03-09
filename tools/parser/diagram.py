from graphviz import *
from ipaddress import *
import nmap_parser
from nmap_parser import NetworkElement

### MY CLASS DEFINTIONS ###
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

test_box = NetworkElement()
test_box.addr="192.168.10.1"
test_box.os="Solaris 11.3"
test_box.hostnames=["solarbox"]

test_box2 = NetworkElement()
test_box2.addr="192.168.10.4"
test_box2.os="Windows 7"
test_box2.hostnames=["smb_share"]

test_box3 = NetworkElement()
test_box3.addr="10.0.0.5"
test_box3.os="FreeBSD 10"
test_box3.hostnames=["joxerboi"]

test_net = Network()
test_net.boxes = [test_box, test_box2, test_box3]

test_graph = NetworkGraph()
test_graph.graphNetwork(test_net.groupBySubnet())