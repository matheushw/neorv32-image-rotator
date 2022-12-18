library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;


entity testbanch is
end testbanch;

architecture sim of testbanch is

  type header_type  is array (0 to 53) of character;

  type pixel_type is record
    red : std_logic_vector(7 downto 0);
    green : std_logic_vector(7 downto 0);
    blue : std_logic_vector(7 downto 0);
  end record;

  type row_type is array (integer range <>) of pixel_type;
  type row_pointer is access row_type;
  type image_type is array (integer range <>) of row_pointer;
  type image_pointer is access image_type;
  

  signal clk, start : std_logic;
  signal Angle : signed(15 downto 0);
  signal X : signed(15 downto 0);
  signal Y : signed(15 downto 0);
  signal XOut : unsigned(31 downto 0);
  signal YOut : unsigned(31 downto 0);
  signal calculed : boolean;

begin

  DUT :entity work.maxThroughput(rtl)
  port map (
    clk => clk,
    start => start,
    Angle => Angle,
    X => X,
    Y => Y,
    XOut => XOut,
    YOut => YOut,
	 calculed => calculed
  );

  process
    type char_file is file of character;
    file bmp_file : char_file open read_mode is "/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/a.bmp";
    file out_file : char_file open write_mode is "/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/out.bmp";
    variable header : header_type;
    variable image_width : integer;
    variable image_height : integer;
    variable row : row_pointer;
    variable image : image_pointer;
    variable padding : integer;
    variable new_padding : integer;
    variable char : character;
    variable r_img : character;
    variable g_img : character;
    variable b_img : character;
    variable new_image_size : integer := 1000; 
  begin
	for i in header_type'range loop
     read(bmp_file, header(i));
	  wait for 10 ns;
   end loop;

	report "indice0: " & header(0) &
     ", indice1: " & header(1);
	  
  assert header(0) = 'B' and header(1) = 'M'
    report "First two bytes are not ""BM"". This is not a BMP file"
    severity failure;

  assert character'pos(header(10)) = 54 and
    character'pos(header(11)) = 0 and
    character'pos(header(12)) = 0 and
    character'pos(header(13)) = 0
    report "Pixel array offset in header is not 54 bytes"
    severity failure;

  assert character'pos(header(14)) = 40 and
    character'pos(header(15)) = 0 and
    character'pos(header(16)) = 0 and
    character'pos(header(17)) = 0
    report "DIB headers size is not 40 bytes,"
    severity failure;

  assert character'pos(header(26)) = 1 and
    character'pos(header(27)) = 0
    report "Color planes is not 1" severity failure;

  assert character'pos(header(28)) = 24 and
    character'pos(header(29)) = 0
    report "Bits per pixel is not 24" severity failure;
 
	-- report "characterpos(header(18)): " & to_string(character'pos(header(18)));
  -- report "characterpos(header(19)): " & to_string(character'pos(header(19)));
  -- report "characterpos(header(20)): " & to_string(character'pos(header(20)));
  -- report "characterpos(header(21)): " & to_string(character'pos(header(21)));
	-- report "header(18): " & header(18);

  -- report "characterpos(header(22)): " & to_string(character'pos(header(22)));
  -- report "characterpos(header(23)): " & to_string(character'pos(header(23)));
  -- report "characterpos(header(24)): " & to_string(character'pos(header(24)));
  -- report "characterpos(header(25)): " & to_string(character'pos(header(25)));


  -- report "characterpos(header(39)): " & to_string(character'pos(header(39)));
  -- report "characterpos(header(40)): " & to_string(character'pos(header(40)));
  -- report "characterpos(header(41)): " & to_string(character'pos(header(41)));
  -- report "characterpos(header(42)): " & to_string(character'pos(header(42)));

  -- report "characterpos(header(43)): " & to_string(character'pos(header(43)));
  -- report "characterpos(header(44)): " & to_string(character'pos(header(44)));
  -- report "characterpos(header(45)): " & to_string(character'pos(header(45)));
  -- report "characterpos(header(46)): " & to_string(character'pos(header(46)));
	  
  image_width := character'pos(header(18)) +
    character'pos(header(19)) * 2**8 +
    character'pos(header(20)) * 2**16 +
    character'pos(header(21)) * 2**24;

  image_height := character'pos(header(22)) +
    character'pos(header(23)) * 2**8 +
    character'pos(header(24)) * 2**16 +
    character'pos(header(25)) * 2**24;

	report "image_width: " & integer'image(image_width) &
     ", image_height: " & integer'image(image_height);
	  
  -- Number of bytes needed to pad each row to 32 bits
  padding := (4 - image_width*3 mod 4) mod 4;

  -- Create a new image type in dynamic memory
  image := new image_type(0 to new_image_size - 1);

	for row_i in 0 to new_image_size - 1 loop
    row := new row_type(0 to new_image_size - 1);
    for col_i in 0 to new_image_size - 1 loop
      row(col_i).red := "11111111";
      row(col_i).green := "11111111";
      row(col_i).blue := "11111111";
    end loop;
	  image(row_i) := row;
	end loop;
	
	Angle <= "0000000000101101";
	clk <= '1';
	wait for 10 ns;
	
  for row_i in 0 to image_height - 1 loop
    for col_i in 0 to image_width - 1 loop
      -- Read blue pixel
      read(bmp_file, b_img);
      -- Read green pixel
      read(bmp_file, g_img);
      -- Read red pixel
      read(bmp_file, r_img);
		 
      X <= to_signed(col_i, X'length);
      Y <= to_signed(row_i, Y'length);

      if(clk = '1') then
        clk <= '0';
      else
        clk <= '1';
      end if;
      wait for 10 ns;

      row := image(to_integer(YOut));
      row(to_integer(XOut)).red := std_logic_vector(to_unsigned(character'pos(r_img), 8));
      row(to_integer(XOut)).green := std_logic_vector(to_unsigned(character'pos(g_img), 8));
      row(to_integer(XOut)).blue := std_logic_vector(to_unsigned(character'pos(b_img), 8));

      -- row := image(row_i);
      -- row(col_i).red := std_logic_vector(to_unsigned(character'pos(r_img), 8));
      -- row(col_i).green := std_logic_vector(to_unsigned(character'pos(g_img), 8));
      -- row(col_i).blue := std_logic_vector(to_unsigned(character'pos(b_img), 8));

      end loop;

     -- Read and discard padding
     for i in 1 to padding loop
       read(bmp_file, char);
     end loop;
  end loop;

  -- Number of bytes needed to pad each row to 32 bits
  new_padding := (4 - new_image_size*3 mod 4) mod 4;


  header(18) := character'val(232);
  header(19) := character'val(3);
  header(22) := character'val(232);
  header(23) := character'val(3);

  -- Write header to output file
  for i in header_type'range loop
    write(out_file, header(i));
  end loop;

  for row_i in 0 to new_image_size - 1 loop
    row := image(row_i);

    for col_i in 0 to new_image_size - 1 loop
      write(out_file, character'val(to_integer(unsigned(row(col_i).blue))));
      write(out_file, character'val(to_integer(unsigned(row(col_i).green))));
      write(out_file, character'val(to_integer(unsigned(row(col_i).red))));
    end loop;

    deallocate(row);

    -- Write padding
    for i in 1 to padding loop
      write(out_file, character'val(0));
    end loop;

  end loop;

  deallocate(image);

  file_close(bmp_file);
  file_close(out_file);

  report "Simulation done. Check ""out.bmp"" image.";
  finish;
  end process;

end architecture;