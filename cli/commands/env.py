import click 

from cli.root import dfst

from utils.python.shell import run, pass_args

import os 

@dfst.group("env")
def env(): 
    pass

@env.command("reset")
def reset(): 
    """ Removes containers, networks and volumes the environment. """
    os.system("bash scripts/env/reset.sh")

@env.command("on")
def reset(): 
    """ Turns on the environment. """
    os.system("bash scripts/env/on.sh")

@env.command("off")
def reset(): 
    """ Turns off the environment. """
    os.system("bash scripts/env/off.sh")

@env.command("var")
@click.argument("key")
def var(key): 
    """ 
        Prints a configuration variable. 
        
        KEY is the name of the file to check.
    """
    os.system(f"bash scripts/env/var.sh {key}")