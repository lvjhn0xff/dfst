## DFST 

Dockerized Full-Stack Templates  

### Installation (Specific Version)

Run the following command in the terminal.

```plaintext
MAJOR_VERSION=1

cd ~/Downloads 

git clone --branch ${VERSION}.0.0 --depth 1 https://github.com/lvjhn0xff/dfst.git dfst
cd dfst 
bash install

# Replace 1 with major version of DFST.
echo "DFST${MAJOR_VERSION}_VERSION=/opt/dfst/${MAJOR_VERSION}/main" >> ~/.bashrc
```