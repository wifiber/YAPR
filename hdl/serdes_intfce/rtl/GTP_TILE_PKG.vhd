------------------------------------------
------------------------------------------
-- Date        : Fri May 23 11:13:17 2014
--
-- Author      : Tom Levens <tom.levens@cern.ch>
--
-- Company     : CERN, BE-RF-FB
--
-- Description : Functions for GTP_TILE genericisation
--
------------------------------------------
------------------------------------------

package GTP_TILE_PKG  is

    -- ENUMERATIO TYPE
    type GTP_RATE_TYPE is (
        GBPS_1_0,
        GBPS_2_0,
        GBPS_2_5
    );

    -- FUNCTIONS FOR SPARTAN6 (GTP_TILE_S6)
    function F_S6_PLL_TRXDIVSEL_OUT (R: GTP_RATE_TYPE) return integer;
    function F_S6_TX_TDCC_CFG       (R: GTP_RATE_TYPE) return bit_vector;
    function F_S6_PMA_RX_CFG        (R: GTP_RATE_TYPE) return bit_vector;
    function F_S6_PLL_DIVSEL_FB     (R: GTP_RATE_TYPE) return integer;
    function F_S6_PLL_DIVSEL_REF    (R: GTP_RATE_TYPE) return integer;

    -- FUNCTIONS FOR VIRTEX5 (GTP_TILE)
    function F_V5_SIM_PLL_PERDIV2   (R: GTP_RATE_TYPE) return bit_vector;
    function F_V5_PLL_TRXDIVSEL_OUT (R: GTP_RATE_TYPE) return integer;
    function F_V5_PLL_DIVSEL_FB     (R: GTP_RATE_TYPE) return integer;
    function F_V5_PLL_DIVSEL_REF    (R: GTP_RATE_TYPE) return integer;

    -- FUNCTIONS FOR ARTIX7 (GTP_TILE_A7)
    function F_A7_PLL_FBDIV_IN      (R: GTP_RATE_TYPE) return integer;
    function F_A7_RXCDR_CFG         (R: GTP_RATE_TYPE) return bit_vector;
    function F_A7_TRXOUT_DIV        (R: GTP_RATE_TYPE) return integer;

end;

------------------------------------------
------------------------------------------
-- Date        : Fri May 23 11:18:32 2014
--
-- Author      : Tom Levens <tom.levens@cern.ch>
--
-- Company     : CERN, BE-RF-FB
--
------------------------------------------
------------------------------------------

package body  GTP_TILE_PKG  is

    ------------------------------------------
    -- FUNCTIONS FOR SPARTAN6 (GTP_TILE_S6)
    ------------------------------------------
    function F_S6_PLL_TRXDIVSEL_OUT (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 1; -- 2.5 GBPS
            when GBPS_2_0 => return 1; -- 2.0 GBPS
            when others   => return 2; -- 1.0 GBPS
        end case;
    end F_S6_PLL_TRXDIVSEL_OUT;

    function F_S6_TX_TDCC_CFG (R: GTP_RATE_TYPE) return bit_vector is
    begin
        case R is
            when GBPS_2_5 => return "11"; -- 2.5 GBPS
            when GBPS_2_0 => return "11"; -- 2.0 GBPS
            when others   => return "00"; -- 1.0 GBPS
        end case;
    end F_S6_TX_TDCC_CFG;

    function F_S6_PMA_RX_CFG (R: GTP_RATE_TYPE) return bit_vector is
    begin
        case R is
            when GBPS_2_5 => return X"05ce089"; -- 2.5 GBPS
            when GBPS_2_0 => return X"05ce089"; -- 2.0 GBPS
            when others   => return X"05ce049"; -- 1.0 GBPS
        end case;
    end F_S6_PMA_RX_CFG;

    function F_S6_PLL_DIVSEL_FB (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 5; -- 2.5 GBPS
            when GBPS_2_0 => return 2; -- 2.0 GBPS
            when others   => return 2; -- 1.0 GBPS
        end case;
    end F_S6_PLL_DIVSEL_FB;

    function F_S6_PLL_DIVSEL_REF (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 2; -- 2.5 GBPS
            when GBPS_2_0 => return 1; -- 2.0 GBPS
            when others   => return 1; -- 1.0 GBPS
        end case;
    end F_S6_PLL_DIVSEL_REF;
    ------------------------------------------
    -- FUNCTIONS FOR SPARTAN6 (GTP_TILE_S6)
    ------------------------------------------

    ------------------------------------------
    -- FUNCTIONS FOR VIRTEX5 (GTP_TILE)
    ------------------------------------------
    function F_V5_SIM_PLL_PERDIV2 (R: GTP_RATE_TYPE) return bit_vector is
    begin
        case R is
            when GBPS_2_5 => return X"190"; -- 2.5 GBPS
            when GBPS_2_0 => return X"1F4"; -- 2.0 GBPS
            when others   => return X"1F4"; -- 1.0 GBPS
        end case;
    end F_V5_SIM_PLL_PERDIV2;

    function F_V5_PLL_TRXDIVSEL_OUT (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 1; -- 2.5 GBPS
            when GBPS_2_0 => return 1; -- 2.0 GBPS
            when others   => return 2; -- 1.0 GBPS
        end case;
    end F_V5_PLL_TRXDIVSEL_OUT;

    function F_V5_PLL_DIVSEL_FB (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 5; -- 2.5 GBPS
            when GBPS_2_0 => return 2; -- 2.0 GBPS
            when others   => return 2; -- 1.0 GBPS
        end case;
    end F_V5_PLL_DIVSEL_FB;

    function F_V5_PLL_DIVSEL_REF (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 2; -- 2.5 GBPS
            when GBPS_2_0 => return 1; -- 2.0 GBPS
            when others   => return 1; -- 1.0 GBPS
        end case;
    end F_V5_PLL_DIVSEL_REF;
    ------------------------------------------
    -- END FUNCTIONS FOR VIRTEX5 (GTP_TILE)
    ------------------------------------------


    ------------------------------------------
    -- FUNCTIONS FOR ARTIX7 (GTP_TILE_A7)
    ------------------------------------------
    function F_A7_RXCDR_CFG (R: GTP_RATE_TYPE) return bit_vector is
    begin
        case R is
            when GBPS_2_5 => return X"0000107FE206001041010"; -- 2.0 GBPS
            when GBPS_2_0 => return X"0000107FE206001041010"; -- 2.0 GBPS
            when others   => return X"0000107FE106001041010"; -- 1.0 GBPS
        end case;
    end F_A7_RXCDR_CFG;

    function F_A7_TRXOUT_DIV (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 2; -- 2.5 GBPS
            when GBPS_2_0 => return 2; -- 2.0 GBPS
            when others   => return 4; -- 1.0 GBPS
        end case;
    end F_A7_TRXOUT_DIV;

    function F_A7_PLL_FBDIV_IN (R: GTP_RATE_TYPE) return integer is
    begin
        case R is
            when GBPS_2_5 => return 5; -- 2.5 GBPS
            when GBPS_2_0 => return 4; -- 2.0 GBPS
            when others   => return 4; -- 1.0 GBPS
        end case;
    end F_A7_PLL_FBDIV_IN;
    ------------------------------------------
    -- END FUNCTIONS FOR ARTIX7 (GTP_TILE_A7)
    ------------------------------------------

end;

