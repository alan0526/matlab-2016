clear all
tic
% Data reading & stacking
folder_path_without_index='G:\Everday Experiements\Wide_20160302_172323_pork_after 4th adj_S140_R4_IT2800\';

%parts=regexp(folder_path_without_index, '\','split');
%Parent_folder=folder_path_without_index(1:(length(folder_path_without_index)-length(parts{end})));
correction_set=2;
map_method='mean';  %mean std kurtosis skewness diff

If_load_correction_file=1;

if correction_set == 1
    if_glass_interface_searching=1;
    cmin=12;%12;%11
    cmax_set=16;%16;%60;%120;%20;
    start_index_offset_from_max=-30;
    G_Ratio=0.95;
    Gaussian_X_width=400*G_Ratio;
    Gaussian_Y_width=300*G_Ratio;
    X_offset=10;
    Y_offset=30;

elseif correction_set == 2
    if_glass_interface_searching=1;
    start_index_offset_from_max=0;%16*4;
    
    %cmin=8;%12;%11
    %cmax_set=10;%16;%60;%120;%20;
    %G_Ratio=1.5;
    %Gaussian_X_width=120*G_Ratio;
    %Gaussian_Y_width=140*G_Ratio;
    %X_offset=25;
    %Y_offset=-50;
    cmin_1=0;
    cmax_1=30;
    cmin_2=0.4;%12;%11
    cmax_2=0.6;%16;%60;%120;%20;
    G_Ratio=6;
    Gaussian_X_width=400*G_Ratio;%350*G_Ratio;
    Gaussian_Y_width=250*G_Ratio;%250*G_Ratio;
    X_offset=0;%160;
    Y_offset=-10;%-100;
elseif correction_set == 3  %for 1x
    if_glass_interface_searching=1;
    start_index_offset_from_max=0;%16*4;
    
    %cmin=8;%12;%11
    %cmax_set=10;%16;%60;%120;%20;
    %G_Ratio=1.5;
    %Gaussian_X_width=120*G_Ratio;
    %Gaussian_Y_width=140*G_Ratio;
    %X_offset=25;
    %Y_offset=-50;
    cmin_1=6;
    cmax_1=7.5;
    cmin_2=0;%12;%11
    cmax_2=0.5;%16;%60;%120;%20;
    G_Ratio=1.25;
    Gaussian_X_width=400*G_Ratio;%350*G_Ratio;
    Gaussian_Y_width=200*G_Ratio;%250*G_Ratio;
    X_offset=0;%160;
    Y_offset=125;%-100;
    
end




if_notch=0;

frame_width=648;
frame_height=488;

X_overlapping=25;
Y_overlapping=21;




frame_width_eff=frame_width-X_overlapping;
frame_height_eff=frame_height-Y_overlapping;


num_of_frame_per_division=16;

normalization_factor=50;

X_mosaic_starting_index=6;%+6;%6;%13;%+6;%6;%1;  %start from 0
Y_mosaic_starting_index=8;%+8;%+8+4;%12;%8;%17;%+8;%8;%1;


X_mosaic_number=12;%12;%3;%6;%3;%-9;%6;%3;%12;%12;
Y_mosaic_number=16;%16;%4;%8;%16;%4;%-12;%8;%4;%16;%16;

%% glass interface searching


frame_average_factor=16;    %averaged to stack

stack_sampling_spacing=8;

total_stack_number=1;


%%


total_FOV_number=X_mosaic_number*Y_mosaic_number;
k=0;


%stiched_volume=zeros(frame_width_eff*X_mosaic_number+X_overlapping,frame_height_eff*Y_mosaic_number+Y_overlapping,num_of_frame_per_division);
% correction image generation

% correction 1 (edge summation correction)

correction_A=ones(frame_width,frame_height);

% left&right bound
%% revised 2016/3/2 
for tt=1:X_overlapping
    correction_A(tt,:)=correction_A(tt,:)*((tt-1)/((X_overlapping-1)));
    correction_A(frame_width-tt+1,:)=correction_A(frame_width-tt+1,:)*((tt-1)/((X_overlapping-1))); 
end
for tt=1:Y_overlapping
    correction_A(:,tt)=correction_A(:,tt)*((tt-1)/(Y_overlapping-1));
    correction_A(:,frame_height-tt+1)=correction_A(:,frame_height-tt+1)*((tt-1)/((Y_overlapping-1))); 
end


imagesc(correction_A);
colormap('gray');
axis equal
xlim([0 size(correction_A,2)]);
ylim([0 size(correction_A,1)]);


correction_B_X=ones(frame_width,frame_height);
correction_B_Y=ones(frame_width,frame_height);

for tt=1:frame_height
    correction_B_X(:,tt)=gaussmf((1:frame_width),[Gaussian_X_width frame_width/2+X_offset]);
end
for tt=1:frame_width
    correction_B_Y(tt,:)=gaussmf((1:frame_height),[Gaussian_Y_width frame_height/2+Y_offset]);
end

if If_load_correction_file==0
    correction_B=1./(correction_B_X.*correction_B_Y);
else
    correction_B_Raw_loaded=dlmread([sprintf('%s_correction_file\\',folder_path_without_index),'correction_file.txt']);
    correction_B_Raw_Normalized=correction_B_Raw_loaded/max(correction_B_Raw_loaded(:));
    correction_B=1./(correction_B_Raw_Normalized.*correction_B_X.*correction_B_Y);
end
correction_image=correction_A.*correction_B;

if if_notch==1
    notch_height=0.85;
    notch_X=222;
    notch_Y=247;
    notch_width=15;
    notch_X_mat=ones(frame_width,frame_height);
    notch_Y_mat=ones(frame_width,frame_height);
    for tt=1:frame_height
        notch_X_mat(:,tt)=notch_height*gaussmf((1:frame_width),[notch_width notch_X]);
    end
    for tt=1:frame_width
        notch_Y_mat(tt,:)=notch_height*gaussmf((1:frame_height),[notch_width notch_Y]);
    end
    notch_image_1=ones(frame_width,frame_height)-(notch_X_mat.*notch_Y_mat);
    %notch_2
    notch_height=0.5;
    notch_X=184;
    notch_Y=434;
    notch_width=32;
    notch_X_mat=ones(frame_width,frame_height);
    notch_Y_mat=ones(frame_width,frame_height);
    for tt=1:frame_height
        notch_X_mat(:,tt)=notch_height*gaussmf((1:frame_width),[notch_width notch_X]);
    end
    for tt=1:frame_width
        notch_Y_mat(tt,:)=notch_height*gaussmf((1:frame_height),[notch_width notch_Y]);
    end
    notch_image_2=ones(frame_width,frame_height)-(notch_X_mat.*notch_Y_mat);
    
    correction_image=correction_image./notch_image_1./notch_image_2;
end

%dlmwrite('correction_B.txt',correction_B,'delimiter','\t','newline','pc');

%correction_image(:)=1;
imagesc(correction_image);
colormap('gray');
axis equal
xlim([0 size(correction_B,2)]);
ylim([0 size(correction_B,1)]);

%% glass interface searching

Value_1_1=0;
X_incre=0;%3;
Y_incre=0;%18;
    
glass_interface_index_map_set=zeros(X_mosaic_number,Y_mosaic_number);
    
glass_interface_index_map_set(:)=Value_1_1;
    
for p=1:size(glass_interface_index_map_set,1)
    for q=1:size(glass_interface_index_map_set,2)
        glass_interface_index_map_set(p,q)=glass_interface_index_map_set(p,q)+X_incre*(q-1)+Y_incre*(p-1);
    end
end
imagesc(glass_interface_index_map_set);
colormap('gray');
xlim([1 size(glass_interface_index_map_set,2)]);
ylim([1 size(glass_interface_index_map_set,1)]);
axis equal
        
    
    
%glass_interface_index_map_set=glass_interface_index_map;
%%
total_ave_frame=zeros(648,488);
total_ave_frame_after_correction=zeros(648,488);

%stiched_images=zeros(frame_width_eff*X_mosaic_number+X_overlapping,frame_height_eff*Y_mosaic_number+Y_overlapping,total_stack_number);
for NNN=1:total_stack_number
    stiched_image=zeros(frame_width_eff*X_mosaic_number+X_overlapping,frame_height_eff*Y_mosaic_number+Y_overlapping);

    for N=0:(total_FOV_number-1)
        X_number=rem(N,X_mosaic_number)+X_mosaic_starting_index; %0~2
        Y_number=floor(N/X_mosaic_number)+Y_mosaic_starting_index; %0~2
        X_FOV_number=X_number-X_mosaic_starting_index;
        Y_FOV_number=Y_number-Y_mosaic_starting_index;
        %Y_FOV_number=X_mosaic_number-1-X_number+X_mosaic_starting_index;
        %X_FOV_number=Y_mosaic_number-1-Y_number+Y_mosaic_starting_index;
        if if_glass_interface_searching==1
            division_starting_index=floor((start_index_offset_from_max+glass_interface_index_map_set(X_FOV_number+1,Y_FOV_number+1)+(NNN-1)*stack_sampling_spacing)/num_of_frame_per_division);   %start from zero
            the_starting_frame_index_in_the_first_division=start_index_offset_from_max+glass_interface_index_map_set(X_FOV_number+1,Y_FOV_number+1)+(NNN-1)*stack_sampling_spacing-division_starting_index*num_of_frame_per_division+1; %corrected, add 1
            division_end_index=     ceil((start_index_offset_from_max+glass_interface_index_map_set(X_FOV_number+1,Y_FOV_number+1)+(NNN-1)*stack_sampling_spacing+frame_average_factor)/num_of_frame_per_division)-1;
        else
            division_starting_index=floor((start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)/num_of_frame_per_division);   %start from zero
            the_starting_frame_index_in_the_first_division=start_index_offset_from_max+(NNN-1)*stack_sampling_spacing-division_starting_index*num_of_frame_per_division+1; %corrected, add 1
            division_end_index=     ceil((start_index_offset_from_max+(NNN-1)*stack_sampling_spacing+frame_average_factor)/num_of_frame_per_division)-1;    %應該是ceil +1 而非floor
        end
        division_number=division_starting_index:division_end_index;
        temp_frame_volume=zeros(frame_width,frame_height,num_of_frame_per_division*length(division_number));
    
        if (X_number<10)&&(Y_number<10)
            folder_path=sprintf('%s_% d_% d\\',folder_path_without_index,Y_number,X_number);
        elseif (X_number>9)&&(Y_number<10)
            folder_path=sprintf('%s_ %d_%d\\',folder_path_without_index,Y_number,X_number);
        elseif (Y_number>9)&&(X_number<10)
            folder_path=sprintf('%s_%d_ %d\\',folder_path_without_index,Y_number,X_number);
        else
            folder_path=sprintf('%s_%d_%d\\',folder_path_without_index,Y_number,X_number);
        end
        cd(folder_path);
        for NN=1:length(division_number)
            file_path=[folder_path sprintf('%08d',division_number(NN))];
            fin=fopen(file_path);
            A=fread(fin,[frame_width,frame_height*num_of_frame_per_division],'float32','b');
            if fin ==-1
                k=k+1;
                fclose('all');
            else

            for q=1:num_of_frame_per_division
          %temp_frame_volume(:,:,(NN-1)*num_of_frame_per_division+q)=A(:,(frame_height*(q-1)+1):frame_height*q).*correction_image;
                temp_frame_volume(:,:,(NN-1)*num_of_frame_per_division+q)=A(:,(frame_height*(q-1)+1):frame_height*q);
            end

                    
                fclose('all');
            end
        end
        if strcmp(map_method,'mean')==1
            Averaged_frame=mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3);
            %total_ave_frame=total_ave_frame+Averaged_frame;
            Averaged_frame=(Averaged_frame-cmin_1)/(cmax_1-cmin_1);  %因為無從做max intensity判斷, 只好用固定值
            Averaged_frame(Averaged_frame<0)=0; 
            Averaged_frame(Averaged_frame>1)=1; 
            total_ave_frame=total_ave_frame+Averaged_frame;
            total_ave_frame_after_correction=total_ave_frame_after_correction+Averaged_frame.*correction_B;
            Averaged_frame=Averaged_frame.*correction_image;   %這次試把]normalization放在corre後
            
        elseif strcmp(map_method,'std')==1
            Averaged_frame=std(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),0,3)./mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3);
            %Averaged_frame=(Averaged_frame-cmin)/cmax_set;  %因為無從做max intensity判斷, 只好用固定值
            Averaged_frame(Averaged_frame<0)=0; 
            Averaged_frame(Averaged_frame>1)=1; 
            Averaged_frame=Averaged_frame.*correction_A;   %因為是normalized的std, 故不需要做flat-field correction
        elseif strcmp(map_method,'kurtosis')==1 %內建的好像沒有比較快, 就先不改了
            temp_mean=repmat(mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3),[1 1 length(the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1))]);
            Averaged_frame=mean(((temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1))-temp_mean).^4),3)./(std(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),0,3).^4);
            %Averaged_frame=(Averaged_frame-cmin)/cmax_set;  %因為無從做max intensity判斷, 只好用固定值
            Averaged_frame=(Averaged_frame-1.5)/3;   %原本應該要減3 (see kurt定義), 但因為不想要它有負值, so)
            Averaged_frame(Averaged_frame<0)=0; 
            Averaged_frame(Averaged_frame>1)=1; 
            Averaged_frame=Averaged_frame.*correction_A;
        elseif strcmp(map_method,'skewness')==1 %內建的好像沒有比較快, 就先不改了
            temp_mean=repmat(mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3),[1 1 length(the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1))]);
            Averaged_frame=mean(((temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1))-temp_mean).^3),3)./(std(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),0,3).^3);
            %Averaged_frame=(Averaged_frame-cmin)/cmax_set;  %因為無從做max intensity判斷, 只好用固定值
            Averaged_frame=(Averaged_frame)/2;   %因為是normalized的std, 故不需要做flat-field correction
            Averaged_frame(Averaged_frame<0)=0; 
            Averaged_frame(Averaged_frame>1)=1; 
            Averaged_frame=Averaged_frame.*correction_A;   %因為是normalized的std, 故不需要做flat-field correction
        elseif strcmp(map_method,'diff')==1
            temp_mean_all=mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3);
            temp_mean_Q1=mean(temp_frame_volume(:,:,the_starting_frame_index_in_the_first_division:(the_starting_frame_index_in_the_first_division+frame_average_factor/4-1)),3);
            temp_mean_Q4=mean(temp_frame_volume(:,:,(the_starting_frame_index_in_the_first_division+frame_average_factor*3/4):(the_starting_frame_index_in_the_first_division+frame_average_factor-1)),3);
            Averaged_frame=(temp_mean_Q1-temp_mean_Q4)./temp_mean_all;
            %Averaged_frame=(Averaged_frame-cmin)/cmax_set;  %因為無從做max intensity判斷, 只好用固定值
            %Averaged_frame=(Averaged_frame)/2;   %因為是normalized的std, 故不需要做flat-field correction
            Averaged_frame(Averaged_frame<0)=0; 
            Averaged_frame(Averaged_frame>1)=1; 
            Averaged_frame=Averaged_frame.*correction_A;   %因為是normalized的std, 故不需要做flat-field correction
        end
        %Averaged_frame(Averaged_frame>1)=1;
        %NOTE: 2016/2/26 在下面這行加上flip
        stiched_image(((X_FOV_number)*frame_width_eff+1):((X_FOV_number)*frame_width_eff+frame_width),((Y_FOV_number)*frame_height_eff+1):((Y_FOV_number)*frame_height_eff+frame_height))=stiched_image(((X_FOV_number)*frame_width_eff+1):((X_FOV_number)*frame_width_eff+frame_width),((Y_FOV_number)*frame_height_eff+1):((Y_FOV_number)*frame_height_eff+frame_height))+flipud(fliplr(Averaged_frame));
   
        disp(N);

    end
    %if max(max(stiched_image))<cmax_set
    %    cmax=max(max(stiched_image));
    %else
        %cmax=cmax_set;
    %end
    %Normailzed_image=(stiched_image-cmin)/cmax;
    %Normailzed_image(Normailzed_image>1)=1;
    %Normailzed_image(Normailzed_image<0)=0;
    
       %% 以下為新嘗試, 原本是放在corr前的 2015/12/30    2015/1/20 back to the old method  2016/2/26 try this again 2016/3/1 disable
    stiched_image=(stiched_image-cmin_2)/(cmax_2-cmin_2);  %因為無從做max intensity判斷, 只好用固定值
    stiched_image(stiched_image<0)=0; 
    stiched_image(stiched_image>1)=1; 
    %%
        
    stiched_image_write=stiched_image;
    stiched_image_write(stiched_image_write>1)=1;
    mkdir(sprintf('%s_stiched_image\\',folder_path_without_index));
    imwrite(stiched_image_write,[sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index),'.png']);
    fout=fopen([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index)],'w+');
    fwrite(fout,stiched_image,'float32','b');
    %dlmwrite([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index),'.txt'],stiched_image_write,'delimiter','\t','newline','pc','precision', '%.6f');

