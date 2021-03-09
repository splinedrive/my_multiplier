# Project setup
PROJ      = top

# Files
FILES = top.v

.PHONY: iceFUN clean burn

iceFUN:
	# synthesize using Yosys
	yosys -D SYNTHESIS -p "synth_ice40 -top top -json $(PROJ).json" $(FILES)
	# Place and route using nextpnr
	nextpnr-ice40 -r --hx8k --json $(PROJ).json --package cb132 --asc $(PROJ).asc --opt-timing --pcf iceFUN.pcf

	# Convert to bitstream using IcePack
	icepack $(PROJ).asc $(PROJ).bin

burn: iceFUN
	iceFUNprog -v $(PROJ).bin

clean:
	rm *.asc *.bin *.json
