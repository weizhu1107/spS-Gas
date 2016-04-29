# spS-Gas
Simulation pipeline for sequencing based genetic association study

Required packages:
1. Python >2.6.0;
2. Perl;
2. R program;
3. Hapgen2;
4. Impute2;
5. Gotcloud;
6. ART sequencing reads simulator;
7. PLINK and PLINK/SEQ.

Before run, unzip the hap_ref.tar.gz file: tar -xf hap_ref.tar.gz. Do not move or rename the unzipped folder. Once unzipped, the original zip file can be deleted.

To run the pipeline:first fill in the config_to_run.txt. It includes 10 rows corresponding to 10 parameters. An example for the configure file is:

      Gotcloud_installation_location=                             ##directory to Gotcloud
      basis_directory_for_output=                                 ##directory to save outputs
      basis_directory_for_spS-Gas=                                ##directory to spS-Gas
      number_of_regions=                                          ##number of regions to be simulated
      region_length=                                              ##length for each region in base
      prevalence=                                                 ##disease prevalence
      number_of_causal_alleles=                                   ##number of causal alleles

the end.

Then:
      ./init.sh  config_to_run.txt                    ##The config_to_run.txt can be renamed but need to be the same format.
      ./sample.sh config_to_run.txt number_of_cases number_of_controls sequencing_coverage SN                ##SN is the serial number for the ith region
      ./call.sh config_to_run.txt number_of_cases number_of_controls sequencing_coverage SN                  ##SN is the serial number for the ith region

The program will create a folder with the name "SIM_n$number_of_cases_c$sequencing_coverage" under the specified output basis directory. Each region will have a same structured folder with its index number under the created folder. The called SNP file for the ith region is saved in a folder named "vcfs" within the directory of the ith region.

The output file structure is shown below:
Output_basis/
      |...SIM_n2000_c20/
            |...1/
                  |...vcfs/
                        |...chr22.vcf
                        .
                        .
                        .*other filtered vcf files
            |...2/
            |...3/
            .
            .
            .
            

the end.
