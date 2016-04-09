--------------------------------------------------------------------------------
--                                                                            --
-- CERN BE-CO-HT         GN4124 core for PCIe FMC carrier                     --
--                       http://www.ohwr.org/projects/gn4124-core             --
--------------------------------------------------------------------------------
--
-- unit name: spec_gn4124_test (spec_gn4124_test.vhd)
--
-- author: Matthieu Cattin (matthieu.cattin@cern.ch)
--
-- date: 07-07-2011
--
-- version: 0.1
--
-- description: Wrapper for the GN4124 core to drop into the FPGA on the
--              SPEC (Simple PCIe FMC Carrier) board
--
-- dependencies:
--
--------------------------------------------------------------------------------
-- last changes: see svn log.
--------------------------------------------------------------------------------
-- TODO: - 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.gn4124_core_pkg.all;
use work.wishbone_pkg.all; -- New for WB port Data Type
use work.genram_pkg.all;   -- Needed for subordinate moudle needing this xwb_clock_crossing
use work.ddr3_ctrl_pkg.all;
use work.serdes_intfce_pkg.all;
use work.GTP_TILE_PKG.all;
library UNISIM;
use UNISIM.vcomponents.all;


entity yarr is
  generic (
	  g_TX_CHANNELS : integer := 4;
	  g_RX_CHANNELS : integer := 16;
     g_RATE        : GTP_RATE_TYPE := GBPS_2_5 -- { GBPS_1_0, GBPS_2_0, GBPS_2_5 }     
	  );
  port
    (
      -- On board 20MHz oscillator
      --clk20_vcxo_i : in std_logic;
      -- DAC interface (20MHz and 25MHz VCXO)
      pll25dac_sync_n : out std_logic;  -- 25MHz VCXO
      pll20dac_sync_n : out std_logic;  -- 20MHz VCXO
      plldac_din      : out std_logic;
      plldac_sclk     : out std_logic;
	  
      -- From GN4124 Local bus
      --L_CLKp : in std_logic;            -- Local bus clock (frequency set in GN4124 config registers)
      --L_CLKn : in std_logic;            -- Local bus clock (frequency set in GN4124 config registers)
		
      --125MHz clock from clock generator for FPGA fabric
	   clk_125m_pllref_n_i : in std_logic;
	   clk_125m_pllref_p_i : in std_logic;
	   --125MHz clock from clock generator for GTP
	   fpga_pll_ref_clk_101_n_i : in std_logic; 
	   fpga_pll_ref_clk_101_p_i : in std_logic;

      L_RST_N : in std_logic;           -- Reset from GN4124 (RSTOUT18_N)

      -- General Purpose Interface
      GPIO : out std_logic_vector(1 downto 0);  -- GPIO[0] -> GN4124 GPIO8
                                                  -- GPIO[1] -> GN4124 GPIO9

      -- PCIe to Local [Inbound Data] - RX
      P2L_RDY    : out std_logic;                      -- Rx Buffer Full Flag
      P2L_CLKn   : in  std_logic;                      -- Receiver Source Synchronous Clock-
      P2L_CLKp   : in  std_logic;                      -- Receiver Source Synchronous Clock+
      P2L_DATA   : in  std_logic_vector(15 downto 0);  -- Parallel receive data
      P2L_DFRAME : in  std_logic;                      -- Receive Frame
      P2L_VALID  : in  std_logic;                      -- Receive Data Valid

      -- Inbound Buffer Request/Status
      P_WR_REQ : in  std_logic_vector(1 downto 0);  -- PCIe Write Request
      P_WR_RDY : out std_logic_vector(1 downto 0);  -- PCIe Write Ready
      RX_ERROR : out std_logic;                     -- Receive Error

      -- Local to Parallel [Outbound Data] - TX
      L2P_DATA   : out std_logic_vector(15 downto 0);  -- Parallel transmit data
      L2P_DFRAME : out std_logic;                      -- Transmit Data Frame
      L2P_VALID  : out std_logic;                      -- Transmit Data Valid
      L2P_CLKn   : out std_logic;                      -- Transmitter Source Synchronous Clock-
      L2P_CLKp   : out std_logic;                      -- Transmitter Source Synchronous Clock+
      L2P_EDB    : out std_logic;                      -- Packet termination and discard

      -- Outbound Buffer Status
      L2P_RDY    : in std_logic;                     -- Tx Buffer Full Flag
      L_WR_RDY   : in std_logic_vector(1 downto 0);  -- Local-to-PCIe Write
      P_RD_D_RDY : in std_logic_vector(1 downto 0);  -- PCIe-to-Local Read Response Data Ready
      TX_ERROR   : in std_logic;                     -- Transmit Error
      VC_RDY     : in std_logic_vector(1 downto 0);  -- Channel ready

      -- Font panel LEDs
      led_red_o   : out std_logic;
      led_green_o : out std_logic;

      -- Auxiliary pins
      AUX_LEDS_O    : out std_logic_vector(3 downto 0);
      AUX_BUTTONS_I : in  std_logic_vector(1 downto 0);

      -- PCB version
      pcb_ver_i : in std_logic_vector(3 downto 0);
		
		-- DDR3
		DDR3_CAS_N : out std_logic;
		DDR3_CK_P : out std_logic;
		DDR3_CK_N : out std_logic;
		DDR3_CKE : out std_logic;
		DDR3_LDM : out std_logic;
		DDR3_LDQS_N : inout std_logic;
		DDR3_LDQS_P : inout std_logic;
		DDR3_ODT : out std_logic;
		DDR3_RAS_N : out std_logic;
		DDR3_RESET_N : out std_logic;
		DDR3_UDM : out std_logic;
		DDR3_UDQS_N : inout std_logic;
		DDR3_UDQS_P : inout std_logic;
		DDR3_WE_N : out std_logic;
		DDR3_RZQ : inout std_logic;
		DDR3_ZIO : inout std_logic;
		DDR3_A : out std_logic_vector(13 downto 0);
		DDR3_BA : out std_logic_vector(2 downto 0);
		DDR3_DQ : inout std_logic_vector(15 downto 0);
		
		---------------------------------------------------------
        -- FMC
		---------------------------------------------------------
		-- Trigger input
		--ext_trig		: out std_logic;
		-- LVDS buffer
		--pwdn_l			: out std_logic_vector(2 downto 0);
		-- FE-I4
		--fe_clk_p		: out std_logic_vector(g_TX_CHANNELS-1 downto 0);
		--fe_clk_n		: out std_logic_vector(g_TX_CHANNELS-1 downto 0);
		--fe_cmd_p		: out std_logic_vector(g_TX_CHANNELS-1 downto 0);
		--fe_cmd_n		: out std_logic_vector(g_TX_CHANNELS-1 downto 0);
		--fe_data_p		: in  std_logic_vector(g_RX_CHANNELS-1 downto 0);
		--fe_data_n		: in  std_logic_vector(g_RX_CHANNELS-1 downto 0);
		
		---------------------------------------------------------
        -- SFP
		---------------------------------------------------------		
		
		SFPRX_123_N		: in std_logic;
		SFPRX_123_P		: in std_logic;
		SFPTX_123_N		: out std_logic;
		SFPTX_123_P		: out std_logic;
      
      SFP_TX_DISABLE : out std_logic;
      SFP_LOS        : in  std_logic;
      SFP_MOD_DEF0   : in  std_logic;
      
		---------------------------------------------------------
        -- UART
		---------------------------------------------------------		 
      
      UART_RXD       : out  std_logic;
      UART_TXD       : in std_logic
		
      );
end yarr;



