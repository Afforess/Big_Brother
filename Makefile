PACKAGE_NAME := Big_Brother
VERSION_STRING := 0.4.3

OUTPUT_NAME := $(PACKAGE_NAME)_$(VERSION_STRING)
OUTPUT_DIR := build/$(OUTPUT_NAME)

PKG_COPY := $(wildcard *.md) graphics locale

SED_FILES := $(shell find . -iname '*.json' -type f -not -path "./build/*") $(shell find . -iname '*.lua' -type f -not -path "./build/*")
OUT_FILES := $(SED_FILES:%=$(OUTPUT_DIR)/%)

SED_EXPRS := -e 's/{{MOD_NAME}}/$(PACKAGE_NAME)/g'
SED_EXPRS += -e 's/{{VERSION}}/$(VERSION_STRING)/g'

all: clean package install_mod

package-copy: $(PKG_DIRS) $(PKG_FILES)
	mkdir -p $(OUTPUT_DIR)
ifneq ($(PKG_COPY),)
	cp -r $(PKG_COPY) build/$(OUTPUT_NAME)
endif

$(OUTPUT_DIR)/%.lua: %.lua
	@mkdir -p $(@D)
	@sed $(SED_EXPRS) $< > $@
	luac -p $@

$(OUTPUT_DIR)/%: %
	mkdir -p $(@D)
	sed $(SED_EXPRS) $< > $@

package: package-copy $(OUT_FILES)
	cd build && zip -r $(OUTPUT_NAME).zip $(OUTPUT_NAME)

clean:
	rm -rf build/

install_mod:
	if [ -L factorio_mods ] ; \
	then \
		cp -R build/$(OUTPUT_NAME) factorio_mods ; \
	fi;
