TARGETS := x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu
MACOS_TARGETS := aarch64-apple-darwin x86_64-apple-darwin
DIST := dist

setup:
	brew install zig
	cargo install --locked cargo-zigbuild
	rustup target add $(TARGETS) $(MACOS_TARGETS)

all: $(TARGETS) $(MACOS_TARGETS)

$(TARGETS):
	AR="$(CURDIR)/.cargo/zig-ar.sh" cargo zigbuild --release --target $@
	mkdir -p $(DIST)/$@
	cp target/$@/release/yazi $(DIST)/$@/
	cp target/$@/release/ya $(DIST)/$@/

clean:
	rm -rf $(DIST)

dist-clean: clean
	cargo clean

$(MACOS_TARGETS):
	AR="$(CURDIR)/.cargo/zig-ar.sh" cargo zigbuild --release --target $@
	mkdir -p $(DIST)/$@
	cp target/$@/release/yazi $(DIST)/$@/
	cp target/$@/release/ya $(DIST)/$@/

deploy:
	@read -p "Hostname: " host; \
	read -p "Target [$(TARGETS) $(MACOS_TARGETS)]: " target; \
	scp $(DIST)/$$target/yazi $(DIST)/$$target/ya $(USER)@$$host:~/; \
	ssh -t $(USER)@$$host 'sudo mv ~/yazi ~/ya /usr/local/bin/'

.PHONY: setup all clean dist-clean deploy $(TARGETS) $(MACOS_TARGETS)
