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
[Actions_size, dynamics, rewards, pack_poses, Funcs] = build_monte_carlo_dynamics(pack_poses);

% Environment
Env = mc_post_delivery_environment(25, Actions_size, dynamics, rewards, pack_poses, Funcs);

% number of training episodes
num_episodes	= 30000;

% number of simulations per control algorithm 
simu_cnt = 1;

% creating foolders
base_dir		= ".." + filesep  + "..";
result_dir		= "results";
this_algorithm	= "monte-calro";

res_dir			= fullfile(base_dir, result_dir);
dst_dir			= fullfile(base_dir, result_dir, this_algorithm);
Onp_dir			= fullfile(base_dir, result_dir, this_algorithm, "on_policy");
Ofp_dir			= fullfile(base_dir, result_dir, this_algorithm, "off_policy");
Aop_dir			= fullfile(base_dir, result_dir, this_algorithm, "advanced_on_policy");

if ~isfolder(res_dir),	mkdir(res_dir),	end
if ~isfolder(dst_dir),	mkdir(dst_dir),	end
if ~isfolder(Onp_dir),	mkdir(Onp_dir),	end
if ~isfolder(Ofp_dir),	mkdir(Ofp_dir),	end
if ~isfolder(Aop_dir),	mkdir(Aop_dir),	end


% on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
disp("On policy: ");
tic;
[onp_policy, onp_Q_val, onp_AveRet] = on_policy_control(	...
	Env,							[],				...
	epsilon,						gamma,			...
	num_episodes, 					num_states,		...
	Actions_size,					epsilon_decay,	...
	EDI);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(onp_policy,	"On Policy", 						Onp_dir);
Env.Plot_gridworld_State_Values	(onp_Q_val, 	"On Policy", 						Onp_dir);
Env.simulate					(simu_cnt,		"On Policy",	onp_policy,	0.5,	Onp_dir);
fprintf('Elapsed time of On policy: %.4f seconds\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(Onp_dir, "\", "/") + """\n\n");




% off policy
epsilon			= 0.5;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 100;
disp("Off policy: ");
tic;
[ofp_policy, ofp_Q_val, ofp_AveRet] = off_policy_control(	...
	Env,							[],				...
	epsilon,						gamma,			...
	num_episodes,					num_states,		...
	Actions_size,					epsilon_decay,	...
	EDI,							1);

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(ofp_policy,	"Off Policy",						Ofp_dir);
Env.Plot_gridworld_State_Values	(ofp_Q_val,		"Off Policy",						Ofp_dir);
Env.simulate					(simu_cnt,		"Off Policy",	ofp_policy,	0.5,	Ofp_dir);
fprintf('Elapsed time of On policy: %.4f seconds\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(Ofp_dir, "\", "/") + """\n\n");






% Advanced on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
epsilon_decay	= 1;
EDI				= 1000;
Aonp_policy		= [];
Aonp_AveRet		= zeros(num_episodes, 1);
disp("On policy: ");
tic;
for i=1:floor(num_episodes/10000)
	disp("run " + i + "/" + floor(num_episodes/10000));
	epsilon			= 1 / 10 / i;
	[Aonp_policy, Aonp_Q_val, Aonp_AveRet_t] = on_policy_control(	...
		Env,						Aonp_policy,	...
		epsilon,					gamma,			...
		min(10000,num_episodes),	num_states,		...
		Actions_size,				epsilon_decay,	...
		EDI);
	Aonp_AveRet(10000*(i-1)+1:10000*(i), 1) = Aonp_AveRet_t;
end

fprintf('\nTrainign Done.\n');
elapsed = toc;
Env.Plot_gridworld_actions		(Aonp_policy,	"Advanced On Policy",							Aop_dir);
Env.Plot_gridworld_State_Values	(Aonp_Q_val,	"Advanced On Policy",							Aop_dir);
Env.simulate					(simu_cnt,		"Advanced On Policy",	Aonp_policy,	0.5,	Aop_dir);
fprintf('Elapsed time of On policy: %.4f seconds\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(Aop_dir, "\", "/") + """\n\n");








% comparison
window = 25;
onp_AveRet_s  = movmean(onp_AveRet,  window, 'Endpoints','fill');
ofp_AveRet_s  = movmean(ofp_AveRet,  window, 'Endpoints','fill');
Aonp_AveRet_s = movmean(Aonp_AveRet, window, 'Endpoints','fill');
fig = figure; 
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
exportgraphics(fig, fullfile(dst_dir, "Comparison.jpg"), 'Resolution', 600);


