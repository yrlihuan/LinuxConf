#!/usr/bin/env bash

dir_name=$( basename "$PWD" )


if [ "$dir_name" != "RBQL" ] && [ "$dir_name" != "rbql_core" ]; then
    echo "Error: This test must be run from RBQL dir. Exiting"
    exit 1
fi


die_if_error() {
    if [ $1 != 0 ]; then
        echo "One of the tests failed. Exiting"
        exit 1
    fi
}


cleanup_tmp_files() {
    rm tmp_out.csv 2> /dev/null
    rm random_tmp_table.txt 2> /dev/null
    rm speed_test.csv 2> /dev/null
}


run_unit_tests="yes"
run_node_tests="yes"


while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --skip_unit_tests)
        run_unit_tests="no"
        ;;
        --skip_node_tests)
        run_node_tests="no"
        ;;
        *)
        echo "Unknown option '$key'"
        exit 1
        ;;
    esac
    shift
done


cleanup_tmp_files

py_rbql_version=$( python -m rbql --version )


if [ $run_node_tests == "yes" ]; then
    node_version=$( node --version 2> /dev/null )
    rc=$?
    if [ "$rc" != 0 ] || [ -z "$node_version" ]; then
        echo "WARNING! Node.js was not found. Skipping node unit tests"  1>&2
        run_node_tests="no"
    fi
fi


PYTHONPATH=".:$PYTHONPATH" python test/test_csv_utils.py --create_big_csv_table speed_test.csv


if [ $run_unit_tests == "yes" ]; then
    python2 -m unittest test.test_csv_utils
    die_if_error $?
    python3 -m unittest test.test_csv_utils
    die_if_error $?

    python2 -m unittest test.test_rbql
    die_if_error $?
    python3 -m unittest test.test_rbql
    die_if_error $?

    python2 -m unittest test.test_mad_max
    die_if_error $?
    python3 -m unittest test.test_mad_max
    die_if_error $?

    PYTHONPATH=".:$PYTHONPATH" python test/test_csv_utils.py --create_random_csv_table random_tmp_table.txt

    if [ "$run_node_tests" == "yes" ]; then
        node rbql-js/build_engine.js
        js_rbql_version=$( node rbql-js/cli_rbql.js --version )
        if [ "$py_rbql_version" != "$js_rbql_version" ]; then
            echo "Error: version missmatch between rbql.py ($py_rbql_version) and rbql.js ($js_rbql_version)"  1>&2
            exit 1
        fi
        cd test

        node test_csv_utils.js --run-random-csv-mode ../random_tmp_table.txt
        die_if_error $?

        node test_rbql.js
        die_if_error $?

        node test_csv_utils.js
        die_if_error $?

        cd ..
    fi
fi


