DOCKER_RUN = docker run --rm --user $$(id -u)\:$$(id -g)
VOLUMES = -v $(CURDIR):/elm


all: reactor



build:
	docker build --rm -t elm .

serve: compile
	$(DOCKER_RUN) $(VOLUMES) -p 8080:8080 -d elm http-server
	@echo http://127.0.0.1:8080/Home.html

compile: public/Home.min.js public/Home.html


reactor: 
	$(DOCKER_RUN) $(VOLUMES) -p 8000:8000 -d -it elm elm reactor
	@echo http://localhost:8000/

sh: 
	$(DOCKER_RUN) $(VOLUMES) -it --entrypoint sh elm

repl: 
	$(DOCKER_RUN) $(VOLUMES) -it elm elm repl


public/%.min.js: public/%.js
	$(DOCKER_RUN) $(VOLUMES) elm ./optimize.sh $< $@

public/%.js: src/%.elm
	$(DOCKER_RUN) $(VOLUMES) elm elm make --optimize $< --output $@




public/%.html: template.sh
	$(DOCKER_RUN) $(VOLUMES) elm ./template.sh $@ > $@


clean:
	find public -name "*.js" -type f -print0 | xargs -0 rm -f
	find public -name "*.html" -type f -print0 | xargs -0 rm -f

