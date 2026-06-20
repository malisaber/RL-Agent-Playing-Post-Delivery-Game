close all
clear
clc


% % Initialization
% Possible location for packages
%				X, Y;
pack_poses = [	0, 0; 
				0, 4; 
				4, 1; 
				4, 3];

% number of states = 
num_states = size(pack_poses,1) * 5 * 5;

% Dynamics
[Actions_size, dynamics, rewards, pack_poses, funcs] = build_temporal_difference_dynamics(pack_poses);

%  Environment
Env = td_post_delivery_environment(Actions_size, dynamics, rewards, pack_poses, funcs);

% number of training episodes
episode_len		= 30;
num_episodes	= 3000;

% number of simulations per control algorithm 
simu_cnt = 1;

% creating foolders
base_dir		= ".." + filesep  + "..";
result_dir		= "results";
this_algorithm	= "tempolar-difference";

res_dir			= fullfile(base_dir, result_dir);
dst_dir			= fullfile(base_dir, result_dir, this_algorithm);
SAR_dir			= fullfile(base_dir, result_dir, this_algorithm, "SARSA");
QLe_dir			= fullfile(base_dir, result_dir, this_algorithm, "QL");
nSA_dir			= fullfile(base_dir, result_dir, this_algorithm, "n-SARSA");
nQL_dir			= fullfile(base_dir, result_dir, this_algorithm, "n-QL");

if ~isfolder(res_dir),	mkdir(res_dir),	end
if ~isfolder(dst_dir),	mkdir(dst_dir),	end
if ~isfolder(SAR_dir),	mkdir(SAR_dir),	end
if ~isfolder(QLe_dir),	mkdir(QLe_dir),	end
if ~isfolder(nSA_dir),	mkdir(nSA_dir),	end
if ~isfolder(nQL_dir),	mkdir(nQL_dir),	end


% SARSA 
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.02;
disp("SARSA: ");
tic;
[SARSA_policy, SARSA_Q_val, SARSA_AveRet] = SARSA_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	num_episodes, 	num_states,		...
	Actions_size,	epsilon_decay,	...
	EDI);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(SARSA_policy,		"SARSA",											SAR_dir);
Env.Plot_gridworld_State_Values	(SARSA_Q_val,		"SARSA",											SAR_dir);
Env.simulate					(simu_cnt,			"SARSA",	SARSA_policy,	episode_len,	0.5,	SAR_dir);
fprintf('Elapsed time of SARSA: %.4f seconds.\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(SAR_dir, "\", "/") + """\n\n");





% Q_Learning
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.01;
disp("Q_Learning: ");
tic;
[QL_policy, QL_Q_val, QL_AveRet] = Q_Learning_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	num_episodes, 	num_states,		...
	Actions_size,	epsilon_decay,	...
	EDI);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(QL_policy,			"Q Learning",										QLe_dir);
Env.Plot_gridworld_State_Values	(QL_Q_val,			"Q Learning",										QLe_dir);
Env.simulate					(simu_cnt,			"Q Learning",	QL_policy,	episode_len,	0.5,	QLe_dir);
fprintf('Elapsed time of Q_Learning: %.4f seconds.\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(QLe_dir, "\", "/") + """\n\n");





% 4 step SARSA 
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4 step SARSA: ");
tic;
[n4_SARSA_policy, n4_SARSA_Q_val, n4_SARSA_AveRet] = n_SARSA_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_size,	...
	epsilon_decay,	EDI);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(n4_SARSA_policy,	"4 step SARSA",										nSA_dir);
Env.Plot_gridworld_State_Values	(n4_SARSA_Q_val,	"4 step SARSA",										nSA_dir);
Env.simulate					(simu_cnt,			"4 step SARSA",	n4_SARSA_policy, episode_len, 0.5,	nSA_dir);
fprintf('Elapsed time of 4 step SARSA: %.4f seconds.\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(nSA_dir, "\", "/") + """\n\n");



% 4 step Q Learning 
pause(0.01)
epsilon			= 1;
gamma			= 1;
epsilon_decay	= 0.9;
EDI				= 1000;
alpha			= 0.02;
steps			= 4;
disp("4 step Q Learning: ");
tic;
[n4_QL_policy, n4_QL_Q_val, n4_QL_AveRet] = n_QL_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	alpha,			episode_len,	...
	steps,			num_episodes, 	...
	num_states,		Actions_size,	...
	epsilon_decay,	EDI);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(n4_QL_policy,		"4 step Q Learning",								nQL_dir);
Env.Plot_gridworld_State_Values	(n4_QL_Q_val,		"4 step Q Learning",								nQL_dir);
Env.simulate					(simu_cnt,			"4 step Q Learning",n4_QL_policy, episode_len, 0.5,	nQL_dir);
fprintf('Elapsed time of 4 step SARSA: %.4f seconds.\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(nQL_dir, "\", "/") + """\n\n");





% comparison
window = 8;
SARSA_AveRet_s		= movmean(SARSA_AveRet,		window, 'Endpoints','fill');
QL_AveRet_s			= movmean(QL_AveRet,		window, 'Endpoints','fill');
n4_SARSA_AveRet_s	= movmean(n4_SARSA_AveRet,	window, 'Endpoints','fill');
n4_QL_AveRet_s		= movmean(n4_QL_AveRet,		window, 'Endpoints','fill');
fig = figure; 
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
exportgraphics(fig, fullfile(dst_dir, "Comparison.jpg"), 'Resolution', 600);


