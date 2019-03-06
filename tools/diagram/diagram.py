from graphviz import *

def makeEntry(box):
	hostnames = "\n".join(name for name in box.hostnames)
	addrs = "\n".join(addr[0] for addr in box.addrs)
	services = "\n".join(service[1]+' // '+str(service[0]) for service in box.services)
	entry = "\n".join([hostnames, addrs, services])
	return(entry)

def getSubnet(box):
	return(box.addr[1] & box.addr[2])

def groupBySubnet(boxes):
	subnet_list = []
	for box in boxes:
		subnet_list.append(getSubnet(box))
	subnets = frozenset(subnet_list)

	topo_dict = {}

	for subnet in subnets:
		boxes_in_subnet = []
		for box in boxes:
			if getSubnet(box) == subnet:
				boxes_in_subnet.append(box)
		topo_dict[subnet] = boxes_in_subnet

	return topo_dict

def makeSubnet(graph, subnet_name, boxes):
	subgraph = graph.subgraph(name = subnet_name)
	subgraph.attr(splines = 'ortho')
	subgraph.attr('node', shape='cylinder')
	subgraph.node(subnet_name, 'Subnet: '+subnet_name)
	subgraph.attr('node', shape='box')

	i = 0
	subgraph.attr(rank='same')
	for box in boxlist:
		subgraph.node(subnet_name+str(i), makeEntry(box))
		subgraph.edge(subnet_name, subnet_name+str(i))

	return(subgraph)

def joinSubnets(graph, subnet_name_list):
	graph.attr('node', shape='oval')
	graph.node('I', 'Internet')
	for name in subnet_name_list:
		graph.edge('I', subnet_name_list)

	return(graph)



lan = Graph()
lan.attr('node', shape='oval')
lan.node('I', 'Internet')
lan.attr('node', shape='cylinder')
lan.node('P', 'PAN OS')
lan.attr('node', shape='box')
lan.attr(splines = 'ortho')
lan.node('1', label = 'Workstation 1'+'\n'+'Ubuntu 16.04 LTE')
lan.node('2', 'Workstation 2'+'\n'+'Debian 9')
lan.node('3', 'Workstation 3'+'\n'+'Windows 7 Home Edition')
lan.edges(['IP','P1', 'P2', 'P3'])

lan.render('test_output', view=True)
