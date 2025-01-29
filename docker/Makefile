# inlcude ~/.bashrc 

build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

dev-build: 
	docker build --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

build-no-cache:
	docker build --build-arg DUMMY=`date +%s` --build-arg VEH_NAME=${VEH_NAME} --build-arg MAV_SYS_ID=${MAV_SYS_ID} -t dynus:1 .

run-container: 
	sudo docker run -it --privileged --network host --rm  dynus:1 .

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