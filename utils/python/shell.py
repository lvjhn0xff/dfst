import sys 
import subprocess

def run():
    """ 
        Execute a command a get output.
    """ 
    result = subprocess.run(
        command,
        capture_output=True,  
        text=True            
    )
    return result.stdout

def pass_args():
    """ 
        Pass arguments to shell script.
    """ 
    return " ".join(sys.argv)