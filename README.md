# spS-Gas
Simulation pipeline for sequencing based genetic association study

Required packages:
1. Python >2.6.0;
2. R program;
3. Hapgen2;
4. Impute2;
5. Gotcloud;
6. ART sequencing reads simulator;
7. PLINK and PLINK/SEQ.


To run the pipeline:first fill in the config_to_run.txt. It includes 7 rows corresponding to 7 parameters. An example for the configure file is:

      haplotype_reference_file_location=/home/xc/bin/f.f                      ##haplotype referecne file location
      basis_directory_for_output=/lustre/project                              ##directory to save outputs
      basis_directory_for_bin=/home/bin                                       ##directory to bin files
      number_of_regions=15                                                    ##number of regions want to simulated
      region_length(b)=100000                                                 ##length for each region in base
      prevalence=0.05                                                         ##disease prevalence
      number_of_causal_alleles=10                                             ##number of causal alleles

the end.

Then:
      ./init.sh  config_to_run.txt                    ##The config_to_run.txt can be renamed but need to be the same format.
      ./sample.sh
      ./call.sh