architecture rtl of yarr is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------



  component wb_addr_decoder
    generic
      (
        g_WINDOW_SIZE  : integer := 18;  -- Number of bits to address periph on the board (32-bit word address)
        g_WB_SLAVES_NB : integer := 2
        );
    port
      (
        ---------------------------------------------------------
        -- GN4124 core clock and reset
        clk_i   : in std_logic;
        rst_n_i : in std_logic;

        ---------------------------------------------------------
        -- wishbone master interface
        wbm_adr_i   : in  std_logic_vector(31 downto 0);  -- Address
        wbm_dat_i   : in  std_logic_vector(31 downto 0);  -- Data out
        wbm_sel_i   : in  std_logic_vector(3 downto 0);   -- Byte select
        wbm_stb_i   : in  std_logic;                      -- Strobe
        wbm_we_i    : in  std_logic;                      -- Write
        wbm_cyc_i   : in  std_logic;                      -- Cycle
        wbm_dat_o   : out std_logic_vector(31 downto 0);  -- Data in
        wbm_ack_o   : out std_logic;                      -- Acknowledge
        wbm_stall_o : out std_logic;                      -- Stall

        ---------------------------------------------------------
        -- wishbone slaves interface
        wb_adr_o   : out std_logic_vector(31 downto 0);                     -- Address
        wb_dat_o   : out std_logic_vector(31 downto 0);                     -- Data out
        wb_sel_o   : out std_logic_vector(3 downto 0);                      -- Byte select
        wb_stb_o   : out std_logic;                                         -- Strobe
        wb_we_o    : out std_logic;                                         -- Write
        wb_cyc_o   : out std_logic_vector(g_WB_SLAVES_NB-1 downto 0);       -- Cycle
        wb_dat_i   : in  std_logic_vector((32*g_WB_SLAVES_NB)-1 downto 0);  -- Data in
        wb_ack_i   : in  std_logic_vector(g_WB_SLAVES_NB-1 downto 0);       -- Acknowledge
        wb_stall_i : in  std_logic_vector(g_WB_SLAVES_NB-1 downto 0)        -- Stall
        );
  end component wb_addr_decoder;

  component dummy_stat_regs_wb_slave
    port (
      rst_n_i                 : in  std_logic;
      wb_clk_i                : in  std_logic;
      wb_addr_i               : in  std_logic_vector(1 downto 0);
      wb_data_i               : in  std_logic_vector(31 downto 0);
      wb_data_o               : out std_logic_vector(31 downto 0);
      wb_cyc_i                : in  std_logic;
      wb_sel_i                : in  std_logic_vector(3 downto 0);
      wb_stb_i                : in  std_logic;
      wb_we_i                 : in  std_logic;
      wb_ack_o                : out std_logic;
      dummy_stat_reg_1_i      : in  std_logic_vector(31 downto 0);
      dummy_stat_reg_2_i      : in  std_logic_vector(31 downto 0);
      dummy_stat_reg_3_i      : in  std_logic_vector(31 downto 0);
      dummy_stat_reg_switch_i : in  std_logic_vector(31 downto 0)
      );
  end component;

  component dummy_ctrl_regs_wb_slave
    port (
      rst_n_i         : in  std_logic;
      wb_clk_i        : in  std_logic;
      wb_addr_i       : in  std_logic_vector(1 downto 0);
      wb_data_i       : in  std_logic_vector(31 downto 0);
      wb_data_o       : out std_logic_vector(31 downto 0);
      wb_cyc_i        : in  std_logic;
      wb_sel_i        : in  std_logic_vector(3 downto 0);
      wb_stb_i        : in  std_logic;
      wb_we_i         : in  std_logic;
      wb_ack_o        : out std_logic;
      dummy_reg_1_o   : out std_logic_vector(31 downto 0);
      dummy_reg_2_o   : out std_logic_vector(31 downto 0);
      dummy_reg_3_o   : out std_logic_vector(31 downto 0);
      dummy_reg_led_o : out std_logic_vector(31 downto 0)
      );
  end component;

	component wb_rx_bridge is
	port (
		-- Sys Connect
		sys_clk_i		: in  std_logic;
		rst_n_i			: in  std_logic;
		-- Wishbone slave interface
		wb_adr_i	: in  std_logic_vector(31 downto 0);
		wb_dat_i	: in  std_logic_vector(31 downto 0);
		wb_dat_o	: out std_logic_vector(31 downto 0);
		wb_cyc_i	: in  std_logic;
		wb_stb_i	: in  std_logic;
		wb_we_i		: in  std_logic;
		wb_ack_o	: out std_logic;
		wb_stall_o	: out std_logic;
		-- Wishbone DMA Master Interface
		dma_clk_i	: in  std_logic;
		dma_adr_o	: out std_logic_vector(31 downto 0);
		dma_dat_o	: out std_logic_vector(31 downto 0);
		dma_dat_i	: in  std_logic_vector(31 downto 0);
		dma_cyc_o	: out std_logic;
		dma_stb_o	: out std_logic;
		dma_we_o	: out std_logic;
		dma_ack_i	: in  std_logic;
		dma_stall_i	: in  std_logic;
		-- Rx Interface
		rx_data_i 	: in  std_logic_vector(31 downto 0);
		rx_valid_i	: in  std_logic;
		-- Status in
		trig_pulse_i : in std_logic;
		-- Status out
		irq_o		: out std_logic;
		busy_o		: out std_logic;
		-- New Signals
			 txdata1_o		: out std_logic_vector(31 downto 0);
			 rxdata1_i		: in std_logic_vector(31 downto 0);   
			 recclk_i      : in  std_logic;
			 refclk_i		: in  std_logic		
		
	);
	end component;

	component wb_ddr3_status_slave is
               port (
                 rst_n_i                                  : in     std_logic;
                 clk_sys_i                                : in     std_logic;
                 wb_adr_i                                 : in     std_logic_vector(0 downto 0); --Only two reg to address
                 wb_dat_i                                 : in     std_logic_vector(31 downto 0);
                 wb_dat_o                                 : out    std_logic_vector(31 downto 0);
                 wb_cyc_i                                 : in     std_logic;
                 wb_sel_i                                 : in     std_logic_vector(3 downto 0);
                 wb_stb_i                                 : in     std_logic;
                 wb_we_i                                  : in     std_logic;
                 wb_ack_o                                 : out    std_logic;
                 wb_stall_o                               : out    std_logic;
             -- Port for BIT field: 'Command FIFO full' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_cmd_full_o_i           : in     std_logic;
             -- Port for BIT field: 'Command FIFO empty' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_cmd_empty_o_i          : in     std_logic;
             -- Port for BIT field: 'Read FIFO full' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_rd_full_o_i            : in     std_logic;
             -- Port for BIT field: 'Read FIFO empty' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_rd_empty_o_i           : in     std_logic;
             -- Port for std_logic_vector field: 'Read FIFO count' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_rd_count_o_i           : in     std_logic_vector(6 downto 0);
             -- Port for BIT field: 'Read FIFO overflow' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_rd_overflow_o_i        : in     std_logic;
             -- Port for BIT field: 'Read FIFO error' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_rd_error_o_i           : in     std_logic;
             -- Port for BIT field: 'Write FIFO full' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_wr_full_o_i            : in     std_logic;
             -- Port for BIT field: 'Write FIFO empty' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_wr_empty_o_i           : in     std_logic;
             -- Port for std_logic_vector field: 'Write FIFO count' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_wr_count_o_i           : in     std_logic_vector(6 downto 0);
             -- Port for BIT field: 'Write FIFO underrun' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_wr_underrun_o_i        : in     std_logic;
             -- Port for BIT field: 'Write FIFO error' in reg: 'DDR3 Port 0 Status'
                 wb_ddr3_status_p0_wr_error_o_i           : in     std_logic;
             -- Port for BIT field: 'Command FIFO full' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_cmd_full_o_i           : in     std_logic;
             -- Port for BIT field: 'Command FIFO empty' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_cmd_empty_o_i          : in     std_logic;
             -- Port for BIT field: 'Read FIFO full' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_rd_full_o_i            : in     std_logic;
             -- Port for BIT field: 'Read FIFO empty' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_rd_empty_o_i           : in     std_logic;
             -- Port for std_logic_vector field: 'Read FIFO count' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_rd_count_o_i           : in     std_logic_vector(6 downto 0);
             -- Port for BIT field: 'Read FIFO overflow' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_rd_overflow_o_i        : in     std_logic;
             -- Port for BIT field: 'Read FIFO error' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_rd_error_o_i           : in     std_logic;
             -- Port for BIT field: 'Write FIFO full' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_wr_full_o_i            : in     std_logic;
             -- Port for BIT field: 'Write FIFO empty' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_wr_empty_o_i           : in     std_logic;
             -- Port for std_logic_vector field: 'Write FIFO count' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_wr_count_o_i           : in     std_logic_vector(6 downto 0);
             -- Port for BIT field: 'Write FIFO underrun' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_wr_underrun_o_i        : in     std_logic;
             -- Port for BIT field: 'Write FIFO error' in reg: 'DDR3 Port 1 Status'
                 wb_ddr3_status_p1_wr_error_o_i           : in     std_logic
               );
        end component wb_ddr3_status_slave;

  ------------------------------------------------------------------------------
  -- Constants declaration
  ------------------------------------------------------------------------------
  constant c_BAR0_APERTURE    : integer := 16;  -- nb of bits for 32-bit word address
  constant c_CSR_WB_SLAVES_NB : integer := 4;
  
  constant c_TX_CHANNELS : integer := g_TX_CHANNELS;
  constant c_RX_CHANNELS : integer := g_RX_CHANNELS;

  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------

  -- System clock
  signal sys_clk : std_logic;
  
  -- IO clocks
  signal CLK_40 : std_logic;
  signal CLK_80 : std_logic;
  signal clk_125 : std_logic; --125 Mhz ref clokc from FPGA fabric
  signal gtp_clk : std_logic; --New Signal for clock signal GTP - 125 Ref Clock directy into GTP
  signal CLK_160 : std_logic;
  signal CLK_640 : std_logic;
  signal CLK_40_buf : std_logic;
  signal CLK_80_buf : std_logic;
  signal CLK_160_buf : std_logic;
  signal CLK_640_buf : std_logic;
  signal ioclk_fb : std_logic;
  
  -- System clock generation
  signal sys_clk_buf         : std_logic;
  signal sys_clk_40_buf    : std_logic;
  signal sys_clk_200_buf    : std_logic;
  signal sys_clk_40        : std_logic;
  signal sys_clk_200        : std_logic;
  signal sys_clk_fb         : std_logic;
  signal sys_clk_pll_locked : std_logic;
  
  -- DDR3 clock
  signal ddr_clk     : std_logic;
  signal ddr_clk_buf : std_logic;  
  
  signal locked : std_logic;
  signal locked_v : std_logic_vector(1 downto 0);
  signal rst_n : std_logic;

  -- LCLK from GN4124 used as system clock
  signal l_clk : std_logic;

  -- P2L colck PLL status
  signal p2l_pll_locked : std_logic;

  -- CSR wishbone bus (master)
  signal wbm_adr   : std_logic_vector(31 downto 0);
  signal wbm_dat_i : std_logic_vector(31 downto 0);
  signal wbm_dat_o : std_logic_vector(31 downto 0);
  signal wbm_sel   : std_logic_vector(3 downto 0);
  signal wbm_cyc   : std_logic;
  signal wbm_stb   : std_logic;
  signal wbm_we    : std_logic;
  signal wbm_ack   : std_logic;
  signal wbm_stall : std_logic;

  -- CSR wishbone bus (slaves)
  signal wb_adr   : std_logic_vector(31 downto 0);
  signal wb_dat_i : std_logic_vector((32*c_CSR_WB_SLAVES_NB)-1 downto 0);
  signal wb_dat_o : std_logic_vector(31 downto 0);
  signal wb_sel   : std_logic_vector(3 downto 0);
  signal wb_cyc   : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);
  signal wb_stb   : std_logic;
  signal wb_we    : std_logic;
  signal wb_ack   : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);
  signal wb_stall : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);

  -- DMA wishbone bus
  signal dma_adr   : std_logic_vector(31 downto 0);
  signal dma_dat_i : std_logic_vector(31 downto 0);
  signal dma_dat_o : std_logic_vector(31 downto 0);
  signal dma_sel   : std_logic_vector(3 downto 0);
  signal dma_cyc   : std_logic;
  signal dma_stb   : std_logic;
  signal dma_we    : std_logic;
  signal dma_ack   : std_logic;
  signal dma_stall : std_logic;
  signal ram_we    : std_logic;
  
  -- DMAbus RX bridge
  signal rx_dma_adr	: std_logic_vector(31 downto 0);
  signal rx_dma_dat_o	: std_logic_vector(31 downto 0);
  signal rx_dma_dat_i	: std_logic_vector(31 downto 0);
  signal rx_dma_cyc	: std_logic;
  signal rx_dma_stb	: std_logic;
  signal rx_dma_we	: std_logic;
  signal rx_dma_ack	: std_logic;
  signal rx_dma_stall : std_logic;
  
  -- Interrupts stuff
  signal irq_sources   : std_logic_vector(1 downto 0);
  signal irq_to_gn4124 : std_logic;
  signal irq_out : std_logic;

  -- CSR whisbone slaves for test
  signal dummy_stat_reg_1      : std_logic_vector(31 downto 0);
  signal dummy_stat_reg_2      : std_logic_vector(31 downto 0);
  signal dummy_stat_reg_3      : std_logic_vector(31 downto 0);
  signal dummy_stat_reg_switch : std_logic_vector(31 downto 0);

  signal dummy_ctrl_reg_1   : std_logic_vector(31 downto 0);
  signal dummy_ctrl_reg_2   : std_logic_vector(31 downto 0);
  signal dummy_ctrl_reg_3   : std_logic_vector(31 downto 0);
  signal dummy_ctrl_reg_led : std_logic_vector(31 downto 0);

  -- FOR TESTS
  signal debug       : std_logic_vector(31 downto 0);
  signal clk_div_cnt : unsigned(3 downto 0);
  signal clk_div     : std_logic;

  -- LED
  signal led_cnt   : unsigned(24 downto 0);
  signal led_en    : std_logic;
  signal led_k2000 : unsigned(2 downto 0);
  signal led_pps   : std_logic;
  signal leds      : std_logic_vector(3 downto 0);
  
  -- ILA
  signal CONTROL : STD_LOGIC_VECTOR(35 DOWNTO 0);
  signal TRIG0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal TRIG1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal TRIG2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal TRIG0_t : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal TRIG1_t : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal TRIG2_t : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal debug_dma : std_logic_vector(31 downto 0);
  
  signal ddr_status : std_logic_vector(31 downto 0);
  signal gn4124_core_Status : std_logic_vector(31 downto 0);
  
  signal tx_data_o : std_logic_vector(0 downto 0);
  signal trig_pulse : std_logic;
  	
	signal fe_cmd_o : std_logic_vector(c_TX_CHANNELS-1 downto 0);
	signal fe_clk_o : std_logic_vector(c_TX_CHANNELS-1 downto 0);
	signal fe_data_i : std_logic_vector(c_RX_CHANNELS-1 downto 0);
	
	signal rx_data : std_logic_vector(31 downto 0);
	signal rx_valid : std_logic;
	
	signal rx_busy : std_logic;
	
  ------------------------------------------------------------------------------
  -- ALL NEW SFP PROJECT SIGNAL DECLARATION AND ASSIGNMENT AND EVERYTHING I CAN
  -- !!!!!!!!!!!--->>>PLACED HERE<<<-----!!!!!!!!!!!! 
  -- SO THAT ALL THE SFP CHANGES ARE IN ONE SPOT AS MUCH AS POSSIBLE
  ------------------------------------------------------------------------------
