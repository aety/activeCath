for ii = 1
    
    [X,map,alpha,overlays] = dicomread(['..\DICOM\I' num2str(ii) '\IMG0']);
    montage(X,map);
%     pause;
    
end