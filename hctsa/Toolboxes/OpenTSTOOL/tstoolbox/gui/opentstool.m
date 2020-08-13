function tstool(varargin)

global TSTOOLdatapath TSTOOLpath TSTOOLfilter

% tstool is a matlab toolbox for nonlinear time series analysis
% which includes a graphical user interface (GUI) 
% 
% The command 'tstool' creates a GUI that allows
% the user to perform data manipulation and analysis
% with a wide range of classical and modern nonlinear methods
%
% An optional input argument may be given : The directory path
% from which tstool will load signal files
%
% C.Merkwirth,U.Parlitz,W.Lauterborn  DPI Goettingen 1998

TSTOOLfilter='.sgo';
cwd=pwd;

searchex=exist('nn_search');

if(searchex==2)
    fprintf(['WARNING: mex-files do not seem to be available. Many ' ...
             'features of OpenTSTool will not work!\nDownload ' ...
             'mex-files for your platform or compile them yourself ' ...
             'using makemex in the mex-dev directory.\n'])
elseif(searchex==0)
    fprintf(['Seems like OpenTSTool paths are not set. Will try to set ' ...
          'them now... '])
    if(exist('settspath')==2)
        tstoolpath=fileparts(which('settspath'));
        settspath(tstoolpath);
        fprintf('done.\n')
    elseif(exist('tstool')==2)
        tstoolpath=fileparts(which('tstool'));
        tstoolpath=fullfile(tstoolpath,['..' filesep '..' filesep']);
        if(exist(fullfile(tstoolpath,'settspath.m'))==2)
            addpath(tstoolpath);
            settspath(tstoolpath);
            fprintf('done.\n')
        else
            error(['Sorry, could not set path. Please use settspath ' ...
                  'before calling tstool.'])
        end
    else
        error(['Sorry, could not set path. Please use settspath ' ...
               'before calling tstool.'])
    end
end



if ~isempty(findobj('Tag', 'TSTOOL'))
  error('Another tstool window seems to be running, only one at a time is possible');
end    		

load tstool.mat -mat    
                       
screensize = get(0, 'ScreenSize');
%Settings = get(0, 'UserData');
TSTOOLpath=fileparts(which('units.mat'));
datafiles={};
% if length(Settings) > 2
% 	TSTOOLdatapath = Settings{3};
% else
% 	TSTOOLdatapath = '';
% end

if nargin > 0
  TSTOOLdatapath = varargin{1};
end
if isunix
  a=pwd;
  cd('~');  
  b=pwd;
  TSTOOLdatapath = fullfile(b, '.tstool');
  cd(a);
else
  TSTOOLdatapath= fullfile(fileparts(TSTOOLpath),'datafiles');
end

if ~exist(TSTOOLdatapath,'dir')
  if isequal(questdlg(['TSTOOL needs a datapath to store the' ...
		       ' calculation results. The datapath ' ... 
		       TSTOOLdatapath ' doesnt exists! Should I create' ...
		    ' it?'], 'Question','Yes','Cancel','Yes'),'Yes') 
    [path,name,ext]=fileparts(TSTOOLdatapath);
    if mkdir(path,[name ext])==0
      disp(['Could not create datapath ' TSTOOLdatapath '!']);
      return
    end
    [path,name,ext]=fileparts(fullfile(TSTOOLdatapath,'scripts'));
    if mkdir(path,[name ext])==0
      disp(['Could not create datapath ' fullfile(TSTOOLdatapath,'scripts') '!']);
      return
    end
  else
    return
  end
end

readpath = TSTOOLdatapath;
writepath = TSTOOLdatapath;



% try to list all files from directory @signal under menu 'help'
sigdir = dir(fullfile(TSTOOLpath, '@signal' , '*.m'));

% sort directory entries
names = cell(length(sigdir),1);
for i=1:length(sigdir)
	names{i,1} = sigdir(i).name;	
end

[dummy, index] = sortrows(char(names));
sigdir = sigdir(index);

ScreenSize=get(0,'ScreenSize');
FigWidth=600;FigHeight=200;
FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;

a = figure('Units','normalized',...
	'Visible', 'off', ...
	'Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'MenuBar','none', ...
	'Name','TSTOOL V1.2', ...
	'NumberTitle','off', ...
	'PaperOrientation','landscape', ...
	'PaperType','a4letter', ...
	'Units', 'pixels', ...
	'Position',FigPos, ...
	'Tag', 'TSTOOL');
fighandle = a;
set(0, 'DefaultTextInterpreter', 'none');
	b = uimenu('Parent',a, ...
		'Label','Signal', ...
        'Tag','List');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''load'')', ...
			'Label','Load', ...
			'Tag','Load');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''save'')', ...
			'Label','Save', ...
			'Tag','Save');
		c = uimenu('Parent',b, ...
			'Label','Import file from', ...
			'Separator','on', ...
			'Tag','Import');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''impascii'')', ...
				'Label','ASCII', ...
				'Tag','ImpASCII');
			d = uimenu('Parent',c, ...
				   'Enable', 'on', ...
				   'Callback', 'tscallback(''impmat'')',...
				   'Label', 'Matlab', ...
				   'Tag', 'ImpMAT');
			d = uimenu('Parent',c, ...
				'Label','Sound file', ...
				'Tag','FileImport file fromSound file1');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''impwav'')', ...
					'Label','.wav', ...
					'Tag','ImpWav');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''impau'')', ...
					'Label','.au', ...
					'Tag','ImpAu');

			d = uimenu('Parent',c, ...
				'Callback','tscallback(''impnld'')', ...
				'Enable', 'off', ...
				'Label','NLD-Format', ...
				'Tag','ImpNLD');				
			d = uimenu('Parent',c, ...
				'Enable', 'off', ...
				'Callback','tscallback(''impnetcdf'')', ...
				'Label','netCDF', ...
				'Tag','ImpnetCDF');
			
			
