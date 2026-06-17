function [	Returns_Ave,	Val_Returns_Ave,	losses,				...
			val_losses,		last_episode,		step_cntr] =		...
	DQN(	Env,			Net,				Tar,				...
			epsilon,		EDI,				ED,					...
			episode_len,	gamma,				buf_size,			...
			batch_size,		update_freq,		num_episodes,		...
			Val_scen_cnt,   Returns_Ave, 		Val_Returns_Ave,	...
			losses,			val_losses,			last_episode,		...
			step_cntr)



% initialization
if last_episode == 0
	Returns_Ave		= zeros(num_episodes, 1);
	losses			= zeros(num_episodes, 1);
	Val_Returns_Ave	= zeros(num_episodes, 1);
	val_losses		= zeros(num_episodes, 1);
else
	Net.en_monitor();
	for i=1:last_episode
		epsilon = epsilon * ED;
		Net.progress_monitor(losses(i), val_losses(i), Returns_Ave(i),...
				Val_Returns_Ave(i), i, epsilon, num_episodes, step_cntr);
	end
end
Buf					= zeros(buf_size+100, 5);
ilen				= Net.get_inp_len();

disp("filling the buffer ...");
cntr = 0;
while true
	Env.restart();
	[this_states, this_actions, this_rewards, is_TC] = ...
		Env.generate_episode(Tar, epsilon, max(floor(batch_size/8),4));
	for i=1:(size(this_states, 2)-1)
		cntr = cntr + 1;
		Buf(cntr,1) = this_states(i);
		Buf(cntr,2) = this_actions(i);
		Buf(cntr,3) = this_rewards(i);
		Buf(cntr,4) = this_states(i+1);
		Buf(cntr,5) = 0;
	end
	Buf(cntr,5) = is_TC;
	if(cntr >= buf_size)
		break;
	end
end
Buf = Buf(1:buf_size, :);
disp("done");


% loop on episodes
disp(" ")
disp("Start Training ...");
disp("Progress: ")
fprintf("\tEpisode: ");
Net.en_monitor();
pause(0.5)
insert_cntr	= 0;
BSC			= 0;
loss		= 0;
for episode = (last_episode+1):num_episodes 
	for i=1:BSC
		fprintf("\b");
	end
	s = num2str(episode) + " / " +...
		num2str(num_episodes) +	"    Loss: " + ...
		num2str(loss);
	fprintf(s);
	BSC = size(char(s), 2);

	% generating the requence
	Env.restart();
	state_cntr	= 0;
	loss		= 0;
	rews		= 0;
	is_TC		= false;

	while (state_cntr < episode_len) && (~is_TC)  && ~Net.monitor.Stop
		[this_states, this_actions, this_rewards, is_TC] = ...
			Env.generate_episode(Net, epsilon, 1);
		step_cntr	= step_cntr + 1;
		state_cntr	= state_cntr + 1;
		rews		= rews		+ this_rewards;
		insert_cntr	= insert_cntr + 1;
		if insert_cntr > buf_size
			insert_cntr	= 1;
		end
		Buf(insert_cntr,1)	= this_states (1);
		Buf(insert_cntr,2)	= this_actions;
		Buf(insert_cntr,3)	= this_rewards;
		Buf(insert_cntr,4)	= this_states (2);
		Buf(insert_cntr,5)	= is_TC;
		
		
		batch_idx	= randperm(buf_size,	batch_size);
		data_fram	= Buf(batch_idx, :);
		Pres_state	= zeros(ilen, batch_size);
		Next_state	= zeros(ilen, batch_size);
		for i=1:batch_size
			Pres_state(data_fram(i,1)+1, i) = 1;
			Next_state(data_fram(i,4)+1, i) = 1;
		end
		Tar_NQVs = Tar.predict(Next_state);
		Tar_Qval = data_fram(:, 3)' + ...
			gamma * max(Tar_NQVs) .* (1-data_fram(:, 5)');
		stp_loss =  Net.Train(Pres_state, Tar_Qval, data_fram(:, 2), step_cntr);
		loss = loss + stp_loss;
		
		if mod(step_cntr, update_freq) == 0
			Tar.initiate(Net.extract());
		end
	end
	
	%	Validating
	val_ave_ret	= 0;
	val_loss	= 0;
	val_lngs	= 0;
	for val_cntr = 1:Val_scen_cnt
		Env.restart();
		[sx, sy, pp, dp] = Env.extract_point_info();
		[Net_states, Net_actions, Net_rewards, Net_isdone] = ...
			Env.generate_episode(Net, 0, episode_len);
		Env.define_start_point(sx, sy, pp, dp);
		[Tar_states, Tar_actions, ~,		   Tar_isdone] = ...
			Env.generate_episode(Tar, 0, episode_len);
		val_ave_ret = val_ave_ret + sum(Net_rewards);
		
		min_isx		= min(size(Net_actions, 2), size(Tar_actions, 2));
		Net_state	= zeros(ilen, min_isx);
		Tar_state	= zeros(ilen, min_isx);
		for i=1:min_isx
			Net_state(Net_states(i)+1, i) = 1;
			Tar_state(Tar_states(i)+1, i) = 1;
		end
		Net_NQV	= max(Net.predict(Next_state));
		Tar_NQV	= max(Tar.predict(Next_state));
		TVL		= mse(Net_NQV, Tar_NQV);
		val_loss= val_loss + Tar_isdone*(1 - Net_isdone)*20 + ...
			(extractdata(TVL) / min_isx);
		val_lngs = val_lngs + min_isx;
	end
	val_ave_ret = val_ave_ret	/ Val_scen_cnt;
	val_loss	= val_loss		/ Val_scen_cnt;
	val_lngs	= val_lngs		/ Val_scen_cnt;
	
	
	loss						= loss/state_cntr;
	Returns_Ave(episode,1)		= rews;
	losses(episode,1)			= extractdata(loss);
	Val_Returns_Ave(episode,1)	= val_ave_ret;
	val_losses(episode,1)		= val_loss;
	
	Net.progress_monitor(extractdata(loss), val_loss, rews,...
				val_ave_ret, episode, epsilon, num_episodes, step_cntr, val_lngs);
	
	epsilon = epsilon * ED;
	if  Net.monitor.Stop
		break;
	end
	
	if mod(episode, 1000) == 0
		net = Net.Net;
		name = "Backup/data_back_" + num2str(episode) + ".mat";
		save(name,	"Returns_Ave",	"Val_Returns_Ave",	"losses",	...
					"val_losses",	"episode",			"step_cntr",...
					"net");
	end
end


last_episode = episode;
disp(" ")
end




