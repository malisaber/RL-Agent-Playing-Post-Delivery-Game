function [policy, Q_val, Returns_Ave] = off_policy_control(	Env,			policy,			...
													epsilon,		gamma,			...
													num_episodes,	num_states,		...
													num_actions,	epsilon_decay,	...
													eps_dec_iVal,	verbose_policy)
% initialization
if isempty(policy)
	policy		= ones (num_states, 1);
end
Q_val   		= zeros(num_states, num_actions);
C_val			= zeros(num_states, num_actions);
behavior_policy	= zeros(num_states, num_actions);
Returns_Ave		= zeros(num_episodes, 1);

% loop on episodes
for episode = 1:num_episodes
	if mod(100*episode/num_episodes,1) == 0
		disp(floor(100*episode/num_episodes) + "%")
	end

	for i=1:num_states
		behavior_policy(i,:)			= epsilon / num_actions;
		behavior_policy(i, policy(i))	= behavior_policy(i, policy(i)) + 1 - epsilon;
	end
	
	% generating the requence
	Env.restart();
	[states, actions, rewards] = Env.generate_episode(behavior_policy);
	
	G = 0;
	W = 1;
	for t = length(actions):-1:1
		G = gamma * G + rewards(t);
		C_val(states(t), actions(t)) = C_val(states(t), actions(t)) + W;
		Q_val(states(t), actions(t)) = Q_val(states(t), actions(t)) + ...
			W / C_val(states(t), actions(t)) * (G - Q_val(states(t), actions(t)));

		[~, A_star] = max(Q_val(states(t), :));
		policy(states(t),1) = A_star;
		if actions(t) ~= A_star
			break;
		end
		W = W / behavior_policy(states(t), actions(t));
	end
	
	Returns_Ave(episode,1) = G;
	
	if mod(episode, eps_dec_iVal)
		epsilon = epsilon * epsilon_decay;
	end
end


if verbose_policy ~= 0
	tmp_policy = zeros(num_states, num_actions);
	for i=1:num_states
		tmp_policy(i, policy(i)) = 1;
	end
	policy = tmp_policy;
end


end
