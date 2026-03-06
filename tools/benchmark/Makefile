WORKER ?= WorkerOptimize.elm

.PHONY: build run all clean build-main build-optimize compare

# Default: build and run with the optimize worker
all: build run

# Build whichever Worker is specified (default: WorkerOptimize)
build:
	elm make $(WORKER) --output=worker.js --optimize

# Build specifically for main branch
build-main:
	elm make WorkerMain.elm --output=worker.js --optimize

# Build specifically for optimize branch
build-optimize:
	elm make WorkerOptimize.elm --output=worker.js --optimize

# Run the benchmark
run:
	node run.js

# Run with custom iteration count
run-%:
	node run.js --iterations $*

# Full cross-branch comparison (creates worktrees, builds both, compares)
compare:
	bash compare.sh

clean:
	rm -f worker.js results-*.json
	rm -rf elm-stuff
