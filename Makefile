name:=login-server

path:=/opt/${name}
service:=/etc/systemd/system/${name}.service

container_id:=$(shell docker ps -a | grep ${name} | awk '{print $$1}')
image_id:=$(shell docker image ls | grep mlb/${name} | awk '{print $$3}')

install:
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@echo "Service ${name} already exists" 
else
#prepare systemd file 
	@mkdir -p bin
	@cp systemd/template.service bin/${name}.service
	@sed -i 's@<path>@${path}@gm' bin/${name}.service

#copy docker files to /opt 
	@cp -r docker ${path}
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml up -d --remove-orphans --quiet-pull > docker.log && rm docker.log

#create and configure systemd service
	@cp bin/${name}.service ${service}
	@systemctl enable ${service}
	@systemctl daemon-reload
	@systemctl start ${name}
endif
#remove bin folder
ifneq ($(shell test -d bin && echo 'exists'),)
	@rm -rf bin 
endif

uninstall:
#remove systemd service
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@systemctl stop ${name}
	@systemctl disable ${name}
	@systemctl daemon-reload
	@rm ${service}
endif
#remove bin folder
ifneq ($(shell test -d bin && echo 'exists'),)
	@rm -rf bin 
endif
#remove docker
ifneq (${container_id},)
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml down	
endif
ifneq (${image_id},)
	@docker rmi ${image_id}
endif
ifneq ($(shell test -d ${path} && echo 'exists'),)
	@/usr/bin/docker-compose -f ${path}/docker-compose.yml down	
	@rm -rf ${path} 
endif

reinstall:
ifneq ($(shell test -f ${service} && echo 'exists'),)
	@make uninstall
	@make install
endif