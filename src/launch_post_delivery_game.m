function launch_post_delivery_game(choice)

clc;
project_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(project_root));

if nargin < 1
	fprintf("Post-Delivery Game launcher\n");
	fprintf("  1) Monte Carlo control\n");
	fprintf("  2) Temporal-Difference control\n");
	fprintf("  3) Deep Q-Network control\n");
	fprintf("  0) Exit\n");
	choice = input("Select an experiment: ");
end

switch choice
	case 1
		run(fullfile(project_root, "src", "monte-carlo", "run_monte_carlo_control.m"));
	case 2
		run(fullfile(project_root, "src", "temporal-difference", "run_td_control.m"));
	case 3
		run(fullfile(project_root, "src", "deep-q-network", "run_dqn_control.m"));
	case 0
		return;
	otherwise
		error("Unknown launcher choice. Use 0, 1, 2, or 3.");
end

launch_post_delivery_game;
end
