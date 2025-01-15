# dynus_setup


1. Clone this repo.
2. Generate key with gen_ssh_key.sh file and add it to your github account
3. Run setup_dynus.sh script 
4. Go to gurobi and get an academic license 
5. Get ip address using: ifconfig | grep inet. It should be on the 192.168.0.xxx network (raven). Save it somewhere
6. Set wired connection ip for lidar to 192.168.1.50 on ubuntu gui
7. Modify the MID360 config file in livox_driver_ros2 to be 192.168.1.1xx where xx are last two digits of serial number
8. Add the following line to the alsa.config file in /usr/share/alsa

pcm.!default { \
                  type plug \
                  slave.pcm "null" \
            }

9. Add vehicle name to ~/.bashrc. E.g. for PX01: echo ' export VEH_NAME="PX01" ' >> ~/.bashrc

10. Reboot for dialout privileges to take effect

11. Modify hardware_blue_drone.yaml to use the right vehicle name as namespace and add source ~/code/get_init_pose.sh before running dynus_mavros.launch 

TODO: Add d455 installation 