constant c_dpram_size : natural := 16384; -- in 32-bit words (64KB)  

signal lm32_interrupt : std_logic_vector(31 downto 0);
signal lm32_rstn : std_logic;

	-- Status - Port 0
signal    p0_cmd_empty_o   : std_logic;
signal    p0_cmd_full_o    : std_logic;
signal    p0_rd_full_o     : std_logic;
signal    p0_rd_empty_o    : std_logic;
signal    p0_rd_count_o    : std_logic_vector(6 downto 0);
signal    p0_rd_overflow_o : std_logic;
signal    p0_rd_error_o    : std_logic;
signal    p0_wr_full_o     : std_logic;
signal    p0_wr_empty_o    : std_logic;
signal    p0_wr_count_o    : std_logic_vector(6 downto 0);
signal    p0_wr_underrun_o : std_logic;
signal    p0_wr_error_o    : std_logic;
                             
	-- Status - Port 1   
signal    p1_cmd_empty_o   : std_logic;
signal    p1_cmd_full_o    : std_logic;
signal    p1_rd_full_o     : std_logic;
signal    p1_rd_empty_o    : std_logic;
signal    p1_rd_count_o    : std_logic_vector(6 downto 0);
signal    p1_rd_overflow_o : std_logic;
signal    p1_rd_error_o    : std_logic;
signal    p1_wr_full_o     : std_logic;
signal    p1_wr_empty_o    : std_logic;
signal    p1_wr_count_o    : std_logic_vector(6 downto 0);
signal    p1_wr_underrun_o : std_logic;
signal    p1_wr_error_o    : std_logic;

