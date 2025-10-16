## DFST 

Dockerized Full-Stack Templates  

### Installation (Specific Version)

Run the following command in the terminal.

```plaintext
#!/bin/bash
cd ~/Downloads 

# Replace --branch 1.0.0 with appropriate version.
git clone --branch 1.0.0 --depth 1 https://github.com/lvjhn0xff/dfst.git dfst
cd dfst 
bash install

# Replace 1 with major version of DFST.
echo "DFST1_VERSION=/opt/dfst/1/main" >> ~/.bashrc
```