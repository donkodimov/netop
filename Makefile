.PHONY: build test app run check clean

build:
	swift build

test:
	swift test

app:
	scripts/bundle.sh debug

run: app
	pkill -x Netop || true
	open build/Netop.app

# Validation gate for every commit (see AGENTS.md).
check: build test app

clean:
	rm -rf .build build
