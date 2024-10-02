mamba activate tracks

# Figure 4A
GENE="CEP57_intron"
pyGenomeTracks --tracks ini/$GENE.ini --region chr11:95,802,547-95,815,956 -t $GENE -o tracks/$GENE.pdf

GENE="ZNF708"
pyGenomeTracks --tracks ini/$GENE.ini --region chr19:21,289,160-21,331,410 -t $GENE -o tracks/$GENE.pdf

# Supplemental Figure 4F
GENE="ZNF37A"
pyGenomeTracks --tracks ini/$GENE.ini --region 10:38,092,337-38,126,625 -t $GENE -o tracks/$GENE.pdf

GENE="Chr19_ZNF_cluster"
pyGenomeTracks --tracks ini/$GENE.ini --region 19:20,680,375-23,659,667 -t $GENE -o tracks/$GENE.pdf

GENE="SLAIN1"
pyGenomeTracks --tracks ini/$GENE.ini --region 13:77,695,687-77,766,229 -t $GENE -o tracks/$GENE.pdf

GENE="MIGA1_zoomed"
pyGenomeTracks --tracks ini/$GENE.ini --region 1:77,839,819-77,859,864 -t $GENE -o tracks/$GENE.pdf

GENE="MAPK8_intron"
pyGenomeTracks --tracks ini/$GENE.ini --region 10:48,319,385-48,362,478 -t $GENE -o tracks/$GENE.pdf

GENE="JPX"
pyGenomeTracks --tracks ini/$GENE.ini --region X:73,942,324-74,072,384 -t $GENE -o tracks/$GENE.pdf