close all force
clear
clc

% Deep Q-Network control experiment

script_dir = fileparts(mfilename('fullpath'));
project_root = fileparts(script_dir);
addpath(genpath(project_root));
old_dir = pwd;
cleanup_dir = onCleanup(@() cd(old_dir));
cd(script_dir);

load_en			= true; 


% % Initialization
Pack_poses = [0, 0; 0, 4; 4, 1; 4, 3];
Dest_poses = [0, 0; 0, 4; 4, 1; 4, 3];
Walls      = [	0 3 1 3; 1 3 0 3;
				0 4 1 4; 1 4 0 4;
				2 4 3 4; 3 4 2 4;
				4 1 4 2; 4 2 4 1];

inp_size		= 500;
hid_size		= 128;
out_size		= 6;
alpha			= 0.00025;
gamma			= 0.99;
epsilon			= 1;
EDI				= 20;
ED				= 0.999;
ep_len			= 100;
buf_size		= 50000;
batch_size		= 32;
upd_freq		= 100;
num_episodes	= 10000;
Val_scens		= 8;



% Task 1, Environment
Env = PostDeliveryDqnEnv(Pack_poses, Dest_poses, Walls, gamma);
Net = DqnNetwork(inp_size, hid_size, out_size, alpha);
Tar = DqnNetwork(inp_size, hid_size, out_size, alpha);
Net.initiate();
Net.plot_net();
Tar.initiate();


% DQN training
DQN_AveRet		= [];
DQN_Val_AveRet	= [];
DQN_losses		= [];
DQN_Val_losses	= [];
last_episode	= 0;
step_cntr		= 0;


disp("DQN: ");
tic;
if ~load_en
	[DQN_AveRet, DQN_Val_AveRet, DQN_losses, DQN_Val_losses, last_episode, step_cntr] = ...
		train_dqn(	Env,			Net,			Tar,			...
				epsilon,		EDI,			ED,				...
				ep_len,			gamma,			buf_size,		...
				batch_size,		upd_freq,		num_episodes,	...
				Val_scens,  	DQN_AveRet, 	DQN_Val_AveRet, ...
				DQN_losses, 	DQN_Val_losses,	last_episode,	...
				step_cntr);
	
	net = Net.Net;
	save(	"data.mat",		"DQN_AveRet",		"DQN_Val_AveRet",	...
			"DQN_losses",	"DQN_Val_losses",	"last_episode",		...
			"step_cntr",	"net");
	clear net
else
	load ("data_backup.mat")
	Net.Net = net;
	clear net; 
end


elapsed = toc;
	fprintf('Elapsed time of DQN: %.4f seconds\n\n', elapsed);
[DQN_Qval, DQN_Pol] = Net.get_policy();
Env.Plot_gridworld_actions		(DQN_Pol,	"DQN");
Env.Plot_gridworld_State_Values	(DQN_Qval,	"DQN");
Env.simulate					(3, Net, 0, 20, 0.5, [0, 4, 4, 1]);




% comparison
window = 100;
DQN_AveRet_Ts		= movmean(DQN_AveRet,		window, 'Endpoints','fill');
DQN_AveRet_Vs		= movmean(DQN_Val_AveRet,	window, 'Endpoints','fill');
figure; 
title("DQN Average Returns");
hold on;
plot(1:num_episodes, DQN_AveRet_Ts, 'LineWidth', 1);
plot(1:num_episodes, DQN_AveRet_Vs, 'LineWidth', 1);
plot([0 num_episodes], [0 0],	':k', 'LineWidth', 1);
plot([0 num_episodes], [20 20],	':k', 'LineWidth', 1);
ylim([-600, 40])
legend('Training Average','Validation Average','Location','southeast')






