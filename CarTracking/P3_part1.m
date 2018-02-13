 clc
 close all
 clear all
 %% Train Cascade
directory = fullfile('Project 3', 'Dataset', 'vehicles','good');
false_directory = fullfile('Project 3', 'Dataset', 'non-vehicles');
dataset=[]
negatives=[]
boxes=[]
PositiveSet = imageSet(directory, 'recursive');
PositiveSet = imageSet(directory);
NegativeSet = imageSet(false_directory ,'recursive');
for i=1:1
   file_names=PositiveSet(1,i).ImageLocation';
   dataset=[dataset;file_names];
end
for i=1:2
    file_names=NegativeSet(1,i).ImageLocation';
    negatives=[negatives;file_names];
end
img_size=[1,1,64,64];
pos_data=struct('imageFilename',dataset,'objectBoundingBoxes',img_size);
trainCascadeObjectDetector('Car4.xml',pos_data,negatives,'NegativeSamplesFactor',2,'FalseAlarmRate',0.01,'NumCascadeStages',4);
%%
cd('Project 3/Dataset')
vid = VideoReader('simple.avi');
cd ..
cd ..
v = VideoWriter('test_vid','MPEG-4');
v.FrameRate = 30;
open(v);
step_size=5;
difference = 1;
track_state = [0 0 0 0];
old_pos =[];
old_pos = [old_pos;268.9164  319.8956   66.2242   65.4878];
old_pos = [old_pos;351.1405  327.7253   40.9711   42.3733];
old_pos = [old_pos;381.7336  325.5896   47.7822   48.8403];
old_pos = [old_pos;533.7090  315.1031   93.7672   92.5626];

for frm=1:step_size:300
frame = read(vid,frm);
feat_detect = vision.CascadeObjectDetector('car2.xml');
img = frame;
img_mask=img;
x = [230 630 630 230];
y = [310 310 470 470];
masked_img = poly2mask(x,y, 480, 704);
img_mask(:,:,1) = immultiply(img(:,:,1),masked_img);
img_mask(:,:,2) = immultiply(img(:,:,2),masked_img);
img_mask(:,:,3) = immultiply(img(:,:,3),masked_img);
boundbox = step(feat_detect,img_mask);
detectedImg2 = insertObjectAnnotation(img,'rectangle',boundbox,'Car');
fet=size(boundbox,1);
for l=1:fet
    track = 2;
    if (l>fet)
            break
    end
    area=boundbox(l,3)*boundbox(l,4);
    if (area>10000 || area<1200)
        boundbox(l,:)=[];
        fet=fet-1;            
    end
end
   track = [];
        sizeB = size(boundbox);
        rowsgB = size(1);
        for a = 1:sizeB
            for b = 1:sizeB
                Box1 = boundbox(b,:);
                Box2 = boundbox(a,:);
                if (Box2(1)>Box1(1) && Box2(1)+Box2(3)<Box1(1)+Box1(3))
                    track = [track; b];
                end
                
            end
        end
        boundbox(track,:) = [];
new_image=img;
new_image = insertObjectAnnotation(img,'rectangle',boundbox,'Car');

