# Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave

This repository contains scripts and supporting data for the manuscript:

> **Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave**

In this study, we explored  thermal tolerance in the Stylophora pistillata species complex during the 2024 marine heatwave at Heron Island Reef, Australia. We used a long-term common garden experiment that mimced the heatwave thermal profile and  quantified inter- and intra-specific differences in bleaching and survival. We found distinct heat-stress responses between the three cryptic taxa, but weak evidence of within-taxon local acclimatisation or adaptation among reef habitats. Importantly, survival patterns in the common garden mirrored those on the reef. Overall, this study highlights complex interactions among host identity, symbiont community, and environmental history in shaping coral thermal tolerance.

---

## Repository Overview

The repository is organised into two main sections:

1. Data - Raw and processed data used for analyses
   
2. Scripts - Bash and R Scripts used for analyses
   
 **A. Variant calling for host whole genome sequence data**  
   Scripts for processing raw sequencing reads, variant calling, and quality control.

 **B. Data analyses and visualisation**  
   R scripts used to analyse environmental, genomic, and phenotypic datasets, and to reproduce figures from the manuscript.

Each script is numbered to indicate its order in the analytical workflow.

---

## A. Scripts for calling variants

Scripts in this section process whole-genome sequencing data of the coral host to obtain high-quality SNPs for downstream analyses.  
*(See manuscript Methods for details.)*

---

## B. Scripts for data Analyses and visualisation

### **01_ereefs_data.R**
- Retrieve temperature data from **eReefs** for sampling sites  
- Calculate derived temperature metrics  

### **02_NOAA_data.R**
- Obtain temperature data from **NOAA Coral Reef Watch**  
- Calculate **Degree Heating Weeks (DHW)**  

### **03_temperature_HOBO.R**
- Compare in situ logger (HOBO) temperature data with NOAA data  
- Code reproduces **Figure 1A**

### **04_env_PCA.R**
- Perform PCA on environmental data across sites  
- Code reproduces **Figure SX**

### **05_genomic_PCA.R**
- Perform PCA on genomic SNP data  
  - For all individuals,  
  - For all individuals together with outgroup samples representive of the three cryptic taxa, and  
  - For a subset of five samples per taxon  
- Code reproduces **Figure 2A**

### **06_taxon_distribution.R**
- Map taxon distributions across sampling sites  
- Code reproduces **Figure 2C**

### **07_data_wrangling.R**
- Reshape datasets into long format for downstream analyses  

### **08_time_series.R**
- Analyse bleaching data across time points  
- Code reproduces **Figure 3A**

### **09_phenotypic_responses.R**
- Calculate phenotypic response metrics from time series data  

### **10_GLM.R**
- Fit Generalised Linear Models (GLMs) to phenotypic traits for all taxa and for Taxon 1 only   
- Test model significance and estimate marginal means  
- Code reproduces **Figure 4**

### **11_survival_analyses.R**
- Perform survival analyses for all taxa  
- Code reproduces **Figure 3**

### **12_dhw_survival.R**
- Compare survival before and after peak DHW  
- Code reproduces **Figure SX**

### **13_in_ex_situ.R**
- Compare in situ vs ex situ survival outcomes  
- Code reproduces **Figure 5**

### **14_symbionts_ITS2.R**
- Analyse **SymPortal** ITS2 output data to assess symbiont community composition  

---

## Reproducibility Notes

- Analyses were performed in **R version 4.3**.  
- All data files necessary to run the scripts are located in the Data folder and scripts follow directory structure.  
- Required R packages are listed at the beginning of each script.  

---

## Citation

If you use these scripts or data, please cite the associated manuscript once published.
