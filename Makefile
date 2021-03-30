DOCKER_RUN = docker run --rm --user $$(id -u)\:$$(id -g)
PORT = -p 8000:8000
VOLUMES = -v $(CURDIR):/elm


all: reactor

build:
	docker build --rm -t elm .

compile: build/home.html

reactor: 
	$(DOCKER_RUN) $(PORT) $(VOLUMES) -d -it elm elm reactor

sh: 
	$(DOCKER_RUN) $(VOLUMES) -it --entrypoint sh elm

repl: 
	$(DOCKER_RUN) $(VOLUMES) -it elm elm repl

build/%.html: src/%.elm
	$(DOCKER_RUN) $(VOLUMES) elm elm make --optimize $< --output $@


