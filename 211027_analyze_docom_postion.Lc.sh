animal="L_camtschaticum"
input="vertebrate"
inner_out="L_camtschaticum/211025_${animal}_${input}_inner_domcom.Lc_Trinity.cds.tsv"
outer_out="L_camtschaticum/211025_${animal}_${input}_outer_domcom.Lc_Trinity.cds.tsv"
inputfile="q_L_camtchaticum_vertebrate_class2_db_Lc_Trinity.cds.tsv"

function domain_test () {

    local inputfile=$1
    local inner_out=$2
    local outer_out=$3

    function test_domain_region () {
        # Test the domain combination is inner the blast best hit
        if  [ $qstart -le $dom1start ] && [ $qend -ge $dom1end ] && \
            [ $qstart -le $dom2start ] && [ $qend -ge $dom2end ]; then
            echo "${acc}\t${domain1},${domain2}\t${qstart}\t${qend}\t${dom1start}\t${dom1end}\t${dom2start}\t${dom2end}" \
                >> $inner_out
        # Else
        else
            echo "${acc}\t${domain1},${domain2}\t${qstart}\t${qend}\t${dom1start}\t${dom1end}\t${dom2start}\t${dom2end}" \
                >> $outer_out
        fi

    }

    function read_domtblout_file () {
        # Read domtblout file about domain 1
        cat ${animal}.domtblout | grep $acc | grep $domain1 |  \
            awk '{if($7 < 1e-3) print }' | while read domtblout1
        do
            local dom1start=`echo $domtblout1 | awk '{print $18}'`
            local dom1end=`  echo $domtblout1 | awk '{print $19}'`
            echo "${dom1start}\t${dom1end}"

            # Read domtblout file about domain 2
            cat ${animal}.domtblout | grep $acc | grep $domain2 |  \
                awk '{if($7 < 1e-3) print }' | while read domtblout2
            do
                local dom2start=`echo $domtblout2 | awk '{print $18}'`
                local dom2end=`  echo $domtblout2 | awk '{print $19}'`
                test_domain_region
            done
        done
    }

    function read_domcom_file () {
        # Read each domain combination file
        cat L_camtschaticum_vertebrate_class2.final_list.csv | grep $acc | while read line
        do
            local domain1=`echo $line | awk -F , '{print $20}'`
            local domain2=`echo $line | awk -F , '{print $21}'`
            echo "${domain1}\t${domain2}"
            read_domtblout_file
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

    # outfile header
    echo "Acc\tDomain1,Domain2\tQstart\tQend\tDomain1_start\tDomain1_end\tDomain2_start\tDomain2_end" \
        > $inner_out
    echo "Acc\tDomain1,Domain2\tQstart\tQend\tDomain1_start\tDomain1_end\tDomain2_start\tDomain2_end" \
        > $outer_out
    read_blast_result_file
}

domain_test "q_L_camtchaticum_vertebrate_class2_db_210715_Ls_S_Trinity.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_inner_domain.210715_Ls_S_Trinity.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_outer_domain.210715_Ls_S_Trinity.tsv"

domain_test "q_L_camtchaticum_vertebrate_class2_db_LcEmb.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_inner_domain.LcEmb.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_outer_domain.LcEmb.tsv"

domain_test "q_L_camtchaticum_vertebrate_class2_db_Lc_Trinity.cds.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_inner_domain.Lc_Trinity.cds.tsv" \
    "L_camtschaticum/211027_${animal}_${input}_outer_domain.Lc_Trinity.cds.tsv"