% Check for installed netCDF tools from
% http://www.marine.csiro.au/sw/matlab-netcdf.html
			if (exist('mexcdf53','file')==3) & ... 
			  (exist('getnc','file')==2),
			  set(d, 'Enable', 'on');
			end;

		c = uimenu('Parent',b, ...
			'Label','Export file to', ...
			'Tag','Export');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''ascii'')', ...
				'Label','ASCII', ...
				'Tag','ascii');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''mat'')', ...
				'Label','Matlab', ...
				'Tag','mat');
			d = uimenu('Parent',c, ...
				'Enable', 'off', ...
				'Callback','tscallback(''nld'')', ...
				'Label','NLD-Format', ...
				'Tag','ExpNLD');
			d = uimenu('Parent',c, ...
				'Enable', 'off', ...
				'Callback','tscallback(''sipp'')', ...
				'Label','si++ Format', ...
				'Tag','ExpSI++');
		c = uimenu('Parent',b, ...
			'Label','Generate Data', ...
			'Separator','on', ...
			'Tag','Generate');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''sine'')', ...
				'Label','Sine', ...
				'UserData', { '1', '1000', '1', '8000', '0' }, ...
				'Tag','sine');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''fnoise'')', ...
				'Tag','fnoise', ...
				'UserData', { '1' ,  '8000'}, ...
				'Label','Spectral flat noise');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''unoise'')', ...
				'Tag','unoise', ...
				'UserData', { '1' ,  '8000'}, ...
				'Label','Uniform distributed random numbers');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''gnoise'')', ...
				'Tag','gnoise', ...
				'UserData', { '1' ,  '8000'}, ...
				'Label','Gaussian distributed random numbers');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''dynsys'')', ...
				'Label','Integrate dynamical system', ...
				'UserData', {'lorenz', '[0; 0.01; -0.01]', '40', '50', 'ode45'}, ...
				'Tag','dynsys');
			d = uimenu('Parent',c, ...
				'Separator' , 'on', ...
				'UserData', {'Lorenz', '[-10 28 -2.66666666]','[0 0.01 -0.01]',  '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Lorenz', ...
				'Label','Lorenz');
			d = uimenu('Parent',c, ...
				'UserData', {'Chua', '[9.0 14.286]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Chua', ...
				'Label','Chua');
			d = uimenu('Parent',c, ...
				'UserData', {'Chua5Scroll', '[9.0 14.286]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Chua5Scroll', ...
				'Label','Chua5Scroll');
			d = uimenu('Parent',c, ...
				'UserData', {'Duffing', '[40 0.2 1.0]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Duffing', ...
				'Label','Duffing');
			d = uimenu('Parent',c, ...
				'UserData', {'Roessler', '[0.45 2.0 4.0]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Roessler', ...
				'Label','Roessler');
			d = uimenu('Parent',c, ...
				'UserData', {'Toda', '[0 0.01 -0.01]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Toda', ...
				'Label','Toda');
			d = uimenu('Parent',c, ...
				'UserData', {'VanDerPol', '[0 0.01 -0.01 0.03]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'VanDerPol', ...
				'Label','VanDerPol');	
			d = uimenu('Parent',c, ...
				'UserData', {'Colpitts', '[4.7e-6 4.7e-6 2.7e-3 390 20 5 -5]', '[0 0.01 -0.01]', '40', '50'}, ...
				'Callback','tscallback(''genbyode'')', ...
				'Tag', 'Colpitts', ...
				'Label','Colpitts');	
			d = uimenu('Parent',c, ...
				'Separator' , 'on', ...
				'UserData', {'Henon', '[-1.4 0.3]', '[0.01 0.04]', '500'}, ...
				'Callback','tscallback(''genbymap'')', ...
				'Tag', 'Henon', ...
				'Label','Henon');					
			d = uimenu('Parent',c, ...
				'UserData', {'Baker', '[0.6 0.25 0.4]', '[0.01 0.2]', '500'}, ...
				'Callback','tscallback(''genbymap'')', ...
				'Tag', 'Baker', ...
				'Label','Baker');		
			d = uimenu('Parent',c, ...
				'UserData', {'Tentmap', '[0 1 0.97]', '0.3465', '500'}, ...
				'Callback','tscallback(''genbymap'')', ...
				'Tag', 'Tentmap', ...
				'Label','Tentmap');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''da'')', ...
			'Label','Audio playback', ...
			'Tag','DA');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''loadall'')', ...
			'Label','Rescan', ...
			'Tag','LoadAll', ...
			'UserData',TSTOOLfilter);
		lallhandle = c;
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''Rm!!!'')', ...
			'Label','Remove entry', ...
			'Accelerator', 'd');
%       	c = uimenu('Parent',b, ...
% 			'Callback','tscallback(''makescript'')', ...
% 			'Label','Make script from signal', ...
% 			'Separator','on');
		c = uimenu('Parent',b, ...
			'Separator','on', ...
			'Label','Show ...');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''info'')', ...
				'Label','Summary Info');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''history'')', ...
				'Label','History');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''plot'')', ...
				'Label','View','Accelerator','v');
		c = uimenu('Parent',b, ...
			'Label','Edit');
			d = uimenu('Parent',c, ...
				'Label','Desired type of plot');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''graph'')', ...
					'Label', 'graph');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''bar'')', ...
					'Label', 'bar');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''surrerrorbar'')', ...
					'Label', 'surrerrorbar');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''surrbar'')', ...
					'Label', 'surrbar');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''points'')', ...
					'Label', 'points');	
				e = uimenu('Parent',d, ...
					'Separator', 'on', ...
					'Callback','tscallback(''editplothint'', ''xyplot'')', ...
					'Label', 'xyplot');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''xypoints'')', ...
					'Label', 'xypoints');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''scatter'')', ...
					'Label', 'scatter');	
				e = uimenu('Parent',d, ...
					'Separator', 'on', ...
					'Callback','tscallback(''editplothint'', ''3dcurve'')', ...
					'Label', '3dcurve');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''3dpoints'')', ...
					'Label', '3dpoints');	
				e = uimenu('Parent',d, ...
					'Separator', 'on', ...
					'Callback','tscallback(''editplothint'', ''spectrogram'')', ...
					'Label', 'spectrogram');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''image'')', ...
					'Label', 'image');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''multigraph'')', ...
					'Label', 'multigraph');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''multipoints'')', ...
					'Label', 'multipoints');	
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''editplothint'', ''subplotgraph'')', ...
					'Label', 'subplotgraph');						
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''edit'')', ...
				'Label','Descriptive parameters');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''editaxes'')', ...
				'Label','Axes parameters');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''newcomment'')', ...
				'Label','Comment text');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''exit'')', ...
			'Label','Exit', ...
			'Separator','on', ...
			'Tag','Exit');
	b = uimenu('Parent',a, ...
		'Label','Methods I');
		c = uimenu('Parent',b, ...
			'Label','Reconstruction');		
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''embed'')', ...
				'Label','Time-Delay Vectors');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''mixembed'')', ...
				'Label','Mixed-State Vectors');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''stts'')', ...
