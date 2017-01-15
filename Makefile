DESIGN=

build: default
default: 

include $(GADGETRON_ROOT)/Tools/Gadgetron/Gadgetron2.make

ifeq ($(shell uname),Darwin)
ARDUINO=Arduino
else
ARDUINO=arduino
endif


%.zip: %.gspec
	@rm -rf $(GADGETRON_ROOT)/Libraries/GadgetronSketchBook/libraries/*/.\#*
	@echo Building $@
	@$(MAKE_GADGET) --expert --gspec $< -nopr > $*.log 2>&1 || (cat $*.log; exit 1)
	@$(MAKE) $*.ardubuilt

%.ardubuilt: %.zip
	@echo Compiling test program for $@
	@$(ARDUINO) --preferences-file arduino-config.txt --verify $*-Test-Program/$*-Test-Program.ino > $*-build.log 2>&1 || (cat $*-build.log;  exit 1)

.PHONY:test
test: solo-components all-in-one

GTRON_PART_LIST?=../../Tools/jet/Jet/assets/partSets/Release.json

.PHONY: solo-components
solo-components:
	build_omnigadget.py --catalog ../../Libraries/JetComponents/Catalog/Components.xml --components Adafruit-Pro-Trinket-5V-battery-powered battery-9V-vertical --write test.gspec --spacing 100 --component-list-file $(GTRON_PART_LIST) --build-all test-gspecs > test-gspecs.log 2>&1
	$(MAKE) retest

.PHONY: all-in-one
all-in-one:
	build_omnigadget.py --catalog ../../Libraries/JetComponents/Catalog/Components.xml --write all-in-one.gspec --spacing 100 --component-list-file $(GTRON_PART_LIST)  > all-in-one.log 2>&1
	$(MAKE_GADGET) --gspec all-in-one.gspec -nopr -a > all-in-one.log 2>&1 || (cat all-in-one.log; exit 1)

.PHONY: retest
retest:
	$(MAKE) $(patsubst %.gspec,%.zip,$(shell cat test-gspecs))

clean:
	rm -rf *.zip *.brd *.sch *.html *.pro test-*.gspec *.log *.csv *.readme *.status test-gspecs everything*.gspec
	rm -rf *-Test-Program *.h

