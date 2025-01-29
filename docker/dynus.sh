#!/bin/bash

source ~/.bashrc
source /home/code/dynus_ws/install/setup.bash
source /usr/share/gazebo/setup.sh

# (0) default sim
# tmuxp load src/dynus/launch/default_sim.yaml

# (1) docker haredware for ground robot
# tmuxp load src/dynus/launch/docker_hardware_ground_robot.yaml

# (2) docker sim
tmuxp load src/dynus/launch/docker_sim.yaml