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


To run the pipeline:
      ./init.sh haplotype_reference_file_location number_of_regions region_length basis_directory_for_output
      ./sample.sh
      ./call.sh
