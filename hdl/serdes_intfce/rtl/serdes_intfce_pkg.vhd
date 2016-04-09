------------------------------------------
------------------------------------------
-- Date        : Fri May 16 16:01:35 2014
--
-- Author      : Tom Levens <tom.levens@cern.ch>
--
-- Company     : CERN, BE-RF-FB
--
-- Description : Package for SERDES interface
--
------------------------------------------
------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.wishbone_pkg.all;
library work;
use work.GTP_TILE_PKG.all;

package serdes_intfce_pkg is

  ------------------------------------------
  -- SDB records for CSR & EIC
  ------------------------------------------

  constant c_wb_serdes_csr_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                 -- 32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"000000000000003F",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"fb63f3f6",          -- echo "WB-SERDES-CSR      " | md5sum | cut -c1-8
        version   => x"00000001",
        date      => x"20140618",
        name      => "WB-SERDES-CSR      ")));

  constant c_wb_serdes_eic_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                 -- 32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"000000000000000F",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"21c5d7b1",          -- echo "WB-SERDES-EIC      " | md5sum | cut -c1-8
        version   => x"00000001",
        date      => x"20140516",
        name      => "WB-SERDES-EIC      ")));

  ------------------------------------------
  -- Top level component declaration
  ------------------------------------------

  component serdes_intfce
    generic (
      G_RATE : GTP_RATE_TYPE := GBPS_1_0
      );
    port (
      -- CSR Wishbone port
      wb_csr_adr_i   : in  std_logic_vector (3 downto 0);
      wb_csr_dat_i   : in  std_logic_vector (31 downto 0);
      wb_csr_dat_o   : out std_logic_vector (31 downto 0);
      wb_csr_cyc_i   : in  std_logic;
      wb_csr_sel_i   : in  std_logic_vector (3 downto 0);
      wb_csr_stb_i   : in  std_logic;
      wb_csr_we_i    : in  std_logic;
      wb_csr_ack_o   : out std_logic;
      wb_csr_stall_o : out std_logic;

      -- EIC Wishbone port
      wb_eic_adr_i   : in  std_logic_vector (1 downto 0);
      wb_eic_dat_i   : in  std_logic_vector (31 downto 0);
      wb_eic_dat_o   : out std_logic_vector (31 downto 0);
      wb_eic_cyc_i   : in  std_logic;
      wb_eic_sel_i   : in  std_logic_vector (3 downto 0);
      wb_eic_stb_i   : in  std_logic;
      wb_eic_we_i    : in  std_logic;
      wb_eic_ack_o   : out std_logic;
      wb_eic_stall_o : out std_logic;
      wb_eic_int_o   : out std_logic;

      -- DDR pipelined Wishbone port
      wb_ddr_adr_o   : out std_logic_vector (31 downto 0);
      wb_ddr_dat_o   : out std_logic_vector (31 downto 0);
      wb_ddr_sel_o   : out std_logic_vector (3 downto 0);
      wb_ddr_stb_o   : out std_logic;
      wb_ddr_we_o    : out std_logic;
      wb_ddr_cyc_o   : out std_logic;
      wb_ddr_ack_i   : in  std_logic;
      wb_ddr_stall_i : in  std_logic;

      -- Clocks & reset
      clk_wb_i           : in  std_logic;
      clk_gtp_refclk_i   : in  std_logic;
      clk_gtp_userclk_i  : in  std_logic;
      clk_gtp_userclk2_i : in  std_logic;
      rst_n_i            : in  std_logic;

      -- SFP
      sfp_tx_disable_o : out std_logic;
      sfp_los_i        : in  std_logic;
      sfp_prsnt_n_i    : in  std_logic;
      sfp_rx_p_i       : in  std_logic;
      sfp_rx_n_i       : in  std_logic;
      sfp_tx_p_o       : out std_logic;
      sfp_tx_n_o       : out std_logic;

      -- Misc
      led_red_o : out std_logic;
      led_grn_o : out std_logic;
      irq_o     : out std_logic_vector(1 downto 0);

      -- DIO
      dio_clk_i       : in    std_logic;
      dio_i           : in    std_logic_vector(4 downto 0);
      dio_o           : out   std_logic_vector(4 downto 0);
      dio_oe_n_o      : out   std_logic_vector(4 downto 0);
      dio_term_en_o   : out   std_logic_vector(4 downto 0);
      dio_led_top_o   : out   std_logic;
      dio_led_bot_o   : out   std_logic;
      dio_onewire_b   : inout std_logic;
      dio_prsnt_n_i   : in    std_logic
      );
  end component serdes_intfce;

  ------------------------------------------
  -- Line rate function declarations
  ------------------------------------------

  function f_gtp_userclk_div(R: GTP_RATE_TYPE) return integer;
  function f_gtp_userclk2_div(R: GTP_RATE_TYPE) return integer;
  function f_khz1_div(R: GTP_RATE_TYPE) return std_logic_vector;
  function f_line_rate(R: GTP_RATE_TYPE) return std_logic_vector;

end serdes_intfce_pkg;


------------------------------------------
------------------------------------------
-- Date        : Fri May 16 16:01:35 2014
--
-- Author      : Tom Levens <tom.levens@cern.ch>
--
-- Company     : CERN, BE-RF-FB
--
------------------------------------------
------------------------------------------

package body serdes_intfce_pkg is

  function f_gtp_userclk_div (R: GTP_RATE_TYPE) return integer is
  begin
    case R is
        when GBPS_2_5 => return 4;  -- 2.5 GBPS: GTPUSERCLK = CLK/4  = 250MHz
        when GBPS_2_0 => return 5;  -- 2.0 GBPS: GTPUSERCLK = CLK/5  = 200MHz
        when others   => return 10; -- 1.0 GBPS: GTPUSERCLK = CLK/10 = 100MHz
    end case;
  end f_gtp_userclk_div;

  function f_gtp_userclk2_div (R: GTP_RATE_TYPE) return integer is
  begin
    case R is
        when GBPS_2_5 => return 8;  -- 2.5 GBPS: GTPUSERCLK2 = CLK/8  = 125MHz
        when GBPS_2_0 => return 10; -- 2.0 GBPS: GTPUSERCLK2 = CLK/10 = 100MHz
        when others   => return 20; -- 1.0 GBPS: GTPUSERCLK2 = CLK/20 = 50MHz
    end case;
  end f_gtp_userclk2_div;

  function f_khz1_div (R: GTP_RATE_TYPE) return std_logic_vector is
  begin
    case R is
        when GBPS_2_5 => return '1' & X"E848"; -- 2.5 GBPS: 1KHz = CLK/125k
        when GBPS_2_0 => return '1' & X"86A0"; -- 2.0 GBPS: 1KHz = CLK/100k
        when others   => return '0' & X"C350"; -- 1.0 GBPS: 1KHz = CLK/50k
    end case;
  end f_khz1_div;


  function f_line_rate (R: GTP_RATE_TYPE) return std_logic_vector is
  begin
    case R is
        when GBPS_2_5 => return X"000009C4"; -- 2.5 GBPS: 2500
        when GBPS_2_0 => return X"000007D0"; -- 2.0 GBPS: 2000
        when others   => return X"000003E8"; -- 1.0 GBPS: 1000
    end case;
  end f_line_rate;

end  serdes_intfce_pkg;


