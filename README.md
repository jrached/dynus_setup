# dynus_setup

Before running the docker image, let's configure the local machine. 

1. Generate key with gen_ssh_key.sh file and add it to your github account. You can follow this guide: 

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent 

2. Set wired connection ip for lidar to 192.168.1.50 on ubuntu gui

3. Add vehicle name and mavlink id to ~/.bashrc. E.g. for PX01:

```sh 
 echo >> ~/.bashrc
 echo '# Vehicle Vars' >> ~/.bashrc
 echo 'export VEH_NAME="PX01"' >> ~/.bashrc
 echo 'export MAV_SYS_ID="1"' >> ~/.bashrc 
```

For the big drones the mavlink system id and telemtry ids start at 11 so BD03 would have id 13. 

4. Install docker: 

```sh
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done  

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world
```

Debugging: If the hello-world docker doesn't run, run the following: 

```sh
sudo service docker start
sudo docker run hello-world
```


Once that's done, we can setup the docker container.

1. Copy and paste the following code to a terminal window to create the build content directory, copy necessary files there, and git clone this repo. 

```sh
mkdir -p ~/docker/build_context &&
cp ~/.ssh/id_ed25519 ~/docker/build_context &&
cd ~/docker &&
git clone git@github.com:jrached/dynus_setup.git && 
cd ~/docker/dynus_setup && 
git switch docker &&
cp ~/docker/dynus_setup/wls_license/gurobi.lic ~/docker/build_context 

```

2. Build the docker container with 

```sh
docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 -f /home/swarm/docker/dynus_setup/docker/Dockerfile /home/swarm/docker/build_context

``` 

3. Then run it with 

```sh
sudo docker run -it \
      --privileged \
      --network host \
      -v ~/docker/build_context/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
      -v ~/docker/build_context/code/dynus:/root/code/dynus_ws/src/dynus \
      -v ~/docker/build_context/code/livox_ros_driver2:/root/code/livox_ws/src/livox_ros_driver2 \
      --rm  dynus:1

```

4. Inside the container, modify the lidar's ip in the MID360 config file in /root/code/livox_ws/src/livox_ros_driver2/config to be 192.168.1.1xx where xx are the last two digits of the lidar's serial number. 

5. Colcon build and source livox driver workspace inside container

```sh
cd /root/code/livox_ws &&
colcon build && source install/setup.bash &
cd 
```

6. Run dynus with

```sh
dynus 
```

or the trajectory generator with 

```sh
mocap_trajgen
```

 


