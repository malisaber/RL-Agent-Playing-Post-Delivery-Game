classdef td_post_delivery_environment < handle
	properties
		Action_length; 
		Dynamics;
		Rewards;
		pack_poses;
		c2s_f;
		s2c_f;
		TC_f;
		
		which_package;
		car_pos;
		pac_pos;
		fig;
		ax;
		car_shape; 
		box_shape; 
		tit_objct;
		video;
	end
	
	methods
		% Constructor
		function obj = td_post_delivery_environment(action_length, ...
				dynamics, rewards, goal_pos, func)
			obj.Action_length = action_length;
			obj.Dynamics = dynamics;
			obj.Rewards = rewards;
			obj.pack_poses = goal_pos;
			obj.c2s_f = func.conv_cordn2state;
			obj.s2c_f = func.conv_state2cordn;
			obj.TC_f  = func.is_terminal_cond;
			obj.car_pos.x = 0;
			obj.car_pos.y = 0;
			obj.pac_pos.x = 0;
			obj.pac_pos.y = 0;
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
			obj.which_package = randi(4);
			obj.car_pos.x = randi(5)-1;
			obj.car_pos.y = randi(5)-1;
			obj.pac_pos.x = obj.pack_poses(obj.which_package, 1);
			obj.pac_pos.y = obj.pack_poses(obj.which_package, 2);
			obj.car_shape.Position = [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.box_shape.Position = [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
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
			obj.car_shape = text(obj.ax, 0, 0, '🚘', 'FontSize', 30, 'HorizontalAlignment', 'center');
			obj.box_shape = text(obj.ax, 0, 0, '📫', 'FontSize', 30, 'HorizontalAlignment', 'center');
			obj.tit_objct = title(obj.ax, "#(0), @0, Reward = 0");
			obj.car_shape.Position = [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.box_shape.Position = [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
		end
		
		
		% generate an episode
		function [episode_states, episode_actions, episode_rewards, terminated] = generate_episode(obj, policy, max_length)
			ep_all_states	= zeros(1, max_length+1);
			ep_all_actions	= zeros(1, max_length+1);
			ep_all_rewards	= zeros(1, max_length+1);
			terminated		= false;
			
			for ep_cntr = 1:max_length
				this_state  = obj.c2s_f(obj.which_package-1, obj.car_pos.y, obj.car_pos.x);
				this_action = randsample(1:obj.Action_length, 1, true, policy(this_state, :));
				
				state_dynamics = squeeze(obj.Dynamics(:, :, this_state, this_action));
				state_dynamics_flt = state_dynamics(:);
				where = randsample(1:length(state_dynamics_flt), 1, true, state_dynamics_flt) - 1;
				next_state  = mod (where,size(state_dynamics,1))+1;
				next_reward = floor(where/size(state_dynamics,1))+1;
				
				next_pos      = obj.s2c_f(next_state);
				obj.car_pos.x = next_pos(3);
				obj.car_pos.y = next_pos(2);
				
				ep_all_states (ep_cntr) = this_state;
				ep_all_actions(ep_cntr) = this_action;
				ep_all_rewards(ep_cntr) = obj.Rewards(next_state, next_reward, this_state, this_action);
				
				
				if obj.TC_f(obj.car_pos.x, obj.car_pos.y,...
							obj.pac_pos.x,  obj.pac_pos.y,  this_action)
					terminated = true;
					break;
				end
			end
			ep_all_states(ep_cntr+1) = next_state;
			episode_states  = ep_all_states (1 : ep_cntr+1);
			episode_actions = ep_all_actions(1 : ep_cntr);
			episode_rewards = ep_all_rewards(1 : ep_cntr);
		end
		
		
		% simulate an episode
		function [Aeps, Aepa, Aepr] = simulate(obj, runs, name, policy, max_length, sleep_time, path)
			obj.show();
			Aeps = cell(runs, 1);
			Aepa = cell(runs, 1);
			Aepr = cell(runs, 1);
			for run = 1:runs
				% creating the video 
				Video_name = fullfile(path, name + "Simulation_" + run + ".mp4");
				frame_rate = ceil(1/sleep_time);
				obj.create_video_file(Video_name, frame_rate)
				% simulation
				obj.restart();
				[eps, epa, epr, ~] = obj.generate_episode(policy, max_length);
				Aeps(run) = {eps};
				Aepa(run) = {epa};
				Aepr(run) = {epr};
				rew = 0;
				obj.show();
				obj.tit_objct.String = "#(" + string(run) + "), @" + 0 + ", Reward = " + string(rew);
				% insert new frame:
				drawnow;
				frame = getframe(gcf);
				writeVideo(obj.video, frame);
				writeVideo(obj.video, frame);
				pause(sleep_time);
				for i=1:length(epa)
					if ~isvalid(obj.ax)
						obj.init();
						obj.show();
					end
					pos = obj.s2c_f(eps(i));
					obj.car_shape.Position = [0.5+pos(3), 0.5+pos(2), 0];
					obj.tit_objct.String = "#(" + string(run) + "), @" + string(i-1) + ", Reward = " + string(rew);
					rew = rew + epr(i);
					% insert new frame:
					drawnow;
					frame = getframe(gcf);
					writeVideo(obj.video, frame);
					pause(sleep_time);
				end
				if ~isvalid(obj.ax)
					obj.init();
					obj.show();
				end
				obj.tit_objct.String = "#(" + string(run) + "), @" + string(i-1) + ", Reward = " + string(rew);
				pos = obj.s2c_f(eps(i+1));
				obj.car_shape.Position = [0.5+pos(3), 0.5+pos(2), 0];
				% insert new frame:
				drawnow;
				frame = getframe(gcf);
				writeVideo(obj.video, frame);
				writeVideo(obj.video, frame);
				pause(2*sleep_time);
				% closing the video
				obj.close_video();
			end
			
			obj.hide();
			pause(0.01);
		end
		
		
		% defined start point
		function define_start_point(obj, sx, sy, pp)
			if ~isvalid(obj.ax)
				obj.init();
			end
			obj.which_package = pp;
			obj.car_pos.x = sx;
			obj.car_pos.y = sy;
			obj.pac_pos.x = obj.pack_poses(obj.which_package, 1);
			obj.pac_pos.y = obj.pack_poses(obj.which_package, 2);
			obj.car_shape.Position = [0.5+obj.car_pos.x, 0.5+obj.car_pos.y, 0];
			obj.box_shape.Position = [0.5+obj.pac_pos.x, 0.5+obj.pac_pos.y, 0];
		end
		
		
		% plotting a base action
		function Plot_actions_base(obj, this_Policy, ax)
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
			
			for i=1:m
				for j=1:m
					ps = m*i+j-m;
					pol_max = max(this_Policy(ps, :));
					if	(this_Policy(ps,1) == pol_max),	text(ax, j-0.55,m+0.5-i,'\uparrow',   'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	end		
					if	(this_Policy(ps,2) == pol_max),	text(ax, j-0.50,m+0.5-i,'\rightarrow','HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	end	
					if	(this_Policy(ps,3) == pol_max),	text(ax, j-0.55,m+0.5-i,'\downarrow', 'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	end	
					if	(this_Policy(ps,4) == pol_max),	text(ax, j-0.50,m+0.5-i,'\leftarrow', 'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	end	
					if	(this_Policy(ps,5) == pol_max),	text(ax, j-0.50,m+0.5-i,'X',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);	end	
				end
			end
		end
		
		
		% Plotting the whole action space
		function Plot_gridworld_actions(obj, this_Policy, name, path)
			this_fig = figure;
			t = tiledlayout(2,2);
			title(t, "Near Optimum Policy of " + name);
			ax1 = nexttile(t, 1);  % First tile
			ax2 = nexttile(t, 2);  % Second tile
			ax3 = nexttile(t, 3);
			ax4 = nexttile(t, 4);
			title(ax1, "North West");
			obj.Plot_actions_base(this_Policy( 1:25,  :), ax1);
			title(ax2, "South West");
			obj.Plot_actions_base(this_Policy(26:50,  :), ax2);
			title(ax3, "North East");
			obj.Plot_actions_base(this_Policy(51:75,  :), ax3);
			title(ax4, "East");
			obj.Plot_actions_base(this_Policy(76:100, :), ax4);
			exportgraphics(this_fig, fullfile(path, name + " Action Space.jpg"), 'Resolution', 600);
		end
		
		
		% plotting a base state value
		function Plot_state_value_base(obj, this_Q_val, color_bar_range, ax)
			hold(ax, "on")
			axis(ax, "off")
			axis(ax, "equal")
			m = 5;
			xlim(ax, [0.5, 0.5+m]);
			ylim(ax, [0.5, 0.5+m]);
			Vs = rot90(reshape(this_Q_val, m, m));
			imagesc(ax, Vs);
			colorbar(ax);
			clim(ax, color_bar_range);
		end
		
		
		% plotting the whole state values
		function Plot_gridworld_State_Values(obj, this_Q_val, name, path)
			this_action_val = max(this_Q_val, [], 2);
			ma  = max(max(this_action_val));
			mi  = min(min(this_action_val));
			CBR = [floor(mi) ceil(ma)];
			
			this_fig = figure;
			t = tiledlayout(2,2);
			title(t, "State Value of " + name);
			ax1 = nexttile(t, 1);  % First tile
			ax2 = nexttile(t, 2);  % Second tile
			ax3 = nexttile(t, 3);
			ax4 = nexttile(t, 4);
			title(ax1, "North West");
			obj.Plot_state_value_base(this_action_val( 1:25,  1), CBR, ax1);
			text(ax1, 1, 5,'X',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax2, "South West");
			obj.Plot_state_value_base(this_action_val(26:50,  1), CBR, ax2);
			text(ax2, 1, 1,'X',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax3, "North East");
			obj.Plot_state_value_base(this_action_val(51:75,  1), CBR, ax3);
			text(ax3, 5, 4,'X',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			title(ax4, "East");
			obj.Plot_state_value_base(this_action_val(76:100, 1), CBR, ax4);
			text(ax4, 5, 2,'X',		  'HorizontalAlignment',	'center',	'VerticalAlignment',   'middle', 'FontSize', 8);
			exportgraphics(this_fig, fullfile(path, name + " State Value.jpg"), 'Resolution', 600);
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
	
	
		% Creating a video file
		function create_video_file(obj, Video_name, frame_rate)
			obj.video = VideoWriter(Video_name, 'MPEG-4');
			obj.video.FrameRate = frame_rate;
			open(obj.video);
		end
		
		
		% closing the video file
		function close_video(obj)
			close(obj.video);
		end
		
		
	end
end