library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maxThroughput is
  port (
    clk, start : in std_logic;
    Angle : in signed(15 downto 0);
    X : in signed(15 downto 0);
    Y : in signed(15 downto 0);

    XOut : out unsigned(31 downto 0);
    YOut : out unsigned(31 downto 0);
    RadOut: out unsigned(31 downto 0);
    AngleOut: out unsigned(31 downto 0);
    TestOut: out unsigned(31 downto 0);
    COS_OUT: out unsigned(31 downto 0);
    SIN_OUT: out unsigned(31 downto 0)
  );
end maxThroughput; 

architecture rtl of maxThroughput is
begin
  process(clk)
  variable real_angle_inter : signed(31 downto 0);
  variable real_angle : signed(15 downto 0);

  variable COS_VAR : signed(31 downto 0);
  
  variable COS_VAR2 : signed(31 downto 0);
  variable COS_VAR_INTER : signed(63 downto 0);
  
  variable COS_VAR3 : signed(63 downto 0);
  variable COS_VAR3_INTER1 : signed(63 downto 0);
  variable COS_VAR3_INTER2 : signed(31 downto 0);

  variable SIN_VAR : signed(31 downto 0);
  variable SIN_VAR_INTER : signed(47 downto 0);

  variable SIN_VAR2 : signed(31 downto 0);
  variable SIN_VAR2_INTER1 : signed(47 downto 0);
  variable SIN_VAR2_INTER2 : signed(31 downto 0);
  variable SIN_VAR2_INTER3 : signed(63 downto 0);

  variable SIN_VAR3 : signed(63 downto 0);
  variable SIN_VAR3_INTER1 : signed(47 downto 0);
  variable SIN_VAR3_INTER2 : signed(31 downto 0);
  variable SIN_VAR3_INTER3 : signed(63 downto 0);
  variable SIN_VAR3_INTER4 : signed(31 downto 0);

  variable X_TRAN : signed(15 downto 0);  				-- X transformado 
  variable Y_TRAN : signed(15 downto 0);
  
  variable X_INTER : signed (47 downto 0);			-- X intermediario
  variable Y_INTER : signed (47 downto 0);

  variable X_INTER_2 : signed (47 downto 0);			-- X intermediario
  variable Y_INTER_2 : signed (47 downto 0);
  
  begin
    if (rising_edge(clk)) then
        real_angle_inter := ((Angle * 31415)/180)/10;
        real_angle := real_angle_inter(15 downto 0);
        RadOut <= unsigned(real_angle_inter);
        AngleOut <= unsigned(resize(Angle, AngleOut'length));

        COS_VAR := (1000 - (( real_angle * real_angle/1000 ) / 2));

        COS_VAR_INTER := ((COS_VAR + ( ( real_angle * real_angle/1000 * real_angle/1000 * real_angle/1000 ) / 24 )));
        COS_VAR2 := COS_VAR_INTER(31 downto 0);

        COS_VAR3_INTER1 := (real_angle/1000 * real_angle/1000 * real_angle/1000 * real_angle/1000); 
        COS_VAR3_INTER2 := COS_VAR3_INTER1(31 downto 0);
        COS_VAR3 := (COS_VAR2 - ( ( real_angle * COS_VAR3_INTER2 * real_angle/1000 ) / 720 ));

        SIN_VAR_INTER := ( real_angle - (real_angle *  real_angle/1000 *  real_angle/1000 ) / 6 );
        SIN_VAR := SIN_VAR_INTER(31 downto 0);

        SIN_VAR2_INTER1 := real_angle *  real_angle/1000 *  real_angle/1000;
        SIN_VAR2_INTER2 := SIN_VAR2_INTER1(31 downto 0);
        SIN_VAR2_INTER3 := SIN_VAR + ((SIN_VAR2_INTER2 * real_angle/1000 * real_angle/1000 ) / 120);
        SIN_VAR2 := SIN_VAR2_INTER3(31 downto 0);

        SIN_VAR3_INTER1 := real_angle *  real_angle/1000 *  real_angle/1000;
        SIN_VAR3_INTER2 := SIN_VAR3_INTER1(31 downto 0);
        SIN_VAR3_INTER3 := SIN_VAR3_INTER2 * real_angle/1000 * real_angle/1000;
        SIN_VAR3_INTER4 := SIN_VAR3_INTER3(31 downto 0);
        SIN_VAR3 := SIN_VAR2 - ( SIN_VAR3_INTER4 * real_angle/1000 * real_angle/1000 ) / 5040;

        COS_OUT <= unsigned(abs(COS_VAR3(31 downto 0)));
        SIN_OUT <= unsigned(abs(SIN_VAR3(31 downto 0)));
        
        X_TRAN := X - 50;
        Y_TRAN := Y - 50;

        X_INTER := ((X_TRAN * COS_VAR3(31 downto 0)) + (Y_TRAN * SIN_VAR3(31 downto 0)))/1000;
        Y_INTER := ((Y_TRAN * COS_VAR3(31 downto 0)) - (X_TRAN * SIN_VAR3(31 downto 0)))/1000;

        X_INTER_2 := X_INTER + 50 + 50;
        Y_INTER_2 := Y_INTER + 50 + 50;

        Xout <= unsigned(X_INTER_2(31 downto 0));
        Yout <= unsigned(Y_INTER_2(31 downto 0));
        TestOut <= unsigned(resize(X_TRAN, TestOut'length));
    end if;
  end process;
end architecture;
