% ballnstick2ppt(indir,pptfile)
% copy ball-n-nstick tif-images in "images"-dir to single PPT-file
% inputs: inputfolder, output-PPTfile: 
%% ======== example ======================================
% in='F:\data6\img2ppt\images'
% out='F:\data6\img2ppt\ballnsticks.pptx'
% ballnstick2ppt(in,out);
    
function ballnstick2ppt(indir,pptfile)

if 0
    %% ===============================================
    in='F:\data6\img2ppt\images'
    out='F:\data6\img2ppt\ballnsticks.pptx'
    ballnstick2ppt(in,out);
    
    
    %% ===============================================
    
end

warning off;

% ==============================================
%%   
% ===============================================
% clear
pa=indir;%'F:\data6\img2ppt\images'
% [pain fin extin]=fileparts(pa);
% if isempty()
if exist('pptfile')==0
    pptfile=fullfile(indir,'ballnsticks.pptx' );
else
    [pax fix ext]=fileparts(pptfile);
    if isempty(pax); pax=pa; end
    if exist(pax)~=7
        mkdir(pax);
    end
end
% indir=pa
% outdir=pwd
% pptfile=fullfile(outdir,'test2.pptx');

[fis] = spm_select('FPList',pa,'v.*.tif');
fis=cellstr(fis);


% ==============================================
%%   
% ===============================================
% clc;

% fg; imagesc

s.doc='add';
s.doc='new';
% ===============================================
% p.hideControls=1;
% hf=findobj(0,'tag','dtifig1');
% hf=gcf;


%% ===============================================



[pptpa pptfi pptext]=fileparts(pptfile);
if isempty(pptpa); pptpa=pwd; end
pptfile=fullfile(pptpa ,[pptfi '.pptx']);



% s.doc='add';
isOpen  = exportToPPTX();
if ~isempty(isOpen)    % If PowerPoint already started, then close first and then open a new one
    exportToPPTX('close');
end

sip=[11.69 8.27];
if strcmp(s.doc,'add') && exist([pptfile])
    exportToPPTX('open',[pptfile]);
else
    exportToPPTX('new','Dimensions',sip, ...
        'Title','Example Presentation', ...
        'Author','MatLab', ...
        'Subject','Automatically generated PPTX file', ...
        'Comments','This file has been automatically generated by exportToPPTX');
end


slideNum = exportToPPTX('addslide','BackgroundColor',[1 1 1]);
% if p.hideControls==1
%     set(findall(hf,'type','uicontrol'),'visible','off');
% end
% exportToPPTX('addpicture',hf);
% exportToPPTX('addpicture',a);
% exportToPPTX('addpicture',a,'Position',[0 0 2 2]);
%% ===============================================
if 1
    % sip=[11.69 8.27];
    ncol=4;
    nimg=length(fis);
    re=mod(nimg,ncol);
    nrow=((nimg-re)/ncol)+sum(re>0);
    %nrow=4;
    x=2; y=2;
    mxrow=4;
    
    px=[];
    irow=1;
    xstp=x;
    ystp=y;
    cn=1;
    px2=[];
    gap=0.1;
    for j=1:(nrow)
%         if mod(irow,mxrow)==0
%             irow=1;
%         end
        for i=1:(ncol)
            if mod(cn,17)==0
                slideNum = exportToPPTX('addslide','BackgroundColor',[1 1 1]);
                irow=1;
            end
            px=[i*xstp-xstp+gap   irow*ystp-ystp+gap x y ];
            if cn<=length(fis)
                a=imread(fis{cn});
                exportToPPTX('addpicture',a,'Position',px);
                px2=px;
            end
            cn=cn+1;
        end
        irow=irow+1;
    end
    [fis2] = spm_select('FPList',pa,'colorbar.tif');
    a=imread(fis2);
    b=a(30:250,1520:1750,:);
    if isempty(px2); px2=[px(1)+xstp px(2)]; end
    px2(1)=px2(1)+2+gap;
    px2(2)=px2(2)+gap;
    px2(3:4)=[x/2 y/2];
    exportToPPTX('addpicture',b,'Position',px2);
end

% reurn

%% ========== TXT =====================================
[fis3] = spm_select('FPList',pa,'node_list.txt');
labs=preadfile(fis3); labs=labs.all;

 exportToPPTX('addtext',strjoin(labs,char(10)),'FontSize',10,...
        'Position',[ ncol.*xstp+1 0.5 4  sip(2) ]);



%% ===============================================
v={'ball-n-stick:'
    ['path:  ' pa ]};
%fprintf('Added slide %d\n',slideNum);
% 
% if 1
    %     exportToPPTX('addtext',lb.String{lb.Value});
    exportToPPTX('addtext',strjoin(v,char(10)),'Position',[sip(1)-3 sip(2)-1 3 0.4  ],...
        'Color',[0 0 1],'FontWeight','bold','BackgroundColor',[1.0000    0.9686    0.9216],'FontSize',8);
    %exportToPPTX('addtext',    [['C' num2str(cons(1))] ': '  lb.String{lb.Value}]   );
%    
% end
%   exportToPPTX('addtext',strjoin(info,char(10)),'FontSize',10,...
%         'Position',[0 1 3 3  ]);
%     
% exportToPPTX('addtext',strjoin(info2,char(10)),'FontSize',8,...
%         'Position',[ sip(1)/2 sip(2)-1+sip(2)/20 8 1]);
%     
% %exportToPPTX('addnote',sprintf('Notes data: slide number %d',slideNum));
 exportToPPTX('addnote',['source: '  pa ]);

try
newFile = exportToPPTX('saveandclose',pptfile);
catch
  error('PPT-file is open...please close it')  ;
end


% if p.hideControls==1
%     set(findall(hf,'type','uicontrol'),'visible','on');
% end
% ==============================================
%%   
% ===============================================
showinfo2('saved: ',newFile);


