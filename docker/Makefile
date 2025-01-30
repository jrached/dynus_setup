#!/bin/bash 

SHELL:=/bin/bash

build: 
	bash -c " echo '${VEH_NAME}'"
	echo "$(VEH_NAME)"
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

dev-build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 -f /home/swarm/docker/dynus_setup/docker/Dockerfile /home/swarm/docker/build_context
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .


build-no-cache:
	docker build --build-arg DUMMY=`date +%s` --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

run-hw: 
	sudo docker run -it --privileged --network host --volume=${PWD}/gurobi.lic:/opt/gurobi/gurobi.lic:ro --rm  dynus:1 

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


# docker build --build-arg GIT_ACCESS_TOKEN=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 -t dynus:1 .

####TODO: 
# 1. Modify run command to have 3 volumes: One for the gurobi license, one for the livox_ws and one for dynus_ws 
# 2. Figure out how to actually get environment variables in make file
# 3. Add instructions on how to setup nuc prior to docker (including installing docker)
# 4. Ideally add those code snippets to the github readme so that users can just copy from there.