name:=login-server
port:=21986

path:=/opt/${name}
volume:=/var/${name}
service:=/etc/systemd/system/${name}.service

container_id:=$(shell docker ps -a | grep ${name} | awk '{print $$1}')
image_id:=$(shell docker image ls | grep mlb/${name} | awk '{print $$3}')

install:
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@echo "Service ${name} already exists" 
else
ifeq ($(shell test -d bin && echo 'exists'),)
	@mkdir -p bin
endif
	@cp systemd/template.service bin/${name}.service
	@sed -i 's@<path>@${path}@gm' bin/${name}.service

	@cp -r docker bin/docker
	@sed -i 's@<name>@${name}@gm' bin/docker/docker-compose.yml
	@sed -i 's@<port>@${port}@gm' bin/docker/docker-compose.yml

	@mkdir ${volume}
	@touch ${volume}/authorized_keys
	@touch ${volume}/auth.log
	@chmod 777 ${volume}/auth.log

	@cp -r bin/docker ${path}
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml up -d  --build --remove-orphans

	@cp bin/${name}.service ${service}
	@systemctl enable ${service}
	@systemctl daemon-reload
	@systemctl start ${name}
endif
ifneq ($(shell test -d bin && echo 'exists'),)
	@rm -rf bin 
endif

uninstall:
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@systemctl stop ${name}
	@systemctl disable ${name}
	@systemctl daemon-reload
	@rm ${service}
endif
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
ifneq ($(shell test -d bin && echo 'exists'),)
	@rm -rf bin
endif

update:
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@mkdir backup

	@cp ${volume}/authorized_keys backup
	@cp ${volume}/auth.log backup

	@make uninstall --no-print-directory
	@make install --no-print-directory

	@cp backup/authorized_keys ${volume}/authorized_keys
	@cat backup/auth.log > ${volume}/auth.log

	@rm -rf backup
endif