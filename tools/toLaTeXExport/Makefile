DOCS_DIR := ../../tests/toLaTeXExportTestDocs
SOURCES  := $(wildcard $(DOCS_DIR)/*.scripta)

.PHONY: build all clean

build:
	elm make Worker.elm --output=worker.js

all: build
	@for f in $(SOURCES); do \
		echo "=== Processing $$f ==="; \
		node run.js $$f; \
	done

%.scripta: build
	node run.js $(DOCS_DIR)/$@

clean:
	rm -f worker.js
	rm -rf elm-stuff
