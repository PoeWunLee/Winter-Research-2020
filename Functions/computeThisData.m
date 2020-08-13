function computeThisData(this_channel)

%description
%computes catch22 using hctsa toolbox. Reads HCTSA_<channel>.mat files from
%<hcsta_mat_files> folder

%input
%this_channel = dataset to be used for catch22 computation, string

%output
%writes the HCTSA_<channel>.mat files with features computed with
%HCTSA_<channel>_N.mat file saved to <hctsa_mat_files> folder for normalised
%features

tic;

%loading data
thisStruct = load(sprintf('Data and mat files\\INP_Files\\INP_test_sleep_%s.mat',this_channel));
timeSeriesData = getfield(thisStruct,'timeSeriesData');
labels = getfield(thisStruct,'labels');
keywords = getfield(thisStruct,'keywords');

%Step 1: initialising
thisFile = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s.mat',this_channel)
thisFileNorm = sprintf('Data and mat files\\hctsa_mat_files\\HCTSA_%s_N.mat',this_channel)
TS_Init(sprintf('Data and mat files\\INP_Files\\INP_test_sleep_%s.mat',this_channel),'INP_mops_catch22.txt','INP_ops_catch22.txt', [true,true,true],thisFile);


%step 2: compute, default settings 
TS_Compute(false,[],[],'missing',thisFile)

%step 3: inspect special values 
TS_InspectQuality('summary',thisFile)

%step 4: normalize label groups 
TS_LabelGroups(thisFile,{})
TS_Normalize('maxmin',[],thisFile)

toc;
end
