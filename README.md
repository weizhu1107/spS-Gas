# spS-Gas
Simulation pipeline for sequencing based genetic association study

Required packages:
1. Python >2.6.0;
2. Perl;
3. R program;
4. Hapgen2;
5. Impute2;
6. Gotcloud;
7. ART sequencing reads simulator;
8. PLINK and PLINK/SEQ;
9. Vcftools.

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

      ./init.sh  config_to_run.txt                                                                          ##The config_to_run.txt can be renamed but need to be the same format.
      ./sample.sh config_to_run.txt number_of_cases number_of_controls sequencing_coverage SN               ##SN is the serial number for the ith region
      ./call.sh config_to_run.txt number_of_cases number_of_controls sequencing_coverage SN                 ##SN is the serial number for the ith region

The init.sh will create the necessary files given settings of global parameters specificed in config_to_run.txt.

The sample.sh and call.sh are used to get simulated sequences and call SNPs from them. The number of cases and controls and sequencing coverage are needed as input parameters. The program will automatically assign a scenario name to the submitted job. The scenario name looks like "SIM_n$number_of_cases_c$sequencing_coverage". A folder with the scenario name will be created under the specified output basis directory. Then for the ith region, it will have a folder with its index number under the scenario folder to save all the outputs with regard to the ith region. All the region folders have the same files structure. The called SNP file for the ith region is saved in a folder named "vcfs" within the directory of the ith region.

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


Above is for the single stage sequencing scenarios. Different from single stage scenarios, two-stage is using high coverage to impute into low coverage scenarios. Then get the imputed SNP calls. The impute.sh is designed to do the imputation in two-stage scenarios. The command syntax is:

      ./impute.sh config_to_run.txt ref_scenario_name(high-coverage) target_scenario_name(low-coverage) SN                  ##SN is the serial number for the ith region
      
All the imputation results are sved in a folder named impute under the output basis directory. The impute.sh will create a folder named by the concatenation of the two scenario names. Within this two-scenario folder, another folder are created for the ith region. The impute2 outputs are stored in the created region folder.

The imputation output file structure is shown below:

Output_basis/
      |...impute/
            |...SIM_n100_c30_SIM_n2000_c2
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