% 				'Label','Spatio-Temparal (STTS)');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''multichannel'')', ...
% 				'Label','Multichannel', ...
% 				'Tag','MethodsReconstructionMultichannel1');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''cao'')', ...
				'Separator', 'on', ...
				'Label','Minimum Embedding Dimension (Cao)');			
		c = uimenu('Parent',b, ...
			'Label','Spectral');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''fft'')', ...
				'Label','FFT');			
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''spec'')', ...
				'Label','Periodogram');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''psd'')', ...
% 				'Label','Power Spectral Density');				
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''spec2'')', ...
                'Label','Spectrogram');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''scalogram'')', ...
				'Label','Scalogram');					
%             d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''aok'')', ...
% 				'Label','TFR using Adaptive Kernel');
		c = uimenu('Parent',b, ...
			'Label','Derivative/Integration');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''int'')', ...
				'Label','Integrate');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''diff'')', ...
				'Label','Differentiate');	
		c = uimenu('Parent',b, ...
			'Label','Correlation and more');
                        d = uimenu('Parent',c, ...
				'Callback','tscallback(''acf'')', ...
				'Label','Auto Correlation');				
%                        d = uimenu('Parent',c, ...
%				'Callback','tscallback(''ccf'')', ...
%				'Label','Cross Correlation');				
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''amutual'')', ...
                  'Label','Auto Mutual Information');
