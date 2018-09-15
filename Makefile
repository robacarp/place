PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin
PLACE_SYSTEM=$(INSTALL_DIR)/place

OUT_DIR=$(shell pwd)/bin
PLACE=$(OUT_DIR)/place
PLACE_SOURCES=$(shell find src/ -type f -name '*.cr')

all: build

build: lib $(PLACE)

lib:
	@shards install --production

$(PLACE): $(PLACE_SOURCES) | $(OUT_DIR)
	@echo "Building place in $@"
	@crystal build -o $@ src/place.cr -p --no-debug

$(OUT_DIR) $(INSTALL_DIR):
	 @mkdir -p $@

run:
	$(PLACE)

install: build | $(INSTALL_DIR)
	@rm -f $(PLACE_SYSTEM)
	@cp $(PLACE) $(PLACE_SYSTEM)

link: build | $(INSTALL_DIR)
	@echo "Symlinking $(PLACE) to $(PLACE_SYSTEM)"
	@ln -s $(PLACE) $(PLACE_SYSTEM)

force_link: build | $(INSTALL_DIR)
	@echo "Symlinking $(PLACE) to $(PLACE_SYSTEM)"
	@ln -sf $(PLACE) $(PLACE_SYSTEM)

clean:
	rm -rf $(PLACE)

distclean:
	rm -rf $(PLACE) .crystal .shards libs lib
