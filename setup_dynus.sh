#!/bin/bash 

# This will prompt the user for sudo password and the credentials will be cached for 15 minutes
# All subsequent sudo commands won't prompt user for password as it is already cached
sudo -v 

# Go to home directory and create code directory 
cd /home/swarm
mkdir code

# Basic software ########################################################################################################################################
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
sudo apt upgrade -y
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -q -y --no-install-recommends git tmux vim wget tmuxp make openssh-server net-tools g++ xterm python3-pip 
pip install pymavlink
sudo apt install -y libomp-dev libpcl-dev libeigen3-dev

# Install ros humble ##########################################################################################################################################################
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt install software-properties-common
echo -e "\n" | sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update 
sudo apt upgrade

sudo apt install -y ros-humble-desktop 
sudo apt install -y ros-dev-tools 

echo >> ~/.bashrc
echo '# Source ros distro' >> ~/.bashrc
echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc 

export ROS_DISTRO=humble
# Ros dependencies ##################################################################################################
sudo apt-get install -y  ros-${ROS_DISTRO}-octomap 
sudo apt-get install -y  ros-${ROS_DISTRO}-octomap-msgs 
sudo apt-get install -y  ros-${ROS_DISTRO}-octomap-ros 
sudo apt-get install -y  ros-${ROS_DISTRO}-octomap-rviz-plugins 
sudo apt-get install -y  ros-${ROS_DISTRO}-gazebo-* 
sudo apt-get install -y  ros-${ROS_DISTRO}-pcl-conversions 
sudo apt-get install -y  ros-${ROS_DISTRO}-example-interfaces 
sudo apt-get install -y  ros-${ROS_DISTRO}-pcl-ros 
sudo apt-get install -y  ros-${ROS_DISTRO}-rviz2 
sudo apt-get install -y  ros-${ROS_DISTRO}-rqt-gui 
sudo apt-get install -y  ros-${ROS_DISTRO}-rqt-gui-py 
sudo apt-get install -y  ros-${ROS_DISTRO}-tf2-tools 
sudo apt-get install -y  ros-${ROS_DISTRO}-tf-transformations

sudo apt install -y  ros-${ROS_DISTRO}-turtlesim 
sudo apt install -y  ros-${ROS_DISTRO}-rqt* 
sudo apt install -y  ros-${ROS_DISTRO}-rviz2 
sudo apt install -y  ros-${ROS_DISTRO}-gazebo-ros-pkgs 
sudo apt install -y  ros-${ROS_DISTRO}-rviz-common 
sudo apt install -y  libpcl-dev 
sudo apt install -y  build-essential

# Install Gurobi ######################################################################################################
wget https://packages.gurobi.com/11.0/gurobi11.0.3_linux64.tar.gz -P . 
tar -xzf gurobi11.0.3_linux64.tar.gz
rm gurobi11.0.3_linux64.tar.gz
sudo mv gurobi1103/ /opt

cd /opt/gurobi1103/linux64/src/build 
make && cp libgurobi_c++.a ../../lib/
echo >> ~/.bashrc
echo "# Gurobi" >> ~/.bashrc
echo 'export GUROBI_HOME="/opt/gurobi1103/linux64" ' >> ~/.bashrc
echo 'export PATH="${PATH}:${GUROBI_HOME}/bin" ' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="${GUROBI_HOME}/lib" ' >> ~/.bashrc
source ~/.bashrc 

export GUROBI_HOME="/opt/gurobi1103/linux64" 
export PATH="${PATH}:${GUROBI_HOME}/bin" 
export LD_LIBRARY_PATH="${GUROBI_HOME}/lib" 

# Add github ssh key to known hosts
echo >> ~/.ssh/known_hosts 
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Mavros Stack and Trajectory Generator ###############################################################################################
mkdir -p /home/swarm/code/mavros_ws/src
cd /home/swarm/code/mavros_ws/src
git clone https://github.com/jrached/trajectory_generator_ros2.git
git clone https://github.com/jrached/behavior_selector2.git
git clone https://github.com/jrached/mission_mode.git
git clone https://github.com/jrached/snapstack_msgs2.git 
git clone https://github.com/jrached/ros2_px4_stack.git
cd /home/swarm/code/mavros_ws/src/ros2_px4_stack
git switch multiagent 

#mavros interface
cd /home/swarm/code/mavros_ws
colcon build --packages-select snapstack_msgs2 
source install/setup.bash 
colcon build 

# Add ros to library path 
echo >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/opt/ros/humble/lib:${LD_LIBRARY_PATH}" ' >> ~/.bashrc
source ~/.bashrc

# Install mavros 
cd /home/swarm
sudo apt install -y ros-humble-mavros 
sudo apt install -y ros-humble-mavros-extras 
wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
sudo chmod +x install_geographiclib_datasets.sh
sudo ./install_geographiclib_datasets.sh
rm install_geographiclib_datasets.sh

# Add user to dialout group to use ttyACM port
sudo usermod -aG dialout ${USER}

touch ~/code/get_init_pose.sh 
echo '#!/bin/bash' >> ~/code/get_init_pose.sh 
echo >> ~/code/get_init_pose.sh 
echo ' source ~/code/mavros_ws/install/setup.bash ' >> ~/code/get_init_pose.sh 
echo ' eval $(ros2 run ros2_px4_stack get_init_pose) ' >> ~/code/get_init_pose.sh 
sudo chmod +x /home/swarm/code/get_init_pose.sh 

# Install and configure cyclonedds
sudo apt install -y ros-humble-rmw-cyclonedds-cpp

echo >> ~/.bashrc
echo '# ROS2 RTPS network' >> ~/.bashrc
echo 'export ROS_DOMAIN_ID=10' >> ~/.bashrc
echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> ~/.bashrc
echo 'export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET' >> ~/.bashrc
echo 'export CYCLONEDDS_URI="<CycloneDDS><Domain><General><NetworkInterfaceAddress>wlo1</NetworkInterfaceAddress></General></Domain></CycloneDDS>"' >> ~/.bashrc
echo >> ~/.bashrc
echo '# Path to library for cyclonedds' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/ros/humble/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc


# Vehicle name  
echo >> ~/.bashrc 
echo '# Change to unique vehicle name' >> ~/.bashrc 
echo 'export VEH_NAME="6QUAD"' >> ~/.bashrc 

source ~/.bashrc