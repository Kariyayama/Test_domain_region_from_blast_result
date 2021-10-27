input="vertebrate"

function domain_test () {

    local inputfile=$1
    local inner_out=$2
    local outer_out=$3
    local animal=$4

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
        cat "${animal}.domtblout" | grep $acc | grep $domain1 |  \
            awk '{if($7 < 1e-3) print }' | while read domtblout1
        do
            local dom1start=`echo $domtblout1 | awk '{print $18}'`
            local dom1end=`  echo $domtblout1 | awk '{print $19}'`
            echo "Domain1\t${dom1start}\t${dom1end}"

            # Read domtblout file about domain 2
            cat "${animal}.domtblout" | grep $acc | grep $domain2 |  \
                awk '{if($7 < 1e-3) print }' | while read domtblout2
            do
                local dom2start=`echo $domtblout2 | awk '{print $18}'`
                local dom2end=`  echo $domtblout2 | awk '{print $19}'`
                echo "Domain2\t${dom2start}\t${dom2end}"
                test_domain_region
            done
        done
    }

    function read_domcom_file () {
        # Read each domain combination file
        cat ${animal}_vertebrate_class2.csv | grep $acc | while read line
        do
            local domain1=`echo $line | awk -F , '{print $20}'`
            local domain2=`echo $line | awk -F , '{print $21}'`
            echo "Domain1\t${domain1}\tDomain2\t${domain2}"
            read_domtblout_file
        done
    }

    function read_blast_result_file () {
        cat $inputfile | grep -v "#" | \
            grep `cat ${animal}_vertebrate_class2.csv | \
            cut -d , -f 22- | tr , "\n" | awk '{print " -e "$1}'` | \
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

for target in P_marinus E_burgeri; do
    for file in Lr_Trinity LcEmb Lc_Trinity.cds; do
        domain_test "q_${target}_vertebrate_class2_db_${file}.tsv" \
            "${target}/211027_${target}_${input}_inner_domain.${file}.tsv" \
            "${target}/211027_${target}_${input}_outer_domain.${file}.tsv" \
            $target
    done
done


