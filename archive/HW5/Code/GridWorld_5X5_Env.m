classdef GridWorld_5X5_Env < handle
	properties
		Pack_poses;
		Dest_poses;
		Action_length;
		Walls;
		gamma;
		
		where_pack;
		which_pack;
		which_dest;
		car_pos;
		pac_pos;
		des_pos;
		fig;
		ax;
		car_shape;
		pac_shape;
		des_shape;
		tit_objct;
	end
	
	
	methods
		% Constructor
		function obj = GridWorld_5X5_Env(Pack_poses, Dest_poses, Walls, gamma)
			obj.Pack_poses = Pack_poses;
			obj.Dest_poses = Dest_poses;
			obj.Walls = Walls;
			obj.gamma = gamma;
			
			%Initialization
			obj.Action_length = 6;
			obj.car_pos.x = 0;
			obj.car_pos.y = 0;
			obj.pac_pos.x = 0;
			obj.pac_pos.y = 0;
			obj.des_pos.x = 0;
			obj.des_pos.y = 0;
			obj.init();
			obj.restart();
		end
		
		
		% initialization 
		function init(obj)
			obj.fig = figure('Visible', 'off');
			obj.ax = axes('Parent', obj.fig);
			obj.ax.YDir = 'reverse';
			obj.ax.XTick = 0:5;
			obj.ax.YTick = 0:5;
			obj.ax.XLim = [-0.5, 5.5];
			obj.ax.YLim = [-0.5, 5.5];
			obj.ax.XAxisLocation = 'top';
			hold on;
			grid on;
			obj.draw_frame();
		end
		
		
		% restart function
		function restart(obj)
			if ~isvalid(obj.ax)
				obj.init();
			end
			obj.which_pack			= randi(size(obj.Pack_poses, 1));
			obj.which_dest			= randi(size(obj.Pack_poses, 1));
			obj.car_pos.x			= randi(5)-1;
			obj.car_pos.y			= randi(5)-1;
			obj.pac_pos.x			= obj.Pack_poses(obj.which_pack, 1);
			obj.pac_pos.y			= obj.Pack_poses(obj.which_pack, 2);
			obj.des_pos.x			= obj.Dest_poses(obj.which_dest, 1);
			obj.des_pos.y			= obj.Dest_poses(obj.which_dest, 2);
			obj.car_shape.Position	= [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.pac_shape.Position	= [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
			obj.des_shape.Position	= [0.5+obj.des_pos.x, 0.5+obj.des_pos.y, 0];
			if rand > 5/6
				obj.where_pack = 5;
				obj.pac_shape.Visible = 'off';
				obj.car_shape.Color	  = [0 1 0];
			else
				obj.where_pack = obj.which_pack;
				obj.pac_shape.Visible = 'on';
				obj.car_shape.Color	  = [0 0 0];
			end
		end
		
		
		% draw the frame
		function draw_frame(obj)
			%plotting the inner walls
			line(obj.ax, [1, 1], [3, 5], 'LineWidth', 5);
			line(obj.ax, [4, 5], [2, 2], 'LineWidth', 5);
			line(obj.ax, [3, 3], [4, 5], 'LineWidth', 5);
			% plotting the box
			line(obj.ax, [0, 0], [0, 5], 'LineWidth', 7.5, 'Marker', 'o', 'MarkerSize', 0.75);
			line(obj.ax, [0, 5], [0, 0], 'LineWidth', 7.5, 'Marker', 'o', 'MarkerSize', 0.75);
			line(obj.ax, [5, 5], [0, 5], 'LineWidth', 7.5, 'Marker', 'o', 'MarkerSize', 0.75);
			line(obj.ax, [0, 5], [5, 5], 'LineWidth', 7.5, 'Marker', 'o', 'MarkerSize', 0.75);
			% plotting the trees 
			for i=0.5:10.5
				tree_type = [55356, 57136] + [0 randi(5)];
				text(obj.ax, -0.25,      i/2,      char(tree_type), 'FontSize', 20, 'HorizontalAlignment', 'center');
				tree_type = [55356, 57136] + [0 randi(5)];
				text(obj.ax,  5.25,      i/2-0.5,  char(tree_type), 'FontSize', 20, 'HorizontalAlignment', 'center');
				tree_type = [55356, 57136] + [0 randi(5)];
				text(obj.ax,  i/2-0.5,  -0.25,     char(tree_type), 'FontSize', 20, 'HorizontalAlignment', 'center');
				tree_type = [55356, 57136] + [0 randi(5)];
				text(obj.ax,  i/2,       5.25,     char(tree_type), 'FontSize', 20, 'HorizontalAlignment', 'center');
			end
			% plotting the car 📫, 💌, ✉️, 📦, 📪, 🚘
			obj.car_shape = text(obj.ax, 0, 0, '🚘', 'FontSize', 30, 'HorizontalAlignment', 'center', 'Color', [0 0 0]);
			obj.pac_shape = text(obj.ax, 0, 0, '📦', 'FontSize', 30, 'HorizontalAlignment', 'center', 'Color', [0 0 0]);
			obj.des_shape = text(obj.ax, 0, 0, '📫', 'FontSize', 30, 'HorizontalAlignment', 'center', 'Color', [0 0 0]);
			obj.tit_objct = title(obj.ax, "#(0), @0, Reward = 0");
			obj.car_shape.Position = [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.pac_shape.Position = [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
			obj.des_shape.Position = [0.5+obj.des_pos.x, 0.5+obj.des_pos.y, 0];
			obj.pac_shape.Visible = 'on';
		end
		
		
		% Position to State function
		function state = P2S(obj)
			state = 0;
			state = state + obj.car_pos.y;
			state = state + (obj.car_pos.x * 5);
			state = state + ((obj.which_dest-1) * 25);
			state = state + ((obj.where_pack-1) * 100);
		end
		
		
		% Custom Position to State function
		function state = CP2S(~, wp, wd, x, y)
			state = 0;
			state = state + y;
			state = state + (x * 5);
			state = state + ((wd-1) * 25);
			state = state + ((wp-1) * 100);
		end
		
		
		% State to Position function
		function [wp, wd, x, y] = S2P(~, state)
			y  = mod(state, 5);
			x  = mod(floor(state/5), 5);
			wd = mod(floor(state/25), 4)+1;
			wp = mod(floor(state/100), 5)+1;
		end
		
		
		% Check illigal Move
		function illigal = Check_illigal(obj, nx, ny)
			illigal = false;
			for r = 1:size(obj.Walls)
				cp = [obj.car_pos.x, obj.car_pos.y, nx, ny];
				wp = obj.Walls(r,:);
				if sum(cp == wp) == 4
					illigal = true;
					break;
				end
			end
		end
		
		
		% Dynamics
		function [ns, nr, done] = Dynamics(obj, action)
			%	actions:
			%		1:	North
			%		2:	East
			%		3:	South
			%		4:	West
			%		5:	Pick
			%		6:	Drop
			wrong = false;
			done = false;
			nx = obj.car_pos.x;
			ny = obj.car_pos.y;
			switch action
				case 1
					[ny, wrong] = clip(obj.car_pos.y-1, 0, 4);
				case 2
					[nx, wrong] = clip(obj.car_pos.x+1, 0, 4);
				case 3
					[ny, wrong] = clip(obj.car_pos.y+1, 0, 4);
				case 4
					[nx, wrong] = clip(obj.car_pos.x-1, 0, 4);
				case 5
					if (obj.car_pos.x == obj.Pack_poses(obj.which_pack, 1)) && (obj.car_pos.y == obj.Pack_poses(obj.which_pack, 2)) && (obj.where_pack ~= 5)
						obj.where_pack = 5;
					else
						wrong = true;
					end
				case 6
					if (obj.car_pos.x == obj.Pack_poses(obj.which_dest, 1)) && (obj.car_pos.y == obj.Pack_poses(obj.which_dest, 2)) && (obj.where_pack == 5)
						done = true;
					else
						wrong = true;
					end
				otherwise
					error("Wrong Action");
			end
			
			illigal = obj.Check_illigal(nx, ny);
			nr = -1 + 21*done - 9*wrong - 9*illigal;
			if ~illigal 
				obj.car_pos.x = nx;
				obj.car_pos.y = ny;
			end
			ns = obj.P2S();
		end
		
		
		% generate an episode
		function [episode_states, episode_actions, episode_rewards, terminated] = generate_episode(obj, Net, Epsilon, max_length)
			ep_all_states	= zeros(1, max_length+1);
			ep_all_actions	= zeros(1, max_length+1);
			ep_all_rewards	= zeros(1, max_length+1);
			terminated		= false;
			next_state      = obj.P2S();
			action_len		= Net.get_action_len();
			
			for ep_cntr = 1:max_length
				this_state  = next_state;
				if rand <= Epsilon
					this_action = randi(action_len);
				else
					inp = zeros(Net.get_inp_len(), 1);
					inp(this_state+1,1) = 1;
					pred = Net.predict(inp);
					[~, this_action] = max(pred);
				end
					
				[next_state, this_reward, terminated] = obj.Dynamics(this_action);
				
				ep_all_states (ep_cntr) = this_state;
				ep_all_actions(ep_cntr) = this_action;
				ep_all_rewards(ep_cntr) = this_reward;
				
				if terminated == true
					break;
				end
			end
			ep_all_states(ep_cntr+1) = next_state;
			episode_states  = ep_all_states (1 : ep_cntr+1);
			episode_actions = ep_all_actions(1 : ep_cntr);
			episode_rewards = ep_all_rewards(1 : ep_cntr);
		end
		
		
		% simulate an episode
		function [Aeps, Aepa, Aepr] = simulate(obj, runs, Net, epsilon, max_length, sleep_time, start_point)
			obj.show();
			Aeps = cell(runs, 1);
			Aepa = cell(runs, 1);
			Aepr = cell(runs, 1);
			for run = 1:runs
				if isempty(start_point)
					obj.restart();
				else
					obj.define_start_point(start_point(1), start_point(2), start_point(3), start_point(4));
				end
				[eps, epa, epr, ~] = obj.generate_episode(Net, epsilon, max_length);
				Aeps(run) = {eps};
				Aepa(run) = {epa};
				Aepr(run) = {epr};
				rew = 0;
				obj.show();
				obj.tit_objct.String = "#(" + string(run) + "), @" + 0 + ", Reward = " + string(rew);
				pause(sleep_time);
				for i=1:length(epa)
					if ~isvalid(obj.ax)
						obj.init();
						obj.show();
					end
					[wp, ~, x, y] = obj.S2P(eps(i));
					obj.car_shape.Position = [0.5+x, 0.5+y, 0];
					obj.tit_objct.String = "#(" + string(run) + "), @" + string(i-1) + ", Reward = " + string(rew);
					rew = (obj.gamma * rew) + epr(i);
					if(wp == 5)
						obj.car_shape.Color   = [0 1 0];
						obj.pac_shape.Visible = 'off';
					else
						obj.car_shape.Color   = [0 0 0];
						obj.pac_shape.Visible = 'on';
					end
					pause(sleep_time);
				end
				if ~isvalid(obj.ax)
					obj.init();
					obj.show();
				end
				obj.tit_objct.String = "#(" + string(run) + "), @" + string(i) + ", Reward = " + string(rew);
				[wp, ~, x, y] = obj.S2P(eps(i));
				if(wp == 5)
					obj.pac_shape.Visible = 'off';
				else
					obj.pac_shape.Visible = 'on';
				end
				obj.car_shape.Position = [0.5+x, 0.5+y, 0];
				pause(2*sleep_time);
			end
			
			obj.hide();
			pause(0.01);
		end
		
		
		% defined start point
		function define_start_point(obj, sx, sy, pp, dp)
			if ~isvalid(obj.ax)
				obj.init();
			end
			obj.which_pack	= pp;
			obj.where_pack	= pp;
			obj.which_dest	= dp;
			obj.car_pos.x	= sx;
			obj.car_pos.y	= sy;
			if pp == (size(obj.Pack_poses,1)+1)
				obj.which_pack			= pp-1;
				obj.pac_shape.Visible	= 'off';
				obj.car_shape.Color		= [0 1 0];
			end
			obj.pac_pos.x	= obj.Pack_poses(obj.which_pack, 1);
			obj.pac_pos.y	= obj.Pack_poses(obj.which_pack, 2);
			obj.des_pos.x	= obj.Dest_poses(obj.which_dest, 1);
			obj.des_pos.y	= obj.Dest_poses(obj.which_dest, 2);
			obj.car_shape.Position = [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.pac_shape.Position = [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
			obj.des_shape.Position = [0.5+obj.des_pos.x, 0.5+obj.des_pos.y, 0];
		end
		
		
		% extract the point info
		function [sx, sy, pp, dp] = extract_point_info(obj)
			sx = obj.car_pos.x;
			sy = obj.car_pos.y;
			pp = obj.which_pack;
			dp = obj.which_dest;
		end
		
		
		% plotting a base action
		function Plot_actions_base(obj, this_Policy, ax, added)
			hold(ax, "on")
			axis(ax, "off")
			axis(ax, "equal")
			m = 5;
			xlim(ax, [0 m]);
			ylim(ax, [0 m]);
			for i=0:m
				plot(ax, [0 m], [i i], 'k');
				plot(ax, [i i], [0 m], 'k');
			end
			
			for i=1:size(this_Policy, 2)
				[~, ~, x, y] = obj.S2P(added + i - 1);
				switch this_Policy(1, i)
				case 1,	text(ax, x+0.55,5-0.5-y,'\uparrow',   'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);			
				case 2,	text(ax, x+0.50,5-0.5-y,'\rightarrow','HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);		
				case 3, text(ax, x+0.55,5-0.5-y,'\downarrow', 'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);		
				case 4,	text(ax, x+0.50,5-0.5-y,'\leftarrow', 'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);		
				case 5,	text(ax, x+0.50,5-0.5-y,'P',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);		
				case 6,	text(ax, x+0.50,5-0.5-y,'D',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	
				end	
			end
		end
		
		
		% Plotting the action space for a single package position
		function Plot_gridworld_actions_plain(obj, this_Policy, name, added, which)
			figure;
			t = tiledlayout(2,2);
			title(t, "Near Optimum Policy of " + name + which);
			ax1 = nexttile(t, 1);  % First tile
			ax2 = nexttile(t, 2);  % Second tile
			ax3 = nexttile(t, 3);
			ax4 = nexttile(t, 4);
			title(ax1, "Dest: North West");
			obj.Plot_actions_base(this_Policy( 1:25),	ax1, added);
			title(ax2, "Dest: South West");
			obj.Plot_actions_base(this_Policy(26:50),	ax2, added+25);
			title(ax3, "Dest: North East");
			obj.Plot_actions_base(this_Policy(51:75),	ax3, added+50);
			title(ax4, "Dest: East");
			obj.Plot_actions_base(this_Policy(76:100),	ax4, added+75);
		end
		
		
		% Plotting the whole action space
		function Plot_gridworld_actions(obj, Pol, name)
			obj.Plot_gridworld_actions_plain(Pol(  1:100), name,   0, "  Surc: North West");
			obj.Plot_gridworld_actions_plain(Pol(101:200), name, 100, "  Surc: South West");
			obj.Plot_gridworld_actions_plain(Pol(201:300), name, 200, "  Surc: North East");
			obj.Plot_gridworld_actions_plain(Pol(301:400), name, 300, "  Surc: East");
			obj.Plot_gridworld_actions_plain(Pol(401:500), name, 400, "  Surc: With the Car");
		end
		
		
		% plotting a base state value
		function Plot_state_value_base(obj, this_Q_val, color_bar_range, added, ax)
			hold(ax, "on")
			axis(ax, "off")
			axis(ax, "equal")
			m  = 5;
			Vs = zeros(5);
			xlim(ax, [0.5, 0.5+m]);
			ylim(ax, [0.5, 0.5+m]);
			for i=1:size(this_Q_val, 2)
				[~, ~, x, y] = obj.S2P(added + i - 1);
				Vs(x+1, y+1) = this_Q_val(i);
			end
			imagesc(ax, rot90(Vs, 1));
			colorbar(ax);
			clim(ax, color_bar_range);
		end
		
		
		% plotting the state values for a single package position
		function Plot_gridworld_State_Values_plain(obj, this_Q_val, CBR, where, added, name)
			figure;
			t = tiledlayout(2,2);
			title(t, "State Value of " + name);
			ax1 = nexttile(t, 1);  % First tile
			ax2 = nexttile(t, 2);  % Second tile
			ax3 = nexttile(t, 3);
			ax4 = nexttile(t, 4);
			PorD = 'D';
			
			title(ax1, "North West");
			obj.Plot_state_value_base(this_Q_val( 1:25),	CBR, added,		ax1);
			text(ax1, 1, 5, PorD,	'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax2, "South West");
			obj.Plot_state_value_base(this_Q_val(26:50),	CBR, added + 25,	ax2);
			text(ax2, 1, 1, PorD,	'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax3, "North East");
			obj.Plot_state_value_base(this_Q_val(51:75),	CBR, added + 50,	ax3);
			text(ax3, 5, 4, PorD,	'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax4, "East");
			obj.Plot_state_value_base(this_Q_val(76:100),	CBR, added + 75,	ax4);
			text(ax4, 5, 2, PorD,	'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			
			if where < 5
				text(	ax1,	...
						1+obj.Dest_poses(where, 1),	5-obj.Dest_poses(where, 2), 'P',...
						'HorizontalAlignment',		'center',...
						'VerticalAlignment',		'middle',...
						'FontSize',					8);
				text(	ax2,	...
						1+obj.Dest_poses(where, 1),	5-obj.Dest_poses(where, 2), 'P',...
						'HorizontalAlignment',		'center',...
						'VerticalAlignment',		'middle',...
						'FontSize',					8);
				text(	ax3,	...
						1+obj.Dest_poses(where, 1),	5-obj.Dest_poses(where, 2), 'P',...
						'HorizontalAlignment',		'center',...
						'VerticalAlignment',		'middle',...
						'FontSize',					8);
				text(	ax4,	...
						1+obj.Dest_poses(where, 1),	5-obj.Dest_poses(where, 2), 'P',...
						'HorizontalAlignment',		'center',...
						'VerticalAlignment',		'middle',...
						'FontSize',					8);
			end
		end
		
		
		% plotting the whole state values
		function Plot_gridworld_State_Values(obj, this_Q_val, name)
			ma  = extractdata(max(max(this_Q_val)));
			mi  = extractdata(min(min(this_Q_val)));
			CBR = [floor(mi) ceil(ma)];
			obj.Plot_gridworld_State_Values_plain(this_Q_val(  1:100), CBR, 1,   0, name);
			obj.Plot_gridworld_State_Values_plain(this_Q_val(101:200), CBR, 2, 100, name);
			obj.Plot_gridworld_State_Values_plain(this_Q_val(201:300), CBR, 3, 200, name);
			obj.Plot_gridworld_State_Values_plain(this_Q_val(301:400), CBR, 4, 300, name);
			obj.Plot_gridworld_State_Values_plain(this_Q_val(401:500), CBR, 5, 400, name);
		end
		
		
		% show the environment
		function show(obj)
			if ~isvalid(obj.ax)
				obj.init();
			end
			obj.fig.Visible = 'on';
		end
		
		
		% hide the Environment
		function hide(obj)
			if ~isvalid(obj.ax)
				obj.init();
			end
			obj.fig.Visible = 'off';
		end
	end
	
end