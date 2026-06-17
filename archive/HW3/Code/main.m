close all
clear
clc


% % Initialization
num_states = 4 * 5 * 5;
Actions_Space = containers.Map({'North', 'East', 'South', 'West', 'Pick'}, [1, 2, 3, 4, 5]);
pack_poses = [0, 0; 0, 4; 4, 1; 4, 3];
conv_cordn2state = @(p, x, y) p * 25 + x * 5 + y + 1;
conv_state2cordn = @(s) [floor((s-1)/25), floor(mod(s-1,25)/5), mod(s-1, 5)];
is_terminal_cond = @(CPX, CPY, PPX, PPY, act) ((CPX == PPX) & (CPY == PPY) & (act == 5));
Actions_length = length(Actions_Space);
dynamics = zeros(num_states, 3, num_states, Actions_length);
rewards  = -ones(num_states, 3, num_states, Actions_length);
behavior_policy = ones(num_states,length(Actions_Space))/Actions_length;
row_mod = [-1, 0, 1,  0];
col_mod = [ 0, 1, 0, -1];
% Dynamics
for pp = 0:3
	for y = 0:4
		for x = 0:4
			[new_y, y_hit] = clip(y + row_mod, 0, 4);
			[new_x, x_hit] = clip(x + col_mod, 0, 4);
			hit = y_hit + x_hit;
			p_state = conv_cordn2state(pp, y,		x);
			n_state = conv_cordn2state(pp, new_y,	new_x);
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



% Task 1, Environment
Env = GridWorld_5X5_Env(25, Actions_length, dynamics, rewards, pack_poses, ...
	conv_cordn2state, conv_state2cordn, is_terminal_cond);




% on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
num_episodes	= 100000;
epsilon_decay	= 1;
EDI				= 1000;
disp("On policy: ");
tic;
[onp_policy, onp_Q_val, onp_AveRet] = on_policy(	...
	Env,			[],				...
	epsilon,		gamma,			...
	num_episodes, 	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(onp_policy, "On Policy");
Env.Plot_gridworld_State_Values	(onp_Q_val,  "On Policy");
Env.simulate					(10, onp_policy, 0.5);
fprintf('Elapsed time of On policy: %.4f seconds\n\n', elapsed);





% off policy
epsilon			= 0.5;
gamma			= 1;
num_episodes	= 100000;
epsilon_decay	= 1;
EDI				= 100;
disp("Off policy: ");
tic;
[ofp_policy, ofp_Q_val, ofp_AveRet] = off_policy(	...
	Env,			[],				...
	epsilon,		gamma,			...
	num_episodes,	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI,			1);

elapsed = toc;
Env.Plot_gridworld_actions		(ofp_policy, "Off Policy");
Env.Plot_gridworld_State_Values	(ofp_Q_val,  "Off Policy");
Env.simulate					(10, ofp_policy, 0.5);
fprintf('Elapsed time of On policy: %.4f seconds\n\n', elapsed);






% Advanced on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
num_episodes	= 10000;
epsilon_decay	= 1;
EDI				= 1000;
Aonp_policy		= [];
Aonp_AveRet		= zeros(num_episodes, 1);

disp("On policy: ");
tic;
for i=1:10
	epsilon			= 1 / 10 / i;
	[Aonp_policy, Aonp_Q_val, Aonp_AveRet_t] = on_policy(	...
		Env,			Aonp_policy,		...
		epsilon,		gamma,			...
		num_episodes, 	num_states,		...
		Actions_length,	epsilon_decay,	...
		EDI);
	Aonp_AveRet(num_episodes*(i-1)+1:num_episodes*(i), 1) = Aonp_AveRet_t;
end
elapsed = toc;
Env.Plot_gridworld_actions		(Aonp_policy, "Advanced On Policy");
Env.Plot_gridworld_State_Values	(Aonp_Q_val,  "Advanced On Policy");
Env.simulate					(10, Aonp_policy, 0.5);
fprintf('Elapsed time of On policy: %.4f seconds\n\n', elapsed);








% comparison
num_episodes	= 100000;
window = 25;
onp_AveRet_s  = movmean(onp_AveRet,  window, 'Endpoints','fill');
ofp_AveRet_s  = movmean(ofp_AveRet,  window, 'Endpoints','fill');
Aonp_AveRet_s = movmean(Aonp_AveRet, window, 'Endpoints','fill');
figure; 
t = tiledlayout(3,1);
title(t, "Average Returns");
ax1 = nexttile(t, 1);  % First tile
ax2 = nexttile(t, 2);  % Second tile
ax3 = nexttile(t, 3);  % Second tile
plot(ax1, 1:num_episodes, onp_AveRet_s);
plot(ax2, 1:num_episodes, ofp_AveRet_s);
plot(ax3, 1:num_episodes, Aonp_AveRet_s);
title(ax1, "On-Policy");
title(ax2, "Off-Policy");
title(ax3, "Advanced On-Policy");
hold(ax1, 'on');
hold(ax2, 'on');
hold(ax3, 'on');
plot(ax1, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
plot(ax2, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
plot(ax3, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
ylim(ax1, [-50, 20])
ylim(ax2, [-50, 20])
ylim(ax3, [-50, 20])



