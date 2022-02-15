#!/bin/bash

main () {
	if ! $(make linker > /dev/null); then
		exit 1
	fi

	mc_and_err_files=`ls tests/*.{mc,err}`
	tmp_mc_file="tests/tmp.mc"
	tmp_err_file="tests/tmp.err"
	passed=0
	failed=0
	for mc_or_file in $mc_and_err_files
	do
		name="${mc_or_file%.*}"
		for as_file in `ls ${name}_*.as`
		do
			./assembler $as_file "${as_file%.as}.obj"
		done
		expected_err_file="${name}.err"
		expected_mc_file="${name}.mc"
		obj_files=`ls ${name}_*.obj`
		run_test
	done
	rm $tmp_mc_file
	rm $tmp_err_file
	if [ "$failed" -eq "0" ]; then
		echo "Succeed! Passed all ${passed} tests!"
		mkdir -p "submit"
		find "tests" -name "*.as" -exec cp {} "submit" \;
		cp "linker.c" "submit"
		echo "Packaged all files required by the AG to submit/"
	else
		total=$(( passed + failed ))
		rm submit/* 2> /dev/null
		echo "${failed}/${total} tests failed."
	fi
}

run_test () {
	./linker $obj_files $tmp_mc_file > $tmp_err_file
	linker_exit_1=$?
	if [ $linker_exit_1 -eq 1 ]; then
		if equal_expected "err"; then
			passed=$(( passed + 1 ))
		else
			print_test_name
			failed=$(( failed + 1 ))
			print_diff "err"

			if ! equal_expected "mc"; then
				print_diff "mc"
			fi
		fi
	else
		if equal_expected "mc"; then
			passed=$(( passed + 1 ))
		else
			print_test_name
			failed=$(( failed + 1 ))
			cat $tmp_err_file
			print_diff "mc"
		fi
	fi
}

print_test_name () {
	local test_name=${name#*/} # remove "tests/" in front of variable name
	echo "------| $test_name |------"
}

equal_expected () {
	local tmp_file="tmp_$1_file"
	local expected_file="expected_$1_file"
	diff -N -q "${!tmp_file}" "${!expected_file}" >/dev/null;
}

print_diff () {
	local tmp_file="tmp_$1_file"
	local expected_file="expected_$1_file"
	if command -v diff-so-fancy &> /dev/null; then
		diff -N -u "${!tmp_file}" "${!expected_file}" | diff-so-fancy | tail -n +4
	else
		diff -N "${!tmp_file}" "${!expected_file}"
	fi
	# print separating newline
	echo ""
}

main "$@"
