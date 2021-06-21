PODMAN_RUN = podman run --rm
VOLUMES = -v $(CURDIR):/elm

SRCS=$(wildcard src/*.elm)

compile: js html

build:
	podman build --rm -t elm .

js: $(patsubst src/%.elm,public/%.min.js,$(SRCS))

html: $(patsubst src/%.elm,public/%.html,$(SRCS))

public/%.min.js: public/%.js optimize.sh
	$(PODMAN_RUN) $(VOLUMES) elm ./optimize.sh $< $@

public/%.js: src/%.elm
	$(PODMAN_RUN) $(VOLUMES) elm elm make --optimize $< --output $@

public/%.html: template.sh
	$(PODMAN_RUN) $(VOLUMES) elm ./template.sh $@ > $@

sh: 
	$(PODMAN_RUN) $(VOLUMES) -it --entrypoint sh elm

repl: 
	$(PODMAN_RUN) $(VOLUMES) -it elm elm repl

reactor: 
	$(PODMAN_RUN) $(VOLUMES) -p 8000:8000 -d -it elm elm reactor
	@echo http://localhost:8000/

serve: compile
	$(PODMAN_RUN) $(VOLUMES) -p 8080:8080 -d elm http-server
	@echo http://127.0.0.1:8080/Home.html

clean:
	find public -name "*.js" -type f -print0 | xargs -0 rm -f
	find public -name "*.html" -type f -print0 | xargs -0 rm -f

