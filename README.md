# 🧬 Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave

This repository contains scripts and supporting data for the manuscript:

> **Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave**

---

## 📂 Repository Overview

The repository is organised into two main sections:

1. **A. Variant Calling for Host Whole Genome Sequence Data**  
   Scripts for processing raw sequencing reads, variant calling, and quality control.

2. **B. Data Analyses and Visualisation**  
   R scripts used to analyse environmental, genomic, and phenotypic datasets, and to reproduce figures from the manuscript.

Each script is numbered to indicate its order in the analytical workflow.

---

## 🧪 A. Scripts for Calling Variants

Scripts in this section process whole-genome sequencing data of the coral host to obtain high-quality SNPs for downstream analyses.  
*(See manuscript Methods for details.)*

---

## 📊 B. Scripts for Data Analyses and Visualisation

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
  - All individuals  
  - Subset with outgroup samples representing three cryptic taxa  
  - Subset of five samples per taxon  
- Code reproduces **Figure 2A**

### **06_taxon_distribution.R**
- Map taxon distributions across sampling sites  
- Code reproduces **Figure 2C**

### **07_data_wrangling.R**
- Reshape and clean datasets into long format for downstream analyses  

### **08_time_series.R**
- Analyse key phenotypic traits across time points  
- Code reproduces **Figure 3A**

### **09_phenotypic_responses.R**
- Calculate phenotypic response metrics from time series data  

### **10_GLM.R**
- Fit Generalised Linear Models (GLMs) to phenotypic traits  
- Analyse all taxa and Taxon 1 separately  
- Test model significance and estimate marginal means  
- Code reproduces **Figure 4**

### **11_survival_analyses.R**
- Perform survival analyses across taxa  
- Code reproduces **Figure 3**

### **12_dhw_survival.R**
- Compare survival before and after peak DHW exposure  
- Code reproduces **Figure SX**

### **13_in_ex_situ.R**
- Compare in situ vs ex situ survival outcomes  
- Code reproduces **Figure 5**

### **14_symbionts_ITS2.R**
- Analyse **SymPortal** ITS2 output data to assess symbiont community composition  

---

## ⚙️ Reproducibility Notes

- Analyses were performed in **R (version ≥4.2)**.  
- All scripts assume that data files are located in the expected directory structure (see comments at the top of each script).  
- Required R packages are listed at the beginning of each script.  
- Figures can be reproduced by running scripts in numerical order.

---

## 🧾 Citation

If you use these scripts or data, please cite the associated manuscript once published.

---

## 📧 Contact

For questions or collaboration inquiries, please contact:  
**Zoe Meziere** – [zoe.meziere@gmail.com](mailto:zoe.meziere@gmail.com)






# Scripts and data to support manuscript "Thermal stress responses and survival differ among closely related coral taxa of the Stylophora pistillata species complex during a heatwave"

### A. Scripts for calling variants for host whole genome sequence data

### B. Scripts for data analyses and visualisation

#### 01_ereefs_data.R

Obtaining temperature data from eReefs for sampling sites and calculating derived metrics

#### 02_NOAA_data.R

Obtaining temperature data from NOAA to calculate Degree Heating Weeks 

#### 03_temperature_HOBO.R

Compairing in situ logger data in tanks with NOAA data
Code for Figure 1A

#### 04_env_PCA.R

Performing PCA on environmental data
Code for Figure SX

#### 05_genomic_PCA.R

Performing PCA on genomic data, for all individuals, for all individuals with outgroup samples representative of the three cryptic taxa, and for a subset of five samples per taxon
Code for Figure 2A

#### 06_taxon_distribution.R

Mapping taxa distribution across sampling sites
Code for Figure 2C

#### 07_data_wrangling.R

Wrangling data to make it long format

#### 08_time_series.R

Analysing key phenotypic traits across time points
Code for Figure 3A

#### 09_phenotypic_responses.R

Calculating phenotypic response traits from time series data

#### 10_GLM.R

Performing generalised linear models on phenotypic response traits, for all taxa and for Taxon1 only
Testing model significance
Estimating marginal means
Code for Figure 4

#### 11_surival_analyses.R

Performing survival analyses
Code for Figure 3

#### 12_dhw_survival.R

Performing survival analyses before and after peak degree heating week
Code for Figure SX

#### 13_in_ex_situ.R

Performing analyses to compare in situ and ex situ survival
Code for Figure 5

#### 14_symbionts_ITS2.R

Performing analyses of symportal output data files of ITS2 
