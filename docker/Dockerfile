FROM ros:humble

LABEL Maintainer="Juan Rached <jrached@mit.edu>" \
      Description="Ubuntu 22.04, ROS2 humble for PIXSTACK"


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
RUN rm -rf /var/lib/apt/lists/*
RUN apt update
RUN apt upgrade -y
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -q -y --no-install-recommends git tmux vim wget tmuxp make ssh openssh-client openssh-server net-tools g++ xterm python3-pip 
RUN pip install pymavlink 
# RUN apt install -y libomp-dev libpcl-dev libeigen3-dev

# Copy ssh key and gurobi license and add github to known ssh hosts 
#########################################
RUN mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && ssh-keyscan github.com >> /root/.ssh/known_hosts 
ADD id_ed25519 /root/.ssh/id_ed25519

# Making directories and setting up the environment
##########################################
WORKDIR /root
RUN mkdir code

# Install dependencies
##########################################
RUN apt-get install -y  ros-${ROS_DISTRO}-pcl-conversions \
                        ros-${ROS_DISTRO}-example-interfaces \
                        ros-${ROS_DISTRO}-pcl-ros \
                        ros-${ROS_DISTRO}-rqt-gui \
                        ros-${ROS_DISTRO}-rqt-gui-py \
                        ros-${ROS_DISTRO}-tf2-tools \
                        ros-${ROS_DISTRO}-tf-transformations

RUN apt install -y  ros-${ROS_DISTRO}-desktop \
                        ros-dev-tools \
                        ros-${ROS_DISTRO}-turtlesim \
                        ros-${ROS_DISTRO}-rqt* \
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

# # Install dlio, mavros interface, and trajectory generator
# ##########################################
# dummy arg to invalidate cache and build from here
ARG DUMMY=unknown
RUN echo DUMMY=${DUMMY}

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
RUN git clone https://github.com/jrached/trajectory_generator_ros2.git
RUN git clone https://github.com/jrached/mission_mode.git
RUN git clone https://github.com/jrached/behavior_selector2.git
RUN git clone https://github.com/jrached/snapstack_msgs2.git

# Build the workspace
##########################################

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
RUN echo 'alias tks="tmux kill-server"' >> ~/.bashrc
RUN echo 'alias sb="source ~/.bashrc"' >> ~/.bashrc
RUN echo 'alias eb="code ~/.bashrc"' >> ~/.bashrc
RUN echo 'alias gs="git status"' >> ~/.bashrc
RUN echo 'alias gp="git push"' >> ~/.bashrc
RUN echo 'alias cbsl="roscd && colcon build --symlink-install && sb"' >> ~/.bashrc
RUN echo 'alias cbps="roscd && colcon build --packages-select"' >> ~/.bashrc
RUN echo 'alias tf_visualize="ros2 run rqt_tf_tree rqt_tf_tree"' >> ~/.bashrc
RUN echo 'alias tks="tmux kill-server"' >> ~/.bashrc
RUN echo 'alias mocap_trajgen="python3 /root/code/mavros_ws/src/ros2_px4_stack/scripts/mocap_trajgen_tmux.py"' >> ~/.bashrc 

### Install mavros 
WORKDIR /root 
RUN apt install -y ros-humble-mavros
RUN apt install -y ros-humble-mavros-extras 
RUN wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh
RUN chmod +x install_geographiclib_datasets.sh 
RUN ./install_geographiclib_datasets.sh 
RUN rm install_geographiclib_datasets.sh 

### Make initial pose file 
RUN touch /root/code/get_init_pose.sh 
RUN echo '#!/bin/bash' >> /root/code/get_init_pose.sh 
RUN echo >> /root/code/get_init_pose.sh 
RUN echo ' source /root/code/mavros_ws/install/setup.bash ' >> /root/code/get_init_pose.sh 
RUN echo ' eval $(ros2 run ros2_px4_stack get_init_pose) ' >> /root/code/get_init_pose.sh 
RUN chmod +x /root/code/get_init_pose.sh

### Install and configure cyclonedds 
RUN apt install -y ros-humble-rmw-cyclonedds-cpp
RUN echo >> ~/.bashrc
RUN echo '# ROS2 RTPS network' >> ~/.bashrc
RUN echo 'export ROS_DOMAIN_ID=10' >> ~/.bashrc
RUN echo 'export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp' >> ~/.bashrc
RUN echo 'export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET' >> ~/.bashrc
RUN echo 'export CYCLONEDDS_URI="<CycloneDDS><Domain><General><NetworkInterfaceAddress>wlo1</NetworkInterfaceAddress></General></Domain></CycloneDDS>"' >> ~/.bashrc
RUN echo >> ~/.bashrc
RUN echo '# Path to library for cyclonedds' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/opt/ros/humble/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH' >> ~/.bashrc
RUN echo >> ~/.bashrc
RUN echo '# Source ros distro' >> ~/.bashrc
RUN echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc

# Set up Entry Point
# ##########################################
WORKDIR /root 
ENTRYPOINT ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && echo 'You have entered the swarm' && exec bash -l"]
