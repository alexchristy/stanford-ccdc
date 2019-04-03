from graphviz import *
from ipaddress import *
from network import NetworkAddress, NetworkElement, NetworkService, parse_file
import os
import sys
import ipaddress as ip
import xml.etree.ElementTree as ET

### DIAGRAM DEFINITIONS ###

# This class contains both an unordered list of NetworkElements
# and a dictionary that maps subnets to list of NetworkElements
# on that subnet.
class Network():
    def __init__(self, netElements):
        self.boxes = netElements
        self.subnetDict = {}

    def getSubnets(self):
        s = []
        for box in self.boxes:
            s.append(str(box.getSubnet()))
        subnets = list(frozenset(s))

        return subnets

    def groupBySubnet(self):
        subnets = self.getSubnets()

        for subnet in subnets:
            boxes_in_subnet = []
            for box in self.boxes:
                if str(box.getSubnet()) == subnet:
                    boxes_in_subnet.append(box)
            self.subnetDict[subnet] = boxes_in_subnet

        return self.subnetDict

# The graphNetwork function of this class takes in a dictionary
# from groupBySubnet and displays an associated DOT graph.
class NetworkGraph(Graph):
    def __init__(self, netDict):
        Graph.__init__(self)
        self.networkDict = netDict

    def graphNetwork(self, output_name="graph"):
        self.attr(splines = 'ortho')
        for subnet in self.networkDict:
            self.attr('node', shape='ellipse')
            self.node(subnet, 'Subnet: '+subnet)
            self.attr('node', shape='box')

            i = 0
            for box in self.networkDict[subnet]:
                self.node(subnet+"_"+str(i), box.makeEntry())
                self.edge(subnet, subnet+"_"+str(i))
                i+=1

        self.render(output_name, view=True)


# Main only for testing
if __name__ == '__main__':
    filename = sys.argv[1]
    output_name = sys.argv[2]
    elements = parse_file(filename)
    net = Network(elements)
    net.groupBySubnet()
    graph = NetworkGraph(net.subnetDict)
    graph.graphNetwork(output_name)

