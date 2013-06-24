	

%
%  This code is provided as a template for your cross-validation
%  computation.  Replace the variables "features", "labels" with your own
%  data.   
%  As well, you can replace the code in the "BUILD" and "EVALUATE" sections
%  to be useful with other types of Classifiers.
%

		%% CROSS VALIDATION 
		numFolds = 10;                      % how many cross-validation folds do you want - (default=10)
		numInstances = size(features,1);     % this is the total number of instances in our training set
		numFeatures = size(features,2);     % this is the total number of instances in our training set
        indices = crossvalind('Kfold',numInstances,numFolds)   % divide test set into 10 random subsets
		
        clear errors
        for i = 1:10
            % SEGMENT DATA INTO FOLDS
			disp(['fold: ' num2str(i)])           
			test = (indices == i) ;    % which points are in the test set
		    train = ~test;       % all points that are NOT in the test set
		
			% SCALE
			[trainingFeatures,mf,sf]=scale(features(train,:));
			
			% BUILD NEW MODEL - ADD YOUR MODEL BUILDING CODE HERE...
		    model = knn(numFeatures,2,3,trainingFeatures,labels(train,:));     

            % RESCALE TEST DATA TO TRAINING SCALE SPACE
			[testingFeatures]=rescale(features(test,:),mf,sf);
			
			% EVALUATE WITH TEST DATA - ADD YOUR MODEL EVALUATION CODE HERE
			[voting,model_output] = knnfwd(model ,testingFeatures);

            
			% EVALUATE WITH TEST DATA - ADD YOUR MODEL EVALUATION CODE HERE
		    [voting,model_output] = knnfwd(model ,features(test,:));
		
            % CONVERT labels(test,:) LABELS TO SAME FORMAT TO COMPUTE ERROR 
            labels_test = zeros(size(model_output,1),1); % create array of 0s
            labels_test(find(labels(test,1)==1))=1;  % convert column 1 to class 1 
            labels_test(find(labels(test,2)==1))=2;  % convert column 2 to class 2 

			%  COUNT ERRORS 
            errors(i) = mean ( model_output ~= labels_test  )
            
        end
		disp(['cross validation error: '  num2str(mean(errors))])
		disp(['cross validation accuracy: ' num2str(1-mean(errors))])