%             	d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''gmi'')', ...
% 				'Label','Generalized Mutual Information');	
		c = uimenu('Parent',b, ...
			'Label','Filter');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''movav'')', ...
				'Label','Moving Average');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''medianfilt'')', ...
				'Label','Median Filter');
%			d = uimenu('Parent',c, ...
%				'Callback','tscallback(''highpass'')', ...
%				'Enable' ,'off', ...
%				'Label','High-Pass');
%			d = uimenu('Parent',c, ...
%				'Callback','tscallback(''lowpass'')', ...
%				'Enable' ,'off', ...
%				'Label','Low-Pass');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''filterbank'')', ...
% 				'Label','Filterbank');				
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''multires'')', ...
				'Label','Multiresolution Analysis');
	        c = uimenu('Parent',b, ...
			'Label','Surrogate Data Generation');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''surrogate3'')', ...
				'Label','Permutation of Samples');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''surrogate1'')', ...
				'Label','Theiler Alg. I');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''surrogate2'')', ...
				'Label','Theiler Alg. II');
		c = uimenu('Parent',b, ...
			'Label','Surrogate Data Test', ...
			'UserData', {'1','10','1',0,0,0});
		trevtc3handle=c;    
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''trev'')', ...
				'Label','Time Reversibility');			    
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''tc3'')', ...
				'Label','Higher order moments');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''surro'')', ...
				'Label','Function', ...
			         'UserData',{'10','1', ...
			  'corrsum(embed(s,3,1,1), -1, 0.1, 20, 32, 0);'});
		surrogatehandle=d;
		c = uimenu('Parent',b, ...
			'Label','Prediction');	
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''scalarpredict'')', ...
				'Label','Local Constant');
% 		c = uimenu('Parent',b, ...
% 			'Label','Psychoacoustics');	
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''level_adaption'')', ...
% 				'Label','Level Adaption');		
		c = uimenu('Parent',b, ...
			'Label','Misc');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''power'')', ...
				'Label','Squared Magnitude');			
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''abs'')', ...
				'Label','Absolut Value');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''db'')', ...
				'Label','Decibel Values');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''histo'')', ...
				'Label','Histogram');																							
