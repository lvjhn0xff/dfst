import click 

from cli.root import dfst

from utils.python.shell import run
from utils.python.dns import dns_entries, dns_publish, dns_reload, dns_restart
from utils.python.network import ip_list

import os 

@dfst.group("dns")
def dns(): 
    pass

@dns.command("reload")
def reload(): 
    """ Reloads the DNS. """
    click.echo("Reloading DNS.")
    dns_reload()
    click.echo("Done.")

@dns.command("ip")
def ip(): 
    """ Gets the IP of the DNS for the current version. """
    click.echo(os.environ.get("DFST_DNS_IP"))

@dns.command("entries")
def entries(): 
    """ Print out DNS entries of the current project. """
    entries = dns_entries() 
    click.echo(entries)

@dns.command("publish")
def entries(): 
    """ Publishes the DNS entries of the current project."""
    click.echo("Publishing DNS entries.")
    dns_publish()
    click.echo("Done.")

@dns.command("update")
def entries(): 
    """ Publishes the DNS entries of the current project."""
    click.echo("Publishing DNS entries.")
    dns_publish()
    click.echo("Reloading DNS server.")
    dns_reload()
    click.echo("Done.")


@dns.command("restart")
def entries(): 
    """ Publishes the DNS entries of the current project."""
    click.echo("Restarting DNS server.")
    dns_restart()
    click.echo("Done.")




