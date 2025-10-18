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
    os.system("docker compose down -v")

@env.command("on")
def reset(): 
    """ Turns on the environment. """
    os.system("docker compose up -d")

@env.command("off")
def reset(): 
    """ Turns off the environment. """
    os.system("docker compose down")

@env.command("var")
@click.argument("key")
def var(key): 
    """ 
        Prints a configuration variable. 
        
        KEY is the name of the file to check.
    """
    click.echo(os.environ.get(key))

@env.command("get-ca")
def get_ca(): 
    """ 
        Gets the CA for the current version.
    """
    source = "caddy:/data/caddy/pki/authorities/local/root.crt"
    destination = os.environ.get('DFST_DATA_DIR') + "/certs/ca.crt"
    os.system(f"docker compose cp {source} {destination}")

@env.command("register-ca")
def register_ca(): 
    """ 
        Register the CA for the current version in commonly used browsers.
    """
    os.system("bash scripts/register-ca.sh")

@env.command("first-time-setup")
def first_time_setup(): 
    """ 
        First time set-up.
    """
    os.system("bash scripts/first-time-setup.sh")

@env.command("user-reset")
def user_reset(): 
    """ 
        Resets DFST for the current user.
    """
    os.system("bash scripts/user-reset.sh")

@env.command("user-setup")
def user_setup(): 
    """ 
        Sets up DFST for the current user.
    """
    os.system("bash scripts/user-setup.sh")