# Testing unicode separators
md5sum_canonic="bdb725416a7b17e64034e0a128c6bb96"
md5sum_test=($(python3 -m rbql --query 'select a2, a1' --delim $(echo -e "\u2063") --policy simple --input test/csv_files/invisible_separator_u2063.txt --encoding utf-8 | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "python3 unicode separator test FAIL!"  1>&2
    exit 1
fi
md5sum_test=($(python2 -m rbql --query 'select a2, a1' --delim $(echo -e "\u2063") --policy simple --input test/csv_files/invisible_separator_u2063.txt --encoding utf-8 | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "python2 unicode separator test FAIL!"  1>&2
    exit 1
fi
if [ "$run_node_tests" == "yes" ]; then
    md5sum_test=($( node ./rbql-js/cli_rbql.js --query 'select a2, a1' --delim $(echo -e "\u2063") --policy simple --input test/csv_files/invisible_separator_u2063.txt --encoding utf-8 | md5sum))
    if [ "$md5sum_canonic" != "$md5sum_test" ]; then
        echo "node unicode separator test FAIL!"  1>&2
        exit 1
    fi
fi


# Testing unicode queries
md5sum_canonic="e1fe4bd13b25b2696e3df2623cd0f134"
md5sum_test=($(python3 -m rbql --query "select a2, '$(echo -e "\u041f\u0440\u0438\u0432\u0435\u0442")' + ' ' + a1" --delim TAB --policy simple --input test/csv_files/movies.tsv --encoding utf-8 | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "python3 unicode query test FAIL!"  1>&2
    exit 1
fi
md5sum_test=($(python2 -m rbql --query "select a2, '$(echo -e "\u041f\u0440\u0438\u0432\u0435\u0442")' + ' ' + a1" --delim TAB --policy simple --input test/csv_files/movies.tsv --encoding utf-8 | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "python3 unicode query test FAIL!"  1>&2
    exit 1
fi
if [ "$run_node_tests" == "yes" ]; then
    md5sum_test=($(node ./rbql-js/cli_rbql.js --query "select a2, '$(echo -e "\u041f\u0440\u0438\u0432\u0435\u0442")' + ' ' + a1" --delim TAB --policy simple --input test/csv_files/movies.tsv --encoding utf-8 | md5sum))
    if [ "$md5sum_canonic" != "$md5sum_test" ]; then
        echo "node unicode query test FAIL!"  1>&2
        exit 1
    fi
fi


expected_warning="Warning: Number of fields in \"input\" table is not consistent: e.g. record 1 -> 8 fields, record 3 -> 6 fields"
actual_warning=$( python3 -m rbql --input test/csv_files/movies_variable_width.tsv --delim TAB --policy simple --query 'select a1, a2' 2>&1 1> /dev/null )
if [ "$expected_warning" != "$actual_warning" ]; then
    echo "expected_warning= '$expected_warning' != '$actual_warning' = actual_warning"  1>&2
    exit 1
fi

if [ "$run_node_tests" == "yes" ]; then
    expected_warning="Warning: Number of fields in \"input\" table is not consistent: e.g. record 1 -> 8 fields, record 3 -> 6 fields"
    actual_warning=$( node rbql-js/cli_rbql.js --input test/csv_files/movies_variable_width.tsv --delim TAB --policy simple --query 'select a1, a2' 2>&1 1> /dev/null )
    if [ "$expected_warning" != "$actual_warning" ]; then
        echo "expected_warning= '$expected_warning' != '$actual_warning' = actual_warning"  1>&2
        exit 1
    fi
fi


expected_error="Error [query execution]: At record 1, Details: name 'unknown_func' is not defined"
actual_error=$( python3 -m rbql --input test/csv_files/countries.csv --query 'select top 10 unknown_func(a1)' --delim , --policy quoted 2>&1 )
if [ "$expected_error" != "$actual_error" ]; then
    echo "expected_error = '$expected_error' != '$actual_error' = actual_error"  1>&2
    exit 1
fi

if [ "$run_node_tests" == "yes" ]; then
    expected_error="Error [query execution]: At record 1, Details: unknown_func is not defined"
    actual_error=$( node rbql-js/cli_rbql.js --input test/csv_files/countries.csv --query 'select top 10 unknown_func(a1)' --delim , --policy quoted 2>&1 )
    if [ "$expected_error" != "$actual_error" ]; then
        echo "expected_error = '$expected_error' != '$actual_error' = actual_error"  1>&2
        exit 1
    fi
fi


# Testing performance

start_tm=$(date +%s.%N)
python3 -m rbql --input speed_test.csv --delim , --policy quoted --query 'select a2, a1, a2, NR where int(a1) % 2 == 0' > /dev/null
end_tm=$(date +%s.%N)
elapsed=$( echo "$start_tm,$end_tm" | python -m rbql --delim , --query 'select float(a2) - float(a1)' )
echo "Python simple select query took $elapsed seconds. Reference value: 3 seconds"

if [ "$run_node_tests" == "yes" ]; then
    start_tm=$(date +%s.%N)
    node ./rbql-js/cli_rbql.js --input speed_test.csv --delim , --policy quoted --query 'select a2, a1, a2, NR where parseInt(a1) % 2 == 0' > /dev/null
    end_tm=$(date +%s.%N)
    elapsed=$( echo "$start_tm,$end_tm" | python -m rbql --delim , --query 'select float(a2) - float(a1)' )
    echo "JS simple select query took $elapsed seconds. Reference value: 2.3 seconds"
fi

start_tm=$(date +%s.%N)
python3 -m rbql --input speed_test.csv --delim , --policy quoted --query 'select max(a1), count(*), a2 where int(a1) > 15 group by a2' > /dev/null
end_tm=$(date +%s.%N)
elapsed=$( echo "$start_tm,$end_tm" | python -m rbql --delim , --query 'select float(a2) - float(a1)' )
echo "Python GROUP BY query took $elapsed seconds. Reference value: 2.6 seconds"

if [ "$run_node_tests" == "yes" ]; then
    start_tm=$(date +%s.%N)
    node ./rbql-js/cli_rbql.js --input speed_test.csv --delim , --policy quoted --query 'select max(a1), count(*), a2 where parseInt(a1) > 15 group by a2' > /dev/null
    end_tm=$(date +%s.%N)
    elapsed=$( echo "$start_tm,$end_tm" | python -m rbql --delim , --query 'select float(a2) - float(a1)' )
    echo "JS GROUP BY query took $elapsed seconds. Reference value: 1.1 seconds"
fi



# Testing generic CLI
md5sum_canonic=($( md5sum test/csv_files/canonic_result_4.tsv ))

md5sum_test=($(python -m rbql --delim TAB --query "select a1,a2,a7,b2,b3,b4 left join test/csv_files/countries.tsv on a2 == b1 where 'Sci-Fi' in a7.split('|') and b2!='US' and int(a4) > 2010" < test/csv_files/movies.tsv | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "CLI Python test FAIL!"  1>&2
    exit 1
fi

# XXX theorethically this test can randomly fail because sleep timeout is not long enough
(echo "select select a1" && sleep 0.5 && echo "select a1, nonexistent_func(a2)" && sleep 0.5 && echo "select a1,a2,a7,b2,b3,b4 left join test/csv_files/countries.tsv on a2 == b1 where 'Sci-Fi' in a7.split('|') and b2!='US' and int(a4) > 2010") | python -m rbql --delim '\t' --input test/csv_files/movies.tsv --output tmp_out.csv > /dev/null
md5sum_test=($(cat tmp_out.csv | md5sum))
if [ "$md5sum_canonic" != "$md5sum_test" ]; then
    echo "Interactive CLI Python test FAIL!"  1>&2
    exit 1
fi

if [ "$run_node_tests" == "yes" ]; then
    md5sum_test=($( node ./rbql-js/cli_rbql.js --delim TAB --query "select a1,a2,a7,b2,b3,b4 left join test/csv_files/countries.tsv on a2 == b1 where a7.split('|').includes('Sci-Fi') && b2!='US' && a4 > 2010" < test/csv_files/movies.tsv | md5sum))
    if [ "$md5sum_canonic" != "$md5sum_test" ]; then
        echo "CLI JS test FAIL!"  1>&2
        exit 1
    fi

    # XXX theorethically this test can randomly fail because sleep timeout is not long enough
    (echo "select select a1" && sleep 0.5 && echo "select a1, nonexistent_func(a2)" && sleep 0.5 && echo "select a1,a2,a7,b2,b3,b4 left join test/csv_files/countries.tsv on a2 == b1 where a7.split('|').includes('Sci-Fi') && b2!='US' && a4 > 2010") | node ./rbql-js/cli_rbql.js --input test/csv_files/movies.tsv --output tmp_out.csv --delim '\t' > /dev/null
    md5sum_test=($(cat tmp_out.csv | md5sum))
    if [ "$md5sum_canonic" != "$md5sum_test" ]; then
        echo "Interactive CLI JS test FAIL!"  1>&2
        exit 1
    fi
fi

cleanup_tmp_files

echo "Finished tests"
