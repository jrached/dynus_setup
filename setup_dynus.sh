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
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc 

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

# Dynus and dependencies ###############################################################################################
mkdir -p /home/swarm/code/dynus_ws/src
cd /home/swarm/code/dynus_ws/src
yes "yes" | git clone git@github.com:kotakondo/dynus.git
cd /home/swarm/code/dynus_ws/src/dynus 
git switch dev-non-uniform
cd /home/swarm/code/dynus_ws/src
git clone git@github.com:kotakondo/dynus_interfaces.git
git clone https://github.com/kotakondo/octomap_mapping.git
git clone https://github.com/kotakondo/realsense_gazebo_plugin.git
git clone https://github.com/kotakondo/livox_laser_simulation_ros2.git
git clone https://github.com/kotakondo/octomap_rviz_plugins.git
git clone https://github.com/kotakondo/gazebo_ros_pkgs.git

mkdir -p /home/swarm/code/decomp_ws/src
cd /home/swarm/code/decomp_ws/src
git clone https://github.com/kotakondo/DecompROS2.git
mkdir -p /home/swarm/code/livox_ws/src
cd /home/swarm/code/livox_ws/src
git clone https://github.com/kotakondo/livox_ros_driver2.git
cd /home/swarm/code
git clone https://github.com/Livox-SDK/Livox-SDK2.git
mkdir -p /home/swarm/code/dlio_ws/src
cd /home/swarm/code/dlio_ws/src 
git clone https://github.com/kotakondo/direct_lidar_inertial_odometry.git 
mkdir -p /home/swarm/code/mavros_ws/src
cd /home/swarm/code/mavros_ws/src
git clone https://github.com/jrached/ros2_px4_stack.git
cd /home/swarm/code/mavros_ws/src/ros2_px4_stack
git switch multiagent 

# Build workspace 
#decomp 
cd /home/swarm/code/decomp_ws
source /opt/ros/humble/setup.sh && colcon build --packages-select decomp_util
source /home/swarm/code/decomp_ws/install/setup.sh && source /opt/ros/humble/setup.sh && colcon build

#Livox-SDK2
cd /home/swarm/code/Livox-SDK2
mkdir build 
cd /home/swarm/code/Livox-SDK2/build 
cmake .. && make -j && sudo make install 

#livox_ros_drver2
cd /home/swarm/code/livox_ws/src/livox_ros_driver2
source /opt/ros/humble/setup.sh && ./build.sh humble

#dlio 
cd /home/swarm/code/dlio_ws
colcon build

#Dynus 
cd /home/swarm/code/dynus_ws
source /opt/ros/humble/setup.sh 
source /home/swarm/code/decomp_ws/install/setup.sh 
export CMAKE_PREFIX_PATH=/home/swarm/code/livox_ws/install/livox_ros_driver2:/home/swarm/code/decomp_ws/install/decomp_util
colcon build

# Add livox to library path 
echo >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/home/swarm/code/livox_ws/install/livox_ros_driver2/lib:${LD_LIBRARY_PATH}" ' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/opt/ros/humble/lib:${LD_LIBRARY_PATH}" ' >> ~/.bashrc

# Useful aliases 
echo 'alias sb="source ~/.bashrc"' >> ~/.bashrc
echo 'alias eb="code ~/.bashrc"' >> ~/.bashrc
echo 'alias gs="git status"' >> ~/.bashrc
echo 'alias gp="git push"' >> ~/.bashrc
echo 'alias roscd="cd ~/code/dynus_ws"' >> ~/.bashrc
echo 'alias cb="roscd && colcon build && sb"' >> ~/.bashrc
echo 'alias ss="roscd && source install/setup.bash"' >> ~/.bashrc
echo 'alias cbd="clear && roscd && colcon build && ss"' >> ~/.bashrc
echo 'alias cbm="clear && roscd && colcon build --packages-select ros2_mapper && ss"' >> ~/.bashrc
echo 'alias cbsl="roscd && colcon build --symlink-install && sb"' >> ~/.bashrc
echo 'alias cbps="roscd && colcon build --packages-select"' >> ~/.bashrc
echo 'alias tf_visualize="ros2 run rqt_tf_tree rqt_tf_tree"' >> ~/.bashrc
echo 'alias tks="tmux kill-server"' >> ~/.bashrc

source ~/.bashrc


# Install mavros 
cd /home/swarm
sudo apt install -y ros-humble-mavros
wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
sudo chmod +x install_geographiclib_datasets.sh
sudo ./install_geographiclib_datasets.sh
rm install_geographiclib_datasets.sh