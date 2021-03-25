library(data.table)
library(pbapply)

library(dplyr)
library(stringr)
library(glue)

scores.extract <- function(w) {
	score.name <- unlist(strsplit(as.character(w[9]), split=":", fixed=T))
	score.res <- unlist(strsplit(as.character(w[10]), split=":", fixed=T))
	alt.f <- as.numeric(unlist(strsplit(score.res[which(score.name=="AD")], split=",", fixed=T))[as.numeric(w[3])+1])
	dp.f <- as.numeric(score.res[which(score.name=="DP")])
	fs <- fisher.test(matrix(as.numeric(unlist(strsplit(score.res[which(score.name=="SB")], split=','))), nrow=2)[,c(1,as.numeric(w[3])+1)])$p.value
	return(c(alt.f, dp.f, fs))
}

binom.var.qual <- function(alt, dp) {
	val <- c(as.numeric(alt), as.numeric(dp))
	if (sum(val)==0) {p <- rep(1,2)}
	else {p <- c(binom.test(val[1], val[2], 0.01)$p.value, binom.test(val[1], val[2], 0.02)$p.value)}
	return(p)
}

#Cosmic.Extract <- function(line, cosmic.db) {
	# cosmic <- data.table::fread("/data/BIOINFO/databases/COSMIC_v90/CosmicCodingMuts.vcf", data.table=F)
#	cosmic.id <- cosmic.db$ID[as.character(cosmic.db[,1])==as.character(line[1])&as.numeric(cosmic.db$POS)==as.numeric(line[2])&as.character(cosmic.db$REF)==as.character(line[4])&as.character(cosmic.db$ALT)==as.character(line[5])]
#	return(ifelse(length(cosmic.id)==0, NA, paste(cosmic.id, sep=";")))
#}

RNAseqFiltering <- function(file, cosmic.db) {

	
	print(paste0("Reading VCF ", file))
	filtMut <- unique(read.table(file, fill=T, header=F, skip=0, sep="\t",stringsAsFactors = FALSE)) 
	
	filtMut <- filtMut[grepl("SB", filtMut[,9]) & filtMut[,1]!=".",]
	print("Duplicated positions")
	
	pos.chr <- paste(filtMut[,1], filtMut[,2])
	filtMut[,3] <- pbsapply(1:length(pos.chr), function(y) sum(pos.chr[1:y]==pos.chr[y])) # /!\ these one is not efficient at all....too long
	rm(pos.chr)
	print(paste0("Scores extraction of ", file))
	scores <- t(pbapply(filtMut, 1, scores.extract))
	colnames(scores) <- c("ALTf", "DPf", "SBf")
	scores[is.na(scores)] <- 0
	filtMut <- cbind(filtMut[,-c(7:8)],scores)
	rm(scores)

	p <- t(apply(filtMut[,9:10], 1, function(i) binom.var.qual(i[1], i[2])))

	setnames(filtMut, c("V1", "V2","V4","V5"), c("#CHROM","POS","REF","ALT"))
	filtMut <- cbind(filtMut,p)
	print("Table")
	print(head(filtMut))
	# Correct for the G,<NON_REF> thing...
	filtMut$ALT <- unlist(str_split(filtMut$ALT, ",")[1])
	# That was the worst thing ever to do, it was slowing downn everything. Don't know exaclty why. I have some concerns about ALT
	# in vcf ALT can be G,<NON_REF> or <NON_REF>
	# whereas in cosmic it's always a A,T,G,C or serveral nucleotides
	# 
	#cosmic.id <- cosmic.read$ID[
			#as.character(cosmic.read[,1])==as.character(filtMut[i,1]) &
			#as.numeric(cosmic.read$POS)==as.numeric(filtMut[i,2]) 	   & 
			#as.character(cosmic.read$REF)==as.character(filtMut[i,4]) &
			#as.character(cosmic.read$ALT)==as.character(filtMut[i,5])
			#]
			
	dataset <- inner_join(filtMut,cosmic.db, by =c("#CHROM","POS","REF","ALT"),copy = FALSE,keep=FALSE)
	
	print(colnames(dataset))
	#"#CHROM" "POS"    "V3"     "REF"    "ALT"    "V6"     "V9"     "V10"    "ALTf"   "DPf"    "SBf"    "1"      "2" 
	setnames(dataset, c("V3",  "ALTf" ,  "DPf"  ,  "SBf" ,   "1"   ,   "2"   ,"V6"    , "V9"   ,  "V10"     ), c("DUP", "ALT.reads", "DP.reads","Fisher.SB","p.1", "p.2","scores.names", "scores.res", "cosmic"))
	# colnames(filtMut) <- c("CHR", "POS", "DUP", "REF", "ALT", "QUAL", "ALT.reads", "DP.reads", "Fisher.SB", "p.1", "p.2", "scores.names", "scores.res", "cosmic")
	
	rownames(dataset) <- NULL
	
	return(dataset)
}

start_time <- Sys.time()
print("Load Cosmic")
# Cosmic is "3,4G #30 178 158 lines. Cannot load only with my 8G. I tested using 10 000 000 lines only , 1.2 G files.
# The  vcf is 815M -> 9 444 292 lines. I tested with 500 000 lines.-> 43M
# Don't use foreach...
# I will be quick enougth fast using a simple loop, on one core, using a relative normal amount of memory (less than 20G-40G)
# For 30 files , I should just take a couple of hours...
# In test mode, with truncated files as described before, with only 8 G, it tooks me 3.5 minutes to treat 2 files sequentially.
# WARNING  :Check I rename the columns as they should be I might have introduce mistaks for scores.names", "scores.res", "cosmic")

cosmic.read <- fread('/home/jp/Desktop/CosmicCodingMuts_10000000.vcf', data.table=F) 
print(head(cosmic.read))

print("Go")
# I change just to read files inside the dir...so you need to remodify a little bit again.
for(i in list.files('/home/jp/Desktop/tosato/SNPs/')) {
	print(i)
	RNAseq <- RNAseqFiltering(file=paste0("/home/jp/Desktop/tosato/SNPs/", i), cosmic.db=cosmic.read)
	save(RNAseq, file=paste0("/home/jp/Desktop/tosato/BPCDN/", i,"RNAseqFilter.RData"))
	write.table(RNAseq,file=glue("/home/jp/Desktop/tosato/BPCDN/{i}_RNAseqFilter.tsv"),quote=F,row.names=F,sep="\t")
	
}
end_time <- Sys.time()
print(end_time-start_time)
