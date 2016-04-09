# NOTE: These files should be ignored as they are sourced
#       from other libraries:
#       --> ddr_sync_fifo.vhd
#       --> genram_pkg.vhd
#       --> wbgen2_pkg.vhd
#       --> wbgen2_eic.vhd
#       --> wishbone_pkg.vhd

files = [ # Library: serdes_intfce
          "serdes_intfce.vhd",
          "serdes_intfce_pkg.vhd",
          "../wb_gen/serdes_intfce_csr.vhd",
          "../wb_gen/serdes_intfce_eic.vhd",

          # Library: GTP
          "GTP_16b20bEnc.vhd",
          "GTP_3b4bTable.vhd",
          "GTP_5b6bTable.vhd",
          "GTP_8b10bEnc.vhd",
          "GTP_CommaTable.vhd",
          "GTP_Dx7Table.vhd",
          "GTP_LinkEncoder.vhd",
          "GTP_LinkTester.vhd",
          "GTP_LinkTestSeq.vhd",
          "GTP_RxLogic.vhd",
          "GTP_S6.vhd",
          "GTP_TILE_S6.vhd",
          "GTP_TILE_PKG.vhd",

          # Library: CommonVisual
          "BlockRamDP.vhd",
          "BusRotate.vhd",
          "ClkDivider.vhd",
          "CRC32_D16.vhd",
          "DffxN.vhd",
          "LEDConditioning.vhd",
          "NegEdge.vhd",
          "PCK_CRC32_D16.vhd",
          "PosEdge.vhd",
          "PulseGen.vhd",
          "PulseSync.vhd",
          "RSFF.vhd",
          "SRFF.vhd",
          "Util.vhd"
        ]
