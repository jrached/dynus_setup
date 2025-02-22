#!/bin/bash

# Source the ROS setup scripts
source /opt/ros/humble/setup.bash
source /root/code/zenoh_ws/install/setup.bash

# Run zenoh bridge
ros2 run zenoh_vendor zenoh-bridge-ros2dds -c /root/code/zenoh_ws/src/zenoh_vendor/configs/zenoh_dynus.json5

# Hold open
#exec bash