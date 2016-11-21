# brewupdate #

Simple bash script to update [homebrew][homebrew] regularly (10:00am and 10:00pm every day).

It was originally inspired from the [brewupdate][brewupdate] script from [mkalmes][mkalmes].


## How to install? ##

To install the script, simply download the `install.sh` script and run it.
You can use either:
```sh
curl -L https://raw.githubusercontent.com/bebelher/brewupdate/master/install.sh | bash
```
Or, if you prefer to use wget:
```sh
wget -q -O - https://raw.githubusercontent.com/bebelher/brewupdate/master/install.sh | bash
```
If your system complains about wget not being installed, you can install it using homebrew:
```sh
# If wget is not present in your system, you can install it with homebrew.
brew install wget
```

## How to upgrade? ##

If you wish to upgrade the script, run the same command as for the installation:
```sh
wget -q -O - https://raw.githubusercontent.com/bebelher/brewupdate/master/install.sh | bash
```

## How does the installation script work? ##

The script will create a folder `~/.brewupdate/` and copy `brewupdate.sh` inside it.
It will install the `brewupdate.job.plist` in the folder `~/Library/LaunchAgents/`, then load the job using `launchctl`.


If a file already exists, it will be replaced only if the downloaded file is different.

## How do I check the output of the script? ##

If you want to check the stdout and stderr of the script, please check the content of `~/.brewupdate/stdout` or `~/.brewupdate/stderr`.

## What to do if the script does not work as expected? ##

You are welcome to [open an issue][issue]!

## Licence ##

The code is under the [MIT License][license].

[homebrew]: https://github.com/mxcl/homebrew/
[license]: https://github.com/bebelher/brewupdate/raw/master/LICENSE
[issue]: https://github.com/bebelher/brewupdate/issues/new
[brewupdate]: https://github.com/mkalmes/brewupdate
[mkalmes]:https://github.com/mkalmes
