clear all
%%
root_folder_path='F:\Mikrotron\160921_Diff Power_2\\';
last_folder_name='14mW';
folder_path=[root_folder_path last_folder_name '\'];

If_EffMap=0;

Data_Save_Folder='F:\Processed Data\';


cd(folder_path);

% Data format related
Row=1024;
Colomn=8;
Byte_Skip=0;
% Processing related
ave_factor=[16];
Product_of_Axial_Decimation_Factor_and_Ave_Factor=16;

for QQQ=1:length(ave_factor)
    N=4;
    micron_per_frame=0.2/ave_factor(QQQ)/N;
    Offset_1=0;
    Offset_2=0; 

    Max_Number_of_Frame=1000;
    if If_EffMap ==1
        Processed_Data_Path=[Data_Save_Folder '160921_in vivo test' last_folder_name sprintf('_EffMap_Ave_Factor_%d.raw',ave_factor(QQQ))];
    elseif If_EffMap ==0
        Processed_Data_Path=[Data_Save_Folder '160921_in vivo test' last_folder_name sprintf('_Ave_Factor_%d.raw',ave_factor(QQQ))];
    elseif If_EffMap ==-1
        Processed_Data_Path=[Data_Save_Folder '160921_in vivo test' last_folder_name sprintf('Test_Ave_Factor_%d.raw',ave_factor(QQQ))];
    end
    %%
    file_list=dir(folder_path);
    file_list=file_list(4:end);
  %% fiel name sorting
    name = {file_list.name};
    str  = sprintf('%s ', name{:});
    num  = sscanf(str, '%u.bmp ');
    [dummy, index] = sort(num);
    file_list = file_list(index);
    %%
    file_list=downsample(file_list,floor(Product_of_Axial_Decimation_Factor_and_Ave_Factor/ave_factor(QQQ)));
    Frame=length(file_list);
    %%
    Ave_Temp=zeros(Row,Colomn,ave_factor(QQQ));
    After_Npoint_Frame_Length=floor(Frame/N/ave_factor(QQQ));
    After_Npoint_Image_Stack=zeros(Row,Colomn,min(Max_Number_of_Frame,After_Npoint_Frame_Length));
    Npoint_Temp=zeros(Row,Colomn,N);

    X=[1:Frame];
    for p=1:min(Max_Number_of_Frame,After_Npoint_Frame_Length)
        for q=1:N
            for r=1:ave_factor(QQQ)

                file_path=[folder_path file_list((p-1)*N*ave_factor(QQQ)+(q-1)*ave_factor(QQQ)+r).name];

                %fin=fopen(file_path);

                %fseek(fin, Byte_Skip, 'bof');

                %Ave_Temp(:,:,r)=fread(fin,[Row,Colomn],'uint16'); %*Frame   不知為何, 看起來就像是要除16
                Ave_Temp(:,:,r)=imread(file_path,'TIFF')';
                
                %fclose(fin);
            end
            Npoint_Temp(:,:,q)=mean(Ave_Temp,3);
        end
        
        if If_EffMap ==1
            After_Npoint_Image_Stack(:,:,p)=((N*sum(Npoint_Temp.^2,3)-sum(Npoint_Temp,3).^2).^0.5)*(2^0.5)/N./mean(Npoint_Temp,3);
        elseif If_EffMap ==0
            After_Npoint_Image_Stack(:,:,p)=((N*sum(Npoint_Temp.^2,3)-sum(Npoint_Temp,3).^2).^0.5)*(2^0.5)/N;
        elseif If_EffMap ==-1
            After_Npoint_Image_Stack(:,:,p)=mean(Npoint_Temp,3);
        end
        disp(p);
    end

    %%
    fid = fopen(Processed_Data_Path, 'w+');
    fwrite(fid, After_Npoint_Image_Stack, 'double');
    fclose(fid);
    disp(QQQ);
    
    %%
    Axial_ave_Factor=2;
    Maximum_Axial_Frame=500;
    Temp=0;
    Axial_Length_Original=size(After_Npoint_Image_Stack,3);
    Axial_Length_Used=floor(Axial_Length_Original/Axial_ave_Factor)*Axial_ave_Factor;
    Reduced_Length=Axial_Length_Used/Axial_ave_Factor;
    for p=1:Axial_ave_Factor
       Temp=Temp+After_Npoint_Image_Stack(:,:,(Axial_ave_Factor-(p-1)):Axial_ave_Factor:(Axial_ave_Factor*Reduced_Length)-(p-1));
    end
    Reduced_Stack=Temp/Axial_ave_Factor;
    Reduced_Image=squeeze(mean(Reduced_Stack,2))';
    Reduced_Image=Reduced_Image(1:min(size(Reduced_Image,1),Maximum_Axial_Frame),:);
%%
    clear After_Npoint_Image_Stack
    %%
    
    ROI_Depth_Glass=[1 5];
    ROI_Width_Glass=[200 250];
    
    ROI_Depth_Sig=[121 125];
    ROI_Width_Sig=[200 250];
  
    ROI_Depth_BND=[21 25];
    ROI_Width_BND=[200 250];
    
    if If_EffMap ==1
        C_max=0.01;
        C_min=0.001;
    elseif If_EffMap ==0
        C_max=2;
        C_min=0.2;
    elseif If_EffMap ==-1
        C_max=256;
        C_min=0;
    end
    Reduced_Image_normalized=(Reduced_Image-C_min)/(C_max-C_min);
    Reduced_Image_normalized(Reduced_Image_normalized<0)=0;
    Reduced_Image_normalized(Reduced_Image_normalized>1)=1;

    imagesc(Reduced_Image_normalized);
    caxis([0 1]);
    colormap(gray);
    
    if If_EffMap ==1
        imwrite(Reduced_Image_normalized,[Data_Save_Folder '160921_in vivo test' last_folder_name '_Bscan_EffMap.png'],'png');
    elseif If_EffMap ==0
        imwrite(Reduced_Image_normalized,[Data_Save_Folder '160921_in vivo test' last_folder_name '_Bscan.png'],'png');
    elseif If_EffMap ==-1
        imwrite(Reduced_Image_normalized,[Data_Save_Folder '160921_in vivo test' last_folder_name '_Bscan_Test.png'],'png');
    end
%     Eff_Coef_Glass(QQQ)=max(mean(Reduced_Image(ROI_Depth_Glass(1):ROI_Depth_Glass(2),ROI_Width_Glass(1):ROI_Width_Glass(2))))
%     Eff_Coef_Sig(QQQ)=max(mean(Reduced_Image(ROI_Depth_Sig(1):ROI_Depth_Sig(2),ROI_Width_Sig(1):ROI_Width_Sig(2))))
%     Eff_Coef_BND(QQQ)=max(mean(Reduced_Image(ROI_Depth_BND(1):ROI_Depth_BND(2),ROI_Width_BND(1):ROI_Width_BND(2))))

    %% retangular ROI selection
      imagesc(Reduced_Image_normalized);
%      imrect(gca);
    %%
    ROI_Width=[450 550];
    ROI_Height=[1 15];
    Noise_ROI=Reduced_Image(ROI_Height(1):ROI_Height(2),ROI_Width(1):ROI_Width(2));
    Noise_EffMap=mean(Noise_ROI(:))
    imagesc(Reduced_Image);

    Max_Noise_ROI=max(Noise_ROI)
    
    colormap(gray);
end
% subplot(1,2,1)
% plot(ave_factor,(Eff_Coef_Glass.^2-Eff_Coef_BND.^2).^0.5);
% 
% subplot(1,2,2)
% plot(ave_factor,(Eff_Coef_Sig.^2-Eff_Coef_BND.^2).^0.5);
% fclose('all');