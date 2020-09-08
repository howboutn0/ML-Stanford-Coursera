function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));
				 %size: hidden_layer_size x input_layer_size + 1

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
				 %size: num_labels x hidden_layer_size + 1
				 


% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
X = [ones(m, 1) X];
a1 = X;
z2 = a1 * Theta1';
a2 = sigmoid(z2);
a2 = [ones(size(a2, 1), 1) a2];
z3 = a2 * Theta2';
a3 = sigmoid(z3);
h_x = a3;

y_Vec = zeros(m, num_labels);
for i = 1:m,
	y_Vec(i, y(i)) = 1;
end

J = (1/m) * sum(sum(-y_Vec .* log(h_x) - ((1-y_Vec) .* log(1-h_x))));

%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%

for t = 1:m,
A1 = X(t, :); %X already has a bias. this line just extracts the t-th training example
A1 = A1'; %A1 is now a 401 x 1 column vector
Z2 = Theta1 * A1; %theta1 is a 25x401 vector. (25x401) (401x1) makes (25x1)
A2 = sigmoid(Z2)

A2 = [1 ; A2]; %add a bias to the 2nd layer
Z3 = Theta2 * A2; % (10x26) * (26x1) makes (10x1) column vector
A3 = sigmoid(Z3);

%y_new = y_Vec'; %y_new: each column is 1 set of results. (10 x 5000)
y_new = (1:num_labels)'==y(t);

DELTA3 = A3 - y_new; %extra the t-th column of y_new. ex: for t=1, get a column vector of results for the 1st training image
DELTA2 = (Theta2' * DELTA3) .* [1; sigmoidGradient(Z2)];
DELTA2 = DELTA2(2:end); %skip bias
Theta2_grad = Theta2_grad + DELTA3*A2';
Theta1_grad = Theta1_grad + DELTA2*A1';

end;

Theta2_grad = 1/m * Theta2_grad;
Theta1_grad = 1/m * Theta1_grad;

% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% -------------------------------------------------------------

% =========================================================================
% Theta1_grad(:, 1) = Theta1_grad(:, 1) ./ m; % for j = 0
% 

reg_term = (lambda/(2*m)) * (sum(sum(Theta1(:,2:end).^2)) + sum(sum(Theta2(:,2:end).^2))); %scalar
  
  %Costfunction With regularization
  J = J + reg_term; %scalar
  
  %Calculating gradients for the regularization
  Theta1_grad_reg_term = (lambda/m) * [zeros(size(Theta1, 1), 1) Theta1(:,2:end)]; % 25 x 401
  Theta2_grad_reg_term = (lambda/m) * [zeros(size(Theta2, 1), 1) Theta2(:,2:end)]; % 10 x 26
  
  %Adding regularization term to earlier calculated Theta_grad
  Theta1_grad = Theta1_grad + Theta1_grad_reg_term;
  Theta2_grad = Theta2_grad + Theta2_grad_reg_term;

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
