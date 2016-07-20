DESIGN=

build: default
default: 

include $(GADGETRON_ROOT)/Tools/Gadgetron/Gadgetron2.make

%.zip: %.gspec
	@echo Building $@
	@$(MAKE_GADGET) -n $* -k $* -nopr > $*.log 2>&1 || (cat $*.log; exit 1)

.PHONY:test
test: solo-components all-in-one

.PHONY: solo-components
solo-components:
	build_omnigadget.py --catalog ../../Libraries/JetComponents/Catalog/Components.xml --components Adafruit-Pro-Trinket-5V-battery-powered battery-9V-vertical --write test.gspec --spacing 100 --component-list-file ../../Tools/jet/assets/partSets/Release.json --build-all test-gspecs > test-gspecs.log 2>&1
	$(MAKE) retest

.PHONY: all-in-one
all-in-one:
	build_omnigadget.py --catalog ../../Libraries/JetComponents/Catalog/Components.xml --write all-in-one.gspec --spacing 100 --component-list-file ../../Tools/jet/assets/partSets/Release.json  > all-in-one.log 2>&1
	$(MAKE_GADGET) -n all-in-one -k all-in-one -nopr -a > all-in-one.log 2>&1 || (cat all-in-one.log; exit 1)
	
.PHONY: retest
retest:
	$(MAKE) $(patsubst %.gspec,%.zip,$(shell cat test-gspecs))

clean:
	rm -rf *.zip *.brd *.sch *.html *.pro test-*.gspec *.log *.csv *.readme *.status test-gspecs everything*.gspec


