# Scripts and data to support manuscript "Thermal stress responses and survival differ among closely related coral taxa of the Stylophora pistillata species complex during a heatwave"

### A. Scripts for calling variants for host whole genome sequence data

### B. Scripts for data analyses and visualisation

01_ereefs_data.R

Obtaining temperature data from eReefs for sampling sites and calculating derived metrics

02_NOAA_data.R

Obtaining temperature data from NOAA to calculate Degree Heating Weeks 

03_temperature_HOBO.R

Compairing in situ logger data in tanks with NOAA data
Code for Figure 1A

04_env_PCA.R

Performing PCA on environmental data
Code for Figure SX

05_genomic_PCA.R

Performing PCA on genomic data, for all individuals, for all individuals with outgroup samples representative of the three cryptic taxa, and for a subset of five samples per taxon
Code for Figure 2A

06_taxon_distribution.R

Mapping taxa distribution across sampling sites
Code for Figure 2C

07_data_wrangling.R

Wrangling data to make it long format

08_time_series.R

Analysing key phenotypic traits across time points
Code for Figure 3A

09_phenotypic_responses.R

Calculating phenotypic response traits from time series data

10_GLM.R

Performing generalised linear models on phenotypic response traits, for all taxa and for Taxon1 only
Testing model significance
Estimating marginal means
Code for Figure 4

11_surival_analyses.R

Performing survival analyses
Code for Figure 3

12_dhw_survival.R

Performing survival analyses before and after peak degree heating week
Code for Figure SX

13_in_ex_situ.R

Performing analyses to compare in situ and ex situ survival
Code for Figure 5

14_symbionts_ITS2.R
