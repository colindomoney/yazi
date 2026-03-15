TARGETS := x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu
DIST := dist

setup:
	brew install zig
	cargo install --locked cargo-zigbuild
	rustup target add $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	cargo zigbuild --release --target $@
	mkdir -p $(DIST)/$@
	cp target/$@/release/yazi $(DIST)/$@/
	cp target/$@/release/ya $(DIST)/$@/

clean:
	rm -rf $(DIST)

dist-clean: clean
	cargo clean

deploy:
	@read -p "Hostname: " host; \
	read -p "Target [$(TARGETS)]: " target; \
	scp target/$$target/release/yazi target/$$target/release/ya $(USER)@$$host:~/; \
	ssh -t $(USER)@$$host 'sudo mv ~/yazi ~/ya /usr/local/bin/'

.PHONY: setup all clean dist-clean deploy $(TARGETS)
