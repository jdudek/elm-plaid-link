NPM      = npm
ELM      = elm
NODE     = node
CHOKIDAR = `npm bin`/chokidar

.PHONY: all
all: public/main.js

public/main.js: src/*.elm
	$(ELM) make src/Main.elm --output='$@'

.PHONY: clean
clean:
	rm public/main.js

.PHONY: setup
setup:
	$(NPM) install
	$(ELM) package install --yes

.PHONY: start
start:
	$(NODE) server.js

.PHONY: watch
watch:
	$(CHOKIDAR) 'src/**/*.elm' -c 'make all' --initial
