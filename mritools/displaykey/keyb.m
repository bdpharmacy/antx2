
function keyb(src,evnt)


% V:\MRI_testdata\T2w_nifti\s20150908_FK_C1M02_1_3_1\c3s20150908_FK_C1M02_1_3_1.nii
% keyb('s2',v)


if nargin==0
%     helphelp;
return
end

if strcmp(src,'help')
helphelp;
return
end

%% direct overlay
if strcmp(src,'ovl')
imageoverlay(evnt)
return
end


if length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & strcmp(evnt.Key, 'control')
return
end
if length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'shift') & strcmp(evnt.Key, 'shift')
return
end


box=getappdata(gcf,'box');

if evnt.Character == 'h'
helphelp
elseif evnt.Character == 'd'
spm_image2('setparams','col',box.col,'wt',box.wt);
elseif evnt.Character == 'f'    %flipdim
global st
if isfield(st.overlay,'orig')==0;
st.overlay.orig=st.overlay
end

prompt = {'order of dims,use[-] to flip dir of this dim, e.g. [1 3 -2], [] for orig. settup '};
dlg_title = 'Input for peaks function';
num_lines = 1;
def = {num2str([1 2 3])};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(char(answer)); %orig settup
st.overlay= st.overlay.orig;
spm_orthviews2('Redraw');
return
elseif length(str2num(char(answer)))==3
vc=[str2num(char(answer)) ];
flips=sign(vc);
perms=abs(vc);

v=spm_vol(st.overlay.fname)
d=spm_read_vols(v); % r

isflip=find(flips==-1);
dia=diag(v.mat(1:3,1:3))
dc=zeros(3,1);
for i=1:length(isflip)
vsiz=dia(isflip(i))
a=[vsiz:vsiz:vsiz*(size(d,isflip(i))+1)]+v.mat(isflip(i),4);
%a=[0:vsiz:vsiz*(size(d,isflip)-1)]+v.mat(isflip(i),4);
dc(isflip(i))=-[a([ end]) ] ;
d=flipdim(d,isflip(i));
end
%permute
d=permute(d,[perms]);

%         dsh=round(size(d)/2)  ;
%         subplot(3,3,7); imagesc( squeeze(d(dsh(1),:     ,:) )   )     ;title(['2 3']);
%         subplot(3,3,8); imagesc( squeeze(d(:     ,dsh(2),:) )   )     ; title(['1 3']);
%         subplot(3,3,9); imagesc( squeeze(d(:     ,:     ,dsh(3)) )   );  title(['1 2']);
%
%
v2=v;
[pa fi fmt]=fileparts(v2.fname);
v2.fname=fullfile(pa ,['p' fi  fmt]);
v2.dim=size(d);
mat=v2.mat;
dia=diag(mat);
mat(1:4+1:end)=dia([perms 4]);

orig=mat(1:3,4);
orig(find(dc~=0) )=dc(find(dc~=0));
%         orig=orig.*flips'
%         orig(2)=orig(2)+3
orig=orig(perms);

mat(:,4)=[orig; 1];
%         mat(3,4)=mat(3,4)+2
v2.mat=mat;

spm_write_vol(v2, d); % write data to an image file.


backup= st.overlay.orig;
st.overlay =v2;
st.overlay.col=backup.col;
st.overlay.wt=backup.wt;
st.overlay.orig =backup;
spm_orthviews2('Redraw');

end


%     v.mat
%
% ans =
%
%     0.0699         0         0   -5.9951
%          0    0.0700         0   -9.5589
%          0         0    0.0700   -8.7410
%          0         0         0    1.0000
%
% v2.mat
%
% ans =
%
%     0.0699         0         0   -5.9951
%          0    0.0700         0   -8.7410
%          0         0    0.0700   -6.5589
%          0         0         0    1.0000
%




%% CONTOUR-->decrease overlay intensity
elseif strcmp(evnt.Character, '#')     

global st

box=getappdata(gcf,'box');
if ~isfield(box,'iscontour')
box.iscontour=0;
end

