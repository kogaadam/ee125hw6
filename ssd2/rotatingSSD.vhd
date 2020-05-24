library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.subprograms_pkg.all;

entity rotatingSSD is
	generic (
		F_CLK_KHZ: natural := 50_000);
	port (
		clk, rst: in std_logic;
		start, direction, speed: in std_logic;
		ssd: out std_logic_vector(6 downto 0));
end entity;

architecture ssdRotator of rotatingSSD is

	type state_type is (stopped,
							  stateA, stateAB, stateB, stateBC,
							  stateC, stateCD, stateD, stateDE,
							  stateE, stateEF, stateF, stateFA);
	signal pr_state, nx_state: state_type;
	
	constant T2_MSEC: natural := 35;
	constant T2_WAIT: natural := T2_MSEC * F_CLK_KHZ;
	constant T1_MSEC_A: natural := 200;
	constant T1_MSEC_B: natural := 140;
	constant T1_MSEC_C: natural := 100;
	constant T1_MSEC_D: natural := 70;
	constant T1_WAIT_A: natural := T1_MSEC_A * F_CLK_KHZ;
	constant T1_WAIT_B: natural := T1_MSEC_B * F_CLK_KHZ;
	constant T1_WAIT_C: natural := T1_MSEC_C * F_CLK_KHZ;
	constant T1_WAIT_D: natural := T1_MSEC_D * F_CLK_KHZ;
	
	signal t, tmax_single, tmax: natural range 0 to T1_WAIT_A;
	signal direction_ind, start_ind, speed_ind: std_logic;
	
begin

	
	-- Direction change
	process(direction)
	begin
		if rising_edge(direction) then
			direction_ind <= not direction_ind;
		end if;
	end process;
	
	-- Start/stop change
	process(start, rst)
	begin
		if not rst then
			start_ind <= '0';
		elsif rising_edge(start) then
			start_ind <= not start_ind;
		end if;
	end process;
	
	-- Speed change
	process(speed)
	begin
		if rising_edge(speed) then
			case tmax_single is
				when T1_WAIT_A =>
					tmax_single <= T1_WAIT_B;
				when T1_WAIT_B =>
					tmax_single <= T1_WAIT_C;
				when T1_WAIT_C =>
					tmax_single <= T1_WAIT_D;
				when T1_WAIT_D =>
					tmax_single <= T1_WAIT_A;
				when others =>
					tmax_single <= T1_WAIT_A;
			end case;		
		end if;
	end process;

	-- Timer
	process(all)
	begin
		case pr_state is
			when stateA | stateB | stateC | stateD | stateE | stateF =>
				tmax <= tmax_single;
			when stopped =>
				tmax <= 0;
			when others =>
				tmax <= T2_WAIT;
		end case;
		
		if rising_edge(clk) then
			if pr_state /= nx_state then
				t <= 0;
			elsif t /= tmax then
				t <= t + 1;
			end if;
		end if;
	end process;
		
	-- Register for state
	process(clk, rst)
	begin
		if not rst then
			pr_state <= stopped;
		elsif rising_edge(clk) then
			pr_state <= nx_state;
		end if;
	end process;
	
	-- Logic for state
	process(all)
	begin
		case pr_state is
			when stopped =>
				if start_ind then
					nx_state <= stateA;
				else
					nx_state <= stopped;
				end if;
				
			when stateA =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateAB;
					else
						nx_state <= stateFA;
					end if;
				else
					nx_state <= stateA;
				end if;
				
			when stateAB =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateB;
					else
						nx_state <= stateA;
					end if;
				else
					nx_state <= stateAB;
				end if;
				
			when stateB =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateBC;
					else
						nx_state <= stateAB;
					end if;
				else
					nx_state <= stateB;
				end if;
				
			when stateBC =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateC;
					else
						nx_state <= stateB;
					end if;
				else
					nx_state <= stateBC;
				end if;
				
			when stateC =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateCD;
					else
						nx_state <= stateBC;
					end if;
				else
					nx_state <= stateC;
				end if;
				
			when stateCD =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateD;
					else
						nx_state <= stateC;
					end if;
				else
					nx_state <= stateCD;
				end if;
				
			when stateD =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateDE;
					else
						nx_state <= stateCD;
					end if;
				else
					nx_state <= stateD;
				end if;
				
			when stateDE =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateE;
					else
						nx_state <= stateD;
					end if;
				else
					nx_state <= stateDE;
				end if;
				
			when stateE =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateEF;
					else
						nx_state <= stateDE;
					end if;
				else
					nx_state <= stateE;
				end if;
				
			when stateEF =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateF;
					else
						nx_state <= stateE;
					end if;
				else
					nx_state <= stateEF;
				end if;
				
			when stateF =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateFA;
					else
						nx_state <= stateEF;
					end if;
				else
					nx_state <= stateF;
				end if;
				
			when stateFA =>
				if not start_ind then
					nx_state <= stopped;
				elsif t = tmax then
					if direction_ind then
						nx_state <= stateA;
					else
						nx_state <= stateF;
					end if;
				else
					nx_state <= stateFA;
				end if;

		end case;
	end process;

	-- Logic for outputs
	process(all)
	begin
		case pr_state is
			when stateA =>
				ssd <= "1111110";
			when stateAB =>
				ssd <= "1111100";
			when stateB =>
				ssd <= "1111101";
			when stateBC =>
				ssd <= "1111001";
			when stateC =>
				ssd <= "1111011";
			when stateCD =>
				ssd <= "1110011";
			when stateD =>
				ssd <= "1110111";
			when stateDE =>
				ssd <= "1100111";
			when stateE =>
				ssd <= "1101111";
			when stateEF =>
				ssd <= "1001111";
			when stateF =>
				ssd <= "1011111";
			when stateFA =>
				ssd <= "1011110";
			when others =>
				null;
		end case;
	end process;
	
		
end architecture;