close all force
clear
clc


% load previously trained Network
disp("To train the Network again, please set the ""load_en"" to false.");
load_en			= true; 
if ~isfile("data.mat"), load_en=false; end


% % Initialization
% Possible location of the package
%               X, Y
Pack_poses = [	0, 0; 
				0, 4; 
				4, 1; 
				4, 3];

% Possible location of the Destination
%               X, Y
Dest_poses = [	0, 0; 
				0, 4; 
				4, 1; 
				4, 3];

% location of walls 
%				X1	Y1	X2	Y2	X2	Y2	X1	Y1
Walls      = [	0	3	1	3;	1	3	0	3;
				0	4	1	4;	1	4	0	4;
				2	4	3	4;	3	4	2	4;
				4	1	4	2;	4	2	4	1];
% not that each row indicate only one wall, between two adjecent squares
% it is possibe to declare the one way path using this mechanism, 
% adding [X3, Y3, X4, Y4] to the above matrix prevent the agent 
% from going from (X3, Y3) to (X4, Y4). 
% but the agent can goes from (X4, Y4) to (X3, Y3).

% Network Size
inp_size		= 500;
hid_size		= 128;
out_size		= 6;

%learnign Rate
alpha			= 0.00025;

% Discount factor
gamma			= 0.99;

% starting epsilon
epsilon			= 1;

% Epsilon decay interval
EDI				= 20;

% Epsilon decay factor
ED				= 0.999;

% Maaximum episode length
ep_len			= 1000;

% number of simulations per control algorithm 
simu_cnt = 3;

% Control Parameter
buf_size		= 50000;
batch_size		= 32;
upd_freq		= 100;
num_epochs		= 100;
Val_scens		= 8;



% creating foolders
base_dir		= ".." + filesep  + "..";
result_dir		= "results";
this_algorithm	= "deep-q-network";

res_dir			= fullfile(base_dir, result_dir);
dst_dir			= fullfile(base_dir, result_dir, this_algorithm);
dqn_dir			= fullfile(base_dir, result_dir, this_algorithm, "dqn");

if ~isfolder(res_dir),	mkdir(res_dir),	end
if ~isfolder(dst_dir),	mkdir(dst_dir),	end
if ~isfolder(dqn_dir),	mkdir(dqn_dir),	end



% Environment
Env = dqn_post_delivery_environment(Pack_poses, Dest_poses, Walls, gamma);
Net = Network(inp_size, hid_size, out_size, alpha);
Tar = Network(inp_size, hid_size, out_size, alpha);
Net.initiate();
Net.plot_net(dqn_dir);
Tar.initiate();


% DQN 
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
		dqn_control(	Env,			Net,			Tar,			...
						epsilon,		EDI,			ED,				...
						ep_len,			gamma,			buf_size,		...
						batch_size,		upd_freq,		num_epochs,	...
						Val_scens,  	DQN_AveRet, 	DQN_Val_AveRet, ...
						DQN_losses, 	DQN_Val_losses,	last_episode,	...
						step_cntr);
	
	net = Net.Net;
	save(	"data.mat",		"DQN_AveRet",		"DQN_Val_AveRet",	...
			"DQN_losses",	"DQN_Val_losses",	"last_episode",		...
			"step_cntr",	"net");
	clear net
else
	load ("data.mat")
	Net.Net = net;
	clear net; 
end


fprintf('\nTrainign Done.\n');
elapsed = toc;
[DQN_Qval, DQN_Pol] = Net.get_policy();
Sim_epsilon = 0;
Sim_max_len = 20;
Sim_sleep_t = 0.5;
Sim_start_p = [];
Env.Plot_gridworld_actions		(DQN_Pol,	"DQN",																dqn_dir);
Env.Plot_gridworld_State_Values	(DQN_Qval,	"DQN",																dqn_dir);
Env.simulate					(simu_cnt,	"DQN",	Net, Sim_epsilon, Sim_max_len, Sim_sleep_t, Sim_start_p,	dqn_dir);
fprintf('Elapsed time of DQN: %.4f seconds\n', elapsed);
fprintf("Results and Simulations are generated and saved at """ + strrep(dqn_dir, "\", "/") + """\n\n");




% comparison
window = 10;
DQN_AveRet_Ts		= movmean(DQN_AveRet,		window, 'Endpoints','fill');
DQN_AveRet_Vs		= movmean(DQN_Val_AveRet,	window, 'Endpoints','fill');
fig = figure; 
title("DQN Average Returns");
hold on;
plot(1:num_epochs, DQN_AveRet_Ts, 'LineWidth', 1);
plot(1:num_epochs, DQN_AveRet_Vs, 'LineWidth', 1);
plot([1 num_epochs], [0 0],	':k', 'LineWidth', 1);
plot([1 num_epochs], [20 20],	':k', 'LineWidth', 1);
ylim([-2000, 40])
legend('Training Average','Validation Average','Location','southeast')
exportgraphics(fig, fullfile(dqn_dir, "Ave_ret.jpg"), 'Resolution', 600);

