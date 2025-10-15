import click 

from cli.root import dfst

from utils.python.shell import run 
import os 

@dfst.group("project")
def project(): 
    pass


@project.command("enter")
@click.argument("service")
def enter(service): 
    """ 
        Enter a service in the project (sh). 

        SERVICE is the name of the service to enter.
    """
    os.system(f"bash scripts/project/enter.sh {service}")

@project.command("run")
@click.argument("service")
@click.argument("command", nargs=-1)
def run(service, command): 
    """ Executes a script in a service in the project (sh). """
    os.system(f"bash scripts/project/run.sh {service} {" ".join(list(command))}")
    
