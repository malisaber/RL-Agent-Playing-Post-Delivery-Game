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
Env = GridWorld_5X5_Env(Actions_length, dynamics, rewards, pack_poses, ...
	conv_cordn2state, conv_state2cordn, is_terminal_cond);




% SARSA 
pause(0.01)
episode_len		= 25;
epsilon			= 0.01;
gamma			= 1;
num_episodes	= 20000;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.02;
disp("SARSA: ");
tic;
[SARSA_policy, SARSA_Q_val, SARSA_AveRet] = SARSA(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	num_episodes, 	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(SARSA_policy, "SARSA");
Env.Plot_gridworld_State_Values	(SARSA_Q_val,  "SARSA");
Env.simulate					(1, SARSA_policy, episode_len, 0.5);
fprintf('Elapsed time of SARSA: %.4f seconds\n\n', elapsed);





% Q_Learning
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.01;
num_episodes	= 100000;
disp("Q_Learning: ");
tic;
[QL_policy, QL_Q_val, QL_AveRet] = Q_Learning(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	num_episodes, 	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(QL_policy, "Q Learning");
Env.Plot_gridworld_State_Values	(QL_Q_val,  "Q Learning");
Env.simulate					(1, QL_policy, episode_len, 0.5);
fprintf('Elapsed time of Q_Learning: %.4f seconds\n\n', elapsed);





% 4 step SARSA 
pause(0.01)
episode_len		= 30;
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4 step SARSA: ");
tic;
[n4_SARSA_policy, n4_SARSA_Q_val, n4_SARSA_AveRet] = n_SARSA(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_length,	...
	epsilon_decay,	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(n4_SARSA_policy, "4 step SARSA");
Env.Plot_gridworld_State_Values	(n4_SARSA_Q_val,  "4 step SARSA");
Env.simulate					(1, n4_SARSA_policy, episode_len, 0.5);
fprintf('Elapsed time of 4 step SARSA: %.4f seconds\n\n', elapsed);



% 4 step Q Learning 
pause(0.01)
episode_len		= 30;
epsilon			= 1;
gamma			= 1;
epsilon_decay	= 0.9;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4 step Q Learning: ");
tic;
[n4_QL_policy, n4_QL_Q_val, n4_QL_AveRet] = n_QL(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_length,	...
	epsilon_decay,	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(n4_QL_policy, "4 step Q Learning");
Env.Plot_gridworld_State_Values	(n4_QL_Q_val,  "4 step Q Learning");
Env.simulate					(1, n4_QL_policy, episode_len, 0.5);
fprintf('Elapsed time of 4 step SARSA: %.4f seconds\n\n', elapsed);





% comparison
window = 8;
SARSA_AveRet_s		= movmean(SARSA_AveRet,		window, 'Endpoints','fill');
QL_AveRet_s			= movmean(QL_AveRet,		window, 'Endpoints','fill');
n4_SARSA_AveRet_s	= movmean(n4_SARSA_AveRet,	window, 'Endpoints','fill');
n4_QL_AveRet_s		= movmean(n4_QL_AveRet,		window, 'Endpoints','fill');
figure; 
t = tiledlayout(4,1);
title(t, "Average Returns");
ax1 = nexttile(t, 1);
ax2 = nexttile(t, 2);
ax3 = nexttile(t, 3);
ax4 = nexttile(t, 4);
plot(ax1, 1:num_episodes, SARSA_AveRet_s);
plot(ax2, 1:num_episodes, QL_AveRet_s);
plot(ax3, 1:num_episodes, n4_SARSA_AveRet_s);
plot(ax4, 1:num_episodes, n4_QL_AveRet_s);
title(ax1, "SARSA");
title(ax2, "Q Learning");
title(ax3, "4 step SARSA");
title(ax4, "4 step Q Learning");
hold(ax1, 'on');
hold(ax2, 'on');
hold(ax3, 'on');
hold(ax4, 'on');
plot(ax1, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
plot(ax2, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
plot(ax3, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
plot(ax4, [0 num_episodes], [0 0], ':k', 'LineWidth', 1);
ylim(ax1, [-40, 20])
ylim(ax2, [-40, 20])
ylim(ax3, [-40, 20])
ylim(ax4, [-40, 20])



