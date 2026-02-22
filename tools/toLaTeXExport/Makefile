DOCS_DIR := ../../tests/toLaTeXExportTestDocs
SOURCES  := $(wildcard $(DOCS_DIR)/*.scripta)

.PHONY: build all clean diagnose diagnose-all summary

build:
	elm make Worker.elm --output=worker.js

all: build
	@for f in $(SOURCES); do \
		echo "=== Processing $$f ==="; \
		node run.js $$f; \
	done

%.scripta: build
	node run.js $(DOCS_DIR)/$@

diagnose:
	node diagnose.js --all

diagnose-%:
	node diagnose.js $*

summary:
	node diagnose.js --summary

clean:
	rm -f worker.js
	rm -rf elm-stuff
