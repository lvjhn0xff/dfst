import click 

from cli.root import dfst

from utils.python.shell import run 
import os 

@dfst.group("project")
def project(): 
    pass