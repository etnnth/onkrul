DOCKER_RUN = docker run --rm --user $$(id -u)\:$$(id -g)
PORT = -p 8000:8000
VOLUMES = -v $(CURDIR):/elm

RUN_IN_DOCKER = $(DOCKER_RUN) $(PORT) $(VOLUMES)
ELM_MAKE = $(DOCKER_RUN) $(VOLUMES) elm elm make --optimize

all: reactor

build:
	docker build --rm -t elm .

compile: build/home.html

reactor: 
	${RUN_IN_DOCKER} -d -it elm elm reactor

sh: 
	${RUN_IN_DOCKER} -it --entrypoint sh elm

repl: 
	${RUN_IN_DOCKER} -it elm elm repl

build/%.html: src/%.elm
	${ELM_MAKE} $< --output $@


