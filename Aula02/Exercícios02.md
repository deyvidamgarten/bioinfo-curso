# Lista de Exercícios do Dia02
### Pré-requisitos
ANNOVAR

* Anovar as Variantes com a base do Abraom
```
time perl /bioinfo/app/annovar/table_annovar.pl dados/annovar/AMOSTRA01_S1_sorted.ann \
/bioinfo/app/annovar/humandb/ -buildver hg19 \
-out dados/annovar/AMOSTRA01_S1 -remove -protocol refGene,exac03,abraom,clinvar_20190114 -operation g,f,f,f -nastring "N/A" -csvout
```
