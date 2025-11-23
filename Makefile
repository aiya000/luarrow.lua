.PHONY: install-dependencies-for-repl repl test lint format clean install-dependencies-for-test build install-to-local release upload open-repo open-luarocks check benchmark benchmark-both increment-version

ROCKSPEC_FILE = $(shell ls | grep '\.rockspec$$' | head -1)
ROCK_FILE = $(shell ls | grep '\.src\.rock$$' | head -1)

# Dependency Installation

install-dependencies-for-repl:
	luarocks install --local luaprompt

install-dependencies-for-test:
	luarocks install --local busted

install-dependencies-for-upload:
	luarocks install --local dkjson

# Development

# Run `dofile('luarrow.lua')` in the REPL to load the library
# e.g.:
# - `fun = require('luarrow').fun`
# - `arrow = require('luarrow').arrow`
repl:
	cd luarrow.lua/src && luap

test:
	@echo "Running tests..."
	busted

lint:
	@echo "Checking code style..."
	stylua --check .

check: lint test
	@echo "All checks completed successfully!"

format:
	@echo "Formatting code..."
	stylua .

# Release Steps
# Steps:
# 1. make increment-version
# 2. make build
# 3. (optional) make check-uploadable
# 	- If the check fails, must fix issues before uploading
# 4. make upload
# 5. (optional) `luarocks install --local luarrow` outside of the repo to verify installation

increment-version:
	@echo "Incrementing rockspec version..."
	./scripts/increment-rockspec-version.sh

# NOTE: Run `git add luarrow-main-(latest).rockspec && git push` before `make build`
build:
	@echo "Validating rockspec..."
	luarocks pack $(ROCKSPEC_FILE)
	luarocks make --local

clean:
	@echo "Cleaning up..."
	rm -f luacov.*.out
	rm -f *.log
	rm -f *.rock

check-uploadable:
	luarocks install --local --force $(ROCK_FILE) && echo "Package is uploadable." || (echo "Package is not uploadable." && exit 1)

# Must specify:
# ```shell-session
# LUAROCKS_API_KEY=$LUAROCKS_LUARROW_API_KEY make upload
# ```
upload:
	luarocks upload $(ROCKSPEC_FILE) --api-key=$(LUAROCKS_API_KEY)

install-to-local:
	$(MAKE) build
	luarocks install --local $(ROCK_FILE)

# Utilities

# TODO: Support pure Linux and macOS
open-repo:
	explorer.exe https://github.com/aiya000/luarrow.lua

open-luarocks:
	explorer.exe https://luarocks.org/modules/aiya000/luarrow

benchmark:
	LUA_PATH='./src/?.lua' lua scripts/benchmark.lua

benchmark-both:
	lua scripts/benchmark-both.lua
