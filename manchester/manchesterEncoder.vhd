library ieee;
use ieee.std_logic_1164.all;

entity manchesterEncoder is
	port (
		clk, rst: in std_logic;
		ena, din: in std_logic;
		dout: out std_logic);
end entity;

architecture mealyFSM of manchesterEncoder is

	type state_type is (do_nothing, high_to_low, low_to_high, go_low_or_high);
	signal state: state_type;
	attribute syn_encoding: string;
	attribute syn_encoding of state_type: type is "sequential";
	
begin

	process(clk, rst)
	begin
	
		if rst then
			state <= do_nothing;
		elsif rising_edge(clk) then
			case state is
				when do_nothing =>
					if ena and not din then
						state <= high_to_low;
						dout <= '1';
					elsif ena and din then
						state <= low_to_high;
						dout <= '0';
					else
						state <= do_nothing;
						dout <= '0';
					end if;
					
				when high_to_low =>
					state <= go_low_or_high;
					dout <= '0';
				
				when low_to_high =>
					state <= go_low_or_high;
					dout <= '1';
				
				when go_low_or_high =>
					if not ena then
						state <= do_nothing;
						dout <= '0';
					elsif not din then
						state <= high_to_low;
						dout <= '1';
					else
						state <= low_to_high;
						dout <= '0';
					end if;
				
			end case;
		end if;
	end process;

end architecture;