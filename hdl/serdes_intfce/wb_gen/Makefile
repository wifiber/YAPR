WBGEN2=wbgen2
RTL=../rtl/

.PHONY: all
all: serdes_intfce_csr serdes_intfce_eic

serdes_intfce_csr:
	$(WBGEN2) -l vhdl -V $@.vhd -f html -D $@.htm -C $@.h $@.wb

serdes_intfce_eic:
	$(WBGEN2) -l vhdl -V $@.vhd -f html -D $@.htm -C $@.h $@.wb
