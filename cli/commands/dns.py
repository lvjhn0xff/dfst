import click 

from cli.root import dfst

from utils.python.shell import run 
import os 

@dfst.group("dns")
def dns(): 
    pass

@dns.command("reload")
def reload(): 
    """ Reloads the DNS. """
    os.system("bash scripts/dns/reload.sh")

@dns.command("ip")
def ip(): 
    """ Gets the IP of the DNS for the current version. """
    os.system("bash scripts/dns/ip.sh")