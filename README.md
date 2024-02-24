# Replication of Text as Policy: Measuring Policy Similarity through Bill Text Reuse

This repository attempts to replicate the 2018 study by Fridolin Linder, Bruce Desmarais, Matthew Burgess, and Eugenia Giraudy, titled "Text as Policy: Measuring Policy Similarity through Bill Text Reuse", published in the Policy Studies Journal. The study introduces a novel methodology for quantifying policy similarity across US states by analyzing the extent of text reuse in legislative bills.

The original publication can be found [here](https://onlinelibrary.wiley.com/doi/abs/10.1111/psj.12257) 
Author's, official github repo for study can be found [here](https://github.com/desmarais-lab/text_reuse/tree/master?tab=readme-ov-file): 


## Abstract

This repository is dedicated to attempting replication of the 2018 study by Fridolin Linder, Bruce Desmarais, Matthew Burgess, and Eugenia Giraudy on policy similarity among US states through bill text reuse. The original study presents a novel approach to quantifying policy similarity by measuring the extent of text reuse between legislative bills across different states. By identifying continuous numeric text alignment scores between bill pairs, the study explores the nuanced dimensions of policy similarity, including domain, ideological stance, specificity level, and other salient policy features embedded within legislative texts.  
This replication effort is structured around three methodological pillars: 1) the construction of a data pipeline for processing raw bills data to generate text alignment scores, 2) conducting robustness checks to validate the text-reuse-based measure of policy similarity against theoretical benchmarks and previous research findings, and 3) analyzing the distribution of alignment scores between bills sponsored by Republicans versus Democrats. Among these, the replication successfully reproduces the analysis for the second robustness check on diffusion networks and text alignments  in full and offers a partial replication for robustness check exploring differences in ideological scores of sponsors of bill pairs and the pairs' alignment scores.

## Tutorial

This README file provides an overview of the methodology undertaken. The R codes used in the article can be found under the folder R Codes and python codes can be found under python codes. The raw bill data and supplementary data are linked below under the Data section.
The codes below do not fully replicate the results due to constraints in computation resources and data availability. We employ manual matching and sampling where required. Details can be found in the replication paper and in methodology undertaken in the code files.

### Codes
**Under python folder**
- `read_textalignment_create_sample_and_aggregate.ipynb`: this code samples bills from the text alignment(notext) dataset and generates state pair level average alignments.
- `read_raw_bills_create_ideology_data.ipynb`: this code reads the raw state_bills data. It details the methodology used to generate counts of bills per state, using the legiscan API for name matching, manual matching and creation of the final datasets used for ideology analysis. Requires legiscan api

**Under R folder**
- `diffusion.r`: this code replicates the robustness check for state pair diffusions and alignments.
- `ideology.r`: this code replicates the ideology and alignments scores using sampled data. Uses final output from Ideology_dataset.ipynb 
- `visualization.r`: this code creates exploratory visualizations

### Data

- Raw bills data and text alignments data can be found [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FCZ25GF).
- Diffusion network data is available [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/A1GIMB).
- Ideology Dataset is accessible [here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/GZJOT3).
- For accessing the LegiScan API, visit [here](https://legiscan.com/about).

