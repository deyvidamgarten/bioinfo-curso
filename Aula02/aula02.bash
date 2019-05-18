#Dia01
#Converter o VCF para o padrão do ANNOVAR de anotação;
time perl /bioinfo/app/annovar/convert2annovar.pl -format vcf4 dados/freebayes/AMOSTRA01_S1_sorted.vcf > dados/annovar/AMOSTRA01_S1_sorted.ann

#Anotar as variantes encontradas;
time perl /bioinfo/app/annovar/table_annovar.pl dados/annovar/AMOSTRA01_S1_sorted.ann \
/bioinfo/app/annovar/humandb/ -buildver hg19 \
-out dados/annovar/AMOSTRA01_S1 -remove -protocol refGene,exac03,clinvar_20190114 -operation g,f,f -nastring "N/A"


