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
	else
		total=$(( passed + failed ))
		echo "${failed}/${total} tests failed."
	fi
}

run_test () {
	./linker $obj_files $tmp_mc_file > $tmp_err_file
	if equal_expected "err"; then
		if equal_expected "mc"; then
			passed=$(( passed + 1 ))
		else
			failed=$(( failed + 1 ))
			print_diff "mc"
		fi
	else
		failed=$(( failed + 1 ))
		print_diff "err"

		if ! equal_expected "mc"; then
			print_diff "mc"
		fi
	fi
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