%% KLT Tracking - adapted from the matlab example on face tracking (https://www.mathworks.com/help/vision/examples/face-detection-and-tracking-using-the-klt-algorithm.html)
frame=read(vid,frm);
for l=frm:frm+step_size-difference 
frame1=read(vid,l);
figure(2), imshow(frame1), hold on, title('Detected features');  
isbox = [0,0,0,0];
for fet=1:size(boundbox)
bboxPoints = bbox2points(boundbox(fet, :));
feats = detectMinEigenFeatures(rgb2gray(frame), 'ROI', boundbox(fet,:),'MinQuality',0.1);
% plot points if need to view detected cars
%plot(feats);
featTracker = vision.PointTracker('MaxBidirectionalError', 4);
feats_loc = feats.Location;
initialize(featTracker, feats_loc, frame);
oldFeat = feats_loc;
%plot(oldPoints);
    % get the next frame
    new_frame = read(vid,l+1);

    % Track the points. Note that some points may be lost.
    [feats_loc, found] = step(featTracker, new_frame);
    visiblePoints = feats_loc(found, :);
    oldInliers = oldFeat(found, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'projective', 'MaxDistance', 2);
        
        % Apply the transformation to the bounding box points
        bboxPoints = transformPointsForward(xform, bboxPoints);
                
        % Insert a bounding box around the object being tracked
        bboxPolygon = reshape(bboxPoints', 1, []);
        xPoints = [bboxPolygon(1) bboxPolygon(3) bboxPolygon(5) bboxPolygon(7)];
        yPoints = [bboxPolygon(2) bboxPolygon(4) bboxPolygon(6) bboxPolygon(8)];
        xmin = min(xPoints);
        ymin = min(yPoints);
        xmax = max(xPoints);
        ymax = max(yPoints);
        figure(2),
        color=['g','m','r','c','y'];
        pos=[xmin ymin xmax-xmin ymax-ymin];
        if fet <= 6
%             rectangle('Position',pos,'EdgeColor',color(r),'linewidth',2);
            if xmin >= 240 & xmax <= 340 & ymin >= 300 & isbox(1) == 0
                rectangle('Position',pos,'EdgeColor',color(1),'linewidth',2);
                isbox(1) = 1;
                old_pos(1,:) = pos;
                
            end
              if xmin >= 300 & xmax <= 400 & xmax >= 370 & ymax <= 405 & isbox(2) == 0
                rectangle('Position',pos,'EdgeColor',color(2),'linewidth',2);
                isbox(2) = 1;
                old_pos(2,:) = pos;
              end
               if xmin >= 358 & xmax <= 450 & isbox(3) == 0
                rectangle('Position',pos,'EdgeColor',color(3),'linewidth',2);
                isbox(3) = 1;
                change = pos -  old_pos(2,:);
                old_pos(3,:) = pos;
                
               
              end
              if xmin >= 500 & xmax <= 640 & isbox(4) ==0
                rectangle('Position',pos,'EdgeColor',color(4),'linewidth',2);
                isbox(4) = 1;
                old_pos(3,:) = pos;
               
              end  
        end
      
        %videoFrame = insertObjectAnnotation(frame,'rectangle',rect,'Car','Color','green');        
        % Display tracked points
        %frame3 = insertMarker(frame, visiblePoints, '+', ...
          %  'Color', 'white');       
        %plot(visiblePoints);
        % Reset the points
        oldFeat = visFeat;
        setPoints(featTracker, oldFeat); 
        release(featTracker)
    end
    

end

if isbox(2) == 0
    track_state(2) = track_state(2)+1;
    if track_state(2) == 10 
        old_pos(2,1) = old_pos(2,1) + change(1)/2;
        old_pos(2,2) = old_pos(2,2) + change(2)/2;
        track_state(2) = 0;
    end
    
    rectangle('Position', old_pos(2,:),'EdgeColor',color(2),'linewidth',2);
end
% if isbox(3) == 0
%     rectangle('Position', old_pos(3,:),'EdgeColor',color(3),'linewidth',2);
%     track_state(3) = track_state(3)+1;
%     if track_state(3) == 6 
%         old_pos(3,:) = old_pos(3,:) + change;
%         track_state(3) = 0;
%     end
% end
% if isbox(4) == 0
%     rectangle('Position', old_pos(4,:),'EdgeColor',color(4),'linewidth',2);
%     track_state(4) = track_state(4)+1;
%     if track_state(4) == 6 
%         old_pos(4,:) = old_pos(4,:) + change;
%         track_state(4) = 0;
%     end
% end
frame_alt = getframe(gca);
writeVideo(v,frame_alt);
%release(pointTracker);

end
end

% end video recording
close(v);

