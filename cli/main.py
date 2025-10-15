import click 

# Load root group.
from cli.root import dfst

# Load commands.
import cli.commands.env
import cli.commands.dns
import cli.commands.project

if __name__ == '__main__':
    dfst(prog_name="template")