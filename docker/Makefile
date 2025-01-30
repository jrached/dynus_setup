#!/bin/bash 

build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

dev-build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 -f /home/swarm/docker/dynus_setup/docker/Dockerfile /home/swarm/docker/build_context
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .


build-no-cache:
	docker build --build-arg DUMMY=`date +%s` --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

run-hw: 
	sudo docker run -it \
		--privileged \
		--network host \
		-v ~/docker/build_context/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
		-v ~/docker/build_context/code/dynus:/root/code/dynus_ws/src/dynus \
		-v ~/docker/build_context/code/livox_ws:/root/code/livox_ws \
		--rm  dynus:1

run-sim:
	docker run  -it \
				--gpus all \
				--env="NVIDIA_DRIVER_CAPABILITIES=all" \
				--privileged \
				-e DISPLAY=${DISPLAY} \
				--network=host \
				--env="DISPLAY" \
				--env="QT_X11_NO_MITSHM=1" \
				--volume=${PWD}/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
				--rm dynus:1

run-rr01:
	docker run  -it \
				--privileged \
				-e DISPLAY=${DISPLAY} \
				--env="DISPLAY" \
				--env="QT_X11_NO_MITSHM=1" \
				--volume=${PWD}/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
				--rm dynus:1





# old build 
# docker build --build-arg GIT_ACCESS_TOKEN=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 -t dynus:1 .

# works run 
# sudo docker run -it --privileged --network host -v ${PWD}/gurobi.lic:/opt/gurobi/gurobi.lic:ro -v code/dynus:/root/code/dynus_ws/src/dynus -v code/livox_ros_driver2:/root/code/livox_ws/src/livox_ros_driver2 --rm  dynus:1 

####TODO: 
# 1. Modify run command to have 3 volumes: One for the gurobi license, one for the livox_ws and one for dynus_ws 
# 2. Figure out how to actually get environment variables in make file
# 3. Add instructions on how to setup nuc prior to docker (including installing docker)
# 4. Ideally add those code snippets to the github readme so that users can just copy from there.