ccrma
=====

Supplementary files for the CCRMA Workshop on Music Information Retrieval at Stanford University.

In your home directory, simply type to following to obtain a copy of the repository:

    git clone https://github.com/stevetjoa/ccrma.git

To receive updates to the repository, from your newly created `ccrma` repository directory:

    git pull


Lab 1 
=====

**Basic Feature Extraction and Classification**

Purpose: Introduce you to the practice of analyzing, segmenting, feature extracting, and applying basic classifications to audio files.  Our future labs will build upon this essential work - but will use more sophisticated training sets, features, and classifiers. 

We'll first need to setup some additional Matlab folders, toolboxes, and scripts that we'll use later. 

Directory
---------

Course related code, toolboxes, and audio are stored at: 

    /usr/ccrma/courses/mir2013
 
A large collection of audio files for your experimentation are located at  

    /usr/ccrma/courses/mir2013/audio

Matlab Setup
------------

1.  Launch Matlab
2.  Configure your Path:  Add the folder `/usr/ccrma/courses/mir2013/Toolboxes` to your local Matlab path (including all subfolders).
3.  Set the "Java Heap Memory" to 900 MB via : File > Preferences > General > Java Heap Memory.
    This allows us to load large audio files and feature vectors into memory.  Click on "OK". Click Apply.
4.  Restart Matlab.

Why are the Paste / Save keys different?   Why does Paste default to Control-Y?  
On Linux, Matlab defaults to using Emacs key bindings.  If you want Mac or Windows bindings, go: File menu > Preferences > Keyboard
Switch the Editor/Debugger key bindings to "Windows".

You can easily comment and uncomment code by hitting Cntr-R,  Cntrl-T. 

To read MP3 files into Matlab, we have a function called `mp3read`.  It is used just like `wavread`. 

 
Section 1: Segmentation and Zero-Crossing Rate
----------------------------------------------

Purpose: We'll experiment with the different features for known frames and see if we can build a basic understanding of what they are doing.  
  
1.  Make sure to save all of your development code in an .m file.  You can build upon and reuse much of this code over the workshop.  To create a new .m file, choose:
    * File > New > Script...
    * Save the file as Lab1.m

    You can execute the code in `Lab1.m` via any of the below options:
    * Type Lab1.m in the command window
    * press F5 in the Editor to execute the current selected script.
    * You can execute 1 or more commands selected in the Editor window at a time.  Select the code and press F9.  Note the Command Window will update. 

2.  Tab Completion. 

    Tab Completion works in Command Window and the Editor.
    After you type a few letters, hit the Tab key and a popup will appear and show you all of the possible completions, including variable names and functions.
    This prevents you to mistyping the names of variables - a big time (and aggravation) saver! 
     
    For example, in the Command Line or Editor , try typing `wavr`  and then hitting Tab!    ("wavread" should appear)

3.  Load the audio file simpleLoop.wav into Matlab, storing it in the variable x and sampling rate in fs. 

        [x,fs] = wavread('/usr/ccrma/courses/mir2013/audio/simpleLoop.wav');

4.  In this course, we will convert all stereo files to mono.  
    Include this code after your read in WAV files to automatically detect if a file is stereo and convert it to mono.

        % MAKING MONO
        % If your audio files (x) are stereo, here's how to make them mono:
        if size(x,2) == 2
            x= (x(:,1)+x(:,2) ) ./ max(abs(x(:,1)+x(:,2))) ;
            disp('Making your file mono…');
        end

5.  You can play the audio file by typing using typing

        sound(x,fs)

    To stop listening to a long audio file, press Control-C.    Audio snippets less than ~8000 samples will often not play out Matlab.  (known bug on Linux machines)

6.  Run an onset detector to determine the approximate onsets in the audio file. 

        [onsets] = onset_times(x,fs);  % leighs onset detector with signal and  sample_rate as input
        onsets=round(fs*onsets);    % convert onset times in seconds to to samples - round to nearest integer sample
        numonsets = length(onsets);

    For debugging, we have function which generates mixes of the original audio file and onset times.  This is demonstrated with `test_onsets.m`.

    One of Matlab's greatest features is its rich and easy visualization functions.  Visualizing your data at every possible step in the algorithm development process not only builds a practical understanding of the variables, parameters and results, but it greatly aids debugging. 
      
8.  Plot the audio file in a figure window. 

        plot(x)

