#!/bin/bash

# This will prompt the user for sudo password and the credentials will be cached for 15 minutes
# All subsequent sudo commands won't prompt user for password as it is already cached
##########################################
sudo -v

# Retrieve and set environment variables
##########################################
clear -x
echo 'What is the VEH_NAME?'
read VEH_NAME

echo 'What is the MAV_SYS_ID?'
read MAV_SYS_ID

echo "
# Dynus Variables
export VEH_NAME=${VEH_NAME}
export MAV_SYS_ID=${MAV_SYS_ID}" >> ~/.bashrc
source ~/.bashrc

echo "VEH_NAME = ${VEH_NAME} and MAV_SYS_ID = ${MAV_SYS_ID} have been saved."
sleep 2

export ROS_DISTRO=humble
export DEBIAN_FRONTEND=noninteractive

# Add root user to dialout group
sudo usermod -aG dialout $USER

# Save current path and make executables
export SETUP_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install global dependencies
##########################################
sudo rm -rf /var/lib/apt/lists/*
sudo apt update && sudo apt upgrade -y
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -q -y --no-install-recommends tmux vim wget ssh openssh-client openssh-server curl tmuxp make net-tools g++ xterm python3-pip unzip libasio-dev
sudo apt-get install -y libomp-dev libpcl-dev libeigen3-dev
pip install pymavlink # specify that it is a user install
source "~/.profile"

# Update locales
sudo apt update && sudo apt upgrade -y
sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Install ROS
##########################################
mkdir ~/code
cd ~/code

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update

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

sudo apt install ros-${ROS_DISTRO}-mavlink
sudo apt-get install -y  ros-${ROS_DISTRO}-desktop
sudo apt-get install -y ros-dev-tools
sudo apt-get install -y  ros-${ROS_DISTRO}-turtlesim
sudo apt-get install -y  ros-${ROS_DISTRO}-rqt*
sudo apt-get install -y  ros-${ROS_DISTRO}-rviz-common
sudo apt-get install -y  libpcl-dev
sudo apt-get install -y  build-essential

echo "
# ROS setup
source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Make dirctory for bagfile
mkdir --parents ~/code/data/bags

# Install mavros
cd ~/
sudo apt install -y ros-humble-mavros ros-humble-mavros-extras
wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
sudo chmod +x install_geographiclib_datasets.sh
sudo bash install_geographiclib_datasets.sh # changed to use bash, not source
rm install_geographiclib_datasets.sh

# Install Gurobi
##########################################
cd ~/code
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

# Copy over the Gurobi license
cp ${SETUP_PATH}/wls_license/gurobi.lic ${HOME}

# Install DYNUS and dependencies
##########################################
# dynus_ws
mkdir -p ~/code/dynus_ws/src
cd ~/code/dynus_ws/src
git clone git@github.com:kotakondo/dynus.git
git clone https://github.com/kotakondo/dynus_interfaces.git
git clone https://github.com/kotakondo/octomap_mapping.git
git clone https://github.com/kotakondo/realsense_gazebo_plugin.git
git clone https://github.com/kotakondo/livox_laser_simulation_ros2.git
git clone https://github.com/kotakondo/octomap_rviz_plugins.git
git clone https://github.com/kotakondo/gazebo_ros_pkgs.git

# decomp_ws
mkdir -p ~/code/decomp_ws/src
cd ~/code/decomp_ws/src
git clone https://github.com/kotakondo/DecompROS2.git

# livox_ws
mkdir -p ~/code/livox_ws/src
cd ~/code/livox_ws/src
git clone https://github.com/kotakondo/livox_ros_driver2.git

# Livox-SDK2
cd ~/code # verify
git clone https://github.com/Livox-SDK/Livox-SDK2.git

# dlio_ws
mkdir -p ~/code/dlio_ws/src
cd ~/code/dlio_ws/src
git clone https://github.com/jrached/direct_lidar_inertial_odometry.git

# ros2_px4_stack
mkdir -p ~/code/mavros_ws/src
cd ~/code/mavros_ws/src
git clone https://github.com/jrached/ros2_px4_stack.git

# trajgen_ws
mkdir -p ~/code/trajgen_ws/src
cd ~/code/trajgen_ws/src
git clone https://github.com/jrached/trajectory_generator_ros2.git
git clone https://github.com/jrached/mission_mode.git
git clone https://github.com/jrached/behavior_selector2.git
git clone https://github.com/jrached/snapstack_msgs2.git

# bridge_ws
mkdir -p ~/code/bridge_ws/src
cd ~/code/bridge_ws/src
git clone https://github.com/jrached/mavros.git

# zenoh_ws
mkdir -p ~/code/zenoh_ws/src
cd ~/code/zenoh_ws/src
git clone https://github.com/jrached/zenoh_vendor.git

# Build the workspace
##########################################
# decomp_ws HAS ERRORS IN CODE
cd ~/code/decomp_ws
source /opt/ros/humble/setup.sh && colcon build --packages-select decomp_util
source ~/code/decomp_ws/install/setup.sh && source /opt/ros/humble/setup.sh && colcon build

# Livox-SDK2 HAS ERRORS IN CODE
cd ~/code/Livox-SDK2
mkdir build
cd ~/code/Livox-SDK2/build
cmake .. && make -j && sudo make install

# livox_ros_drver2 HAS ERRORS IN CODE
cd ~/code/livox_ws/src/livox_ros_driver2
source /opt/ros/humble/setup.sh && ./build.sh humble

# dlio_ws
cd ~/code/dlio_ws
source /opt/ros/humble/setup.bash && colcon build

# trajgen_ws HAS ERRORS IN CODE
cd ~/code/trajgen_ws
source /opt/ros/humble/setup.bash && colcon build --packages-select snapstack_msgs2
source install/setup.bash && colcon build

# mavros_ws
cd ~/code/mavros_ws
colcon build

# dynus_ws
cd ~/code/dynus_ws
source /opt/ros/humble/setup.sh
source ~/code/decomp_ws/install/setup.sh
export CMAKE_PREFIX_PATH=~/code/livox_ws/install/livox_ros_driver2:~/code/decomp_ws/install/decomp_util
colcon build # gives a risks message

# bridge_ws
cd ~/code/bridge_ws
source /opt/ros/humble/setup.sh && colcon build
source ~/code/bridge_ws/install/setup.sh
source /opt/ros/humble/setup.sh && colcon build

# zenoh_ws
cd ~/code/zenoh_ws
source /opt/ros/humble/setup.sh && colcon build

# Gazebo
##########################################
# Handle ALSA-related error
echo '
pcm.!default {
    type plug
    slave.pcm "null"
}' | sudo tee -a /usr/share/alsa/alsa.conf

# Paths for Livox Lidar
export LD_LIBRARY_PATH=/root/code/livox_ws/install/livox_ros_driver2/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=/opt/ros/humble/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=/root/code/decomp_ws/install/decomp_ros_msgs/lib:${LD_LIBRARY_PATH}

# Relevant aliases
echo '
alias tks="tmux kill-server"
alias sb="source ~/.bashrc"
alias eb="code ~/.bashrc"
alias gs="git status"
alias gp="git push"
alias roscd="cd ~/code/dynus_ws"
alias cb="roscd && colcon build && sb"
alias ss="roscd && source install/setup.bash"
alias cbd="clear && roscd && colcon build && ss"
alias cbm="clear && roscd && colcon build --packages-select ros2_mapper && ss"
alias cbsl="roscd && colcon build --symlink-install && sb"
alias cbps="roscd && colcon build --packages-select"
alias tf_visualize="ros2 run rqt_tf_tree rqt_tf_tree"
alias dynus="python3 ~/code/mavros_ws/src/ros2_px4_stack/scripts/livox_dynus_tmux.py"
alias mocap_trajgen="python3 ~/code/mavros_ws/src/ros2_px4_stack/scripts/mocap_trajgen_tmux.py"
alias zenoh_router="source ~/code/zenoh_ws/install/setup.bash && ros2 run zenoh_vendor zenoh-bridge-ros2dds -c ~/code/zenoh_ws/src/zenoh_vendor/configs/zenoh_agent.json5"
' >> ~/.bashrc
source ~/.bashrc

# Make initial pose file
##########################################
cp ${SETUP_PATH}/get_init_pose.sh ~/code/
sudo chmod +x ~/code/get_init_pose.sh

# Install cycloneDDS
##########################################
sudo apt install -y ros-humble-rmw-cyclonedds-cpp
echo '
# Path to library for cyclonedds
export LD_LIBRARY_PATH="/opt/ros/humble/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"

# Source ros distro
source /opt/ros/humble/setup.bash' >> ~/.bashrc
source ~/.bashrc

# Setup Zenoh (untested)
##########################################
echo '
# Zenoh
source ~/code/zenoh_ws/install/setup.bash'>> ~/.bashrc

echo '
# ROS2 RTPS network
export ROS_DOMAIN_ID=10
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST' >> ~/.bashrc
source ~/.bashrc

# Lidar IP
##########################################
# Set wired IP
# Not done #############

# Retrieve Lidar SN
chmod -x ${SETUP_PATH}/set_lidar_ip.sh
clear -x
source ${SETUP_PATH}/set_lidar_ip.sh
source /opt/ros/humble/setup.sh && cd ~/code/livox_ws/ && colcon build && source install/setup.bash && cd 
source ~/.bashrc

clear -x
echo 'Dynus setup completed.'
echo 'Reboot for dialout priviledges to take effect'

# ADD THE FOLLOWING TO BASH:
##########################################
##########################################
# Set wired connection ip for lidar to 192.168.1.50 (copy Ethernet file to hostOS)