--Signals interconnecting GTP Core to Rx Bridge Core

signal	 txdata1		  	  : std_logic_vector(31 downto 0);
signal	 rxdata1		     : std_logic_vector(31 downto 0);
signal	 rxrecclk1        : std_logic;
signal	 refclkpll1		  : std_logic;


signal gtp_userclk_buf    : std_logic;
signal gtp_userclk2_buf   : std_logic;
signal gtp_userclk        : std_logic;
signal gtp_userclk2       : std_logic;


--Wishbone Signals

  signal genum_wb_out     : t_wishbone_master_out;
  signal genum_wb_in      : t_wishbone_master_in;

  signal genum_dma_out    : t_wishbone_master_out;
  signal genum_dma_in     : t_wishbone_master_in;

  signal pri_crossbar_out     : t_wishbone_master_out;
  signal pri_crossbar_in      : t_wishbone_master_in;  
   
  signal wb_ddr0_out       : t_wishbone_slave_out;
  signal wb_ddr0_in        : t_wishbone_slave_in;
  
  signal wb_dummy_out     : t_wishbone_slave_out;
  signal wb_dummy_in      : t_wishbone_slave_in;   
  
  signal wb_dctrl_out     : t_wishbone_slave_out;
  signal wb_dctrl_in      : t_wishbone_slave_in;     
  
  signal wb_dma_ctrl_out  : t_wishbone_slave_out;
  signal wb_dma_ctrl_in   : t_wishbone_slave_in;  
  
  signal wb_ddr_stat_out    : t_wishbone_slave_out;
  signal wb_ddr_stat_in     : t_wishbone_slave_in;  

  signal wb_rx_bri_out    : t_wishbone_slave_out;
  signal wb_rx_bri_in     : t_wishbone_slave_in;    
  
--Wishbone Signals - Secondary Crossbar  

  signal lm32_inst_out     : t_wishbone_master_out;
  signal lm32_inst_in      : t_wishbone_master_in;
  signal lm32_data_out     : t_wishbone_master_out;
  signal lm32_data_in      : t_wishbone_master_in;  
  
  signal wb_dpram_out    : t_wishbone_slave_out;
  signal wb_dpram_in     : t_wishbone_slave_in;  
  
  signal wb_uart_out    : t_wishbone_slave_out;
  signal wb_uart_in     : t_wishbone_slave_in;  
  
  
--Wishbone Signals - DDR Crossbar

  signal sec_crossbar_out     : t_wishbone_master_out;
  signal sec_crossbar_in      : t_wishbone_master_in;
  signal rx_bridge_out        : t_wishbone_master_out;
  signal rx_bridge_in         : t_wishbone_master_in;  
  
  signal wb_ddr1_out    : t_wishbone_slave_out;
  signal wb_ddr1_in     : t_wishbone_slave_in;    
  
--Wishbone Signals - GTP SerDes  

  signal wb_gtp_csr_out    : t_wishbone_slave_out;
  signal wb_gtp_csr_in     : t_wishbone_slave_in;  
  
  signal wb_gtp_eic_out    : t_wishbone_slave_out;
  signal wb_gtp_eic_in     : t_wishbone_slave_in;  

  signal wb_gtp_ddr_out    : t_wishbone_master_out;
  signal wb_gtp_ddr_in     : t_wishbone_master_in;      
  
  
--  signal dummy_reg_1 : std_logic_vector(31 downto 0);
--  signal dummy_reg_2 : std_logic_vector(31 downto 0);
--  signal dummy_reg_3 : std_logic_vector(31 downto 0);
--  signal dummy_reg_led : std_logic_vector(31 downto 0);
  
  

begin

-- Direct connection of GN4124 DMA Wishbone interface to Port 1 of DDR memory controller

  wb_ddr0_in <= genum_dma_out;
  genum_dma_in <= wb_ddr0_out;
  
  --------------------------------------
  -- DDR WISHBONE CROSSBAR
  --------------------------------------   
  cmp_wb_ddr_crossbar : xwb_crossbar
    generic map (
      g_num_masters => 3,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"), --Wishbone Slave 0 - DDR3 Memory
      g_mask        => (0 => x"10000000"))
      
    port map (
      clk_sys_i   => sys_clk,
      rst_n_i     => rst_n,
      --Wishbone Bus Master(s)
      slave_i(2)  => wb_gtp_ddr_out,
      slave_i(1)  => sec_crossbar_out,
      slave_i(0)  => rx_bridge_out,
      
      slave_o(2)  => wb_gtp_ddr_in,
      slave_o(1)  => sec_crossbar_in,
      slave_o(0)  => rx_bridge_in,
      
      --Wishbone Bus Slave
      master_i(0) => wb_ddr1_out,
      master_o(0) => wb_ddr1_in);  
      
      
  --------------------------------------
  -- PRIMARY WISHBONE CROSSBAR
  --------------------------------------   
  cmp_wb_crossbar : xwb_crossbar
    generic map (
      g_num_masters => 1,
      g_num_slaves  => 5,
      g_registered  => false,
      g_address     => ( x"00040000",  --Wishbone Slave 4 - Connection to Secondary Crossbar
		                   x"00030000",  --Wishbone Slave 3 - DDR Status and Control 
		                   x"00020000",  --Wishbone Slave 2 - SERDES EIC Interrupt Interface
		                   x"00010000",  --Wishbone Slave 1 - RX Bridge for GTP Core to DDR Memory
		                   x"00000000"), --Wishbone Slave 0 - DMA Control and Status Registers for GN4124
                        
                        
      g_mask        => ( x"FFFF0000",
		                   x"FFFF0000",
		                   x"FFFF0000",
		                   x"FFFF0000",
                         x"FFFF0000"))
    port map (
      clk_sys_i   => sys_clk,
      rst_n_i     => rst_n,
      --Wishbone Bus Master
      slave_i(0)  => genum_wb_out,
      slave_o(0)  => genum_wb_in,
      --Wishbone Bus Slaves
		master_i(4) => pri_crossbar_in, --Crossover @ dest
		master_i(3) => wb_ddr_stat_out,
		master_i(2) => open,--wb_gtp_eic_out,
		master_i(1) => wb_rx_bri_out,
      master_i(0) => wb_dma_ctrl_out,
		 
		master_o(4) => pri_crossbar_out, --Crossover @ dest
		master_o(3) => wb_ddr_stat_in,
		master_o(2) => open,--wb_gtp_eic_in,
		master_o(1) => wb_rx_bri_in,
      master_o(0) => wb_dma_ctrl_in);
 
  --------------------------------------
  -- SECONDARY WISHBONE CROSSBAR
  -------------------------------------- 
  cmp_wb_sec_crossbar : xwb_crossbar
    generic map (
      g_num_masters => 3,
      g_num_slaves  => 7,
      g_registered  => false,
      
      g_address     => (x"10000000",  --Wishbone Slave 6 - DDR3 Memory
                        x"0000C000",  --Wishbone Slave 5 - SERDES CSR Interface 
                        x"0000B000",  --Wishbone Slave 4 - SERDES EIC Interrupt Interface
                        x"0000A000",  --Wishbone Slave 3 - UART Interface - LM32 User interface
                        x"00009000",  --Wishbone Slave 2 - LM32 Control Regs - 0x0 Reset; 0x1 Interrupt 0 
                        x"00008000",  --Wishbone Slave 1 - Dummy Regs - 
		                  x"00000000"), --Wishbone Slave 0 - Dual-Port RAM for LM32 Instructions
                        
      g_mask        => (x"10000000",
                        x"FFFFF000",
                        x"FFFFF000",
                        x"FFFFF000",
                        x"FFFFF000",
                        x"FFFFF000",
		                  x"FFFF8000"))
    port map (
      clk_sys_i   => sys_clk,
      rst_n_i     => rst_n,
      --Wishbone Bus Master

		slave_i(2)  => lm32_inst_out,
		slave_i(1)  => lm32_data_out,
      slave_i(0)  => pri_crossbar_out,
		
		slave_o(2)  => lm32_inst_in,
		slave_o(1)  => lm32_data_in,
      slave_o(0)  => pri_crossbar_in,
		
      --Wishbone Bus Slaves
		master_i(6) => sec_crossbar_in, --Crossover @ dest
      master_i(5) => wb_gtp_csr_out,
      master_i(4) => wb_gtp_eic_out,
		master_i(3) => wb_uart_out,
		master_i(2) => wb_dctrl_out,
      master_i(1) => wb_dummy_out,
		master_i(0) => wb_dpram_out, 
		
		master_o(6) => sec_crossbar_out, --Crossover @ dest
      master_o(5) => wb_gtp_csr_in,
      master_o(4) => wb_gtp_eic_in,
		master_o(3) => wb_uart_in,
		master_o(2) => wb_dctrl_in,
      master_o(1) => wb_dummy_in,   
		master_o(0) => wb_dpram_in);

  
  wb_dctrl_out.err <= '0';
  wb_dctrl_out.rty <= '0';
  wb_dctrl_out.int <= '0';
  
  wb_dummy_out.err <= '0';
  wb_dummy_out.rty <= '0';
  wb_dummy_out.int <= '0';		
 
  --------------------------------------
  -- LM32 INSTRUCTION RAM
  -------------------------------------- 
  cmp_wb_lm32_inst_ram : xwb_dpram
    generic map(
      g_size                  => c_dpram_size,
      g_init_file             => "",
      g_must_have_init_file   => false,
      g_slave1_interface_mode => PIPELINED, -- Why isn't this the default?!
      g_slave2_interface_mode => PIPELINED,
      g_slave1_granularity    => BYTE,
      g_slave2_granularity    => WORD)
    port map(
      clk_sys_i => sys_clk,
      rst_n_i   => rst_n,
      -- First port connected to the crossbar
      slave1_i  => wb_dpram_in,
      slave1_o  => wb_dpram_out,
      -- Second port disconnected
      slave2_i  => cc_dummy_slave_in, -- CYC always low
      slave2_o  => open);		

  --------------------------------------
  -- LM32 Micro Controller
  -------------------------------------- 
  cmp_wb_lm32 : xwb_lm32
    generic map(
      g_profile => "medium_icache_debug") -- Including JTAG and I-cache (no divide)
    port map(
      clk_sys_i => sys_clk,
      rst_n_i   => lm32_rstn,
      irq_i     => lm32_interrupt,
      dwb_o     => lm32_data_out, -- Data bus
      dwb_i     => lm32_data_in,
      iwb_o     => lm32_inst_out, -- Instruction bus
      iwb_i     => lm32_inst_in);
  
  -- The 31 interrupt pins are unconnected
  lm32_interrupt(31 downto 1) <= (others => '0');		
  lm32_interrupt(0) <= dummy_ctrl_reg_2(1);	
  lm32_rstn         <= dummy_ctrl_reg_2(0);
  
  --------------------------------------
  -- UART
  --------------------------------------
  cmp_wb_uart : xwb_simple_uart
    generic map(
      g_with_virtual_uart   => false,
      g_with_physical_uart  => true,
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE,
      g_vuart_fifo_size     => 1024
      )
    port map(
      clk_sys_i => sys_clk,
      rst_n_i   => rst_n,

      -- Wishbone
      slave_i => wb_uart_in,
      slave_o => wb_uart_out,
      desc_o  => open,

      uart_rxd_i => UART_TXD, --TX of external UART IC connected to rx of FPGA
      uart_txd_o => UART_RXD  --RX of external UART IC connected to tx of FPGA
      );
  ------------------------------------------------------------------------------
  -- Local clock from gennum LCLK
  ------------------------------------------------------------------------------
