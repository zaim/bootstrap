
BUILD_DIR = build

LESS_FILES = less/bootstrap.less less/responsive.less
CSS_FILES  = $(patsubst less/%,$(BUILD_DIR)/css/%,$(LESS_FILES:.less=.css))

JS_SRC_FILES = js/*.js
JS_FULL_FILE = $(BUILD_DIR)/js/bootstrap.js
JS_MIN_FILE  = $(BUILD_DIR)/js/bootstrap.min.js

define COPYRIGHT =
/**\n\
 * Bootstrap.js by @fat & @mdo\n\
 * Copyright 2012 Twitter, Inc.\n\
 * http://www.apache.org/licenses/LICENSE-2.0.txt\n\
 */\n
endef

print = @printf "  \\033[1m%-30s\\033[m \\033[34m%-30s\\033[m "
check = @echo -e "\\033[32m✔\\033[m"


all: head css js jsmin
	@echo

head:
	@echo -e "\\033[33mBUILDING BOOTSTRAP\\033[m"

css: $(BUILD_DIR) $(CSS_FILES)

js: $(BUILD_DIR) $(JS_FULL_FILE)

jsmin: $(BUILD_DIR) $(JS_MIN_FILE)

$(BUILD_DIR):
	$(print) "Creating build directory" $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/css
	@mkdir -p $(BUILD_DIR)/js
	$(check)

$(BUILD_DIR)/css/%.css: less/%.less 
	$(print) "Building CSS" $(notdir $@)
	@recess --compile $< 1>$@ 2>/dev/null
	$(check)

$(JS_FULL_FILE):
	$(print) "Building JavaScript" $(notdir $@)
	@jshint $(JS_SRC_FILES) --config js/.jshintrc
	@cat $(JS_SRC_FILES) > $@
	$(check)

$(JS_MIN_FILE): $(JS_FULL_FILE)
	$(print) "Minifying JavaScript" $(notdir $@)
	@uglifyjs -nc $< > min.tmp
	@echo -e "$(COPYRIGHT)" > copyright.tmp
	@cat copyright.tmp min.tmp > $@
	@rm copyright.tmp min.tmp
	$(check)

clean:
	@echo -e "\\033[31mRemoving build directory\\033[m"
	@rm -rf build/

test:
	jshint js/*.js --config js/.jshintrc
	jshint js/tests/unit/*.js --config js/.jshintrc
	node js/tests/server.js &
	phantomjs js/tests/phantom.js "http://localhost:3000/js/tests"
	kill -9 `cat js/tests/pid.txt`
	rm js/tests/pid.txt

.PHONY: all head css js jsmin clean test

