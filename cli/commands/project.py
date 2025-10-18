import click 
import shlex

from cli.root import dfst
import json

from utils.python.shell import run 
from utils.python.network import ip_list

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
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = os.environ.get("PROJECT_USER")
    command = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose exec -it -e {vars_} --user {user} -it {service} bash
    """
    os.system(command)
    

@project.command("run", context_settings=dict(ignore_unknown_options=True))
@click.argument("service")
@click.argument("command", nargs=-1)
def run(service, command): 
    """ Executes a command in a service in the project (sh). """
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = os.environ.get("PROJECT_USER")
    commands = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose run --rm -e {vars_} --user {user} {service} \
        {shlex.quote(" ".join(command))}
    """
    os.system(commands)


@project.command("exec", context_settings=dict(ignore_unknown_options=True))
@click.argument("service")
@click.argument("command", nargs=-1)
def exec(service, command): 
    """ Executes a command in a service in the project (sh). """
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = os.environ.get("PROJECT_USER")
    commands = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose exec -e {vars_} --user {user} {service} \
        {shlex.quote(" ".join(command))}
    """
    os.system(commands)

@project.command("bash", context_settings=dict(ignore_unknown_options=True))
@click.argument("service")
@click.argument("command", nargs=-1)
def exec(service, command): 
    """Executes a command in a service in the project (bash)."""
    vars_ = 'PROJECT_RAW_CLI="true"'
    user = os.environ.get("PROJECT_USER")
    project_path = os.environ.get("PROJECT_PATH")

    # Properly quote and escape
    inner_cmd = f"source ~/.bashrc && {' '.join(command)}"
    inner_cmd_quoted = shlex.quote(inner_cmd)

    commands = f"""
        cd {project_path} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose exec -e {vars_} --user {user} {service} "bash -c {inner_cmd_quoted}"
    """
    os.system(commands)


@project.command("enter-as-root")
@click.argument("service")
def enter(service): 
    """ 
        Enter a service in the project (sh). 

        SERVICE is the name of the service to enter.
    """
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = "root"
    command = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose exec --rm -e {vars_} --user {user} -it {service} bash
    """
    os.system(command)
    

@project.command("run-as-root", context_settings=dict(ignore_unknown_options=True))
@click.argument("service")
@click.argument("command", nargs=-1)
def run(service, command): 
    """ Executes a script in a service in the project (sh). """
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = "root"
    commands = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose run --rm -e {vars_} --user {user} {service} \
        {" ".join(command)}
    """
    os.system(commands)


@project.command("exec-as-root", context_settings=dict(ignore_unknown_options=True))
@click.argument("service")
@click.argument("command", nargs=-1)
def run(service, command): 
    """ Executes a script in a service in the project (sh). """
    vars_ = "PROJECT_RAW_CLI=\"true\""
    user = "root"
    commands = f"""
        cd {os.environ.get("PROJECT_PATH")} && 
        {vars_} bash docker-compose up -d {service} > /dev/null 2>&1 && 
        bash docker-compose exec --rm -e {vars_} --user {user} {service} \
        {" ".join(command)}
    """
    os.system(commands)
        

@project.command("ip-list")
def run(): 
    """ Shows services mapped to their IPs as JSON. """
    ip_mapping = ip_list(
        os.environ.get("PROJECT_FULL_NAME"),
        os.environ.get("PROJECT_NETWORK_MAIN")
    )
    sorted_mapping = dict(sorted(ip_mapping.items()))
    click.echo(json.dumps(sorted_mapping, indent=4)) 

@project.command("on")
def on(): 
    """ Turns the project on. """
    project_path = os.environ.get("PROJECT_PATH")
    on_script = os.environ.get("PROJECT_SCRIPT_ON")
    os.system(f"cd {project_path} && bash {on_script}")

@project.command("off")
def off(): 
    """ Turns the project on. """
    project_path = os.environ.get("PROJECT_PATH")
    off_script = os.environ.get("PROJECT_SCRIPT_OFF")
    os.system(f"cd {project_path} && bash {off_script}")
