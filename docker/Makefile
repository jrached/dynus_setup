#!/bin/bash 

build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t pixstack:1 .

dev-build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t pixstack:1 -f /home/swarm/docker/dynus_setup/docker/Dockerfile /home/swarm/docker/build_context

build-no-cache:
	docker build --build-arg DUMMY=`date +%s` --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t pixstack:1 .

run-hw: 
	sudo docker run -it \
		--privileged \
		--network host \
		-v ~/docker/build_context/gurobi.lic:/opt/gurobi/gurobi.lic:ro \
		-v ~/docker/build_context/code/livox_ws:/root/code/livox_ws \
		-v ~/docker/build_context/code/ros2_px4_stack:/root/code/mavros_ws/src/ros2_px4_stack \
		--rm  pixstack:1