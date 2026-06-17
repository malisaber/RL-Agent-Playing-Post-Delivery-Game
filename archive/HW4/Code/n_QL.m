function [policy, Q_val, Returns_Ave] = n_QL	(	Env,			policy,			...
													epsilon,		gamma,			...
													alpha,			episode_len,	...
													steps,			num_episodes,	...
													num_states,		num_actions,	...
													epsilon_decay,	epsilon_decay_interval)


% initialization
if isempty(policy)
	policy		= zeros(num_states, num_actions);
	policy(:,1)	= 1;
end

Q_val			= zeros(num_states, num_actions);
Returns_Ave		= zeros(num_episodes, 1);
tmp				= 0:steps-1;
gamma_arr		= (gamma * ones(1,steps)) .^ tmp;

% loop on episodes
for episode = 1:num_episodes
	if mod(100*episode/num_episodes,1) == 0
		disp(floor(100*episode/num_episodes) + "%")
	end
	
	behaviour		= ones(num_states, num_actions) * epsilon / num_actions;
	behaviour		= behaviour + (1 - epsilon) .* policy;

	% generating the requence
	Env.restart();
	eps_cntr = 0;
	states  = zeros(1, episode_len+1);
	actions = zeros(1, episode_len);
	rewards = zeros(1, episode_len+steps);
	T = inf;
	rews = 0;
	
	while eps_cntr < episode_len
		if eps_cntr < T
			[this_states, this_actions, this_rewards, is_TC] = Env.generate_episode(behaviour, 1);
			rews = rews + this_rewards;
			states(eps_cntr+1)  = this_states(1);
			actions(eps_cntr+1) = this_actions;
			rewards(eps_cntr+1) = this_rewards;
			if is_TC 
				T = eps_cntr+1;
			end
		end
		
		tou = eps_cntr - steps + 1;
		if tou >= 0
			G = sum(gamma_arr .* rewards(tou+1:tou+steps));
			rho = 1;
			for i=tou+1:min(tou+steps-1, T-1)
				rho = rho * policy(states(i), actions(i)) / behaviour(states(i), actions(i));
			end
			if (tou + steps) < T
				G = G + (gamma ^ steps) * Q_val(states(tou + steps), actions(tou + steps));
			end
			Q_val(states(tou+1), actions(tou +1)) = Q_val(states(tou+1), actions(tou +1)) + alpha * rho * (G - Q_val(states(tou+1), actions(tou +1)));
			[~, A_star] = max(Q_val(states(tou+1), :));
			policy(states(tou+1), :)	  = 0;
			policy(states(tou+1), A_star) = 1;
		end
		
		eps_cntr = eps_cntr + 1;
		if tou == (T - 1)
			break;
		end
	end
	
	Returns_Ave(episode,1) = rews;
	
	if mod(episode, epsilon_decay_interval)
		epsilon = epsilon * epsilon_decay;
	end
end





end