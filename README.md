# Winter Research 2020: Neural basis of consciousness (data analytics) - Sleep Staging
# Monash University (tLab)

## Introduction
Human EEG recordings over 32 hours of a sample is obtained. 
The assumed sleep region from the dataset is extracted for channels Fp1 and Fp2 and analysed using highly comparative time series analysis (hctsa). 
In this project, a subset of the highest performing 22 canonical features out of the 7000 time series analyses in hctsa are considered, known as catch22.
The features are then analysed and visualised, utilising unsupervised machine learning and dimensionality reduction techniques.
All codes are written in MATLAB.

## Prerequisites to run code
1) hctsa toolbox (https://github.com/benfulcher/hctsa)
2) fieldtrip toolbox (http://www.fieldtriptoolbox.org)

## Description
### Step 1: doExtractTimeSeries
Extract data from .edf files and convert to .mat files, which are both located in _*Data and mat files*_. 

### Step 2: doSaveINP
Saves INP files which are required for initialisation for catch22 execution

### Step 3: docatch22
Compute catch22 features and saves results + figures 

### Step 4: doKMeansAndDimReduction
Clustering and visualisation of clusters in low dimentional space

### Step 5: doCompareDataMat
Repeat from step 1- step 4 for another dataset case (e.g. processed vs unprocessed) and execute this to compare and visualise correlation of features

## References
* B.D. Fulcher, M.A. Little, N.S. Jones. Highly comparative time-series analysis: the empirical structure of time series and their methods. J. Roy. Soc. Interface 10, 83 (2013).
* B.D. Fulcher and N.S. Jones. hctsa: A computational framework for automated time-series phenotyping using massive feature extraction. Cell Systems 5, 527 (2017).
* C.H. Lubba, S.S. Sethi, P. Knaute, S.R. Schultz, B.D. Fulcher, N.S. Jones. catch22: CAnonical Time-series CHaracteristics. Data Mining and Knowledge Discovery 33, 1821 (2019).