--	IBUFGDS_gn_clk	: IBUFGDS
--	generic map (
--		DIFF_TERM => TRUE, -- Differential Termination 
--		IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--		IOSTANDARD => "DIFF_SSTL18_I"
--	)
--	port map (
--		O => l_clk,  -- Clock buffer output
--		I  => L_CLKp,  -- Diff_p clock buffer input (connect directly to top-level port)
--		IB => L_CLKn -- Diff_n clock buffer input (connect directly to top-level port)
--	);
  ------------------------------------------------------------------------------
  -- Differential clock input from 125Mhz external PLL to FPGA fabric
  ------------------------------------------------------------------------------	
	IBUFGDS_pll_clk : IBUFGDS
	generic map (
		DIFF_TERM => TRUE, -- Differential Termination 
		IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
		IOSTANDARD => "LVDS_25"
	)
	port map (
		O =>  clk_125,  -- Clock buffer output
		I  => clk_125m_pllref_p_i,  -- Diff_p clock buffer input (connect directly to top-level port)
		IB => clk_125m_pllref_n_i -- Diff_n clock buffer input (connect directly to top-level port)
	);	
  ------------------------------------------------------------------------------
  -- Differential clock input from 125Mhz external PLL to GTP Transceivers
  ------------------------------------------------------------------------------		
	IBUFGDS_gtp_clk : IBUFGDS
	generic map (
		DIFF_TERM => TRUE, -- Differential Termination 
		IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
		IOSTANDARD => "LVDS_25"
	)
	port map (
		O =>  gtp_clk,  -- Clock buffer output
		I  => fpga_pll_ref_clk_101_p_i,  -- Diff_p clock buffer input (connect directly to top-level port)
		IB => fpga_pll_ref_clk_101_n_i -- Diff_n clock buffer input (connect directly to top-level port)
	);		
	
	
	

  ------------------------------------------------------------------------------
  -- GN4124 interface
  ------------------------------------------------------------------------------
  cmp_gn4124_core : gn4124_core
    port map
    (
      ---------------------------------------------------------
      -- Control and status
      rst_n_a_i             => rst_n,
      status_o => gn4124_core_status,


      ---------------------------------------------------------
      -- P2L Direction
      --
      -- Source Sync DDR related signals
      p2l_clk_p_i  => P2L_CLKp,
      p2l_clk_n_i  => P2L_CLKn,
      p2l_data_i   => P2L_DATA,
      p2l_dframe_i => P2L_DFRAME,
      p2l_valid_i  => P2L_VALID,

      -- P2L Control
      p2l_rdy_o  => P2L_RDY,
      p_wr_req_i => P_WR_REQ,
      p_wr_rdy_o => P_WR_RDY,
      rx_error_o => RX_ERROR,

      ---------------------------------------------------------
      -- L2P Direction
      --
      -- Source Sync DDR related signals
      l2p_clk_p_o  => L2P_CLKp,
      l2p_clk_n_o  => L2P_CLKn,
      l2p_data_o   => L2P_DATA,
      l2p_dframe_o => L2P_DFRAME,
      l2p_valid_o  => L2P_VALID,
      l2p_edb_o    => L2P_EDB,

      -- L2P Control
      l2p_rdy_i    => L2P_RDY,
      l_wr_rdy_i   => L_WR_RDY,
      p_rd_d_rdy_i => P_RD_D_RDY,
      tx_error_i   => TX_ERROR,
      vc_rdy_i     => VC_RDY,

      ---------------------------------------------------------
      -- Interrupt interface
      dma_irq_o => irq_sources,
      irq_p_i   => irq_to_gn4124,
      irq_p_o   => irq_out,

      ---------------------------------------------------------
      -- DMA registers wishbone interface (slave classic)
      dma_reg_clk_i   => sys_clk,
      dma_reg_adr_i   => wb_dma_ctrl_in.adr,  --wb_adr,
      dma_reg_dat_i   => wb_dma_ctrl_in.dat,  --wb_dat_o,
      dma_reg_sel_i   => wb_dma_ctrl_in.sel,  --wb_sel,
      dma_reg_stb_i   => wb_dma_ctrl_in.stb,  --wb_stb,
      dma_reg_we_i    => wb_dma_ctrl_in.we,  --wb_we,
      dma_reg_cyc_i   => wb_dma_ctrl_in.cyc,  --wb_cyc(0),
      dma_reg_dat_o   => wb_dma_ctrl_out.dat,  --wb_dat_i(31 downto 0),
      dma_reg_ack_o   => wb_dma_ctrl_out.ack,  --wb_ack(0),
      dma_reg_stall_o => wb_dma_ctrl_out.stall,  --wb_stall(0),

      ---------------------------------------------------------
      -- CSR wishbone interface (master pipelined)
      csr_clk_i   => sys_clk,
      csr_adr_o   => genum_wb_out.adr,  --genum_wb_out.adr,  --wbm_adr,
      csr_dat_o   => genum_wb_out.dat,  --wbm_dat_o,
      csr_sel_o   => genum_wb_out.sel,  --wbm_sel,
      csr_stb_o   => genum_wb_out.stb,  --wbm_stb,
      csr_we_o    => genum_wb_out.we,  --wbm_we,
      csr_cyc_o   => genum_wb_out.cyc,  --wbm_cyc,
      csr_dat_i   => genum_wb_in.dat,  --wbm_dat_i,
      csr_ack_i   => genum_wb_in.ack,  --wbm_ack,
      csr_stall_i => genum_wb_in.stall,  --wbm_stall,
      csr_err_i   => '0',
      csr_rty_i   => '0',
      csr_int_i   => '0',

      ---------------------------------------------------------
      -- DMA wishbone interface (master pipelined)
      dma_clk_i   => sys_clk,
      dma_adr_o   => genum_dma_out.adr,  --dma_adr,
      dma_dat_o   => genum_dma_out.dat,  --dma_dat_o,
      dma_sel_o   => genum_dma_out.sel,  --dma_sel,
      dma_stb_o   => genum_dma_out.stb,  --dma_stb,
      dma_we_o    => genum_dma_out.we,  --dma_we,
      dma_cyc_o   => genum_dma_out.cyc,  --dma_cyc,
      dma_dat_i   => genum_dma_in.dat,  --dma_dat_i,
      dma_ack_i   => genum_dma_in.ack,  --dma_ack,
      dma_stall_i => genum_dma_in.stall,  --dma_stall,
      dma_err_i   => '0',
      dma_rty_i   => '0',
      dma_int_i   => '0'
      );
	GPIO(0) <= irq_out;
	GPIO(1) <= '0';

  ------------------------------------------------------------------------------
  -- CSR wishbone bus slaves
  ------------------------------------------------------------------------------
    cmp_dummy_ctrl_regs_wb_slave : dummy_ctrl_regs_wb_slave
    port map(
      rst_n_i                 => rst_n,
      wb_clk_i                => sys_clk,
      wb_addr_i               => wb_dctrl_in.adr(1 downto 0), --wb_adr(1 downto 0),
      wb_data_i               => wb_dctrl_in.dat, --wb_dat_o,
      wb_data_o               => wb_dctrl_out.dat, --wb_dat_i(63 downto 32),
      wb_cyc_i                => wb_dctrl_in.cyc, --wb_cyc(1),
      wb_sel_i                => wb_dctrl_in.sel, --wb_sel,
      wb_stb_i                => wb_dctrl_in.stb, --wb_stb,
      wb_we_i                 => wb_dctrl_in.we, --wb_we,
      wb_ack_o                => wb_dctrl_out.ack, --wb_ack(1),
      dummy_reg_1_o      => dummy_ctrl_reg_1,
      dummy_reg_2_o      => dummy_ctrl_reg_2,
      dummy_reg_3_o      => dummy_ctrl_reg_3,
      dummy_reg_led_o    => dummy_ctrl_reg_led
      );
      
  cmp_dummy_stat_regs : dummy_stat_regs_wb_slave
    port map(
      rst_n_i                 => rst_n,
      wb_clk_i                => sys_clk,
      wb_addr_i               => wb_dummy_in.adr(1 downto 0), --wb_adr(1 downto 0),
      wb_data_i               => wb_dummy_in.dat, --wb_dat_o,
      wb_data_o               => wb_dummy_out.dat, --wb_dat_i(63 downto 32),
      wb_cyc_i                => wb_dummy_in.cyc, --wb_cyc(1),
      wb_sel_i                => wb_dummy_in.sel, --wb_sel,
      wb_stb_i                => wb_dummy_in.stb, --wb_stb,
      wb_we_i                 => wb_dummy_in.we, --wb_we,
      wb_ack_o                => wb_dummy_out.ack, --wb_ack(1),
      dummy_stat_reg_1_i      => dummy_stat_reg_1,
      dummy_stat_reg_2_i      => dummy_stat_reg_2,
      dummy_stat_reg_3_i      => dummy_stat_reg_3,
      dummy_stat_reg_switch_i => dummy_stat_reg_switch
      );

	cmp_wb_rx_bridge : wb_rx_bridge port map (
		-- Sys Connect
		sys_clk_i => sys_clk,
		rst_n_i => rst_n,
		-- Wishbone slave interface
		wb_adr_i => wb_rx_bri_in.adr,  --wb_adr,
		wb_dat_i => wb_rx_bri_in.dat,  --wb_dat_o,
		wb_dat_o => wb_rx_bri_out.dat,  --wb_dat_i(63 downto 32),
		wb_cyc_i => wb_rx_bri_in.cyc,  --wb_cyc(1),
		wb_stb_i => wb_rx_bri_in.stb,  --wb_stb,
		wb_we_i =>  wb_rx_bri_in.we,  --wb_we,
		wb_ack_o => wb_rx_bri_out.ack,  --wb_ack(1),
		wb_stall_o => wb_rx_bri_out.stall,  --wb_stall(1),
		-- Wishbone DMA Master Interface
		dma_clk_i => sys_clk,
		dma_adr_o => rx_bridge_out.adr, --rx_dma_adr,
		dma_dat_o => rx_bridge_out.dat, --rx_dma_dat_o,
		dma_dat_i => rx_bridge_in.dat, --rx_dma_dat_i,
		dma_cyc_o => rx_bridge_out.cyc, --rx_dma_cyc,
		dma_stb_o => rx_bridge_out.stb, --rx_dma_stb,
		dma_we_o =>  rx_bridge_out.we, --rx_dma_we,
		dma_ack_i => rx_bridge_in.ack, --rx_dma_ack,
		dma_stall_i => rx_bridge_in.stall, --rx_dma_stall,
		-- Rx Interface (sync to sys_clk)
		rx_data_i => rx_data,
		rx_valid_i => rx_valid,
		-- Status in
		trig_pulse_i => trig_pulse,
		-- Status out
		irq_o => open,
		busy_o => rx_busy,
		
		txdata1_o  => txdata1,
		rxdata1_i  => rxdata1,
		recclk_i   => rxrecclk1,
		refclk_i	  => refclkpll1
		
	);
   
   rx_bridge_out.sel <= "1111";

  --wb_stall(1) <= '0' when wb_cyc(1) = '0' else not(wb_ack(1));
  --wb_stall(2) <= '0' when wb_cyc(2) = '0' else not(wb_ack(2));

  dummy_stat_reg_1      <= X"DEADBABE";
  dummy_stat_reg_2      <= X"BEEFFACE";
  dummy_stat_reg_3      <= X"12345678";
  dummy_stat_reg_switch <= X"0000000" & "000" & p2l_pll_locked;

  --led_red_o   <= dummy_ctrl_reg_led(0);
  --led_green_o <= dummy_ctrl_reg_led(1);

  ------------------------------------------------------------------------------
  -- Interrupt stuff
  ------------------------------------------------------------------------------
  -- just forward irq pulses for test
  irq_to_gn4124 <= irq_sources(1) or irq_sources(0);


  ------------------------------------------------------------------------------
  -- FOR TEST
  ------------------------------------------------------------------------------
  p_led_cnt : process (L_RST_N, sys_clk)
  begin
    if L_RST_N = '0' then
      led_cnt <= (others => '1');
      led_en  <= '1';
    elsif rising_edge(sys_clk) then
      led_cnt <= led_cnt - 1;
      led_en  <= led_cnt(23);
    end if;
  end process p_led_cnt;

  led_pps <= led_cnt(23) and not(led_en);


  p_led_k2000 : process (sys_clk, L_RST_N)
  begin
    if L_RST_N = '0' then
      led_k2000 <= (others => '0');
      leds      <= "0001";
    elsif rising_edge(sys_clk) then
      if led_pps = '1' then
        if led_k2000(2) = '0' then
          if leds /= "1000" then
            leds <= leds(2 downto 0) & '0';
          end if;
        else
          if leds /= "0001" then
            leds <= '0' & leds(3 downto 1);
          end if;
        end if;
        led_k2000 <= led_k2000 + 1;
      end if;
    end if;
  end process p_led_k2000;

  AUX_LEDS_O <= not(leds);

