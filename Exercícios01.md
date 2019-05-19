# Lista de Exercícios do Dia01
### Pré-requisitos
BEDtools

* Encontrar bases sobrepostas entre dois BEDs
````
bedtools intersect -a reads.bed -b genes.bed
````
* Encontrar bases que NÃO tem sobreposição em outro BED
````
bedtools intersect -a reads.bed -b genes.bed -v
````

* Encontrar bases sobrepostas que NÃO estão presentes em outro BED
````
bedtools intersect -a genes.bed -b LINES.bed | \ </br>
bedtools intersect -a stdin -b SINEs.bed -v
````

* Merge BED
````
bedtools merge -i repeatMasker.bed -d 1000
```

* SortBED
````
bedtools sort -i FILE.bed
```