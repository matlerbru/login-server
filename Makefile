name:=login-server
port:=21986

path:=/opt/${name}
volume:=/var/${name}

container_id:=$(shell docker ps -a | grep ${name} | awk '{print $$1}')
image_id:=$(shell docker image ls | grep mlb/${name} | awk '{print $$3}')

install:
ifneq (${container_id},)
	@echo "Service ${name} already exists" 
else
	@mkdir ${volume}
	@touch ${volume}/authorized_keys
	@touch ${volume}/auth.log
	@chmod 777 ${volume}/auth.log

	@cp -r docker ${path}
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml up -d  --build --remove-orphans
endif

uninstall:
ifneq (${container_id},)
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml down	
endif
ifneq (${image_id},)
	@docker rmi ${image_id}
endif
ifneq ($(shell test -d ${path} && echo 'exists'),)
	@rm -rf ${path} 
endif
ifneq ($(shell test -d ${volume} && echo 'exists'),)
	@rm -rf ${volume} 
endif

update:
ifneq (${container_id},)
	@mkdir backup

	@cp ${volume}/authorized_keys backup
	@cp ${volume}/auth.log backup

	@make uninstall --no-print-directory
	@make install --no-print-directory

	@cp backup/authorized_keys ${volume}/authorized_keys
	@cat backup/auth.log > ${volume}/auth.log

	@rm -rf backup
endif