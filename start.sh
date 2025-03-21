#!/bin/bash

# Source the ROS setup scripts
source /opt/ros/humble/setup.bash
source /root/code/zenoh_ws/install/setup.bash

# Run setup files
#chmod +x ./set_lidar_ip.sh
#./set_lidar_ip.sh
chmod +x /root/code/set_lidar_ip.sh
/root/code/set_lidar_ip.sh
cd /root/code/mavros_ws
colcon build

cd /root/code/livox_ws/src/livox_ros_driver2
./build.sh humble
#colcon build

# Run zenoh bridge
ros2 run zenoh_vendor zenoh-bridge-ros2dds -c /root/code/zenoh_ws/src/zenoh_vendor/configs/zenoh_dynus.json5

# Hold open
#exec bash