## SCCA_FC_TFEQ ##
### About The Project
:large_blue_diamond: This is code for the paper **"Multivariate association between brain function and eating disorders using sparse canonical correlation analysis"**<br />
:large_blue_diamond: **Paper link:** https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0237511<br />
:large_blue_diamond: If you use this code, please cite the article.<br />
　　*Lee, Hyebin, et al. "Multivariate association between brain function and eating disorders using sparse canonical correlation analysis." Plos one 15.8 (2020): e0237511.*<br /><br />

### Prerequisites
✔ We obtained data from **[Enhanced Nathan Kline Institute-Rockland Sample (eNKI) database](http://fcon_1000.projects.nitrc.org/indi/enhanced/access.html)**.<br />
✔ Imaging data were preprocessed using **[FuNP pipeline](https://gitlab.com/by9433/funp)**.<br /><br />

### Usage
- **load_and_preproc.m**　　-----　to load and preprocess MRI data<br />
- **scca_FC_TFEQ.m**　　　　　-----　to perform SCCA analysis with functional connectome and eating disorder-related scores<br />
- **find_optimal_params.m**　-----　to optimize parameters used in SCCA analysis<br />
- **svds_initial1.m**　　　　　-----　to perform SCCA, right of this code is reserved by Mansu Kim and JiHye Won (co-authors)<br /><br />
   
```bash
├── README.md
├── load_and_preproc.m
├── scca_FC_TFEQ.m
├── find_optimal_params.m
└── svds_initial1.m
```
<br />

### License
:pushpin: **copyrightⓒ 2020 All rights reserved by Hyebin Lee<br /><br />**