--	rst_n <= (L_RST_N and sys_clk_pll_locked and locked);
	rst_n <= L_RST_N;        --Reset relies on GN4124 reset only
		

	------------------------------------------------------------------------------
	-- Clocks distribution from 20MHz TCXO
	--  40.000 MHz IO driver clock
	-- 200.000 MHz fast system clock
	-- 333.333 MHz DDR3 clock
	------------------------------------------------------------------------------
	--sys_clk <= l_clk;
	-- AD5662BRMZ-1 DAC output powers up to 0V. The output remains valid until a
	-- write sequence arrives to the DAC.
	-- To avoid spurious writes, the DAC interface outputs are fixed to safe values.
	pll25dac_sync_n <= '1';
	pll20dac_sync_n <= '1';
	plldac_din      <= '0';
	plldac_sclk     <= '0';

--  cmp_sys_clk_buf : IBUFG
--    port map (
--      I => clk20_vcxo_i,
--      O => sys_clk_in);

  cmp_sys_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      
      CLKOUT0_DIVIDE     => 20,
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      
      CLKOUT1_DIVIDE     => 3,
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      
      CLKOUT2_DIVIDE     => 4,    --1000 / 4 = 250Mhz Userclk
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      
      CLKOUT3_DIVIDE     => 16,  -- 1000 / 4*4 = 62.5Mhz Userclk2
      CLKOUT3_PHASE      => 0.000,
      CLKOUT3_DUTY_CYCLE => 0.500,      
      
      CLKIN_PERIOD       => 8.0,
      REF_JITTER         => 0.016)
    port map (
      CLKFBOUT => sys_clk_fb,
      CLKOUT0  => sys_clk_buf,
      CLKOUT1  => ddr_clk_buf,
      CLKOUT2  => gtp_userclk_buf,
      CLKOUT3  => gtp_userclk2_buf,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => sys_clk_pll_locked,
      RST      => '0',
      CLKFBIN  => sys_clk_fb,
      CLKIN    => clk_125);

  cmp_ddr_clk_buf : BUFG
    port map (
      O => ddr_clk,
      I => ddr_clk_buf);
      
  cmp_sys_clk_buf : BUFG
    port map (
      O => sys_clk,
      I => sys_clk_buf);

  cmp_gtp_userclk_buf : BUFG
    port map (
      O => gtp_userclk,
      I => gtp_userclk_buf);

  cmp_gtp_userclk2_buf : BUFG
    port map (
      O => gtp_userclk2,
      I => gtp_userclk2_buf);      
	  
	cmp_ddr3_ctrl: ddr3_ctrl 
   GENERIC MAP(
		 --! Bank and port size selection
		 g_BANK_PORT_SELECT   => "SPEC_BANK3_32B_32B",
		 --! Core's clock period in ps
		 g_MEMCLK_PERIOD      => 3000,
		 --! If TRUE, uses Xilinx calibration core (Input term, DQS centering)
		 g_CALIB_SOFT_IP      => "TRUE",
		 --! User ports addresses maping (BANK_ROW_COLUMN or ROW_BANK_COLUMN)
		 g_MEM_ADDR_ORDER     => "BANK_ROW_COLUMN",
		 --! Simulation mode
		 g_SIMULATION         => "FALSE",
		 --! DDR3 data port width
		 g_NUM_DQ_PINS        => 16,
		 --! DDR3 address port width
		 g_MEM_ADDR_WIDTH     => 14,
		 --! DDR3 bank address width
		 g_MEM_BANKADDR_WIDTH => 3,
		 --! Wishbone port 0 data mask size (8-bit granularity)
		 g_P0_MASK_SIZE       => 4,
		 --! Wishbone port 0 data width
		 g_P0_DATA_PORT_SIZE  => 32,
		 --! Port 0 byte address width
		 g_P0_BYTE_ADDR_WIDTH => 30,
		 --! Wishbone port 1 data mask size (8-bit granularity)
		 g_P1_MASK_SIZE       => 4,
		 --! Wishbone port 1 data width
		 g_P1_DATA_PORT_SIZE  => 32,
		 --! Port 1 byte address width
		 g_P1_BYTE_ADDR_WIDTH => 30
		 )
   PORT MAP(
		clk_i => ddr_clk,
		rst_n_i => rst_n,
		status_o => ddr_status,
		ddr3_dq_b => DDR3_DQ,
		ddr3_a_o => DDR3_A,
		ddr3_ba_o => DDR3_BA,
		ddr3_ras_n_o => DDR3_RAS_N,
		ddr3_cas_n_o => DDR3_CAS_N,
		ddr3_we_n_o => DDR3_WE_N,
		ddr3_odt_o => DDR3_ODT,
		ddr3_rst_n_o => DDR3_RESET_N,
		ddr3_cke_o => DDR3_CKE,
		ddr3_dm_o => DDR3_LDM,
		ddr3_udm_o => DDR3_UDM,
		ddr3_dqs_p_b => DDR3_LDQS_P,
		ddr3_dqs_n_b => DDR3_LDQS_N,
		ddr3_udqs_p_b => DDR3_UDQS_P,
		ddr3_udqs_n_b => DDR3_UDQS_N,
		ddr3_clk_p_o => DDR3_CK_P,
		ddr3_clk_n_o => DDR3_CK_N,
		ddr3_rzq_b => DDR3_RZQ,
		ddr3_zio_b => DDR3_ZIO,
		wb0_clk_i => sys_clk,
		wb0_sel_i => wb_ddr0_in.sel,  --dma_sel,
		wb0_cyc_i => wb_ddr0_in.cyc,  --dma_cyc,
		wb0_stb_i => wb_ddr0_in.stb,  --dma_stb,
		wb0_we_i => wb_ddr0_in.we,  --dma_we,
		wb0_addr_i => wb_ddr0_in.adr,  --dma_adr,
		wb0_data_i => wb_ddr0_in.dat,  --dma_dat_o,
		wb0_data_o => wb_ddr0_out.dat,  --dma_dat_i,
		wb0_ack_o => wb_ddr0_out.ack,  --dma_ack,
		wb0_stall_o => wb_ddr0_out.stall,  --dma_stall,
		p0_cmd_empty_o =>    p0_cmd_empty_o    ,
		p0_cmd_full_o =>     p0_cmd_full_o     ,
		p0_rd_full_o =>      p0_rd_full_o      ,
		p0_rd_empty_o =>     p0_rd_empty_o     ,
		p0_rd_count_o =>     p0_rd_count_o     ,
		p0_rd_overflow_o =>  p0_rd_overflow_o  ,
		p0_rd_error_o =>     p0_rd_error_o     ,
		p0_wr_full_o =>      p0_wr_full_o      ,
		p0_wr_empty_o =>     p0_wr_empty_o     ,
		p0_wr_count_o =>     p0_wr_count_o     ,
		p0_wr_underrun_o =>  p0_wr_underrun_o  ,
		p0_wr_error_o =>     p0_wr_error_o     ,
		wb1_clk_i =>   sys_clk,
		wb1_sel_i =>   wb_ddr1_in.sel,  --"1111",
		wb1_cyc_i =>   wb_ddr1_in.cyc,  --rx_dma_cyc,
		wb1_stb_i =>   wb_ddr1_in.stb,  --rx_dma_stb,
		wb1_we_i =>    wb_ddr1_in.we,  --rx_dma_we,
		wb1_addr_i =>  wb_ddr1_in.adr,  --rx_dma_adr,
		wb1_data_i =>  wb_ddr1_in.dat,  --rx_dma_dat_o,
		wb1_data_o =>  wb_ddr1_out.dat,  --rx_dma_dat_i,
		wb1_ack_o =>   wb_ddr1_out.ack,  --rx_dma_ack,
		wb1_stall_o => wb_ddr1_out.stall,  --rx_dma_stall,
		p1_cmd_empty_o =>       p1_cmd_empty_o   ,
		p1_cmd_full_o =>        p1_cmd_full_o    ,
		p1_rd_full_o =>         p1_rd_full_o     ,
		p1_rd_empty_o =>        p1_rd_empty_o    ,
		p1_rd_count_o =>        p1_rd_count_o    ,
		p1_rd_overflow_o =>     p1_rd_overflow_o ,
		p1_rd_error_o =>        p1_rd_error_o    ,
		p1_wr_full_o =>         p1_wr_full_o     ,
		p1_wr_empty_o =>        p1_wr_empty_o    ,
		p1_wr_count_o =>        p1_wr_count_o    ,
		p1_wr_underrun_o =>     p1_wr_underrun_o ,
		p1_wr_error_o =>        p1_wr_error_o    
	);
	
	
	cmp_wb_ddr3_status_slave : wb_ddr3_status_slave PORT MAP (
    rst_n_i                                  => rst_n,                         
    clk_sys_i                                => sys_clk,                      
    wb_adr_i                                 => wb_ddr_stat_in.adr(2 downto 2),  --wb_adr(2 downto 2), --Align at word to make hw addressing match sw addressing
    wb_dat_i                                 => wb_ddr_stat_in.dat,  --wb_dat_o ,         
    wb_dat_o                                 => wb_ddr_stat_out.dat,  --wb_dat_i(127 downto 96),
    wb_cyc_i                                 => wb_ddr_stat_in.cyc,  --wb_cyc(3),
    wb_sel_i                                 => wb_ddr_stat_in.sel,  --wb_sel   ,   
    wb_stb_i                                 => wb_ddr_stat_in.stb,  --wb_stb   ,
    wb_we_i                                  => wb_ddr_stat_in.we,  --wb_we    ,
    wb_ack_o                                 => wb_ddr_stat_out.ack,  --wb_ack(3),   
    wb_stall_o                               => wb_ddr_stat_out.stall,  --wb_stall(3),
    --Port 0 Status Signals
    wb_ddr3_status_p0_cmd_full_o_i           => p0_cmd_full_o    ,
    wb_ddr3_status_p0_cmd_empty_o_i          => p0_cmd_empty_o   ,
    wb_ddr3_status_p0_rd_full_o_i            => p0_rd_full_o     ,
    wb_ddr3_status_p0_rd_empty_o_i           => p0_rd_empty_o    ,
    wb_ddr3_status_p0_rd_count_o_i           => p0_rd_count_o    ,
    wb_ddr3_status_p0_rd_overflow_o_i        => p0_rd_overflow_o ,
    wb_ddr3_status_p0_rd_error_o_i           => p0_rd_error_o    ,
    wb_ddr3_status_p0_wr_full_o_i            => p0_wr_full_o     ,
    wb_ddr3_status_p0_wr_empty_o_i           => p0_wr_empty_o    ,
    wb_ddr3_status_p0_wr_count_o_i           => p0_wr_count_o    ,
    wb_ddr3_status_p0_wr_underrun_o_i        => p0_wr_underrun_o ,
    wb_ddr3_status_p0_wr_error_o_i           => p0_wr_error_o    ,
    --Port 1 Status Signals	 
    wb_ddr3_status_p1_cmd_full_o_i           => p1_cmd_full_o    ,
    wb_ddr3_status_p1_cmd_empty_o_i          => p1_cmd_empty_o   ,
    wb_ddr3_status_p1_rd_full_o_i            => p1_rd_full_o     ,
    wb_ddr3_status_p1_rd_empty_o_i           => p1_rd_empty_o    ,
    wb_ddr3_status_p1_rd_count_o_i           => p1_rd_count_o    ,
    wb_ddr3_status_p1_rd_overflow_o_i        => p1_rd_overflow_o ,
    wb_ddr3_status_p1_rd_error_o_i           => p1_rd_error_o    ,
    wb_ddr3_status_p1_wr_full_o_i            => p1_wr_full_o     ,
    wb_ddr3_status_p1_wr_empty_o_i           => p1_wr_empty_o    ,
    wb_ddr3_status_p1_wr_count_o_i           => p1_wr_count_o    ,
    wb_ddr3_status_p1_wr_underrun_o_i        => p1_wr_underrun_o ,
    wb_ddr3_status_p1_wr_error_o_i           => p1_wr_error_o    
  );

  ------------------------------------------------------------------------------
  -- SERDES Interface
  ------------------------------------------------------------------------------
  cmp_serdes_intfce : serdes_intfce
    generic map(
      G_RATE => g_RATE
    )
    port map(
      wb_csr_adr_i   => wb_gtp_csr_in.adr(5 downto 2),  -- cnx_master_out.adr is byte address
      wb_csr_dat_i   => wb_gtp_csr_in.dat,
      wb_csr_dat_o   => wb_gtp_csr_out.dat,
      wb_csr_cyc_i   => wb_gtp_csr_in.cyc,
      wb_csr_sel_i   => wb_gtp_csr_in.sel,
      wb_csr_stb_i   => wb_gtp_csr_in.stb,
      wb_csr_we_i    => wb_gtp_csr_in.we,
      wb_csr_ack_o   => wb_gtp_csr_out.ack,
      wb_csr_stall_o => wb_gtp_csr_out.stall,

      wb_eic_adr_i   => wb_gtp_eic_in.adr(3 downto 2),  -- cnx_master_out.adr is byte address
      wb_eic_dat_i   => wb_gtp_eic_in.dat,
      wb_eic_dat_o   => wb_gtp_eic_out.dat,
      wb_eic_cyc_i   => wb_gtp_eic_in.cyc,
      wb_eic_sel_i   => wb_gtp_eic_in.sel,
      wb_eic_stb_i   => wb_gtp_eic_in.stb,
      wb_eic_we_i    => wb_gtp_eic_in.we,
      wb_eic_ack_o   => wb_gtp_eic_out.ack,
      wb_eic_stall_o => wb_gtp_eic_out.stall,
      wb_eic_int_o   => open,--serdes_eic_irq,

      wb_ddr_adr_o   => wb_gtp_ddr_out.adr,
      wb_ddr_dat_o   => wb_gtp_ddr_out.dat,
      wb_ddr_sel_o   => wb_gtp_ddr_out.sel,
      wb_ddr_stb_o   => wb_gtp_ddr_out.stb,
      wb_ddr_we_o    => wb_gtp_ddr_out.we,
      wb_ddr_cyc_o   => wb_gtp_ddr_out.cyc,
      wb_ddr_ack_i   => wb_gtp_ddr_in.ack,
      wb_ddr_stall_i => wb_gtp_ddr_in.stall,

      clk_wb_i           => sys_clk,
      clk_gtp_refclk_i   => gtp_clk,
      clk_gtp_userclk_i  => gtp_userclk,
      clk_gtp_userclk2_i => gtp_userclk2,

      rst_n_i => rst_n,

      sfp_tx_disable_o => SFP_TX_DISABLE,
      sfp_los_i        => SFP_LOS,
      sfp_prsnt_n_i    => SFP_MOD_DEF0,
      sfp_rx_p_i       => SFPRX_123_P,
      sfp_rx_n_i       => SFPRX_123_N,
      sfp_tx_p_o       => SFPTX_123_P,
      sfp_tx_n_o       => SFPTX_123_N,

      led_red_o => led_red_o,
      led_grn_o => led_green_o,

      irq_o => open, --serdes_irq_p,

      dio_clk_i     => '0',
      dio_i         => (others => '0'),
      dio_o         => open,
      dio_oe_n_o    => open,
      dio_term_en_o => open,
      dio_led_top_o => open,
      dio_led_bot_o => open,
      dio_onewire_b => open,
      dio_prsnt_n_i => '0'
      );

  -- Unused wishbone signals
  wb_gtp_csr_out.err   <= '0';
  wb_gtp_csr_out.rty   <= '0';
  wb_gtp_csr_out.int   <= '0';

  wb_gtp_eic_out.err   <= '0';
  wb_gtp_eic_out.rty   <= '0';

  ------------------------------------------------------------------------------                      
                                                                                               
end rtl;
