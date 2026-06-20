function [Actions_size, dynamics, rewards, pack_poses, funcs] = build_temporal_difference_dynamics(pack_poses)

num_states = 4 * 5 * 5;
Actions_Space = containers.Map({'North', 'East', 'South', 'West', 'Pick'}, [1, 2, 3, 4, 5]);
funcs.conv_cordn2state = @(p, x, y) p * 25 + x * 5 + y + 1;
funcs.conv_state2cordn = @(s) [floor((s-1)/25), floor(mod(s-1,25)/5), mod(s-1, 5)];
funcs.is_terminal_cond = @(CPX, CPY, PPX, PPY, act) ((CPX == PPX) & (CPY == PPY) & (act == 5));
Actions_size = length(Actions_Space);
dynamics = zeros(num_states, 3, num_states, Actions_size);
rewards  = -ones(num_states, 3, num_states, Actions_size);
row_mod = [-1, 0, 1,  0];
col_mod = [ 0, 1, 0, -1];
% Dynamics
for pp = 0:3
	for y = 0:4
		for x = 0:4
			[new_y, y_hit] = clip(y + row_mod, 0, 4);
			[new_x, x_hit] = clip(x + col_mod, 0, 4);
			hit = y_hit + x_hit;
			p_state = funcs.conv_cordn2state(pp, y,		x);
			n_state = funcs.conv_cordn2state(pp, new_y,	new_x);
			for ac=1:4
				dynamics(n_state(ac), 1+hit(ac), p_state, ac) = 1;
				rewards (n_state(ac), 1+hit(ac), p_state, ac) = -1-9*hit(ac);
			end
			pick = (x == pack_poses(pp+1,1)) && (y == pack_poses(pp+1,2));
			dynamics(p_state, 2+pick, p_state, 5) = 1;
			rewards (p_state, 2+pick, p_state, 5) = -10+30*pick;
		end
	end
end
% inner walls:
for pp = 0:3
	% cordinate x = 0, y = 3, action = east
	ps = 16 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('East')) = 0;
	rewards (:,  :,  ps, Actions_Space('East')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('East')) = 1;
	rewards (ps, 2,  ps, Actions_Space('East')) = -10;
	% cordinate x = 1, y = 3, action = west
	ps = 17 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('West')) = 0;
	rewards (:,  :,  ps, Actions_Space('West')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('West')) = 1;
	rewards (ps, 2,  ps, Actions_Space('West')) = -10;
	% cordinate x = 0, y = 4, action = east
	ps = 21 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('East')) = 0;
	rewards (:,  :,  ps, Actions_Space('East')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('East')) = 1;
	rewards (ps, 2,  ps, Actions_Space('East')) = -10;
	% cordinate x = 0, y = 4, action = west
	ps = 22 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('West')) = 0;
	rewards (:,  :,  ps, Actions_Space('West')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('West')) = 1;
	rewards (ps, 2,  ps, Actions_Space('West')) = -10;
	% cordinate x = 4, y = 1, action = South
	ps = 10 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('South')) = 0;
	rewards (:,  :,  ps, Actions_Space('South')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('South')) = 1;
	rewards (ps, 2,  ps, Actions_Space('South')) = -10;
	% cordinate x = 4, y = 2, action = North
	ps = 15 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('North')) = 0;
	rewards (:,  :,  ps, Actions_Space('North')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('North')) = 1;
	rewards (ps, 2,  ps, Actions_Space('North')) = -10;
	% cordinate x = 2, y = 4, action = east
	ps = 23 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('East')) = 0;
	rewards (:,  :,  ps, Actions_Space('East')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('East')) = 1;
	rewards (ps, 2,  ps, Actions_Space('East')) = -10;
	% cordinate x = 3, y = 4, action = west
	ps = 24 + 25*pp;
	dynamics(:,  :,  ps, Actions_Space('West')) = 0;
	rewards (:,  :,  ps, Actions_Space('West')) = 0;
	dynamics(ps, 2,  ps, Actions_Space('West')) = 1;
	rewards (ps, 2,  ps, Actions_Space('West')) = -10;
end



end