# Dia01
## Checar as permissões e coverter os BCLs para FASTQ
```
ls -l /bioinfo/dados/NextSeq_RUN01
chmod -R 775 /bioinfo/dados/NextSeq_RUN01/Files
cd /bioinfo/dados/NextSeq_RUN01/Files
nohup bcl2fastq --no-lane-splitting --barcode-mismatches 1 1>bcl2fastq.log &
```

## Verificar se o processo esta em execução e escrevendo o LOG
```
#lista as primeiras n linhas;
head bcl2fastq.log 
#lista as ultimas n linhas; Para sair digite <Ctrl>+C;
tail -f bcl2fastq.log 
```

## Manual dos comando de linux;
```
man ls
man cp
man cat
#Variável $PWD contém o caminho "onde estou"
echo $PWD
```

## Listar o diretório atual;
```
pwd
```

## Criar diretório de teste
```
mkdir teste
```
## Movimentar para o diretório de teste;
```
cd teste
```

## Listar o diretório atual;
```
pwd
```

## Listar o conteúdo diretório atual;
```
ls -l
touch meuArquivo.txt
ls -l
```

# Movimentar para o seu diretório home;
```
cd ~/
```

# Editor de texto básico de linux;
```
vi arq_texto_exemplo.txt

#<Esc>i  		 = inserir texto antes do cursor, até precionar <Esc> </br>
#<Esc>dd  		 = deletar a linha inteira; </br>
#<Esc>:x<Enter>  = sair do vi e SALVAR as alterações;</br>
#<Esc>:wq<Enter> = sair do vi e SALVAR as alterações;</br>
#<Esc>:q<Enter>	 = sair do vi;</br>
#<Esc>:q!<Enter> = forçar sair do vi SEM SALVAR;</br>
```

## Mostrar o conteúdo de um arquivo;
```
cat arq_texto_exemplo.txt 
```

## Filtrar o conteúdo de um arquivo baseado em um padrão;
```
grep <padrão> arq_texto_exemplo.txt 
```

## Contar o número de linhas de um arquivo;
```
wc -l arq_texto_exemplo.txt
```
## Criar a estrutura de diretórios para trabalhar;
```
mkdir dados
mkdir dados/fastq
mkdir dados/bwa
mkdir dados/picard
mkdir dados/fastqc
mkdir dados/bedtools
mkdir dados/annovar
```

## Criar a estrutura de diretório para guardar seu genoma de referencia;
```
mkdir referencia
mkdir referencia/hg19
```

## Listar o diretório atual;
```
pwd
```

## Copiar os FASTQ para sua pasta de análise;
```
cp /bioinfo/dados/NextSeq_RUN01/Files/Data/Intensities/BaseCalls/AMOSTRA01_S1*.fastq.gz dados/fastq/
```

## Listar os arquivos copiados;
```
ls -lh dados/fastq/*
```

## Executar o FASTQC para avaliar a qualidade das sequencias produzidas;
```
time fastqc -o dados/fastqc dados/fastq/AMOSTRA01_S1_R1_001.fastq.gz dados/fastq/AMOSTRA01_S1_R2_001.fastq.gz
```
Manual do [FastQC](https://dnacore.missouri.edu/PDF/FastQC_Manual.pdf).</br>
Exemplo de resultado [BOM](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/good_sequence_short_fastqc.html) e [RUIM](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/bad_sequence_fastqc.html).</br>


## Remover os reads fora do padrão configurado no sequenciamento 75bp e Q20;
```
time cutadapt --minimum-length 75 --maximum-length 75 \
-o dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq \
-p dados/fastq/AMOSTRA01_S1_R2_001_cutadapt.fastq \
dados/fastq/AMOSTRA01_S1_R1_001.fastq.gz \
dados/fastq/AMOSTRA01_S1_R2_001.fastq.gz 
``` 
## Executar o FASTQC para avaliar a qualidade das sequencias produzidas após o cutadapt;
```
time fastqc -o dados/fastqc dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq dados/fastq/AMOSTRA01_S1_R2_001_cutadapt.fastq
```

## Fazer download dos HTMLs gerados com o FastQC e comparar os dois, antes e depois do cutadapt

## Fazer download de um cromossomo para utilizar como referencia
```
cd referencia/hg19/
pwd
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr13.fa.gz
gunzip chr13.fa.gz
```

## Criar o índice do BWA
```
# reference.fa​ = chr13.fa

bwa index -a bwtsw reference.fa​ 
```

## Gerar o índice do FASTA (genoma de referência)
```
# reference.fa​  = chr13.fa
samtools faidx reference.fa
```

## Gerar o dicionário das sequências FASTA
```
# reference.fa​  = chr13.fa
# reference.dict = chr13.dict

java -jar /bioinfo/app/picard/picard.jar CreateSequenceDictionary \
REFERENCE=reference.fa \
OUTPUT=reference.dict
```

## Mapear os FASTQ limpos contra o hg19;
```
# Voltar para o HOME
cd ~/
NOME=NOME;
Biblioteca=Biblioteca;
Plataforma=Plataforma;

time bwa mem -M -R '@RG\tID:CAP\tSM:$NOME\tLB:$Biblioteca\tPL:$Plataforma' \
/bioinfo/referencia/hg19/chr1_13_17.fa \
dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq \
dados/fastq/AMOSTRA01_S1_R2_001_cutadapt.fastq >dados/bwa/AMOSTRA01_S1.sam
```

## Utilizar o samtools: fixmate, sort e index
```
time samtools fixmate dados/bwa/AMOSTRA01_S1.sam dados/bwa/AMOSTRA01_S1.bam
time samtools sort -O bam -o dados/bwa/AMOSTRA01_S1_sorted.bam dados/bwa/AMOSTRA01_S1.bam
time samtools index dados/bwa/AMOSTRA01_S1_sorted.bam
```

## Visualizar o BAM com o samtools;
```
time samtools view -H dados/bwa/AMOSTRA01_S1_sorted.bam
time samtools view dados/bwa/AMOSTRA01_S1_sorted.bam
```

## Converter BAM to BED para utilizarmos o BED para analise de cobertura;
```
bamToBed -i dados/bwa/AMOSTRA01_S1_sorted.bam >dados/bwa/AMOSTRA01_S1_sorted.bed
mergeBed -i dados/bwa/AMOSTRA01_S1_sorted.bed >dados/bwa/AMOSTRA01_S1_merged.bed
sortBed -i dados/bwa/AMOSTRA01_S1_merged.bed >dados/bwa/AMOSTRA01_S1_merged_sorted.bed
```
## Chamada de variantes com o Freebayes;

```
# -F --min-alternate-fraction N
#      Require at least this fraction of observations supporting
#      an alternate allele within a single individual in the
#      in order to evaluate the position.  default: 0.05
# -C --min-alternate-count N
#      Require at least this count of observations supporting
#      an alternate allele within a single individual in order
#      to evaluate the position.  default: 2

time /bioinfo/app/freebayes/bin/freebayes -f /bioinfo/referencia/hg19/chr1_13_17.fa \
-F 0.3 -C 15 \
--pooled-continuous dados/bwa/AMOSTRA01_S1_sorted.bam \
>dados/freebayes/AMOSTRA01_S1_sorted.vcf
```

## Chamada de variantes com o GATK;