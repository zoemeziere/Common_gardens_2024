# Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave

This repository contains scripts and supporting data for the manuscript:

> **Thermal stress responses and survival differ among closely related coral taxa of the *Stylophora pistillata* species complex during a heatwave**

In this study, we explored  thermal tolerance in the *Stylophora pistillata* species complex during the 2024 marine heatwave at Heron Island Reef, Australia. We used a long-term common garden experiment that mimced the heatwave thermal profile and  quantified inter- and intra-specific differences in bleaching and survival. We found distinct heat-stress responses between the three cryptic taxa, but weak evidence of within-taxon local acclimatisation or adaptation among reef habitats. Importantly, survival patterns in the common garden mirrored those on the reef. Overall, this study highlights complex interactions among host identity, symbiont community, and environmental history in shaping coral thermal tolerance.

---

## Repository Structure

The repository is organised into two main sections: **Data** and **Scripts**. 

### 1. Data:  Raw and processed data used for analyses

**All_taxa_data**  
- `allTaxa_merged.csv`: Master merged table of taxa responses and metadata.  
- `allTaxa_responses.csv`: Wide-format phenotype responses per sample.  
- `allTaxa_responses_lng.csv`: Long-format response table for modeling.  
- `allTaxa_responses_with_thermal_metrics.csv`: Response table with thermal metrics (e.g., cumulative DHW, max temp).  

**Env_data**  
- `DHW_data.csv`: Degree Heating Week metrics.  
- `ereef-collected.csv`: eReefs environmental variables.  
- `Heron_Island_SST_NovMay2024.csv`: SST data for experimental period.  
- `pc_scores_env.csv`: Environmental PCA scores from `04_env_PCA.R`.  
- `Heron_2007_GeomorphicZoneMap/`: Geomorphic zone shapefiles for mapping.  

**Gen_data**  
- `5samples_metadata.csv`: Example metadata for five samples.  
- `5samples_plink.eigenval` & `.eigenvec`: PLINK PCA outputs for five-sample test.  
- `Spis_exp_outgroups_metadata.csv`: Metadata including outgroups.  
- `Spis_expe.het` & `Spis_expe.imiss`: PLINK heterozygosity & missingness reports.  
- `Spis_experiments_filtered_prunned.eigenval` & `.eigenvec`: PCA on filtered/pruned dataset.  
- `Spis_experiments_filtered_prunned_ibd.mdist` & `.mdist.id`: IBD/matrix distances for relatedness checks.  
- `Spis_experiments_outgroups_filtered_prunned.eigenval` & `.eigenvec`: PCA including outgroups.  

**Logger_data**  
- `Hobo_control1.csv` & `hobo_control2.csv`: Control tank HOBO logger data.  
- `hobo_treat1_1.csv`, `hobo_treat1_2.csv`, `hobo_treat2_1.csv`, `hobo_treat2_2.csv`: Treatment logger data.  

**Metadata**  
- `Experiment_Metadata.csv`: Master experimental metadata table.  
- `Experiment_MetadataGenetics.csv`: Genetics-specific metadata.  
- `Experiment_coordinates_RAW.csv`: Raw collection/deployment coordinates.  

**Symbiont_data**  
- `ITS2_rel_abundance.csv`: ITS2 relative abundance per sample.  
- `seq_rel_abundance.csv`: Sequence-level relative abundance.  

**Taxon1_data**  
- `Taxon1_responses.csv`: Raw responses (wide format).  
- `Taxon1_responses_filtered.csv`: Filtered dataset.  
- `Taxon1_responses_lng.csv`: Long-format table.  
- `Taxon1_responses_with_thermal_metrics.csv`: Responses with thermal exposure metrics.  

---

### 1. Scripts:  Scripts to process data and visualise results

2A. Scripts used to process whole-genome sequencing data of the coral host to obtain high-quality SNPs for downstream analyses. Each script is numbered to indicate its order in the analytical workflow. 

2B. Scripts used for data analyses and visualisation. Each script is numbered to indicate its order in the analytical workflow.
   
**01_ereefs_data.R**  
- Downloads/reads eReefs layers, formats and aggregates environmental variables.  

**02_NOAA_data.R**  
- Fetches and cleans NOAA SST and DHW datasets; prepares CSVs for survival analyses.  

**03_temperature_HOBO.R**  
- Reads and cleans HOBO logger data; computes summary statistics and daily series.  

**04_env_PCA.R**  
- Performs PCA on environmental variables; outputs `pc_scores_env.csv`.  

**05_genomic_PCA.R**  
- Processes genomic PCA on PLINK/eigenvec outputs; includes all individuals, with/without outgroups, or subsets.  

**06_taxon_distribution.R**  
- Produces maps and summaries of taxon distributions.  

**07_data_wrangling.R**  
- Harmonises sample IDs, merges phenotype, genotype, and metadata tables.  

**08_time_series.R**  
- Generates time-series plots of temperature, bleaching, or survival trends.  

**09_phenotypic_responses.R**  
- Fits statistical models to phenotype response data; outputs summary tables and figures.  

**10_GLM.R**  
- Fits GLMs for response variables (binary or count); provides diagnostics.  

**11_survival_analyses.R**  
- Performs Kaplan–Meier and Cox proportional hazards analyses; outputs curves and summaries.  

**12_dhw_survival.R**  
- Examines associations between DHW metrics and survival outcomes.  

