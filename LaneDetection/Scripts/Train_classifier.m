clear all
clc


training_folder = fullfile('training_');
trainingSet = imageSet(training_folder,   'recursive');
testing_folder = fullfile('testing_');
testingSet = imageSet(testing_folder, 'recursive');

hogSize = 31;

trainingFeatures = [];
trainingLabels   = [];
testFeatures = [];
testLabels   = [];

for i = 1:numel(trainingSet)
    
   numImages_train = trainingSet(i).Count;
   numImages_test = testingSet(i).Count;
   hog_train = [];
   hog_test = [];
   
   for j = 1:numImages_train
       img = read(trainingSet(i), j);
       
       img = im2single(imresize(img,[64 64]));
       hog_1 = vl_hog(img, 4);
       [hog_r, hog_c] = size(hog_1);
       dim = hog_r*hog_c;
       hog_1_trans = permute(hog_1, [2 1 3]);
       hog_1=reshape(hog_1_trans,[1 dim]); 
       hog_train(j,:) = hog_1;
   end
  
   for j = 1:numImages_test
       img = read(testingSet(i), j);
       img = im2single(imresize(img,[64 64]));
       hog_1 = vl_hog(img, 4);
       [hog_r, hog_c] = size(hog_1);
       dim = hog_r*hog_c;
       hog_1_trans = permute(hog_1, [2 1 3]);
       hog_1=reshape(hog_1_trans,[1 dim]); 
       hog_test(j,:) = hog_1;
   end
   %%
   labels_train = repmat(trainingSet(i).Description, numImages_train, 1); 
   trainingFeatures = [trainingFeatures; hog_train];
   trainingLabels   = [trainingLabels;   labels_train  ];
   classifier = fitcecoc(trainingFeatures, trainingLabels);
   
   labels_test = repmat(testingSet(i).Description,numImages_test, 1);
   testLabels   = [testLabels;   labels_test  ];
   testFeatures = [testFeatures; hog_test];
   [predictedLabels,score] = predict(classifier, testFeatures);

   confMat = confusionmat(testLabels, predictedLabels);
end