% 		c = uimenu('Parent',b, ...
% 			'Enable', 'off', ... 
% 			'Label','Classification');
	b = uimenu('Parent',a, ...
		'Label','Methods II');
		c = uimenu('Parent',b, ...
			'Label','Decompositions');		
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''pca'')', ...
				'Label','PCA (Karhunen-Lo�ve)');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''archetypes'')', ...
				'Label','Archetypal Analysis');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''mutual'')', ...
% 				'Enable', 'off', ...
% 				'Label','Mutual Information');
		c = uimenu('Parent',b, ...
            'Label', 'Lyapunov Exponents');
           d = uimenu('Parent',c, ...
				'Callback','tscallback(''largelyap'')', ...
				'Label','Largest');	
%           d = uimenu('Parent',c, ...
%				'Callback','tscallback(''lyapspectrum'')', ...
%				'Enable', 'off', ...
%				'Label','Spectrum');									
        c = uimenu('Parent',b, ...
			'Label','Fractal Dimensions');
			d = uimenu('Parent',c, ...
				'Label','Box Counting Approach');	
            	e = uimenu('Parent',d, ...
					'Callback','tscallback(''boxdim'')', ...
					'Label','Capacity Dimension D0');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''infodim'')', ...
					'Label','Information dimension D1');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''corrdim'')', ...
                	'Label','Correlation dimension D2');
			d = uimenu('Parent',c, ...
				'Label','Correlation Sum Approach');						
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''corrsum'')', ...
                	'Label','Correlation Sum D2 (GPA like approach)');
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''corrsum2'')', ...
                	'Label','Correlation dimension D2 (fixed number of pairs)');					
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''tak_est'')', ...
                	'Label','Takens Estimator D2');
			d = uimenu('Parent',c, ...
				'Label','Nearest Neighbor Algorithms');						
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''infodim2'')', ...
                	'Label','Information dimension D1 (NNK)');		
				e = uimenu('Parent',d, ...
					'Callback','tscallback(''fracdims'')', ...
                	'Label','Fractal dimension spectrum');									
		c = uimenu('Parent',b, ...
			'Label','Periodicity');
              d = uimenu('Parent', c, ...
				'Callback','tscallback(''ret_time'')', ...
                'Label','Return Times');  
   			d = uimenu('Parent', c, ...
				'Callback','tscallback(''density'')', ...
                'Label','Reciprocal local density');   	
		c = uimenu('Parent',b, ...
			'Label','Modeling');
              d = uimenu('Parent', c, ...
				'Callback','tscallback(''polmodel'')', ...
                'Label','Polynom selection');  							
		c = uimenu('Parent', b, ...
			'Callback','tscallback(''poincare'')', ...
			'Label','Poincare Section');				             
		c = uimenu('Parent',b, ...
			'Label','Prediction');	
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''localconstpred'')', ...
				'Label','Local Constant');
