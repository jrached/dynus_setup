FROM ros:humble
#FROM osrf/ros:humble-desktop

LABEL Maintainer="Juan Rached <jrached@mit.edu>" \
      Description="Ubuntu 22.04, ROS2 humble for DYNUS"


# Declare arguments
ARG VEH_NAME
ARG MAV_SYS_ID  

ENV VEH_NAME=$VEH_NAME
ENV MAV_SYS_ID=$MAV_SYS_ID
ENV DUMMYY=0

# Add root user to dialout group 
RUN usermod -aG dialout root 

# Set environment variables
##########################################
ENV ROS_DISTRO=humble
ENV DEBIAN_FRONTEND=noninteractive

# Usuals
##########################################
RUN rm -rf /var/lib/apt/lists/* && \
    apt update && apt upgrade -y && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -q -y --no-install-recommends \
        git tmux vim wget tmuxp make ssh openssh-client openssh-server \
        net-tools g++ xterm python3-pip libomp-dev libpcl-dev libeigen3-dev \
        curl && \
    pip install pymavlink

    
# Copy ssh key and gurobi license 
# and add github to known ssh hosts 
#########################################
RUN mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && ssh-keyscan github.com >> /root/.ssh/known_hosts 
#ADD id_ed25519 /root/.ssh/id_ed25519


# Setup GitHub Authentication
##########################################

## Token-based authentication

# Install gh for authentication
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install -y gh

# Copy the token file into the container
COPY .auth/token_gh.txt /root/token_gh.txt

# Authenticate GitHub using the token from the file
RUN cat /root/token_gh.txt | gh auth login --with-token && rm /root/token_gh.txt

# Setup git credentials
RUN git config --global user.name "Harvey Merton" \
    && git config --global user.email "hmer101@mit.edu"


## SSH-based authentication

# Create SSH directory
RUN mkdir -p /root/.ssh

# Copy SSH private and public key
COPY .auth/id_ed25519 /root/.ssh/id_ed25519
COPY .auth/id_ed25519.pub /root/.ssh/id_ed25519.pub

# Set correct permissions
RUN chmod 600 /root/.ssh/id_ed25519 && \
    chmod 644 /root/.ssh/id_ed25519.pub && \
    chmod 700 /root/.ssh

# Add GitHub to known hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts


# Making directories and setting up the environment
##########################################
WORKDIR /root
RUN mkdir code

# Install dependencies
##########################################
RUN apt-get install -y  ros-${ROS_DISTRO}-octomap \
                        ros-${ROS_DISTRO}-octomap-msgs \
                        ros-${ROS_DISTRO}-octomap-ros \
                        ros-${ROS_DISTRO}-octomap-rviz-plugins \
                        ros-${ROS_DISTRO}-gazebo-* \
                        ros-${ROS_DISTRO}-pcl-conversions \
                        ros-${ROS_DISTRO}-example-interfaces \
                        ros-${ROS_DISTRO}-pcl-ros \
                        ros-${ROS_DISTRO}-rviz2 \
                        ros-${ROS_DISTRO}-rqt-gui \
                        ros-${ROS_DISTRO}-rqt-gui-py \
                        ros-${ROS_DISTRO}-tf2-tools \
                        ros-${ROS_DISTRO}-tf-transformations

RUN apt install -y  ros-${ROS_DISTRO}-desktop \
                        ros-dev-tools \
                        ros-${ROS_DISTRO}-turtlesim \
                        ros-${ROS_DISTRO}-rqt* \
                        ros-${ROS_DISTRO}-rviz2 \
                        # ros-${ROS_DISTRO}-gazebo-ros-pkgs \
                        ros-${ROS_DISTRO}-rviz-common \ 
                        libpcl-dev \
                        build-essential


# # Gurobi
# ##########################################
RUN wget https://packages.gurobi.com/11.0/gurobi11.0.3_linux64.tar.gz -P . && \
      tar -xzf gurobi11.0.3_linux64.tar.gz && \
      rm gurobi11.0.3_linux64.tar.gz && \
      mv gurobi1103/ /opt
WORKDIR /opt/gurobi1103/linux64/src/build
RUN make && cp libgurobi_c++.a ../../lib/
RUN echo >> ~/.bashrc
ENV GUROBI_HOME="/opt/gurobi1103/linux64"
ENV PATH="${PATH}:${GUROBI_HOME}/bin"
ENV LD_LIBRARY_PATH="${GUROBI_HOME}/lib"

# # Install DYNUS and dependencies
# ##########################################
RUN mkdir -p /root/code/dynus_ws/src
WORKDIR /root/code/dynus_ws/src
# dummy arg to invalidate cache and build from here
ARG DUMMY=unknown
RUN echo DUMMY=${DUMMY}
RUN git clone git@github.com:kotakondo/dynus.git 
WORKDIR /root/code/dynus_ws/src/dynus
RUN git switch hw
WORKDIR /root/code/dynus_ws/src
RUN git clone git@github.com:kotakondo/dynus_interfaces.git && \
    git clone https://github.com/kotakondo/octomap_mapping.git && \
    git clone https://github.com/kotakondo/realsense_gazebo_plugin.git && \
    git clone https://github.com/kotakondo/livox_laser_simulation_ros2.git && \
    git clone https://github.com/kotakondo/octomap_rviz_plugins.git && \
    git clone https://github.com/kotakondo/gazebo_ros_pkgs.git


RUN mkdir -p /root/code/decomp_ws/src
WORKDIR /root/code/decomp_ws/src
RUN git clone https://github.com/kotakondo/DecompROS2.git
RUN mkdir -p /root/code/livox_ws/src
WORKDIR /root/code/livox_ws/src
RUN git clone https://github.com/kotakondo/livox_ros_driver2.git
WORKDIR /root/code
RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git
RUN mkdir -p /root/code/dlio_ws/src 
WORKDIR /root/code/dlio_ws/src 
RUN git clone https://github.com/jrached/direct_lidar_inertial_odometry.git
RUN mkdir -p /root/code/mavros_ws/src
WORKDIR /root/code/mavros_ws/src 
RUN git clone https://github.com/jrached/ros2_px4_stack.git
WORKDIR /root/code/mavros_ws/src/ros2_px4_stack 
RUN git switch multiagent 
RUN mkdir -p /root/code/trajgen_ws/src
WORKDIR /root/code/trajgen_ws/src 
RUN git clone https://github.com/jrached/trajectory_generator_ros2.git && \
    git clone https://github.com/jrached/mission_mode.git && \
    git clone https://github.com/jrached/behavior_selector2.git && \
    git clone https://github.com/jrached/snapstack_msgs2.git


# Build the workspace
##########################################

### for decomp
WORKDIR /root/code/decomp_ws
RUN . /opt/ros/humble/setup.sh && colcon build --packages-select decomp_util
RUN . /root/code/decomp_ws/install/setup.sh && . /opt/ros/humble/setup.sh && colcon build

### for Livox-SDK2
WORKDIR /root/code/Livox-SDK2
RUN mkdir build
WORKDIR /root/code/Livox-SDK2/build
RUN cmake .. && make -j && sudo make install

### for livox_ros_driver2
WORKDIR /root/code/livox_ws/src/livox_ros_driver2
RUN . /opt/ros/humble/setup.sh && ./build.sh humble

### dlio 
WORKDIR /root/code/dlio_ws
RUN bash -c 'source /opt/ros/humble/setup.bash && colcon build'

### trajectory generator 
WORKDIR /root/code/trajgen_ws
RUN bash -c 'source /opt/ros/humble/setup.bash && colcon build --packages-select snapstack_msgs2' 
RUN bash -c '. install/setup.bash && colcon build'

### mavros interface 
WORKDIR /root/code/mavros_ws
RUN colcon build 

### for other packages
WORKDIR /root/code/dynus_ws
# (1) gurobi dependencies, (2) decomp dependencies, (3) livox dependencies for colcon build
RUN bash -c '. /opt/ros/humble/setup.sh && \
    . /root/code/decomp_ws/install/setup.sh && \
    export CMAKE_PREFIX_PATH=/root/code/livox_ws/install/livox_ros_driver2:/root/code/decomp_ws/install/decomp_util && \
    colcon build'

# Gazebo
##########################################
### handle ALSA-related error
RUN echo    'pcm.!default { \
                  type plug \
                  slave.pcm "null" \
            }' >> /usr/share/alsa/alsa.conf

# For livox lidar
ENV LD_LIBRARY_PATH=/root/code/livox_ws/install/livox_ros_driver2/lib:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH=/opt/ros/humble/lib:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH=/root/code/decomp_ws/install/decomp_ros_msgs/lib:${LD_LIBRARY_PATH}

# Alias
RUN echo 'alias tks="tmux kill-server"' >> ~/.bashrc && \
    echo 'alias sb="source ~/.bashrc"' >> ~/.bashrc && \
    echo 'alias eb="code ~/.bashrc"' >> ~/.bashrc && \
    echo 'alias gs="git status"' >> ~/.bashrc && \
    echo 'alias gp="git push"' >> ~/.bashrc && \
    echo 'alias roscd="cd ~/code/dynus_ws"' >> ~/.bashrc && \
    echo 'alias cb="roscd && colcon build && sb"' >> ~/.bashrc && \
    echo 'alias ss="roscd && source install/setup.bash"' >> ~/.bashrc && \
    echo 'alias cbd="clear && roscd && colcon build && ss"' >> ~/.bashrc && \
    echo 'alias cbm="clear && roscd && colcon build --packages-select ros2_mapper && ss"' >> ~/.bashrc && \
    echo 'alias cbsl="roscd && colcon build --symlink-install && sb"' >> ~/.bashrc && \
    echo 'alias cbps="roscd && colcon build --packages-select"' >> ~/.bashrc && \
    echo 'alias tf_visualize="ros2 run rqt_tf_tree rqt_tf_tree"' >> ~/.bashrc && \
    echo 'alias dynus="python3 /root/code/mavros_ws/src/ros2_px4_stack/scripts/livox_dynus_tmux.py"' >> ~/.bashrc && \
    echo 'alias mocap_trajgen="python3 /root/code/mavros_ws/src/ros2_px4_stack/scripts/mocap_trajgen_tmux.py"' >> ~/.bashrc


### Install mavros 
WORKDIR /root 
RUN apt install -y ros-humble-mavros ros-humble-mavros-extras && \
    wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh && \
    chmod +x install_geographiclib_datasets.sh && \
    ./install_geographiclib_datasets.sh && \
    rm install_geographiclib_datasets.sh


### Make initial pose file 
#COPY get_init_pose.sh /root/code/
COPY repos/dynus_setup/get_init_pose.sh /root/code/
RUN chmod +x /root/code/get_init_pose.sh


### ROS2
#########################
# Install cycloneDDS
### Install and configure cyclonedds 
RUN apt install -y ros-humble-rmw-cyclonedds-cpp && \
    echo >> ~/.bashrc && \
    echo '# ROS2 RTPS network' >> ~/.bashrc && \
    #echo 'export ROS_DOMAIN_ID=10' >> ~/.bashrc && \
    #echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> ~/.bashrc && \
    #echo 'export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET' >> ~/.bashrc && \
    #echo 'export CYCLONEDDS_URI="<CycloneDDS><Domain><General><NetworkInterfaceAddress>wlo1</NetworkInterfaceAddress></General></Domain></CycloneDDS>"' >> ~/.bashrc && \
    echo >> ~/.bashrc && \
    echo '# Path to library for cyclonedds' >> ~/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/opt/ros/humble/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc && \
    echo >> ~/.bashrc && \
    echo '# Source ros distro' >> ~/.bashrc && \
    echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc


# Setup Zenoh
##########################################
COPY /ws_ros2/src/zenoh_vendor /root/code/zenoh_ws/src/zenoh_vendor

RUN apt update && apt install -y unzip
RUN cd /root/code/zenoh_ws/ && \
    . /opt/ros/humble/setup.sh && \
    colcon build --packages-select zenoh_vendor

RUN echo "export ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST" >> ~/.bashrc
#RUN echo "export ROS_LOCALHOST_ONLY=1" >> ~/.bashrc
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc
RUN echo "export ROS_DOMAIN_ID=10" >> ~/.bashrc


### for mavros
RUN mkdir -p /root/code/bridge_ws/src
WORKDIR /root/code/bridge_ws/src 
RUN git clone https://github.com/jrached/mavros.git

WORKDIR /root/code/bridge_ws
RUN . /opt/ros/humble/setup.sh && colcon build 
#--packages-select mavros
RUN . /root/code/bridge_ws/install/setup.sh && . /opt/ros/humble/setup.sh && colcon build

# RUN bash -c 'colcon build'
# RUN bash -c '. install/setup.bash'


### Copy over what was previously in volumes
WORKDIR /
COPY /ws_ros2/src/ros2_px4_stack /root/code/mavros_ws/src/ros2_px4_stack
#~/docker/build_context/code
COPY /ws_ros2/src/livox_ros_driver2 /root/code/livox_ws/src/livox_ros_driver2
#~/docker/build_context/code/livox_ws/src
COPY /repos/dynus_setup/wls_license/gurobi.lic /opt/gurobi/gurobi.lic

# Make directory for bagfile
RUN mkdir -p /root/code/data/bags

# mkdir -p ~/docker/build_context/code && cd ~/docker/build_context/code && 
# git clone https://github.com/jrached/ros2_px4_stack.git &&
# #cd ~/docker/build_context/code/ros2_px4_stack &&
# #git switch multiagent &&

# mkdir -p ~/docker/build_context/code/livox_ws/src &&
# cd ~/docker/build_context/code/livox_ws/src && 
# git clone https://github.com/kotakondo/livox_ros_driver2.git &&
# cd ~/docker


# install nano 
RUN sudo apt-get update && sudo apt-get install -y nano

# Set up Entry Point
# ##########################################

# Use the script as the entry point
COPY repos/dynus_setup/set_lidar_ip.sh /root/code/
COPY repos/dynus_setup/start.sh /root/code/
RUN chmod +x /root/code/start.sh

# Source and setup the workspace
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /root/code/zenoh_ws/install/setup.bash" >> ~/.bashrc


#RUN echo "export ROS_LOCALHOST_ONLY=1" >> ~/.bashrc # MIGHT NEED TO USE THIS BUT SEEMS TO WORK WITHOUT CURRENTLY - only 1 drone and 1 laptop 



WORKDIR /root 
CMD ["/root/code/start.sh"]


# Set up Entry Point
# ##########################################
# WORKDIR /root 
# ENTRYPOINT ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && echo 'You have entered the swarm' && exec bash -l"]

# # RUN . /opt/ros/humble/setup.sh && colcon build

# # RUN pip install --upgrade pip
# # RUN pip install python-box numpy-quaternion termcolor -U scikit-image defusedxml PySide2 wheel
# # RUN pip install empy

# # ## Download and install motlee and clipper in the submodules directory
# # WORKDIR /root/code/ws/src/puma/submodules

# # # Clone the FastSAM repository and install it
# # ##########################################
# # WORKDIR /root/code/ws/src/puma/submodules/FastSAM
# # RUN pip install -r requirements.txt
# # RUN pip install git+https://github.com/openai/CLIP.git
# # RUN pip install -e .

# # # Install motlee
# # ##########################################
# # WORKDIR /root/code/ws/src/puma/submodules/motlee
# # RUN pip install --ignore-installed PyYAML
# # RUN pip install -e .

# # # Install clipper
# # ##########################################
# # WORKDIR /root/code/ws/src/puma/submodules/clipper/build
# # RUN cmake ..
# # RUN make
# # RUN python3 -m pip install bindings/python
# # WORKDIR /root/code/ws/src/puma

# # # Create a symlink of FastSAM to the scripts directory
# # # Note that "ln -s FastSAM ../../puma/puma/scripts/FastSAM/" creates a broken link (https://mokacoding.com/blog/symliks-in-git/)
# # ##########################################
# # WORKDIR /root/code/ws/src/puma/puma/scripts
# # RUN ln -s ../../../puma/submodules/FastSAM/ .

# # # Need to run this to make Gazebo publish images
# # ##########################################
# # RUN apt-get install  -y


# From project folder:
# balena push dynus --dockerfile repos/dynus_setup/docker/Dockerfile --source .




# Setup on drone
# cd /mnt/boot/system-connections
# vi Ethernet 

# Set wired connection ip for lidar to 192.168.1.50 (copy Ethernet file to hostOS)

# Ask Juan: Steps 1 & 4 (docker container setup)
# Lidar ethernet 

# Needs changing: vim ~/code/livox_ws/src/livox_ros_driver2/config/MID360_config.json 

# Might need to copy gurobi file to: /opt/gurobi/gurobi.lic:ro (from docker setup readmd)