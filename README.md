# pixstack_setup

TODO: Rename repo to pixstack_setup

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

1. Copy and paste the following code to a terminal window to create the build context directory, copy necessary files there, and git clone this repo. 

```sh
mkdir -p ~/docker/build_context &&
cp ~/.ssh/id_ed25519 ~/docker/build_context &&
cd ~/docker &&
git clone git@github.com:jrached/dynus_setup.git && 
cd ~/docker/dynus_setup && 
cp ~/docker/dynus_setup/wls_license/gurobi.lic ~/docker/build_context 
```

Also clone the mavros and livox repos so the volumes don't wipe them in the container. (TODO: Use named volumes to avoid this.)

```sh
mkdir -p ~/docker/build_context/code && cd ~/docker/build_context/code && 
git clone https://github.com/jrached/ros2_px4_stack.git &&
cd ~/docker/build_context/code/ros2_px4_stack &&
git switch multiagent &&
mkdir -p ~/docker/build_context/code/livox_ws/src &&
cd ~/docker/build_context/code/livox_ws/src && 
git clone https://github.com/kotakondo/livox_ros_driver2.git &&
cd ~/docker 
```

2. Build the docker container with 

```sh
sudo docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t pixstack:1 -f ~/docker/dynus_setup/docker/Dockerfile ~/docker/build_context

``` 

3. Then run it with 

```sh
sudo docker run -it \
      --privileged \
      --network host \
      -v ~/docker/build_context/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
      -v ~/docker/build_context/code/livox_ws:/root/code/livox_ws \
      -v ~/docker/build_context/code/ros2_px4_stack:/root/code/mavros_ws/src/ros2_px4_stack \
      --rm  pixstack:1
```

4. Inside the container, run 

```sh
vim ~/code/livox_ws/src/livox_ros_driver2/config/MID360_config.json 
```

And change the lidar's ip to 192.168.1.1xx where xx are the last two digits of the lidar's serial number. 
Then build the livox workspace again with 

```sh 
cd ~/code/livox_ws/src/livox_ros_driver2 
./build.sh humble 
```

6. Run the trajectory generator with 

```sh
mocap_trajgen
```

7. Optionally, in the host machine add an alias to run the docker container with pixstack_docker:

```sh
echo >> ~/.bashrc 
echo '# Alias for pixstack docker' >> ~/.bashrc 
echo 'alias pixstack_docker="cd ~/docker/dynus_setup/docker && make run-hw"' >> ~/.bashrc
source ~/.bashrc
```

 


