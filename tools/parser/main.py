import argparse
import configparser
import sys
import parse_xml as px
from network import Network, NetworkElement

DEFAULT_NETWORK = "0.0.0.0"
DEFAULT_NETMASK = "255.255.255.0"
DEFAULT_NMAP_FLAGS = "-p 1-65535 -sV -sS -T4"

class Config:
    def __init__(self, network, netmask, gateways, nmap):
        self.network = network
        self.netmask = netmask
        self.gateways = gateways
        self.nmap = nmap

def parse_config_single(title, single_config):
    # Default network is 0.0.0.0
    network = single_config.get("Network", DEFAULT_NETWORK)
    # Default netmask is a /24
    netmask = single_config.get("Netmask", DEFAULT_NETMASK)
    gateways = single_config.get("Gateway", "")
    # Get custom nmap flags or default
    nmap_flags = single_config.get("Nmap", DEFAULT_NMAP_FLAGS)
    gateways = [x.strip() for x in gateways.split(',')]
    return Config(network, netmask, gateways, nmap_flags)

def parse_config(config_file):
    config_list = []
    config = configparser.ConfigParser()
    config.read_file(config_file)
    for section in config.sections():
        config_tuple = parse_config_single(section, config[section])
        config_list.append(config_tuple)
    return config_list

def run_nmap(network, netmask, flags, outfile=None):
    command = network + "/" + netmask + " " + flags + " -oX "
    if outfile is None:
        command += "-"
    else:
        command += outfile

    # TODO: Finish
    raise Exception("Unimplemented")

def parse_arguments():
    parser = argparse.ArgumentParser(description="Generates a network diagram from an nmap XML file")
    parser.add_argument("-c", "--config", help="The network config file to read",
                        type=argparse.FileType('r'), required=True)
    parser.add_argument("-o", "--output", help="The file to save the network diagram to",
                        type=argparse.FileType('w'), required=True)

    # Force the user to either run nmap or supply an XML file
    run_or_parse_group = parser.add_mutually_exclusive_group(required=True)
    run_or_parse_group.add_argument("-i", "--input-xml", help="nmap XML file to parse",
                                    type=argparse.FileType('r'))
    run_or_parse_group.add_argument("-r", "--run-nmap", help="Runs nmap instead of parsing from a file",
                                    action="store_true")

    parser.add_argument("-s", "--store-xml", help="Stores the XML produced by nmap (if no XML file is supplied)",
                        type=argparse.FileType('w'))

    args = parser.parse_args()
    return args

def main():
    args = parse_arguments()
    net_configs = parse_config(args.config)
    print (net_configs)

    nmap_xml_files = []
    if args.run_nmap:
        # TODO
        #nmap_xml_files = run_nmap(net_configs)
        raise Exception("Unimplemented")
    else:
        nmap_xml_files.append(args.input_xml)

    networks = px.build_all(nmap_xml_files, net_configs)
    print (networks)


if __name__ == "__main__":
    main()
