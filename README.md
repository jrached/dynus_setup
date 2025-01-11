# dynus_setup


1. Clone this repo.
2. Generate key with gen_ssh_key.sh file and add it to your github account
3. Run setup_dynus.sh script 
4. Go to gurobi and get an academic license 
5. Get ip address using: ifconfig | grep inet. It should be on the 192.168.0.xxx network (raven)
6. Set wired connection ip for lidar to 192.168.1.50 on ubuntu gui
7. Add the following line to the alsa.config file in /usr/share/alsa

pcm.!default { \
                  type plug \
                  slave.pcm "null" \
            }
8. Add vehicle name to ~/.bashrc. E.g. for PX01: echo ' export VEH_NAME="PX01" ' >> ~/.bashrc
9. Reboot for dialout privileges to take effect

TODO: Add d455 installation 