% 			d = uimenu('Parent',c, ...
% 				'Callback','tscallback(''prederr'')', ...
% 				'Label','Prediction Error', ...
% 				'Enable', 'off');	
%		c = uimenu('Parent',b, ...
%			'Enable', 'off', ... 
%			'Label','Models');
% 		c = uimenu('Parent',b, ...
% 			'Label','?????????');
% 			d = uimenu('Parent', c, ...
% 				'Callback','tscallback(''nnstatistic'')', ...
% 				'Enable', 'off', ...
%                 'Label','Nearest neighbour statistic');
	b = uimenu('Parent',a, ...
		'Label','Utilities');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''min'')', ...
			'Label','Minimum');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''max'')', ...
			'Label','Maximum');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''firstmin'')', ...
			'Label','First Local Minimum');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''firstmax'')', ...
			'Label','First Local Maximum');			
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''firstzero'')', ...
			'Label','First Zero Crossing');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''mean'')', ...
			'Label','Mean');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''std'')', ...
			'Label','Standard Deviation');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''rms'')', ...
			'Label','RMS');	
		c = uimenu('Parent',b, ...
			'Separator','on', ...
			'Callback','tscallback(''compare'')', ...
			'Label','Compare two Signals');
	b = uimenu('Parent',a, ...
		'Label','Modify', ...
		'Tag','Modify');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''cut'')', ...
			'Label','Cut', ...
			'Tag','ModCut');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''swap'')', ...
			'Label','Swap Dimensions');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''reverse'')', ...
			'Label','Reverse');
		c = uimenu('Parent',b, ...
			'Label','Interpolation');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''cubicsplineinterp'')', ...
				'Label','Cubic Spline');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''akimasplineinterp'')', ...
				'Label','Akima Spline');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''fftinterp'')', ...
				'Label','FFT Based');			
		c = uimenu('Parent',b, ...
			'Label','Normalize');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''center'')', ...
				'Label','Center around Zero');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''scale'')', ...
				'Label','Scale by Factor');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''norm1'')', ...
				'Label','Fit to Interval');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''norm2'')', ...
				'Label','Center and Divide by STD');
			d = uimenu('Parent',c, ...
				'Callback','tscallback(''trend'')', ...
            'Label','Remove Trend');
         d = uimenu('Parent',c, ...
				'Callback','tscallback(''rang'')', ...
				'Label','Transform to Rang Values');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''split'')', ...
			'Separator','on', ...
			'Label','Split Multichannel Signal');
		c = uimenu('Parent',b, ...
			'Separator','on', ...
			'Callback','tscallback(''plus'')', ...
			'Label','Add two Signals');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''minus'')', ...
			'Label','Difference of two Signals');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''merge'')', ...
			'Label','Merge two Signals');
	b = uimenu('Parent',a, ...
		'Label','Macro','UserData','macro');			
	macrohandle=b;	
	create_scripts_submenu(b);	
					
	b = uimenu('Parent',a, ...
		'Label','Options', ...
		'Tag','Options1');
		c = uimenu('Parent',b, ...
			'Label','Parameters');
				d = uimenu('Parent',c, ...
					'Callback','tscallback(''embparm'')', ...
					'Label','Reconstruction Parameters', ...
					'UserData', {'3', '1', '1', 'Rect', 0, 0, 0, 0});
				recopthandle = d;
				d = uimenu('Parent', c, ...
					'Label','Default Window Type', ...
					'UserData', 'Hamming');
				defwindowhandle = d;	
					e = uimenu('Parent', d, ...
						'Label', 'Hamming', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Hamming'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Hanning', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Hanning'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Nuttall', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Nuttall'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Papoulis', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Papoulis'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Harris', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Harris'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Rect', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Rect'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Triang', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Triang'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Bartlett', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Bartlett'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Blackman', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Blackman'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Gauss', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Gauss'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Parzen', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Parzen'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Kaiser', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Kaiser'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Dolph', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Dolph'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Hanna', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Hanna'')']); 		
					e = uimenu('Parent', d, ...
						'Label', 'Nutbess', ...
						'Callback' , ['set(' num2str(d) ', ''UserData'', ''Nutbess'')']); 		
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''optmisc'')', ...
			'Label','File and Directory Options', ...
			'UserData',{TSTOOLfilter cwd});
		loadhandle = c;
		c = uimenu('Parent',b, ...
			'Label','Instant View');				
			d1 = uimenu('Parent',c, ...
				'Callback','tscallback(''togglepreviewmode'', 1)', ...
				'Label','Small Window', ...
				'Checked', 'off');	
			d2 = uimenu('Parent',c, ...
				'Callback','tscallback(''togglepreviewmode'', 2)', ...
				'Label','Large Window', ...
				'Checked', 'off');
			plotmodehandle = [d1 d2];						
	b = uimenu('Parent',a, ...
		'Label','Help', ...
		'Tag','Help1');
		c = uimenu('Parent',b, ...
			'Callback','tscallback(''about'')', ...
			'Label','About TSTOOL', ...
                        'Callback', 'tstoolabout(''TSTOOL V1.2'');', ...
                        'Tag','About1');
