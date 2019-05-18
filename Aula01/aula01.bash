#Dia01
#Manual dos comando de linux;
man ls
man cp
man cat

#Listar o diretório atual;
pwd

#Criar diretório de teste
mkdir teste

#Movimentar para o diretório de teste;
cd teste

#Listar o diretório atual;
pwd

#Listar o conteúdo diretório atual;
ls -la

#Movimentar para o seu diretório home;
cd ~/

#Editor de texto básico de linux;
vi arq_texto_exemplo.txt
#<Esc>i  		 = inserir texto antes do cursor, até precionar <Esc>
#<Esc>dd  		 = deletar a linha inteira;
#<Esc>:x<Enter>  = sair do vi e SALVAR as alterações;
#<Esc>:wq<Enter> = sair do vi e SALVAR as alterações;
#<Esc>:q<Enter>	 = sair do vi;
#<Esc>:q!<Enter> = forçar sair do vi SEM SALVAR;

#Mostrar o conteúdo de um arquivo;
cat arq_texto_exemplo.txt 

#Filtrar o conteúdo de um arquivo baseado em um padrão;
grep <padrão> arq_texto_exemplo.txt 

#Contar o número de linhas de um arquivo;
wc -l arq_texto_exemplo.txt

#Criar a estrutura de diretórios para trabalhar;
mkdir dados
mkdir dados/fastq
mkdir dados/bwa
mkdir dados/picard
mkdir dados/fastqc
mkdir dados/bedtools
mkdir dados/annovar

#Criar a estrutura de diretório para guardar seu genoma de referencia;
mkdir referencia
mkdir referencia/hg19

#Listar o diretório atual;
pwd

#Copiar os FASTQ para sua pasta de análise;
cp /bioinfo/dados/NextSeq_RUN01/Files/Data/Intensities/BaseCalls/AMOSTRA01_S1*.fastq.gz dados/fastq/

#Listar os arquivos copiados;
ls -lh dados/fastq/*

#Executar o FASTQC para avaliar a qualidade das sequencias produzidas;
time fastqc -o dados/fastqc dados/fastq/AMOSTRA01_S1_R1_001.fastq.gz dados/fastq/AMOSTRA01_S1_R2_001.fastq.gz

#Remover os reads fora do padrão configurado no sequenciamento 75bp e Q20;
time cutadapt --minimum-length 75 --maximum-length 75 \
-q 30 --quality-base 33 \
-o dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq \
-p dados/fastq/AMOSTRA01_S1_R2_001_cutadapt.fastq \
dados/fastq/AMOSTRA01_S1_R1_001.fastq.gz \
dados/fastq/AMOSTRA01_S1_R2_001.fastq.gz &

#Executar o FASTQC para avaliar a qualidade das sequencias produzidas após o cutadapt;
time fastqc -o dados/fastqc dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq

#Mapear os FASTQ limpos contra o hg19;
time bwa mem -M -R '@RG\tID:CAP\tSM:NOME\tLB:Biblioteca\tPL:Plataforma' \
/bioinfo/referencia/hg19/chr1_13_17.fa \
dados/fastq/AMOSTRA01_S1_R1_001_cutadapt.fastq \
dados/fastq/AMOSTRA01_S1_R2_001_cutadapt.fastq >dados/bwa/AMOSTRA01_S1.sam

#Utilizar o samtools: fixmate, sort e index
time samtools fixmate dados/bwa/AMOSTRA01_S1.sam dados/bwa/AMOSTRA01_S1.bam
time samtools sort -O bam -o dados/bwa/AMOSTRA01_S1_sorted.bam dados/bwa/AMOSTRA01_S1.bam
time samtools index dados/bwa/AMOSTRA01_S1_sorted.bam

#Visualizar o BAM com o samtools;
time samtools view dados/bwa/AMOSTRA01_S1_sorted.bam

#Converter BAM to BED para utilizarmos o BED para analise de cobertura;
bamToBed -i dados/bwa/AMOSTRA01_S1_sorted.bam >dados/bwa/AMOSTRA01_S1_sorted.bed
mergeBed -i dados/bwa/AMOSTRA01_S1_sorted.bed >dados/bwa/AMOSTRA01_S1_merged.bed
sortBed -i dados/bwa/AMOSTRA01_S1_merged.bed >dados/bwa/AMOSTRA01_S1_merged_sorted.bed


#Chamada de variantes com o Freebayes;
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