9.  Now, add a marker showing the position of each onset on top of the waveforms. 

        plot(x); hold on; plot(onsets,0.2,'rx')

10.   Adding text markers to your plots can further aid in debugging or visualizing problems.  Label each onset with it's respective onset number with the following simple loop:

        for i=1:numonsets
            text(onsets(i),0.2,num2str(i));  % num2st converts an number to a string for display purposes
        end

    Labeling the data is crucial.   Add a title and axis to the figures.  (ylabel, xlabel, title.)

        xlabel('seconds')
        ylabel('magnitude')
        title('my onset plot')

11. Now that we can view the various onsets, try out the onset detector and visualization on a variety of other audio examples located in `/usr/ccrma/courses/mir2013/audio`.   Continue to load the various audio files and run the onset detector - does it seem like it works well?    If not, yell at Leigh.

    Segmenting audio in Frames
    As we learned in lecture, it's common to chop up the audio into fixed-frames.  These frames are then further analyzed, processed, or feature extracted.  We're going to analyze the audio in 100 ms frames starting at each onset. 

12. Create a loop which carves up the audio in fixed-size frames (100ms), starting at the onsets.

13. Inside of your loop, plot each frame, and play the audio for each frame. 

        % Loop to carve up audio into onset-based frames
        frameSize = 0.100 *fs;        % sec
        for i=1:numonsets
            frames{i}= x(onsets(i):onsets(i)+frameSize);
            figure(1);
            plot(frames{i}); title(['frame ' num2str(i)]);   
            sound(frames{i}  ,fs);
            pause(0.5)
        end
         
    Feature extract your frames

14. Create a loop which extracts the Zero Crossing Rate for each frame, and stores it in an array.   Your loop will select 100ms (in samples, this value is =  fs * 0.1) , starting at the onsets, and obtain the number of zero crossings in that frame. 

    The command  `[z] = zcr(x)`  returns the number of zero crossings for a vector x.
    Don't forget to store the value of z in a feature array for each frame.

        clear features
        % Extract Zero Crossing Rate from all frames and store it in "features(i,1)"
        for i=1:numonsets
            features(i,1) = zcr(frames{i})
        end
            
    For simpleLoop.wav, you should now have a feature array of 5 x 1 - which is the 5 frames (one at each detected onset) and 1 feature (zcr) for each frame. 
             
    Sort the audio file by its feature array. 
    Let's test out how well our features characterize the underlying audio signal. 
    To build intuition, we're going to sort the feature vector by it's zero crossing rate, from low value to highest value. 

15. If we sort and re-play the audio that corresponds with these sorted frames, what do you think it will sound like?  (e.g., same order as the loop, reverse order of the loop, snares followed by kicks, quiet notes followed by loud notes, or ??? )   Pause and think about this. 

16. Now, we're going to play these sorted audio frames, from lowest to highest.  (The pause command will be quite useful here, too.)  How does it sound?  Does it sort them how you expect them to be sorted? 

        [y,index] = sort(features);

        for i=1:numonsets
            sound(frames{index(i)},fs)
            figure(1); plot(frames{index(i)});title(i);
            pause(0.5)
        end

    You'll notice how trivial this drum loop is - always use familiar and predictable audio files when you're developing your algorithms. 

17. Now that you have this file loading, playing , and sorting working, try this with out files, such as:

        /usr/ccrma/courses/mir2013/audio/CongaGroove-mono.wav
        /usr/ccrma/courses/mir2013/audio/125BOUNC-mono.WAV


Section 2: Spectral Features & k-NN
------------------------------------

My first audio classifier: introducing K-NN!  We can now appreciate why we need additional intelligence in our systems - heuristics can't very far in the world of complex audio signals.  We'll be using Netlab's implementation of the k-NN for our work here.  It proves be a straight-forward and easy to use implementation.  The steps and skills of working with one classifier will scale nicely to working with other, more complex classifiers. 

We're also going to be using the new features in our arsenal: cherishing those "spectral moments" (centroid, bandwidth, skewness, kurtosis) and also examining other spectral statistics. 
 
### TRAINING DATA

First off, we want to analyze and feature extract a small collection of audio samples - storing their feature data as our "training data".  The below commands read all of the .wav files in a directory into a structure, snareFileList.  

