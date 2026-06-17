close all
clear
clc

% Monte Carlo control experiments

project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(project_root));
[Env, num_states, Actions_length] = build_post_delivery_tabular_world(25);




% on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
num_episodes	= 100000;
epsilon_decay	= 1;
EDI				= 1000;
disp("On-Policy: ");
tic;
[onp_policy, onp_Q_val, onp_AveRet] = on_policy_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	num_episodes, 	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI);

elapsed = toc;
Env.Plot_gridworld_actions		(onp_policy, "On-Policy");
Env.Plot_gridworld_State_Values	(onp_Q_val,  "On-Policy");
Env.simulate					(10, onp_policy, 0.5);
fprintf('Elapsed time of On-Policy: %.4f seconds\n\n', elapsed);





% off policy
epsilon			= 0.5;
gamma			= 1;
num_episodes	= 100000;
epsilon_decay	= 1;
EDI				= 100;
disp("Off-Policy: ");
tic;
[ofp_policy, ofp_Q_val, ofp_AveRet] = off_policy_control(	...
	Env,			[],				...
	epsilon,		gamma,			...
	num_episodes,	num_states,		...
	Actions_length,	epsilon_decay,	...
	EDI,			1);

elapsed = toc;
Env.Plot_gridworld_actions		(ofp_policy, "Off-Policy");
Env.Plot_gridworld_State_Values	(ofp_Q_val,  "Off-Policy");
Env.simulate					(10, ofp_policy, 0.5);
fprintf('Elapsed time of Off-Policy: %.4f seconds\n\n', elapsed);






% Advanced on policy
pause(0.01)
epsilon			= 0.01;
gamma			= 1;
num_episodes	= 10000;
epsilon_decay	= 1;
EDI				= 1000;
Aonp_policy		= [];
Aonp_AveRet		= zeros(num_episodes, 1);

disp("Advanced On-Policy: ");
tic;
for i=1:10
	epsilon			= 1 / 10 / i;
	[Aonp_policy, Aonp_Q_val, Aonp_AveRet_t] = on_policy_control(	...
		Env,			Aonp_policy,		...
		epsilon,		gamma,			...
		num_episodes, 	num_states,		...
		Actions_length,	epsilon_decay,	...
		EDI);
	Aonp_AveRet(num_episodes*(i-1)+1:num_episodes*(i), 1) = Aonp_AveRet_t;
end
elapsed = toc;
Env.Plot_gridworld_actions		(Aonp_policy, "Advanced On-Policy");
Env.Plot_gridworld_State_Values	(Aonp_Q_val,  "Advanced On-Policy");
Env.simulate					(10, Aonp_policy, 0.5);
fprintf('Elapsed time of Advanced On-Policy: %.4f seconds\n\n', elapsed);








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







