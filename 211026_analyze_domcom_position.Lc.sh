animal="L_camtschaticum"
input="vertebrate"
inner_out="L_camtschaticum/211025_${animal}_${input}_inner_domcom.Lc_Trinity.cds.tsv"
outer_out="L_camtschaticum/211025_${animal}_${input}_outer_domcom.Lc_Trinity.cds.tsv"
inputfile="q_L_camtchaticum_vertebrate_class2_db_Lc_Trinity.cds.tsv"

cat L_camtschaticum_vertebrate_class2.csv | \
    grep `cat ../Final_gene_list_vertebrate_class2.list| awk '{print " -e "$1","$3}'` | \
    grep -v class2 \
    > L_camtschaticum_vertebrate_class2.final_list.csv

# outfile header
echo "Acc\tDomain1,Domain2" \
    > $inner_out
echo "Acc\tDomain1,Domain2" \
    > $outer_out


cat $inputfile | grep -v "#" | \
    grep `cat L_camtschaticum_vertebrate_class2.list | awk '{print " -e "$1}'` | \
    awk '{if($3 > 90) print}' | \
    while read blast_line
do
    # Read blast result file
    acc=`     echo ${blast_line} | awk '{print $1}'`
    identity=`echo ${blast_line} | awk '{print $3}'`
    qstart=`  echo ${blast_line} | awk '{print $7}'`
    qend=`    echo ${blast_line} | awk '{print $8}'`
    echo $acc

    # Read each domain combination file
    cat L_camtschaticum_vertebrate_class2.final_list.csv | grep $acc | while read line
    do
        domain1=`echo $line | awk -F , '{print $20}'`
        domain2=`echo $line | awk -F , '{print $21}'`
        echo "${domain1}\t${domain2}"

        # Read domtblout file about domain 1
        cat ${animal}.domtblout | grep $acc | grep $domain1 |  \
            awk '{if($7 < 1e-3) print }' | while read domtblout1
        do
            dom1start=`echo $domtblout1 | awk '{print $18}'`
            dom1end=`  echo $domtblout1 | awk '{print $19}'`
            echo "${dom1start}\t${dom1end}"

            # Read domtblout file about domain 2
            cat ${animal}.domtblout | grep $acc | grep $domain2 |  \
                awk '{if($7 < 1e-3) print }' | while read domtblout2
            do
                dom2start=`echo $domtblout2 | awk '{print $18}'`
                dom2end=`  echo $domtblout2 | awk '{print $19}'`

                # Test the domain combination is inner the blast best hit
                if  [ $qstart -le $dom1start ] && [ $qend -ge $dom1end ] && \
                    [ $qstart -le $dom2start ] && [ $qend -ge $dom2end ]; then
                    echo "${acc}\t${domain1},${domain2}" \
                        >> $inner_out
                # Else
                else
                    echo "${acc}\t${domain1},${domain2}" \
                        >> $outer_out
                fi
            done
        done

    done
done