1.  Use these commands to read in a list of filenames (samples) in a directory, replacing the path with the actual directory that the audio \ drum samples are stored in.

        snareDirectory = ['/usr/ccrma/courses/mir2013/audio/drum samples/snares/'];
        snareFileList = getFileNames(snareDirectory ,'wav')

        kickDirectory = ['/usr/ccrma/courses/mir2013/audio/drum samples/kicks/'];
        kickFileList = getFileNames(kickDirectory ,'wav')

2.  To access the filenames contained in the cell array, use the brackets { }  to get to the element that you want to access. 

    For example, to access the text file name of the 1st file in the list, you would type:

        snareFileList{1}

    When we feature extract a sample collection, we need to sequentially access audio files, segment them (or not), and feature extract them.  Loading a lot of audio files into memory is not always a feasible or desirable operation, so you will create a loop which loads an audio file, feature extracts it, and closes  the audio file.  Note that the only information that we retain in memory are the features that are extracted.

3.  Create a loop which reads in an audio file, extracts the zero crossing rate, and some spectral statistics.  The feature information for each audio file (the "feature vector") should be stored as a feature array, with columns being the features and rows for each file. 
 
    Or in Matlab, for example:

        featuresSnare =

            1.0e+003 *
             
             0.5730    1.9183    2.9713    0.0004 0.0002
             0.4750    1.4834    2.4463    0.0004  0.0012
             0.5900    2.2857    3.1788    0.0003  0.0041
             0.5090    1.6622    2.6369    0.0004  0.0051
             0.4860    1.4758    2.2085    0.0004  0.0021
             0.6060    2.2119    3.2798    0.0004  0.0651
             0.4990    2.0607    2.7654    0.0004  0.0721
             0.6360    2.3153    3.0256    0.0003  0.0221
             0.5490    2.0137    3.0342    0.0004  0.0016
             0.5900    2.2857    3.1788    0.0003  0.0012
 
    In your loop, here's how to read in your wav files, using a structure of file names:
      [x,fs]=wavread([snareDirectory snareFileList{i}]);     %note the use of brackets for snareFileList
       
    Here's an example of how to feature extract for the current audio file..
    frameSize = 0.100 * fs;   % 100ms
    currentFrame = x(1:frameSize)
    featuresSnare(i,1)   = zcr(currentFrame);
    [centroid, bandwidth, skew, kurtosis]=spectralMoments(currentFrame,fs,8192)
               featuresSnare(i,2:5) = [centroid, bandwidth, skew, kurtosis];
                    