%			'Callback', 'msgbox( { ''                       TSTOOL'' ; ''     Drittes Physikalisches Institut'';  ''Georg-August-Universit�t G�ttingen''; ''                  1997-2008''} ,''About tstool'', ''none'' )'
		c = uimenu('Parent',b, ...
			'Callback', ['web(''file://' fullfile(fileparts(TSTOOLpath), ...
							   'Doc', 'HTML', 'index.html') ''');'], ...
			'Label','Usage');	
%			'Callback', ['!netscape -remote "openFILE(' fullfile(TSTOOLpath, ...
%							   '..', 'Doc', 'HTML', 'index.html')  ')" &'], ...
		c1 = uimenu('Parent',b, ...
			'Separator' , 'on', ...
			'Label','Modules A-D');		
		c2 = uimenu('Parent',b, ...
			'Label','Modules E-H');		
		c3 = uimenu('Parent',b, ...
			'Label','Modules I-N');	
		c4 = uimenu('Parent',b, ...
			'Label','Modules O-T');	
		c5 = uimenu('Parent',b, ...
			'Label','Modules U-Z');	
		for i=1:length(sigdir)	
			hname = sigdir(i).name;	
			index = findstr(hname, '.m');	
			if ~isempty(index)
				hname = hname(1:index(1)-1);
				if ~isempty(hname)
					switch lower(hname(1))
						case {'a', 'b', 'c', 'd'}
							parent = c1;
						case {'e', 'f', 'g', 'h'}
							parent = c2;
						case {'i', 'j', 'k', 'l', 'm', 'n'}
							parent = c3;
						case {'o', 'p', 'q', 'r' , 's', 't'}
							parent = c4;
						case {'u', 'v', 'w', 'x', 'y', 'z'}
							parent = c5;		
					end
					d = uimenu('Parent',parent, ...
					'Callback',['tshelp(''' hname ''');'], ...
					'Label', hname);	
				end
			end 
		end	
	b = uimenu('Parent',a, ...
            'Label','View', ...
            'Callback','tscallback(''plot'')','Accelerator','v');   		
	b = uicontrol('Parent',a, ...
		'Units','normalized', ...
		'BackgroundColor',[1 1 1], ...
		'Callback','tscallback(''select'')', ...
		'Position',[0.00609756 0.035 0.657012 0.917732], ...
		'Style','listbox', ...
		'Tag','Listbox1', ...
		'Value',1,...
	        'UserData',{});
	lboxhandle = b;
	b = axes('Parent',a, ...
		'CameraUpVector',[0 1 0], ...
		'Color',[1 1 1], ...
		'ColorOrder',mat2, ...
		'Position',[0.724085 0.123711 0.243902 0.804124], ...
		'Tag','Axes', ...
		'XColor',[0 0 0], ...
		'YColor',[0 0 0], ...
		'ZColor',[0 0 0]);
		c = text('Parent',b, ...
			'Color',[0 0 0], ...
			'HandleVisibility','callback', ...
			'HorizontalAlignment','center', ...
			'Position',[0.49375 -0.171875 0], ...
			'Tag','Axes2Text4', ...
			'VerticalAlignment','cap');
		set(get(c,'Parent'),'XLabel',c);
		c = text('Parent',b, ...
			'Color',[0 0 0], ...
			'HandleVisibility','callback', ...
			'HorizontalAlignment','center', ...
			'Position',[-0.16875 0.492188 0], ...
			'Rotation',90, ...
			'Tag','Axes2Text3', ...
			'VerticalAlignment','baseline');
		set(get(c,'Parent'),'YLabel',c);
		c = text('Parent',b, ...
			'Color',[0 0 0], ...
			'HandleVisibility','callback', ...
			'HorizontalAlignment','right', ...
			'Position',[-2.80625 1.07031 0], ...
			'Tag','Axes2Text2', ...
			'Visible','off');
		set(get(c,'Parent'),'ZLabel',c);
		c = text('Parent',b, ...
			'Color',[0 0 0], ...
			'HandleVisibility','callback', ...
			'HorizontalAlignment','center', ...
			'Position',[0.49375 1.04688 0], ...
			'Tag','Axes2Text1', ...
			'VerticalAlignment','bottom');
		set(get(c,'Parent'),'Title',c);

%b = uicontrol('Parent',a, ...
%	'Units','normalized', ...
%	'Position',[0.00914634 0.835052 0.647866 0.113402], ...
%	'BackgroundColor',[1 1 1], ...
%	'String','', ...
%	'Style','text', ...
%	'HorizontalAlignment', 'left', ...
%	'Tag','StaticText1');

%currfilehandle = b;

handles.fighandle 	= fighandle;				% figure handle for tstool main window
handles.lboxhandle 	= lboxhandle;				% listbox handle
handles.loadhandle 	= loadhandle;				% 
handles.lallhandle 	= lallhandle;				% 
handles.recopthandle 	= recopthandle; 		% Options (parameters) for time-delay reconstruction
handles.plotmodehandle = plotmodehandle;		% Flag : small/large plots
handles.macro=macrohandle;
% handles.currfilehandle = currfilehandle;		% Currently selected file
handles.defwindowhandle = defwindowhandle;		% Default window type
handles.surrogate=surrogatehandle;
handles.trevtc3=trevtc3handle;


if exist(fullfile(TSTOOLdatapath,'tstool.mat'))
  loadsettings(handles);
  datafiles=get(lboxhandle,'UserData');
  %  load(fullfile(TSTOOLdatapath,'tstool.mat'));
else  
  [status,datafiles] = loadallfiles(fullfile(TSTOOLdatapath,['*' TSTOOLfilter]), TSTOOLfilter);
  cla
  if status == 0
    datafiles=sortdatafiles(datafiles);
  end
end
filllistbox(datafiles,handles,1);
set(lboxhandle,'UserData',datafiles);

set(fighandle, 'UserData', handles);
%eval('tscallback(''mkdir'')', 'warndlg(lasterr)'); % this line prompts for the read and write path
set(fighandle, 'Visible', 'on');

%colormap('gray');
%image(imread(fullfile(TSTOOLpath,'..','Doc','HTML','logo.gif')));

function create_scripts_submenu(parentobjhandle)

global TSTOOLdatapath

% first delete all children of menu 'Macro'

path(fullfile(TSTOOLdatapath,'scripts'),path);
delete(get(parentobjhandle, 'Children'));

% then create standard submenus

c = uimenu('Parent',parentobjhandle, ...
	'Callback','tscallback(''makemacro''); % create_scripts_submenu(findobj(0, ''Label'', ''Macro''))', ...
	'Separator', 'on', ...
	'Label','Create Macro from Signal');
c = uimenu('Parent',parentobjhandle, ...
	'Callback','tscallback(''editmacro'')', ...
	'Label','Show/Edit Macro');
c = uimenu('Parent',parentobjhandle, ...
	'Callback','tscallback(''renamemacro''); % create_scripts_submenu(findobj(0, ''Label'', ''Macro''))', ...
	'Label','Rename Macro');	  
c = uimenu('Parent',parentobjhandle, ...
	'Callback','tscallback(''macro'')', ...
	'Label','Apply Macro to Signal');
c = uimenu('Parent',parentobjhandle, ...
	'Callback','tscallback(''forall'')', ...
	'Label','Apply Macro to all Signals');

% try to append all m. files located in directory scripts under menu 'Macro'

screensize = get(0, 'ScreenSize');
%Settings = get(0, 'UserData');
%TSTOOLpath = Settings{1};



%return
scriptdir = dir(fullfile(TSTOOLdatapath, 'scripts' , '*.m'));

% sort directory entries
names = cell(length(scriptdir),1);
for i=1:length(scriptdir)
	names{i,1} = scriptdir(i).name;	
end

[dummy, index] = sortrows(char(names));
scriptdir = scriptdir(index);

for i=1:length(scriptdir)	
	hname = scriptdir(i).name;	
	index = findstr(hname, '.m');	
	if ~isempty(index)
		hname = hname(1:index(1)-1);
		if ~isempty(hname)
			d = uimenu('Parent',parentobjhandle, ...
			'Label', hname, ...
		        'Callback',['fighandle = findobj(''Tag'', ''TSTOOL'');' ...
	                            'handles = get(fighandle, ''UserData'');' ... 
				    'set(handles.macro,''UserData'',''' hname ''' );' ....
				    'tscallback(''macro'');']);	
			if i==1
				set(d, 'Separator', 'on');
			end
		end
	end 
end	


