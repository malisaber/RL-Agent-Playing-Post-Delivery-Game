function [policy, Q_val, Returns_Ave] = Q_Learning	(	Env,			policy,			...
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
for episode = 1:num_episodes
	if mod(100*episode/num_episodes,1) == 0
		disp(floor(100*episode/num_episodes) + "%")
	end

	% generating the requence
	Env.restart();
	eps_cntr = 0;
	rews = 0;
	is_TC = false;

	while (eps_cntr < episode_len) && (~is_TC)
		[this_states, this_actions, this_rewards, is_TC] = Env.generate_episode(policy, 1);
		eps_cntr = eps_cntr + 1;
		rews = rews		+ this_rewards;

		if ~is_TC
			Q_val(this_states(1), this_actions) = Q_val(this_states(1), this_actions) +  alpha * ( ...
				this_rewards + ...
				gamma * max(Q_val(this_states(2), :)) - ...
				Q_val(this_states(1), this_actions));
		else
			Q_val(this_states(1), this_actions) = Q_val(this_states(1), this_actions) +  alpha * ( ...
				this_rewards - ...
				Q_val(this_states(1), this_actions));
		end

		[~, A_star] = max(Q_val(this_states(1), :));
		policy(this_states(1), :)	  =  epsilon / num_actions;
		policy(this_states(1), A_star) = policy(this_states(1), A_star) + 1 - epsilon;
	end

	Returns_Ave(episode,1) = rews;

	if mod(episode, epsilon_decay_interval)
		epsilon = epsilon * epsilon_decay;
	end
end





end