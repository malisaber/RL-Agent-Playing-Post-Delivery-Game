function [env, num_states, actions_length] = build_post_delivery_tabular_world(max_length)

if nargin < 1
	max_length = [];
end

num_states = 4 * 5 * 5;
actions_space = containers.Map({'North', 'East', 'South', 'West', 'Pick'}, [1, 2, 3, 4, 5]);
pack_poses = [0, 0; 0, 4; 4, 1; 4, 3];
conv_cordn2state = @(p, x, y) p * 25 + x * 5 + y + 1;
conv_state2cordn = @(s) [floor((s-1)/25), floor(mod(s-1,25)/5), mod(s-1, 5)];
is_terminal_cond = @(CPX, CPY, PPX, PPY, act) ((CPX == PPX) & (CPY == PPY) & (act == 5));
actions_length = length(actions_space);
dynamics = zeros(num_states, 3, num_states, actions_length);
rewards  = -ones(num_states, 3, num_states, actions_length);
row_mod = [-1, 0, 1,  0];
col_mod = [ 0, 1, 0, -1];

% Dynamics
for pp = 0:3
	for y = 0:4
		for x = 0:4
			[new_y, y_hit] = clip_to_bounds(y + row_mod, 0, 4);
			[new_x, x_hit] = clip_to_bounds(x + col_mod, 0, 4);
			hit = y_hit + x_hit;
			p_state = conv_cordn2state(pp, y, x);
			n_state = conv_cordn2state(pp, new_y, new_x);
			for ac = 1:4
				dynamics(n_state(ac), 1 + hit(ac), p_state, ac) = 1;
				rewards(n_state(ac), 1 + hit(ac), p_state, ac) = -1 - 9 * hit(ac);
			end
			pick = (x == pack_poses(pp+1,1)) && (y == pack_poses(pp+1,2));
			dynamics(p_state, 2 + pick, p_state, 5) = 1;
			rewards(p_state, 2 + pick, p_state, 5) = -10 + 30 * pick;
		end
	end
end

% Inner walls.
for pp = 0:3
	% coordinate x = 0, y = 3, action = east
	ps = 16 + 25 * pp;
	dynamics(:, :, ps, actions_space('East')) = 0;
	rewards(:, :, ps, actions_space('East')) = 0;
	dynamics(ps, 2, ps, actions_space('East')) = 1;
	rewards(ps, 2, ps, actions_space('East')) = -10;
	% coordinate x = 1, y = 3, action = west
	ps = 17 + 25 * pp;
	dynamics(:, :, ps, actions_space('West')) = 0;
	rewards(:, :, ps, actions_space('West')) = 0;
	dynamics(ps, 2, ps, actions_space('West')) = 1;
	rewards(ps, 2, ps, actions_space('West')) = -10;
	% coordinate x = 0, y = 4, action = east
	ps = 21 + 25 * pp;
	dynamics(:, :, ps, actions_space('East')) = 0;
	rewards(:, :, ps, actions_space('East')) = 0;
	dynamics(ps, 2, ps, actions_space('East')) = 1;
	rewards(ps, 2, ps, actions_space('East')) = -10;
	% coordinate x = 0, y = 4, action = west
	ps = 22 + 25 * pp;
	dynamics(:, :, ps, actions_space('West')) = 0;
	rewards(:, :, ps, actions_space('West')) = 0;
	dynamics(ps, 2, ps, actions_space('West')) = 1;
	rewards(ps, 2, ps, actions_space('West')) = -10;
	% coordinate x = 4, y = 1, action = south
	ps = 10 + 25 * pp;
	dynamics(:, :, ps, actions_space('South')) = 0;
	rewards(:, :, ps, actions_space('South')) = 0;
	dynamics(ps, 2, ps, actions_space('South')) = 1;
	rewards(ps, 2, ps, actions_space('South')) = -10;
	% coordinate x = 4, y = 2, action = north
	ps = 15 + 25 * pp;
	dynamics(:, :, ps, actions_space('North')) = 0;
	rewards(:, :, ps, actions_space('North')) = 0;
	dynamics(ps, 2, ps, actions_space('North')) = 1;
	rewards(ps, 2, ps, actions_space('North')) = -10;
	% coordinate x = 2, y = 4, action = east
	ps = 23 + 25 * pp;
	dynamics(:, :, ps, actions_space('East')) = 0;
	rewards(:, :, ps, actions_space('East')) = 0;
	dynamics(ps, 2, ps, actions_space('East')) = 1;
	rewards(ps, 2, ps, actions_space('East')) = -10;
	% coordinate x = 3, y = 4, action = west
	ps = 24 + 25 * pp;
	dynamics(:, :, ps, actions_space('West')) = 0;
	rewards(:, :, ps, actions_space('West')) = 0;
	dynamics(ps, 2, ps, actions_space('West')) = 1;
	rewards(ps, 2, ps, actions_space('West')) = -10;
end

if isempty(max_length)
	env = PostDeliveryTabularEnv(actions_length, dynamics, rewards, pack_poses, ...
		conv_cordn2state, conv_state2cordn, is_terminal_cond);
else
	env = PostDeliveryTabularEnv(max_length, actions_length, dynamics, rewards, pack_poses, ...
		conv_cordn2state, conv_state2cordn, is_terminal_cond);
end

end
