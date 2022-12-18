-- #################################################################################################
-- # << NEORV32 - Custom Functions Subsystem (CFS) >>                                              #
-- # ********************************************************************************************* #
-- # Intended for tightly-coupled, application-specific custom co-processors. This module provides #
-- # 32x 32-bit memory-mapped interface registers, one interrupt request signal and custom IO      #
-- # conduits for processor-external or chip-external interface.                                   #
-- #                                                                                               #
-- # NOTE: This is just an example/illustration template. Modify/replace this file to implement    #
-- #       your own custom design logic.                                                           #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2022, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_cfs is
  generic (
    CFS_CONFIG   : std_ulogic_vector(31 downto 0); -- custom CFS configuration generic
    CFS_IN_SIZE  : positive; -- size of CFS input conduit in bits
    CFS_OUT_SIZE : positive  -- size of CFS output conduit in bits
  );
  port (
    -- host access --
    clk_i       : in  std_ulogic; -- global clock line
    rstn_i      : in  std_ulogic; -- global reset line, low-active, use as async
    priv_i      : in  std_ulogic; -- current CPU privilege mode
    addr_i      : in  std_ulogic_vector(31 downto 0); -- address
    rden_i      : in  std_ulogic; -- read enable
    wren_i      : in  std_ulogic; -- word write enable
    data_i      : in  std_ulogic_vector(31 downto 0); -- data in
    data_o      : out std_ulogic_vector(31 downto 0); -- data out
    ack_o       : out std_ulogic; -- transfer acknowledge
    err_o       : out std_ulogic; -- transfer error
    -- clock generator --
    clkgen_en_o : out std_ulogic; -- enable clock generator
    clkgen_i    : in  std_ulogic_vector(07 downto 0); -- "clock" inputs
    -- interrupt --
    irq_o       : out std_ulogic; -- interrupt request
    -- custom io (conduits) --
    cfs_in_i    : in  std_ulogic_vector(CFS_IN_SIZE-1 downto 0);  -- custom inputs
    cfs_out_o   : out std_ulogic_vector(CFS_OUT_SIZE-1 downto 0)  -- custom outputs
  );
end neorv32_cfs;

architecture neorv32_cfs_rtl of neorv32_cfs is

  -- IO space: module base address --
  -- WARNING: Do not modify the CFS base address or the CFS' occupied address
  -- space as this might cause access collisions with other processor modules.
  constant hi_abb_c : natural := index_size_f(io_size_c)-1; -- high address boundary bit
  constant lo_abb_c : natural := index_size_f(cfs_size_c); -- low address boundary bit

  -- access control --
  signal acc_en : std_ulogic; -- module access enable
  signal addr   : std_ulogic_vector(31 downto 0); -- access address
  signal wren   : std_ulogic; -- word write enable
  signal rden   : std_ulogic; -- read enable

  -- default CFS interface registers --
  type cfs_regs_t is array (0 to 11) of std_ulogic_vector(31 downto 0); -- just implement 4 registers for this example
  signal cfs_reg_wr : cfs_regs_t; -- interface registers for WRITE accesses
  signal cfs_reg_rd : cfs_regs_t; -- interface registers for READ accesses

  type header_type is array (0 to 53) of character;
  type pixel_type is record
    red : std_logic_vector(7 downto 0);
    green : std_logic_vector(7 downto 0);
    blue : std_logic_vector(7 downto 0);
  end record;

  type row_type is array (integer range <>) of pixel_type;
  type row_pointer is access row_type;
  type image_type is array (integer range <>) of row_pointer;
  type image_pointer is access image_type;
  

  signal start : std_logic;
  signal Angle : signed(15 downto 0);
  signal X : signed(15 downto 0);
  signal Y : signed(15 downto 0);
  signal XOut : unsigned(31 downto 0);
  signal YOut : unsigned(31 downto 0);
  signal calculed : boolean;

  signal RadOut : unsigned(31 downto 0);
  signal AngleOut : unsigned(31 downto 0);
  signal TestOut : unsigned(31 downto 0);
  signal COS_OUT : unsigned(31 downto 0);
  signal SIN_OUT : unsigned(31 downto 0);

  component maxThroughput is
    port (
      clk, start : in std_logic;
      Angle : in signed(15 downto 0);
      X : in signed(15 downto 0);
      Y : in signed(15 downto 0);
  
      XOut : out unsigned(31 downto 0);
      YOut : out unsigned(31 downto 0);
      calculed : out boolean;
      RadOut : out unsigned(31 downto 0);
      AngleOut : out unsigned(31 downto 0);
      TestOut : out unsigned(31 downto 0);
      COS_OUT : out unsigned(31 downto 0);
      SIN_OUT : out unsigned(31 downto 0)
    );
  end component maxThroughput;
  
