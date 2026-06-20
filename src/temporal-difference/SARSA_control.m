function [policy, Q_val, Returns_Ave] = SARSA_control	(	Env,			policy,			...
															epsilon,		gamma,			...
															alpha,			episode_len,	...
															num_episodes,	num_states,		...
															num_actions,	epsilon_decay,	...
															epsilon_decay_interval)


% initialization
if isempty(policy)
	policy		= ones(num_states, num_actions) * epsilon / num_actions;
	policy(:,1)	= policy(:,1) + 1 - epsilon;
end
Q_val			= zeros(num_states, num_actions);
Returns_Ave		= zeros(num_episodes, 1);


% loop on episodes
a = fprintf('Progress: %d%%', 0);
for episode = 1:num_episodes
	if mod(100*episode/num_episodes,1) == 0
		fprintf(repmat('\b',1,a)); % erase previous text
		a = fprintf('Progress: %d%%', floor(100*episode/num_episodes));
	end
	

	% generating the requence
	Env.restart();
	[this_states, this_actions, this_rewards, is_TC] = Env.generate_episode(policy, 1);
	eps_cntr = 0;
	rews = this_rewards;
	
	if is_TC
		Q_val(this_states(1), this_actions) = Q_val(this_states(1), this_actions) +  alpha * ( ...
			this_rewards - Q_val(this_states(1), this_actions));
	end
	
	while (eps_cntr < episode_len) && (~is_TC)
		eps_cntr = eps_cntr + 1;
		[next_states, next_actions, next_rewards, is_TC] = Env.generate_episode(policy, 1);
		
		Q_val(this_states(1), this_actions) = Q_val(this_states(1), this_actions) +  alpha * ( ...
			this_rewards + ...
			gamma * Q_val(next_states(1), next_actions) - ...
			Q_val(this_states(1), this_actions));
		
		[~, A_star] = max(Q_val(this_states(1), :));
		policy(this_states(1), :)	  =  epsilon / num_actions;
		policy(this_states(1), A_star) = policy(this_states(1), A_star) + 1 - epsilon;
	
		this_states		= next_states;
		this_actions	= next_actions;
		this_rewards	= next_rewards;
		rews = rews		+ this_rewards;
	end
	
	
	Returns_Ave(episode,1) = rews;
	
	if mod(episode, epsilon_decay_interval)
		epsilon = epsilon * epsilon_decay;
	end
end





end