**13_in_ex_situ.R**  
- Compares in situ vs ex situ experimental conditions.  

**14_symbionts_ITS2.R**  
- Processes ITS2 symbiont data; analyses community composition.    

---

## Reproducibility Notes


- Analyses were performed in **R version 4.3**.  
- Required R packages are listed at the beginning of each script.
- R info session:

<details>
<summary><strong>Click to expand sessionInfo()</strong></summary>

```txt

sessionInfo()
R version 4.4.3 (2025-02-28)
Platform: aarch64-apple-darwin20
Running under: macOS Sequoia 15.6

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: Australia/Brisbane
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] ncdf4_1.24          httr_1.4.7          zoo_1.8-14          readxl_1.4.5.9000  
 [5] scales_1.4.0        vegan_2.7-1         permute_0.9-8       dartR_2.9.9.5      
 [9] dartR.data_1.0.8    adegenet_2.1.11     ade4_1.7-23         data.table_1.17.8  
[13] rnaturalearth_1.1.0 patchwork_1.3.2     cowplot_1.2.0       sf_1.0-21          
[17] scatterpie_0.2.6    colorspace_2.1-2    glmmTMB_1.1.12      lme4_1.1-37        
[21] Matrix_1.7-4        survminer_0.5.1     ggpubr_0.6.1        coxme_2.2-22       
[25] bdsmatrix_1.3-7     survival_3.8-3      ggpattern_1.2.1     lubridate_1.9.4    
[29] forcats_1.0.0       stringr_1.5.2       dplyr_1.1.4         purrr_1.1.0        
[33] readr_2.1.5         tidyr_1.3.1         tibble_3.3.0        ggplot2_4.0.0      
[37] tidyverse_2.0.0    

loaded via a namespace (and not attached):
  [1] splines_4.4.3       later_1.4.4         fields_17.1         R.oo_1.27.1        
  [5] cellranger_1.1.0    polyclip_1.10-7     mmod_1.3.3          lifecycle_1.0.4    
  [9] Rdpack_2.6.4        rstatix_0.7.2       doParallel_1.0.17   lattice_0.22-7     
 [13] MASS_7.3-65         backports_1.5.0     magrittr_2.0.4      httpuv_1.6.16      
 [17] gap_1.6             spam_2.11-1         sp_2.2-0            DBI_1.2.3          
 [21] minqa_1.2.8         RColorBrewer_1.1-3  maps_3.4.3          abind_1.4-8        
 [25] R.utils_2.13.0      gdsfmt_1.42.1       PopGenReport_3.1.3  yulab.utils_0.2.1  
 [29] tweenr_2.0.3        rappdirs_0.3.3      sandwich_3.1-1      KMsurv_0.1-6       
 [33] gdata_3.0.1         terra_1.8-60        proto_1.0.0         units_0.8-7        
 [37] StAMPP_1.6.3        codetools_0.2-20    dismo_1.3-16        ggforce_0.5.0      
 [41] tidyselect_1.2.1    raster_3.6-32       farver_2.1.2        e1071_1.7-16       
 [45] Formula_1.2-5       iterators_1.0.14    foreach_1.5.2       tools_4.4.3        
 [49] SNPRelate_1.40.0    Rcpp_1.1.0          glue_1.8.0          gridExtra_2.3      
 [53] genetics_1.3.8.1.3  xfun_0.53           mgcv_1.9-3          withr_3.0.2        
 [57] numDeriv_2016.8-1.1 combinat_0.0-8      fastmap_1.2.0       GGally_2.4.0       
 [61] boot_1.3-32         digest_0.6.37       timechange_0.3.0    R6_2.6.1           
 [65] mime_0.13           gtools_3.9.5        R.methodsS3_1.8.2   generics_0.1.4     
 [69] calibrate_1.7.7     class_7.3-23        ggstats_0.11.0      pkgconfig_2.0.3    
 [73] gtable_0.3.6        S7_0.2.0            survMisc_0.5.6      htmltools_0.5.8.1  
 [77] carData_3.0-5       dotCall64_1.2       TMB_1.9.17          png_0.1-8          
 [81] reformulas_0.4.1    ggfun_0.2.0         knitr_1.50          km.ci_0.5-6        
 [85] rstudioapi_0.17.1   tzdb_0.5.0          reshape2_1.4.4      nlme_3.1-168       
 [89] nloptr_2.2.1        proxy_0.4-27        KernSmooth_2.23-26  parallel_4.4.3     
 [93] pillar_1.11.1       grid_4.4.3          vctrs_0.6.5         promises_1.3.3     
 [97] car_3.1-3           xtable_1.8-4        cluster_2.1.8.1     evaluate_1.0.5     
[101] gsubfn_0.7          mvtnorm_1.3-3       cli_3.6.5           compiler_4.4.3     
[105] rlang_1.1.6         crayon_1.5.3        ggsignif_0.6.4      classInt_0.4-11    
[109] plyr_1.8.9          fs_1.6.6            gap.datasets_0.0.6  stringi_1.8.7      
[113] viridisLite_0.4.2   hms_1.1.3           gdistance_1.6.4     pegas_1.3          
[117] seqinr_4.2-36       RgoogleMaps_1.5.3   shiny_1.11.1        rbibutils_2.3      
[121] igraph_2.1.4        broom_1.0.10        ape_5.8-1
