git-bash-scripts
================

The scripts in this repository should be able to be used within the platform-independent Git bash shell as well as the
actual bash shell on a linux machine.

Installation
============
To use these scripts globally, you will need to copy these to a folder within Git Bash's PATH.
For instance, you can do the following:
	$ # See what paths can contain our scripts
	$ echo $PATH
	/h/bin:.:/usr/local/bin:/mingw/bin:/bin:/c/WINDOWS/system32:/c/WINDOWS:/c/WINDOW
	S/System32/Wbem:/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/c/Program Files (x8
	6)/Microsoft Application Virtualization Client:/c/Program Files/ActivIdentity/Ac
	tivClient/:/c/Program Files (x86)/ActivIdentity/ActivClient/:/c/Program Files (x
	86)/QuickTime/QTSystem/

	$ # Preferred location is ~/bin. Make sure that it translates to a location in
	$ # our PATH variable
	$ echo ~/bin
	/h/bin

	$ # See if this folder exists
	$ ls ~/bin
	ls: /h/bin: No such file or directory

	$ # Create the folder if it does not exist
	$ mkdir ~/bin

	$ # Copy scripts to bin folder
	$ cp /C/path/to/repo/git-scripts/* ~/bin


Contributing
============
This Git script library is maintained by Leonard T. Erwine. The origin repository is located at:
	https://github.com/lerwine/git-bash-scripts.git.
If you wish to contribute, please send an email to lenny@erwinefamily.net.

Windows Development Notes
=========================
Using Git bash is very similar to working within a linux environment. This includes the fact that git bash expects script files to use unix line endings.
Also, you will need to convert windows paths to linux-style paths:
	Use forward slash (\) characters in place of the back-slash (\)
	When referencing a drive: Use a forward slash, followed by the drive letter, omitting the colon. For instance, "C:\Users" should be referenced as "/C/Users".
	When referencing a network UNC, use 2 forward-slashes at the beginning, rather than 2 back-slashes. For instance, "\\MyMachine\MyShare\MyFolder" should be referenced as "//MyMachine/MyShare/MyFolder".

To see a listing of available linux-like commands as well as git-specific commands, use the following command:
	ls /bin

GNU Bash manual page
http://www.gnu.org/software/bash/manual/html_node/index.html

GNU Core Utilities
http://www.gnu.org/software/coreutils/manual/coreutils.html

Linux man-pages project
https://www.kernel.org/doc/man-pages/

Alternate manual page website
http://www.linuxmanpages.com/
