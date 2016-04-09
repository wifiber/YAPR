CRAP=ddr_sync_fifo.vhd genram_pkg.vhd wbgen2_pkg.vhd wbgen2_eic.vhd wishbone_pkg.vhd serdes_intfce_csr.vhd serdes_intfce_eic.vhd

.PHONY: clean
clean:
	# Remove unneeded files
	rm -f $(CRAP)
	# Clean CR+LF -> LF
	dos2unix *.vhd
	# Clean whitespace at end of lines
	sed -i "s/[[:blank:]]\+$$//" *.vhd
	# Fix permissions
	chmod 0644 *.vhd