end
%%
subplot(1,1,1)

imagesc(stiched_image_write);
    colormap('gray');
    caxis([0 1]);
    axis equal
    xlim([0 size(stiched_image,2)]);
    ylim([0 size(stiched_image,1)]);
    
    
    %fin=fopen([sprintf('%s_stiched_image\\',folder_path_without_index),sprintf('stiched_image_offset%.1f micron_X%d_Y%d',(start_index_offset_from_max+(NNN-1)*stack_sampling_spacing)*0.2,X_mosaic_starting_index,Y_mosaic_starting_index)]);
    %loaded_file=fread(fin,[size(stiched_image,1),size(stiched_image,2)],'float32','b');
    
    
    %imagesc(loaded_file);
    %colormap('gray');
    %caxis([0 1]);
    %axis equal
    %xlim([0 size(stiched_image,2)]);
    %ylim([0 size(stiched_image,1)]);
    %imagesc(histeq(stiched_image,[0 1]));
    %colormap('gray');
    %caxis([0 1]);
    %axis equal
    %xlim([0 size(stiched_image,2)]);
    %ylim([0 size(stiched_image,1)]);
    
    
    %fin2=fopen([cd,'\divide\',sprintf('stiched_image_%.1f micron',(starting_frame_index+(NNN-1)*frame_average_factor)*0.2)]);
    %QQQ=fread(fin2,[size(stiched_image,1),size(stiched_image,2)],'float32','b');

    %imagesc(histeq(stiched_image,[0.2:0.001:0.5]));

    %for QQQ=1:4
    %    Normailzed_image=(mean(stiched_volume(:,:,((QQQ-1)*4+1):((QQQ)*4)),3)-cmin)/cmax;
    %    Normailzed_image(Normailzed_image>1)=1;
    %    %stiched_images(:,:,NN)=mean(stiched_volume,3);    
    %    imwrite(Normailzed_image,[cd,'\divide\',sprintf('stiched_image_%d.png',(NN-1)*4+QQQ),'.png']);
    %end
    %for QQQ=1:16
    %    Normailzed_image=(mean(stiched_volume(:,:,QQQ),3)-cmin)/cmax;
    %    Normailzed_image(Normailzed_image>1)=1;
        %stiched_images(:,:,NN)=mean(stiched_volume,3);
    %    imwrite(Normailzed_image,[cd,'\divide3\',sprintf('stiched_image_%d.png',(NN-1)*16+QQQ),'.png']);
    %end
    %stiched_volume=zeros(frame_width_eff*X_mosaic_number+X_overlapping,frame_height_eff*Y_mosaic_number+Y_overlapping,num_of_frame_per_division);
toc
%
disable=1;
if disable==0

imagesc(total_ave_frame);
%caxis([0 1]);
colormap(gray);
axis equal
xlim([0 size(total_ave_frame,2)]);
ylim([0 size(total_ave_frame,1)]);
total_ave_frame_gained=total_ave_frame;

%% try to generate the correction image based on the total_ave_frame (before correction)
% the gain difference (not sure why it exist, should be corrected by the bobcat

Gain_Diff_Bound_Pixel=324;
Gain_ratio=1.03;

Lastline_pixel=488;
Blur_Size=10;  %size of the matrix, must be odd number

Weight_mask=fspecial('gaussian', Blur_Size,Blur_Size/3);    %gaussian mask


total_ave_frame_gained(1:Gain_Diff_Bound_Pixel,:)=total_ave_frame(1:Gain_Diff_Bound_Pixel,:)*Gain_ratio;

total_ave_frame_gained_diff=diff(total_ave_frame_gained,1);
imagesc(total_ave_frame_gained);
%%
Lastline_ratio=1.03;
total_ave_frame_gained_lastline=total_ave_frame_gained;

total_ave_frame_gained_lastline(:,Lastline_pixel)=total_ave_frame_gained_lastline(:,Lastline_pixel)*Lastline_ratio;
subplot(1,1,1)
imagesc(total_ave_frame_gained_lastline);
xlim([480 488]);
%imagesc(total_ave_frame_gained_diff);
%%
total_ave_frame_gained_framed=zeros(size(total_ave_frame_gained_lastline,1)+Blur_Size,size(total_ave_frame_gained_lastline,2)+Blur_Size);
% inpterpol for total_ave_frame_gained_framed
X_ori=repmat(((1:size(total_ave_frame_gained_lastline,2))-1),[size(total_ave_frame_gained_lastline,1) 1]);
Y_ori=repmat(((1:size(total_ave_frame_gained_lastline,1))-1)',[1 size(total_ave_frame_gained_lastline,2)]);

X_new=repmat(((1:size(total_ave_frame_gained_framed,2))-1)/(size(total_ave_frame_gained_framed,2)-1)*(size(total_ave_frame_gained_lastline,2)-1),[size(total_ave_frame_gained_framed,1) 1]);
Y_new=repmat(((1:size(total_ave_frame_gained_framed,1))-1)'/(size(total_ave_frame_gained_framed,1)-1)*(size(total_ave_frame_gained_lastline,1)-1),[1 size(total_ave_frame_gained_framed,2)]);

total_ave_frame_gained_framed_bnd=interp2(X_ori,Y_ori,total_ave_frame_gained_lastline,X_new,Y_new,'linear');
total_ave_frame_gained_framed=total_ave_frame_gained_framed_bnd;

total_ave_frame_gained_framed((Blur_Size/2+1):(Blur_Size/2)+size(total_ave_frame_gained_lastline,1),(Blur_Size/2+1):(Blur_Size/2)+size(total_ave_frame_gained_lastline,2))=total_ave_frame_gained_lastline;

subplot(3,1,1)
imagesc(total_ave_frame_gained_framed_bnd);

subplot(3,1,2)
imagesc(total_ave_frame_gained_framed);

subplot(3,1,3)
imagesc(total_ave_frame_gained);

%%
total_ave_frame_blur_framed=filter2(Weight_mask,total_ave_frame_gained_framed,'same');
total_ave_frame_blur=total_ave_frame_blur_framed((Blur_Size/2+1):(Blur_Size/2)+size(total_ave_frame_gained,1),(Blur_Size/2+1):(Blur_Size/2)+size(total_ave_frame_gained,2));
subplot(1,1,1)
imagesc(total_ave_frame_blur);
colormap(gray);

%% Apply the gain correction
total_ave_frame_blur_final=total_ave_frame_blur;
total_ave_frame_blur_final(1:Gain_Diff_Bound_Pixel,:)=total_ave_frame_blur(1:Gain_Diff_Bound_Pixel,:)/Gain_ratio;

total_ave_frame_blur_final(:,Lastline_pixel)=total_ave_frame_blur_final(:,Lastline_pixel)/Lastline_ratio;
imagesc(total_ave_frame./total_ave_frame_blur_final);

%% Comparison
Predcited_Ratio=total_ave_frame./total_ave_frame_blur_final;
Predcited_Ratio=Predcited_Ratio/max(Predcited_Ratio(:));
Acquired_Ratio=total_ave_frame_after_correction;
Acquired_Ratio=Acquired_Ratio/max(Acquired_Ratio(:));
subplot(3,1,1)
imagesc(Predcited_Ratio);
subplot(3,1,2)
imagesc(Acquired_Ratio);

subplot(3,1,3)
imagesc(Predcited_Ratio-Acquired_Ratio);


%%
mkdir(sprintf('%s_correction_file\\',folder_path_without_index));
dlmwrite([sprintf('%s_correction_file\\',folder_path_without_index),'correction_file.txt'],total_ave_frame_blur_final,'delimiter','\t','newline','pc','precision', '%.6f');
end
%%
fclose all