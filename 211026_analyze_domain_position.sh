animal="L_camtschaticum"
input="vertebrate"

function domain_test () {
    function test_domain_region () {
        # Test the domain combination is inner the blast best hit
        if  [ $qstart -le $domstart ] && [ $qend -ge $domend ] ; then
            echo "${acc}\t${domain}\t${domstart}\t${domend}\t${qstart}\t${qend}" \
                >> $outputfile
        fi
    }

    function read_domain_region () {
        # Read domtblout file about domain 1
        cat ${animal}.domtblout | grep $acc | grep $domain |  \
            awk '{if($7 < 1e-3) print }' | while read domtblout
        do
            local domstart=`echo $domtblout | awk '{print $18}'`
            local domend=`  echo $domtblout | awk '{print $19}'`
            echo "${domstart}\t${domend}"
            test_domain_region
        done
    }

    function read_domcom_file () {
        # Read each domain combination file
        cat L_camtschaticum_vertebrate_class2.final_list.csv | grep $acc | while read line
        do
            local domain1=`echo $line | awk -F , '{print $20}'`
            local domain2=`echo $line | awk -F , '{print $21}'`
            echo "${domain1}\t${domain2}"

            for domain in $domain1 $domain2
            do
                read_domain_region
            done
        done
    }

    function read_blast_result_file () {
        cat $inputfile | grep -v "#" | \
            grep `cat L_camtschaticum_vertebrate_class2.list | awk '{print " -e "$1}'` | \
            awk '{if($3 > 90) print}' | \
            while read blast_line
        do
            # Read blast result file
            local acc=`     echo ${blast_line} | awk '{print $1}'`
            local identity=`echo ${blast_line} | awk '{print $3}'`
            local qstart=`  echo ${blast_line} | awk '{print $7}'`
            local qend=`    echo ${blast_line} | awk '{print $8}'`
            echo $acc
            read_domcom_file
        done

    }
    local inputfile=$1
    local outputfile=$2

    # outfile header
    echo "Acc\tDomain\tQuery_start\tQuery_end\tDomain_start\tDomain_end" \
        > $outputfile
    read_blast_result_file
}

domain_test "q_L_camtchaticum_vertebrate_class2_db_210715_Ls_S_Trinity.tsv" "L_camtschaticum/211026_${animal}_${input}_inner_domain.210715_Ls_S_Trinity.tsv"
domain_test "q_L_camtchaticum_vertebrate_class2_db_LcEmb.tsv" "L_camtschaticum/211026_${animal}_${input}_inner_domain.LcEmb.tsv"
domain_test "q_L_camtchaticum_vertebrate_class2_db_Lc_Trinity.cds.tsv" "L_camtschaticum/211026_${animal}_${input}_inner_domain.Lc_Trinity.cds.tsv"
