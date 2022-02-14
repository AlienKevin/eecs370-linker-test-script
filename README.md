# P2L Linker Test Script

## Set up
1. Put all `.as` and expected `.mc` files in the `/tests` folder. Follow the naming scheme of the P2L spec.
2. For the given `.mc` files, remove `.correct` at the end of the file extension.
3. Copy over the `assembler` executable from P2A
4. Copy the `test.sh` to your project root

Optional but recommended: [Install `diff-so-fancy` for good-looking diffs](https://github.com/so-fancy/diff-so-fancy#install).

## Testing for Errors
When your linker detects an error, it should print a line of error message and `exit(1)`.
Our test script can check if the error is caught. Simply include the `.as` files as usual and put a `.err` file of the same name with the error message in it. *Do not* include a blank `.mc` file.

Your project directory should look like the following:

```
/
├── tests/
│   ├── count5_1.as
│   ├── count5_2.as
│   ├── count5.mc
│   ├── duplicatedGlobal_1.as
│   ├── duplicatedGlobal_2.as
│   └── duplicatedGlobal.err
│ test.sh
│ linker.c
│ Makefile
```

## Running tests
1. Give permission to `test.sh`
```
chmod +x test.sh
```
2. Run `test.sh`. The script will generate the `.obj` file for each `.as`. You can run test directly after changing `linker.c`. The script will run `make` for you.
```
./test.sh
```
3. If all tests pass, you will see a success message. The script packages all test files and `linker.c` to the `submit/` folder. Those are all the files you need for the Autograder.
	```
	Succeed! Passed all 7 tests!
	```
	If one or more of the tests failed, you will see a series of diff outputs for each failed test case:
	```
	@ tests/count5.mc:3 @
	8454153
	8650763
	23527404
	23527424
	16842753

	1/7 tests failed.
	```

## Supported Platforms
* Tested on macOS Monterey
* Should work on Linux and WSL (not tested)

## License
MIT