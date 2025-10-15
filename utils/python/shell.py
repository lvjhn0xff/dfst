import sys 
import subprocess

def run(command):
    """ 
        Execute a command a get output.
    """ 
    result = subprocess.run(
        command,
        capture_output=True,  
        text=True,
        shell=True
    )
    return result.stdout

def pass_args():
    """ 
        Pass arguments to shell script.
    """ 
    return " ".join(sys.argv)