if    box.iscontour==0;
box.iscontour=1;
%          st.overlay.wt=.0999;
else
box.iscontour=0;
%          st.overlay.wt=.5;
try; delete(findobj(gcf, 'tag','pcontourc'));end
end
setappdata(gcf,'box',box);

spm_orthviews2('Redraw');




elseif (strcmp(evnt.Character, '+')   | strcmp(evnt.Character, '-'))   && isempty(evnt.Modifier)
global st
stp=.1;
if evnt.Character == '-'
stp=-stp;
end

try
st.overlay.wt=st.overlay.wt+stp;
catch
st.overlay.wt=st.overlay.wt+stp;
end
%      if st.overlay.wt>1; st.overlay.wt=1; end
if st.overlay.wt<0; st.overlay.wt=0; end
spm_image2('setparams','wt',st.overlay.wt) ;

box=getappdata(gcf,'box');
box.wt=st.overlay.wt;
setappdata(gcf,'box',box);


%   elseif (evnt.Character == '+'  || evnt.Character=='-' )   && strcmp(evnt.Modifier{:},'control')
%      global st
%        stp=.1;
%      if evnt.Character == '-'
%         stp=-stp;
%      end
%
%      try
%          st.overlay.wt=st.overlay.wt+stp;
%      catch
%          st.overlay.wt=st.overlay.wt+stp;
%      end
%      if st.overlay.wt>1; st.overlay.wt=1; end
%      if st.overlay.wt<0; st.overlay.wt=0; end
%     spm_image2('setparams','wt',st.overlay.wt) ;
%     'jjjjj'

elseif evnt.Key == '1'