4.  First, extract all of the feature data for the kick drums and store it in a feature array.  (For my example, above, I'd put it in "featuresKick")

5.  Next, extract all of the feature data for the snares, storing them in a different array. 
Again, the kick and snare features should be separated in two different arrays!
 
    OK, no more help.  The rest is up to you! 

### Building Models

1.  Examine the feature array for the various snare samples.  What do you notice? 

2.  Since the features are different scales, we will want to normalize each feature vector to a common range - storing the scaling coefficients for later use.  Many techniques exist for scaling your features.  We'll use linear scaling, which forces the features into the range -1 to 1.

    For this, we'll use a custom-created function called scale.  Scale returns an array of scaled values, as well as the multiplication and subtraction values which were used to conform each column into -1 to 1.  Use this function in your code. 
     
        [trainingFeatures,mf,sf]=scale([featuresSnare; featuresKick]);

3.  Build a k-NN model for the snare drums in Netlab, using the function knn. 

    We'll the implementation of from the Matlab toolbox "netlab":

        >help knn
        NET = KNN(NIN, NOUT, K, TR_IN, TR_TARGETS) creates a KNN model NET
        with input dimension NIN, output dimension NOUT and K neighbours.
        The training data is also stored in the data structure and the
        targets are assumed to be using a 1-of-N coding.

    The fields in NET are

        type = 'knn'
        nin = number of inputs
        nout = number of outputs
        tr_in = training input data
        tr_targets = training target data

    Here's an example...
     
        labels=[[ones(10,1) zeros(10,1)]; [zeros(10,1) ones(10,1) ]];

    Which is an array of ones and zeros to correspond to the 10 snares and 10 kicks in our training sample set:

        labels=
            1     0
            1     0
            1     0
            1     0
            1     0
            1     0
            1     0
            1     0
            1     0
            1     0
            0     1
            0     1
            0     1
            0     1
            0     1
            0     1
            0     1
            0     1
            0     1
            0     1
                           
        [trainingFeatures,mf,sf]=scale([featuresSnare; featuresKick]);

        model_snare = knn(5,2,1,trainingFeatures,labels);        
         
    This k-NN model uses 5 features,  2 classes for output (the label), uses k-NN = 1, and takes in the feature data via a feature array called trainingFeatures.

    These labels indicate which sample in our feature data is a snare, vs. a non-snare.  The k-NN model uses this information to build a means of comparison and classification.  It is really important that you get these labels correct - because they are the crux of all future classifications that are made later on.  (Trust me, I've made many mistakes in this area - training models with incorrect label data.)

4.  Create a script which extracts features for a single file, re-scales its feature values, and evaluates them with your kNN classifier. 

Evaluating samples with your k-NN
Now that the hard part is done, it's time to throw some feature data through the trained k-NN and see what it outputs. 
 
RESCALING.
In evaluating a new audio file, we need to extract it's features, re-scale them to the same range as the trained feature values, and then send them through the knn.

Some helpful commands:
featuresScaled = rescale(features,mf,sf) ;   % This uses the previous calculated linear scaling parameters to adjust the incoming features to the same range.  

EVALUTING WITH KNN

    [voting,model_output]=knnfwd(model_snare , featuresScaled )

The  output voting gives you a breakdown of how many nearest neighbors were closest to the test feature vector.  
 
The `model_output` provides a list of whether output is Class 1 or Class 2.

    output = zeros(size(model_output),2)
    output(find(model_output==1),1)=1
    output(find(model_output==2),2)=1

Now you can visually compare the output to trainlabels
 
Once you have completed function, first, test it with your training examples.  Since a k-NN model has exact representations of the training data, it will have 100% training accuracy - meaning that every training example should be predicted correctly, when fed back into the trained model. 

Now, test out with the examples in the folder "test kicks" and "test snares", located in the drum samples folder.  These are real-world testing samples…

If the output labels "1" or "0" aren't insightful for you, you can add an if statement to display them as strings "snare" and "kick".

 
NEED HELP?
Tricks of the trade
Select code in Matlab editor and then press F9.  This will execute the currently selected code.
To run a Matlab "cell" (multiline block of code),  press Control-Enter with the text cursor in the current cell.

The clear command re-initializes a variable.  To avoid confusion, you mind find it helpful to clear arrays and structures at the beginning of your scripts.

Common Errors

    >??? Index exceeds matrix dimensions.

Are you trying to access, display, plot, or play past the end of the file / frame? 
For example, if an audio file is 10,000 samples long, make sure that the index is not greater than this maximum value.   If the value is > than the length of your file, use an if statement to catch the problem.

 


Lab 2
=====

Purpose: To gain an understanding of feature extraction, windowing, MFCCs.

SECTION 1 SEGMENTING INTO EVERY N ms FRAMES
-------------------------------------------

Segmenting: Chopping up into frames every N seconds

Previously, we've either chopped up a signal by the location of it's onsets (and taking the following 100 ms) or just analyzing the entire file. 
Analyzing the audio file by "frames" is another technique for your arsenal that is good for analyzing entire songs, phrases, or non-onset-based audio examples.
You easily chop up the audio into frames every, say, 100ms, with a for loop. 

    frameSize = 0.100 * fs; % 100ms
    for i = 1: frameSize : (length(x)-frameSize+1) 
        currentFrame = x(i:i+frameSize-1); % this is the current audio frame 
        % Now, do your feature extraction here and store the features in some matrix / array
    end

Very often, you will want to have some overlap between the audio frames - taking an 100ms long frame but sliding it 50 ms each time. To do a 100ms frame and have it with 50% overlap, try: 

    frameSize = 0.100 * fs; % 100ms
    hop = 0.5; % 50%overlap
    for i = 1: hop * frameSize : (length(x)-frameSize+1) 
        ...
    end

Note that it's also important to multiple the signal by a window (e.g., Hamming / Hann window) equal to the frame size to smoothly transition between the frames. 

SECTION 2 MFCC
--------------

Load an audio file of your choosing from the audio folder on `/usr/ccrma/courses/mir2012/audio`.
Use this as an opportunity to explore this collection.

BAG OF FRAMES

Test out MFCC to make sure that you know how to call it. We'll use the CATbox implementation of MFCC.

    currentFrameIndex = 1; 
    for i = 1: frameSize : (length(x)-frameSize+1)
        currentFrame = x(i:i+frameSize-1) + eps ; % this is the current audio frame
        % Note that we add EPS to prevent divide by 0 errors % Now, do your other feature extraction here 
        % The code generates MFCC coefficients for the audio signal given in the current frame.
        [mfceps] = mfcc(currentFrame ,fs)' ; %note the transpose operator!
        delta_mfceps = mfceps - [zeros(1,size(mfceps,2)); mfceps(1:end-1,:)]; %first delta
        % Calculate the mean and std of the MFCCs, MFCC-deltas.
        MFCC_mean(currentFrameIndex,:) = mean(mfceps);
        MFCC_std(currentFrameIndex,:) = std(mfceps);
        MFCC_delta_mean (currentFrameIndex,:)= mean(delta_mfceps);
        MFCC_delta_std(currentFrameIndex,:)= std(delta_mfceps);
        currentFrameIndex = currentFrameIndex + 1;
    end

    features = [MFCC_mean MFCC_delta_mean ]; % In this case, we'll only store the MFCC and delta-MFCC means
    % NOTE: You might want to toss out the FIRST MFCC coefficient and delta-coefficient since it's much larger than 
    others and only describes the total energy of the signal.

You can include this code inside of your frame-hopping loop to extract the MFCC-values for each frame. 

Once MFCCs per frame have been calculated, consider how they can be used as features for expanding the k-NN classification and try implementing it!

Extract the mean of the 12 MFCCs (coefficients 1-12, do not use the "0th" coefficient) for each onset using the code that you wrote. Add those to the feature vectors, along with zero crossing and centroid. We should now have 14 features being extracted - this is starting to get "real world"! With this simple example (and limited collection of audio slices, you probably won't notice a difference - but at least it didn't break, right?) Try it with the some other audio to truly appreciate the power of timbral classification. 



SECTION 3 CROSS VALIDATION
--------------------------

You'll need some of this code and information to calculate your accuracy rate on your classifiers.

EXAMPLE

Let's say we have 10-fold cross validation...

1. Divide test set into 10 random subsets.
2. 1 test set is tested using the classifier trained on the remaining 9.
3. We then do test/train on all of the other sets and average the percentages. 

To achieve the first step (divide our training set into k disjoint subsets), use the function crossvalind.m (posted in the Utilities)

    INDICES = CROSSVALIND('Kfold',N,K) returns randomly generated indices
    for a K-fold cross-validation of N observations. INDICES contains equal
    (or approximately equal) proportions of the integers 1 through K that
    define a partition of the N observations into K disjoint subsets.

 You can type help crossvalind to look at all the other options. This code is also posted as a template in 
 `/usr/ccrma/courses/mir2010/Toolboxes/crossValidation.m`

     % This code is provided as a template for your cross-validation
     % computation. Replace the variables "features", "labels" with your own
     % data. 
     % As well, you can replace the code in the "BUILD" and "EVALUATE" sections
     % to be useful with other types of Classifiers.
     %
     %% CROSS VALIDATION 
     numFolds = 10; % how many cross-validation folds do you want - (default=10)
     numInstances = size(features,1); % this is the total number of instances in our training set
     numFeatures = size(features,2); % this is the total number of instances in our training set
     indices = crossvalind('Kfold',numInstances,numFolds) % divide test set into 10 random subsets
     clear errors
     for i = 1:10
         % SEGMENT DATA INTO FOLDS
         disp(['fold: ' num2str(i)]) 
         test = (indices == i) ; % which points are in the test set
         train = ~test; % all points that are NOT in the test set
         % SCALE
         [trainingFeatures,mf,sf]=scale(features(train,:));
         % BUILD NEW MODEL - ADD YOUR MODEL BUILDING CODE HERE...
         model = knn(numFeatures,2,3,trainingFeatures,labels(train,:)); 
         % RESCALE TEST DATA TO TRAINING SCALE SPACE
         [testingFeatures]=rescale(features(test,:),mf,sf);
         % EVALUATE WITH TEST DATA - ADD YOUR MODEL EVALUATION CODE HERE
         [voting,model_output] = knnfwd(model ,testingFeatures);
         % CONVERT labels(test,:) LABELS TO SAME FORMAT TO COMPUTE ERROR 
         labels_test = zeros(size(model_output,1),1); % create array of 0s
         labels_test(find(labels(test,1)==1))=1; % convert column 1 to class 1 
         labels_test(find(labels(test,2)==1))=2; % convert column 2 to class 2 
         % COUNT ERRORS 
         errors(i) = mean ( model_output ~= labels_test )
     end
     disp(['cross validation error: ' num2str(mean(errors))])
     disp(['cross validation accuracy: ' num2str(1-mean(errors))])


Lab 4
=====

Summary:

1.  Separate sources.
2.  Separate noisy sources.
3.  Classify separated sources.

Matlab Programming Tips
*   Pressing the up and down arrows let you scroll through command history.
*   A semicolon at the end of a line simply means ``suppress output''.
*   Type `help <command>` for instant documentation. For example, `help wavread`, `help plot`, `help sound`. Use `help` liberally!


Section 1: Source Separation
----------------------------

1.  In Matlab: Select File > Set Path. 

    Select "Add with Subfolders". 

    Select `/usr/ccrma/courses/mir2011/lab3skt`.

2.  As in Lab 1, load the file, listen to it, and plot it.

        [x, fs] = wavread('simpleLoop.wav');
        sound(x, fs)
        t = (0:length(x)-1)/fs;
        plot(t, x)
        xlabel('Time (seconds)')

3.  Compute and plot a short-time Fourier transform, i.e., the Fourier transform over consecutive frames of the signal.

        frame_size = 0.100;
        hop = 0.050;
        X = parsesig(x, fs, frame_size, hop);
        imagesc(abs(X(200:-1:1,:)))

    Type `help parsesig`, `help imagesc`, and `help abs` for more information.

    This step gives you some visual intuition about how sounds (might) overlap.

4.  Let's separate sources!

        K = 2;
        [y, W, H] = sourcesep(x, fs, K);

    Type `help sourcesep` for more information.

5.  Plot and listen to the separated signals.

        plot(t, y)
        xlabel('Time (seconds)')
        legend('Signal 1', 'Signal 2')
        sound(y(:,1), fs)
        sound(y(:,2), fs)

    Feel free to replace `Signal 1` and `Signal 2` with `Kick` and `Snare` (depending upon which is which).   

6.  Plot the outputs from NMF.

        figure
        plot(W(1:200,:))
        legend('Signal 1', 'Signal 2')
        figure
        plot(H')
        legend('Signal 1', 'Signal 2')

    What do you observe from `W` and `H`? 

    Does it agree with the sounds you heard?

7.  Repeat the earlier steps for different audio files.

    *  `125BOUNC-mono.WAV`
    *  `58BPM.WAV` 
    *  `CongaGroove-mono.wav`
    *  `Cstrum chord_mono.wav`

    ... and more.

8.  Experiment with different values for the number of sources, `K`. 

    Where does this separation method succeed? 

    Where does it fail?


Section 2: Noise Robustness
---------------------------

1.  Begin with `simpleLoop.wav`. Then try others.

    Add noise to the input signal, plot, and listen.

        xn = x + 0.01*randn(length(x),1);
        plot(t, xn)
        sound(xn, fs)

2.  Separate, plot, and listen.

        [yn, Wn, Hn] = sourcesep(xn, fs, K);
        plot(t, yn)
        sound(yn(:,1), fs)
        sound(yn(:,2), fs)
        
    How robust to noise is this separation method? 

    Compared to the noisy input signal, how much noise is left in the output signals? 

    Which output contains more noise? Why?


Section 3: Classification
-------------------------

Follow the K-NN example in Lab 1, but classify the *separated* signals.

As in Lab 1, extract features from each training sample in the kick and snare drum directories.

1.  Train a K-NN model using the kick and snare drum samples.

        labels=[[ones(10,1) zeros(10,1)];
                [zeros(10,1) ones(10,1)]];
        model_snare = knn(5, 2, 1, trainingFeatures, labels);
        [voting, model_output] = knnfwd(model_snare, featuresScaled)

2.  Extract features from the drum signals that you separated in Lab 4 Section 1. 

3.  Classify them using the K-NN model that you built.

    Does K-NN accurately classify the separated signals?

4.  Repeat for different numbers of separated signals (i.e., the parameter `K` in NMF). 

5.  Overseparate the signal using `K = 20` or more. For those separated components that are classified as snare, add them together using `sum}. The listen to the sum signal. Is it coherent, i.e., does it sound like a single separated drum?

...and more!

*  If you have another idea that you would like to try out, please ask me!
*  Feel free to collaborate with a partner.  Together, brainstorm your own problems, if you want!

Good luck!
