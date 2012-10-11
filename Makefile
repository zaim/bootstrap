
# Root build directory
BUILD_DIR = build

# Assets (css, img, js files) go here
ASSET_DIR = $(BUILD_DIR)/assets

# Official docs go here
DOCS_DIR = $(BUILD_DIR)/docs

DIRS         = $(ASSET_DIR)/css $(ASSET_DIR)/img $(ASSET_DIR)/js
LESS_FILES   = less/bootstrap.less less/responsive.less
CSS_FILES    = $(patsubst less/%,$(ASSET_DIR)/css/%,$(LESS_FILES:.less=.css))
IMG_FILES    = $(patsubst img/%,$(ASSET_DIR)/img/%,$(wildcard img/*))
JS_SRC_FILES = js/bootstrap-transition.js js/bootstrap-alert.js js/bootstrap-button.js js/bootstrap-carousel.js js/bootstrap-collapse.js js/bootstrap-dropdown.js js/bootstrap-modal.js js/bootstrap-tooltip.js js/bootstrap-popover.js js/bootstrap-scrollspy.js js/bootstrap-tab.js js/bootstrap-typeahead.js
JS_FULL_FILE = $(ASSET_DIR)/js/bootstrap.js
JS_MIN_FILE  = $(ASSET_DIR)/js/bootstrap.min.js
JS_HINT_CONF = js/.jshintrc

define COPYRIGHT =
/**\n\
 * Bootstrap.js by @fat & @mdo\n\
 * Copyright 2012 Twitter, Inc.\n\
 * http://www.apache.org/licenses/LICENSE-2.0.txt\n\
 */\n
endef

print = @printf "  %-24s \\033[34m%-48s\\033[m "
comment = @printf "  \\033[36m%s\\033[m\n"
check = @echo -e "\\033[32m✔\\033[m"

# Use local bins installed in node_modules
recess = @node_modules/.bin/recess
jshint = @node_modules/.bin/jshint
uglifyjs = @node_modules/.bin/uglifyjs

all: css js jsmin

css: $(ASSET_DIR)/css $(CSS_FILES) $(ASSET_DIR)/img $(IMG_FILES)

js: $(ASSET_DIR)/js $(JS_FULL_FILE)

jsmin: $(ASSET_DIR)/js $(JS_MIN_FILE)

docs: $(DOCS_DIR)

$(DOCS_DIR):
	$(print) "Creating directory" "$@"
	@mkdir -p $@
	$(check)
	$(print) "  Rebuilding docs" "node docs/build"
	@node docs/build
	$(check)
	$(print) "  Copying official docs" $(DOCS_DIR)
	@cp docs/*.html $(DOCS_DIR)
	@cp -R docs/examples $(DOCS_DIR)
	@cp -R docs/assets $(DOCS_DIR)
	$(check)

$(DIRS):
	$(print) "Creating directory" "$@"
	@mkdir -p $@
	$(check)

$(ASSET_DIR)/css/bootstrap.css: $(wildcard less/*.less)
	$(print) "  Building CSS" $@
	$(recess) --compile less/bootstrap.less 1>$@ 2>/dev/null
	$(check)

$(ASSET_DIR)/css/responsive.css: $(wildcard less/*.less)
	$(print) "  Building CSS" $@
	$(recess) --compile less/responsive.less 1>$@ 2>/dev/null
	$(check)

$(ASSET_DIR)/img/%: img/%
	$(print) "  Copying image" $@
	@cp $< $@
	$(check)

$(JS_FULL_FILE):
	$(print) "  Building JavaScript" $@
	$(jshint) $(JS_SRC_FILES) --config $(JS_HINT_CONF)
	@cat $(JS_SRC_FILES) > $@
	$(check)

$(JS_MIN_FILE): $(JS_FULL_FILE)
	$(print) "  Minifying JavaScript" $@
	$(uglifyjs) -nc $< > min.tmp
	@echo -e "$(COPYRIGHT)" > copyright.tmp
	@cat copyright.tmp min.tmp > $@
	@rm copyright.tmp min.tmp
	$(check)

clean:
	$(print) "Removing directory" "$(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)
	$(check)

test:
	$(print) "Running JSHint"
	$(jshint) js/*.js --config $(JS_HINT_CONF)
	$(jshint) js/tests/unit/*.js --config $(JS_HINT_CONF)
	$(check)
	$(print) "Starting Server"
	@node js/tests/server.js & sleep .5
	$(check)
	@echo "  (PID: $$(cat js/tests/pid.txt))"
	@echo
	@phantomjs js/tests/phantom.js "http://localhost:3000/js/tests" | sed 's/^/  /'
	@echo
	$(print) "Stopping Server"
	@kill -9 `cat js/tests/pid.txt`
	@rm js/tests/pid.txt
	$(check)

.PHONY: all head css js jsmin clean test