prompt = {'Enter StepSize-->Translation:','Enter StepSize-->Rotation:'};
dlg_title = 'Input for peaks function';
num_lines = 1;
def = {num2str(box.stpshift),num2str(box.stpangle)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

box=getappdata(gcf,'box');
box.stpshift=str2num(answer{1});
box.stpangle=str2num(answer{2});
setappdata(gcf,'box',box);


elseif strcmp(evnt.Key, 'space')

box=getappdata(gcf,'box');
if ~isfield(box,'stpsshifttoggle');
box.stpsshifttoggle=[.1 1 ];
box.stpsshifttoggleID=2;
setappdata(gcf,'box',box);
end
box=getappdata(gcf,'box');
id=mod(box.stpsshifttoggleID+1,   length(box.stpsshifttoggle)) ;
if id==0; id=length(box.stpsshifttoggle); end

box.stpsshifttoggleID=id;
box.stpshift=box.stpsshifttoggle( box.stpsshifttoggleID);
%     box.stpshift
setappdata(gcf,'box',box);
disp(['translasionstep: '  num2str(box.stpshift)  ]);
% getappdata(gcf,'box')
hinfo=findobj(gcf,'userdata','myinfo');
set(hinfo,'string',['shiftstep[mm]: ' num2str(box.stpshift)] );



elseif evnt.Key == '2'
if box.isBackgroundOnly==0;
box.isBackgroundOnly=1;
spm_image2('setparams','col',box.col,'wt',0);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
else
box.isBackgroundOnly=0;
spm_image2('setparams','col',box.col,'wt',box.wt);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
end
elseif evnt.Key == '3'
if box.isOverlayOnly==0;
box.isOverlayOnly=1;
spm_image2('setparams','col',box.col,'wt',5);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
else
box.isOverlayOnly=0;
spm_image2('setparams','col',box.col,'wt',box.wt);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
end

elseif evnt.Key == '4'
if box.isOverlayOnly==0;
box.isOverlayOnly=1;
spm_image2('setparams','col',box.col,'wt',5);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
else
box.isOverlayOnly=0;
spm_image2('setparams','col',box.col,'wt',0);
setappdata(gcf,'box',box);
getappdata(gcf,'box');
end

elseif evnt.Character == 't'
global st
r1=st.vols{1};
r2=st.overlay;
try
adjuest=round(-(r1.dim/2)'.*diag(r1.mat(1:3,1:3)));
catch
disp('no overlay selected..');
return
end

for i=1:3
hfig=findobj(0,'tag','Graphics');
ex=findobj(hfig,'callback',['spm_image(''repos'',' num2str(i) ')' ]);
set(hfig,'CurrentObject',ex  );
set(ex,'string',num2str(adjuest(i)) );
hgfeval(get(ex,'callback'));
end
spm_orthviews2('Redraw');







elseif evnt.Character == 'c'
    try
        col=colorui;
    catch
        col=uisetcolor;
    end
spm_image2('setparams','col',col) ;
elseif strcmp(evnt.Key , 'o'  )   &  length(evnt.Modifier) == 0
spm_image2('addoverlay')
spm_image2('setparams','col',box.col,'wt',box.wt);


global st
name2save=st.overlay.fname;
tx=textread(which('keyb.m'),'%s','delimiter','\n');
i1=find(strcmp(tx,'%% pprivate-path'))+1;
i2=find(strcmp(tx,'%% pprivate-pathEND'))-1;
paths =tx(i1:i2);
paths2=[paths; {['% ' name2save ]}];
iredun=find(strcmp(paths2,paths2(end)));
if length(iredun)>1
paths2(iredun(2:end))=[];
end
tx2=[tx(1:i1-1); paths2; tx(i2+1:end)] ;

fid = fopen([ which('keyb.m')],'w','n');
for i=1:size(tx2,1)
dumh=char(  (tx2(i,:)) );
fprintf(fid,'%s\n',dumh);
end
fclose(fid);



elseif strcmp(evnt.Key , 'o'  ) & strcmp(evnt.Modifier{:},'shift') & length(evnt.Modifier) == 1


tx=textread(which('keyb.m'),'%s','delimiter','\n');
i1=find(strcmp(tx,'%% pprivate-path'))+1;
i2=find(strcmp(tx,'%% pprivate-pathEND'))-1;
paths=tx(i1:i2);
paths=regexprep(paths,{'%','''' ,' '}, {'','' ,''});
if isempty(char(paths))
disp('no paths in memory');
return
end

str =paths;
[s,v] = listdlg('PromptString','Select previous file for overlay:',...
'SelectionMode','single','listsize',[600 200],...
'ListString',str);
if v==0; return; end
img2overlay=paths(s);
global st

try
dum=st.overlay;
catch
dum=getappdata(gcf,'box') ;
end
st.overlay=spm_vol(char(img2overlay));
st.overlay.col=dum.col;
st.overlay.wt=dum.wt;

spm_orthviews2('Redraw');


elseif strcmp(evnt.Key , 'f1'  )
o=getprivate( '%% pprivate-ovlF1' );
imageoverlay(char(o));
elseif strcmp(evnt.Key , 'f2'  )
o=getprivate( '%% pprivate-ovlF2' );
imageoverlay(char(o));
elseif strcmp(evnt.Key , 'f3'  )
o=getprivate( '%% pprivate-ovlF3' );
imageoverlay(char(o));


elseif evnt.Character == 'u'
spm_orthviews2('Redraw');
% elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & evnt.Key == 't'
%  'a'


elseif strcmp(evnt.Key,'return')   
spm_orthviews('context_menu','orientation',3);
spm_orthviews2('Redraw');

elseif strcmp(evnt.Key,'tab')  %% UPDATE
spm_orthviews('context_menu','orientation',3);
spm_orthviews2('Redraw');


%% REPOSSITION   

elseif   strcmp(evnt.Key,'leftarrow')           && isempty(evnt.Modifier)

do('l', 'spm_image(''repos'',1)' , box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif   strcmp(evnt.Key,'rightarrow')           && isempty(evnt.Modifier)
do('r', 'spm_image(''repos'',1)' ,-box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif   strcmp(evnt.Key,'uparrow')               && isempty(evnt.Modifier)
do('l', 'spm_image(''repos'',3)' ,-box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif   strcmp(evnt.Key,'downarrow')              && isempty(evnt.Modifier)
do('r', 'spm_image(''repos'',3)' , box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
%% REPOSSITION-old using ctrl   
% elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & strcmp(evnt.Key ,'uparrow'    )
%     do('l', 'spm_image(''repos'',2)' ,-box.stpshift )
% elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & strcmp(evnt.Key , 'downarrow'    )
%     do('l', 'spm_image(''repos'',2)' , box.stpshift )
% elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & strcmp(evnt.Key ,'leftarrow'    )
%     do('l', 'spm_image(''repos'',2)' ,-box.stpshift )
% elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'control') & strcmp(evnt.Key , 'rightarrow'    )
%     do('l', 'spm_image(''repos'',2)' , box.stpshift )

elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'shift') & strcmp(evnt.Key ,'uparrow'    )
do('l', 'spm_image(''repos'',2)' ,-box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'shift') & strcmp(evnt.Key , 'downarrow'    )
do('l', 'spm_image(''repos'',2)' , box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'shift') & strcmp(evnt.Key ,'leftarrow'    )
do('l', 'spm_image(''repos'',2)' ,-box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif length(evnt.Modifier) == 1 & strcmp(evnt.Modifier{:},'shift') & strcmp(evnt.Key , 'rightarrow'    )
do('l', 'spm_image(''repos'',2)' , box.stpshift )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');


%% ANGLES
elseif   strcmp(evnt.Key,'p')           && isempty(evnt.Modifier)
do('l', 'spm_image(''repos'',4)' , box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif  strcmp(evnt.Key , 'p'    ) & strcmp(evnt.Modifier{:},'shift') & length(evnt.Modifier) == 1
do('l', 'spm_image(''repos'',4)' , -box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif   strcmp(evnt.Key,'r')           && isempty(evnt.Modifier)
do('l', 'spm_image(''repos'',5)' , -box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif  strcmp(evnt.Key , 'r'    ) & strcmp(evnt.Modifier{:},'shift') & length(evnt.Modifier) == 1
do('l', 'spm_image(''repos'',5)' ,  box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');

elseif   strcmp(evnt.Key,'y')           && isempty(evnt.Modifier)
do('l', 'spm_image(''repos'',6)' , -box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
elseif  strcmp(evnt.Key , 'y'    ) & strcmp(evnt.Modifier{:},'shift') & length(evnt.Modifier) == 1
do('l', 'spm_image(''repos'',6)' ,  box.stpangle )
% spm_orthviews('context_menu','orientation',3);
% spm_orthviews2('Redraw');
end



%% save textfile with parameters
if  strcmp(evnt.Key , 's'    ) & strcmp(evnt.Modifier{:},'shift') & length(evnt.Modifier) == 1


e=sort(findobj(gcf,'style','edit'));
for ii=1:9
ex=findobj(gcf,'callback' ,  [ 'spm_image(''repos'','  num2str(ii) ')'  ] );
val0(1,ii)=str2num(get(ex,'string'));
end


end


function imageoverlay(file)
% keyboard
global st
try
dum=st.overlay;
catch
dum=getappdata(gcf,'box') ;
end
st.overlay=spm_vol(char(file));
st.overlay=st.overlay(1);
st.overlay.col=dum.col;
st.overlay.wt=dum.wt;

spm_orthviews2('Redraw');




function out=getprivate(label)
% keyboard

tx=textread(which('keyb.m'),'%s','delimiter','\n');
i1=find(strcmp(tx,label))+1;
i2=find(strcmp(tx,'%% pprivate-end'))-1;
i2=i2(min(find(i2>=i1)));

paths=tx(i1:i2);
paths=regexprep(paths,{'%','''' ,' '}, {'','' ,''});
if isempty(char(paths))
out='';
else
out=paths;
end



function helphelp

a=keylisthelp;
% a={};
% a{end+1,1}=' #yg     DISPLAY SHORTCUTS ';
% a{end+1,1}=' � [h] � shortcuts help';
% a{end+1,1}=' � [o] � overlay reference image (userinput/dialog)';
% a{end+1,1}=' � [shift]+[o] � gui with privious used images for overlay';
% a{end+1,1}=' � [c] � color selection for overlay)';
% a{end+1,1}=' � [d] � default settings for color and overlay Transparency)';
% a{end+1,1}=' � [f] � permute/flip Dimension';
% a{end+1,1}=' � [t] � initial center position of PrimaryImage(rough))';
% a{end+1,1}=' � [u] � update overlay)';
% a{end+1,1}=' � [+/-] � change transparency of overlay';
% a{end+1,1}=' � [#] � see/hide contours';
% 
% a{end+1,1}=' � [return] � update overlay';
% 
% a{end+1,1}=' ';
% a{end+1,1}=' � [arrow up/down]  �           up/down';
% a{end+1,1}=' � [arrow left/right]  �        left/right';
% a{end+1,1}=' � [shift]+[arrow up/down] �    backward/forward';
% a{end+1,1}=' � [shift]+[arrow left/right] �  backward/forward';
% a{end+1,1}=' ';
% a{end+1,1}=' � [p] / [shift]+[p] �           -/+pitch';
% a{end+1,1}=' � [r] / [shift]+[r] �           -/+roll';
% a{end+1,1}=' � [y] / [shift]+[y] �           -/+yaw';
% a{end+1,1}=' � [1] �      change stepSize of translation & rotation';
% a{end+1,1}=' � [space] �  toggle transitionStepSize [1,.1], default [1]';
% a{end+1,1}=' ';
% a{end+1,1}=' � [2] �      toggle blendedIMG /Background ';
% a{end+1,1}=' � [3] �      toggle blendedIMG /Overlay ';
% a{end+1,1}=' � [4] �      toggle Background /Overlay ';
% a{end+1,1}=' ';
% a{end+1,1}=' � [f1] �  userdefined overlay: GrayMatter ';
% a{end+1,1}=' � [f2] �  userdefined overlay: WhiteMatter ';
% a{end+1,1}=' � [f3] �  userdefined overlay: CSF ';

% disp(char(a));
uhelp(a,1,'position',[0.4976    0.3900    0.4951    0.5533]);

function do(key,callback, stp )

hfig=findobj(0,'tag','Graphics');
% stp=callback;
e=sort(findobj(gcf,'style','edit'));
% stp
% if strcmp(key,'l')
ex=findobj(gcf,'callback' ,callback);

val0=str2num(get(ex,'string'));
val=val0+stp  ;
set(hfig,'CurrentObject',ex)
%     try
set(ex,'string',num2str(val) );
% try
 hgfeval(get(ex,'callback'));
% else
%     
% hgfeval(get(ex,'callback'));
% 
% 
% 
%     eval(get(gcbo,'String'))
%     
%     
% end



spm_orthviews2('Redraw');
%     catch
%         set(ex,'string',num2str(val0) );
%         hgfeval(get(ex,'callback'));
%         spm_orthviews2('Redraw');
%     end
% end

% e=sort(findobj(gcf,'style','edit'))
% get(e,'string')
% ans =
%     '2'
%     '1'
%     '0.5'
%     '0.001'
%     '0.002'
%     '0.003'
%     '1'
%     '1'
%     '1'
%     '4.9 1.7 -2.5'
%     '127.7 147.0 89.8'
% get(e,'callback')
% ans =
%     'spm_image('repos',1)'
%     'spm_image('repos',2)'
%     'spm_image('repos',3)'
%     'spm_image('repos',4)'
%     'spm_image('repos',5)'
%     'spm_image('repos',6)'
%     'spm_image('repos',7)'
%     'spm_image('repos',8)'
%     'spm_image('repos',9)'
%     'spm_image('setposmm')'
%     'spm_image('setposvx')'



%% pprivate-path
% V:\mritools\tpm\pwhiter62.nii
% V:\MRI_testdata\T2w_nifti\s20150911_FK_C4M20_1_3_1\c3s20150911_FK_C4M20_1_3_1.nii
% V:\MRI_testdata\T2w_nifti\s20150911_FK_C4M20_1_3_1\c1s20150911_FK_C4M20_1_3_1.nii
% V:\MRI_testdata\test3\s20150908_FK_C1M01_1_3_1\mouseatlas.nii
% V:\MRI_testdata\test3\s20150908_FK_C1M01_1_3_1\mrmNeAtMouseBrain_Template_highRes.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\warpAtlases\pmouseatlas.nii
% V:\warpAtlases\A2A_mrmNeAtMouseBrain_Atlas_23_highRes.nii
% V:\MRI_testdata\test3\s20150908_FK_C1M02_1_3_1\c1s20150908_FK_C1M02_1_3_1.nii
% V:\warpAtlases\pmouseatlas.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\aba2011_indexed_volume\aba2011_indexed_volume.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\aba2011_indexed_volume\r__aba2011_indexed_volume.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\aba2011_indexed_volume\wr__aba2011_indexed_volume.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\c1s20150908_FK_C1M01_1_3_1.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\rcanon_T2W_r.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\prcanon_T2W_r.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\ms20150908_FK_C1M01_1_3_1.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\la_rcanon_T2W_r.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\pla_rcanon_T2W_r.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\la_ms20150908_FK_C1M01_1_3_1.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\rWHS_0.6.1_Labels.nii
% C:\Dokumente und Einstellungen\skoch\Desktop\allenAtlas\MBAT_WHS_atlas_v0.6.2\MBAT_WHS_atlas_v0.6.2\Data\s20150908_FK_C1M01_1_3_1.nii
% V:\atlanten\whs\RWHS_0.6.1_Labels.nii
% V:\atlanten\whs\pRWHS_0.6.1_Labels.nii
% v:\whs\brain.nii
% v:\whs\Re_msk_Flab.nii
% v:\whs\CoRe_Ft2w.nii
% v:\whs\rFt2w.nii
% V:\mrm\c1s20150908_FK_C1M01_1_3_1.nii
% V:\mrm\c2s20150908_FK_C1M01_1_3_1.nii
% V:\mrm\c3s20150908_FK_C1M01_1_3_1.nii
% V:\mrm\s20150908_FK_C1M01_1_3_1.nii
% V:\mrm\FrATL.nii
% V:\mrm\rfNat.nii
% V:\mritools\tpm\s20150908_FK_C1M01_1_3_1.nii
% V:\mritools\tpm\pmouseatlas.nii
% V:\harmsSC\nii\s20150908_FK_C1M01_1_3_1\s20150908_FK_C1M01_1_3_1.nii
% V:\harmsSC\nii\s20150908_FK_C1M01_1_3_1\pcsfr62.nii
% V:\harmsSC\nii\s20150908_FK_C1M01_1_3_1\pgreyr62.nii
% V:\harmsSC\nii\s20150908_FK_C1M01_1_3_1\pmouseatlas.nii
% V:\harmsSC\nii\s20150908_FK_C1M01_1_3_1\pwhiter62.nii
% V:\segmentFreiburg\mouseatlas.nii
% V:\harmsSC\tpl\s20150505SM01_1_x_x_1.nii
% V:\harmsSC\tpl\pmouseatlas.nii
% V:\harmsSC\tpl\pgreyr62.nii
% V:\harmsSC\test\s20150505SM01_1_x_x_1\s20150505SM01_1_x_x_1.nii
% V:\harmsSC\s_alt_s20150910_FK_C6M23_1_3_1_\qT2.nii
% V:\harmsSC\s_alt_s20150910_FK_C6M23_1_3_1_\greyr62.nii
% V:\harmsSC\s_neu_s20150505SM01_1_x_x_1\greyr62.nii
% V:\harmsSC\test\greyr62.nii
% V:\harmsSC\nii\s023_20150507SM24_1_x_x_1\greyr62.nii
% O:\TOMsampleData\harms\dat\zzz_BK__s20150909_FK_C2M10_1_3_1\_refIMG.nii
%% pprivate-pathEND

%% pprivate-ovlF1
% V:\mritools\tpm\pgreyr62.nii
%% pprivate-end
%% pprivate-ovlF2
% V:\mritools\tpm\pwhiter62.nii
%% pprivate-end
%% pprivate-ovlF3
% V:\mritools\tpm\pcsfr62.nii
%% pprivate-end







