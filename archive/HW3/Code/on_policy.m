function [policy, Q_val, Returns_Ave] = on_policy(	Env,			policy,			...
													epsilon,		gamma,			...
													num_episodes,	num_states,		...
													num_actions,	epsilon_decay,	...
													epsilon_decay_interval)

% initialization
if isempty(policy)
	policy		= ones(num_states, num_actions) * epsilon / num_actions;
	policy(:,1)	= policy(:,1) + 1 - epsilon;
end
Q_val			= zeros(num_states, num_actions);
Returns			= zeros(num_states, num_actions);
Action_taken	= zeros(num_states, num_actions);
Returns_Ave		= zeros(num_episodes, 1);

% loop on episodes
for episode = 1:num_episodes
	if mod(100*episode/num_episodes,1) == 0
		disp(floor(100*episode/num_episodes) + "%")
	end

	% generating the requence
	Env.restart();
	[states, actions, rewards] = Env.generate_episode(policy);
	
	visit_hist = zeros(num_states, num_actions, length(actions)+1);
	for i=1:length(actions)
		visit_hist(states(i), actions(i), (i+1):end) = 1;
	end

	G = 0;
	for t = length(actions):-1:1
		G = gamma * G + rewards(t);
		if visit_hist(states(t), actions(t), t) == 0
			Returns(states(t), actions(t)) = Returns(states(t), actions(t)) + G;
			Action_taken(states(t), actions(t)) = Action_taken(states(t), actions(t)) + 1;
			Q_val(states(t), actions(t)) = Returns(states(t), actions(t)) / Action_taken(states(t), actions(t));
			[~, A_star] = max(Q_val(states(t), :));
			policy(states(t), :)	  =  epsilon / num_actions;
			policy(states(t), A_star) = policy(states(t), A_star) + 1 - epsilon;
		end
	end
	
	Returns_Ave(episode,1) = G;
	
	if mod(episode, epsilon_decay_interval)
		epsilon = epsilon * epsilon_decay;
	end
end

end