begin

  -- Access Control -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- This logic is required to handle the CPU accesses - DO NOT MODIFY!
  acc_en <= '1' when (addr_i(hi_abb_c downto lo_abb_c) = cfs_base_c(hi_abb_c downto lo_abb_c)) else '0';
  addr   <= cfs_base_c(31 downto lo_abb_c) & addr_i(lo_abb_c-1 downto 2) & "00"; -- word aligned
  wren   <= acc_en and wren_i; -- only full-word write accesses are supported
  rden   <= acc_en and rden_i; -- read accesses always return a full 32-bit word

  cfs_out_o <= (others => '0'); -- not used for this minimal example
  clkgen_en_o <= '0'; -- not used for this minimal example
  irq_o <= '0'; -- not used for this minimal example.
  err_o <= '0'; -- Tie to zero if not explicitly used.

  maxThroughputInstance: maxThroughput
  port map (
    clk => clk_i,
    start => start,
    Angle => Angle,
    X => X,
    Y => Y,
    XOut => XOut,
    YOut => YOut,
    calculed => calculed,
    RadOut => RadOut,
    AngleOut => AngleOut,
    TestOut => TestOut,
    COS_OUT => COS_OUT,
    SIN_OUT => SIN_OUT
  );

  host_access: process(rstn_i, clk_i)
  begin
    if (rstn_i = '0') then
      Angle <= (others => '0');
      X <= (others => '0');
      -- cfs_reg_wr(2) <= (others => '0');
      Y <= (others => '0');
      start <= '0';
      -- cfs_reg_wr(5) <= (others => '0');
      -- cfs_reg_wr(6) <= (others => '0');
      --
      ack_o  <= '-'; -- no actual reset required
      data_o <= (others => '-'); -- no actual reset required
    elsif rising_edge(clk_i) then -- synchronous interface for read and write accesses
      -- transfer/access acknowledge --
      -- default: required for the CPU to check the CFS is answering a bus read OR write request;
      -- all read and write accesses (to any cfs_reg, even if there is no according physical register implemented) will succeed.
      ack_o <= rden or wren;

      -- write access --
      if (wren = '1') then -- full-word write access, high for one cycle if there is an actual write access
        if (addr = cfs_reg0_addr_c) then -- make sure to use the internal "addr" signal for the read/write interface
          start <= data_i(0);
        end if;
        if (addr = cfs_reg1_addr_c) then
          Angle <= signed(data_i(15 downto 0));
        end if;
        if (addr = cfs_reg3_addr_c) then
          X <= signed(data_i(15 downto 0));
        end if;
        if (addr = cfs_reg4_addr_c) then
          Y <= signed(data_i(15 downto 0));
        end if;
      end if;

      -- read access --
      data_o <= (others => '0'); -- the output HAS TO BE ZERO if there is no actual read access
      if (rden = '1') then -- the read access is always 32-bit wide, high for one cycle if there is an actual read access
        case addr is -- make sure to use the internal 'addr' signal for the read/write interface
          when cfs_reg2_addr_c => data_o <= std_ulogic_vector(resize("1", data_o'length));
          when cfs_reg5_addr_c => data_o <= std_ulogic_vector(Xout);
          when cfs_reg6_addr_c => data_o <= std_ulogic_vector(Yout);
          when cfs_reg7_addr_c => data_o <= std_ulogic_vector(RadOut);
          when cfs_reg8_addr_c => data_o <= std_ulogic_vector(AngleOut);
          when cfs_reg9_addr_c => data_o <= std_ulogic_vector(TestOut);
          when cfs_reg10_addr_c => data_o <= std_ulogic_vector(COS_OUT);
          when cfs_reg11_addr_c => data_o <= std_ulogic_vector(SIN_OUT);
          when others          => data_o <= (others => '0'); -- the remaining registers are not implemented and will read as zero
        end case;
      end if;
    end if;
  end process host_access;


  -- CFS Function Core ----------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  -- cfs_reg_rd(2) <= bin_to_gray_f(cfs_reg_wr(0));
  -- cfs_reg_rd(5) <= gray_to_bin_f(cfs_reg_wr(1));
  -- cfs_reg_rd(6) <= bit_rev_f(cfs_reg_wr(2));


end neorv32_cfs_rtl;
