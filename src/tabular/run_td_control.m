close all
clear
clc

% Temporal-difference control experiments

project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(project_root));
[Env, num_states, Actions_length] = build_post_delivery_tabular_world();




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
[SARSA_policy, SARSA_Q_val, SARSA_AveRet] = sarsa_control(	...
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





% Q-Learning
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.01;
num_episodes	= 100000;
disp("Q-Learning: ");
tic;
[QL_policy, QL_Q_val, QL_AveRet] = q_learning_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	num_episodes, 	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(QL_policy, "Q-Learning");
Env.Plot_gridworld_State_Values	(QL_Q_val,  "Q-Learning");
Env.simulate					(1, QL_policy, episode_len, 0.5);
fprintf('Elapsed time of Q-Learning: %.4f seconds\n\n', elapsed);





% 4-Step SARSA
pause(0.01)
episode_len		= 30;
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4-Step SARSA: ");
tic;
[n4_SARSA_policy, n4_SARSA_Q_val, n4_SARSA_AveRet] = n_step_sarsa_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_length,	...
	epsilon_decay,	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(n4_SARSA_policy, "4-Step SARSA");
Env.Plot_gridworld_State_Values	(n4_SARSA_Q_val,  "4-Step SARSA");
Env.simulate					(1, n4_SARSA_policy, episode_len, 0.5);
fprintf('Elapsed time of 4-Step SARSA: %.4f seconds\n\n', elapsed);



% 4-Step Q-Learning
pause(0.01)
episode_len		= 30;
epsilon			= 1;
gamma			= 1;
epsilon_decay	= 0.9;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4-Step Q-Learning: ");
tic;
[n4_QL_policy, n4_QL_Q_val, n4_QL_AveRet] = n_step_q_learning_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_length,	...
	epsilon_decay,	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(n4_QL_policy, "4-Step Q-Learning");
Env.Plot_gridworld_State_Values	(n4_QL_Q_val,  "4-Step Q-Learning");
Env.simulate					(1, n4_QL_policy, episode_len, 0.5);
fprintf('Elapsed time of 4-Step Q-Learning: %.4f seconds\n\n', elapsed);





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
title(ax2, "Q-Learning");
title(ax3, "4-Step SARSA");
title(ax4, "4-Step Q-Learning");
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









