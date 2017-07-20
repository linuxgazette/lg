emelFM 0.9.2, by Michael Clark <macst92@imap.pitt.edu>
Copyright (c) 1999,2000


Description
~~~~~~~~~~~
emelFM is a file manager that implements the popular two-pane design. It
features a simple GTK+ interface, a flexible filetyping scheme, and a built-in
command line for executing commands without opening an xterm.


Needed to compile/run
~~~~~~~~~~~~~~~~~~~~~
GTK+ v1.2.x

This version is tested with GTK+ 1.2.8 on Solaris 7


Compilation & Installation
~~~~~~~~~~~~~~~~~~~~~~~~~~
make
make install 

* If you need to install to someplace other than /usr/local, edit
  Makefile.common and change PREFIX to wherever you want to install
               
type "emelfm" to run the program


Uninstallation
~~~~~~~~~~~~~~
make uninstall


Default Key Bindings
~~~~~~~~~~~~~~~~~~~~
Open            Enter, Right         Open/Close          Ctrl+W
Up Dir          Backspace, Left      output window
Home Dir        HOME
Switch Panels   Space, Tab           Switch focus        Ctrl+Z
Tag             Ctrl+T, INS          to command line
Find            Ctrl+F
                                     Toggle Hidden       Ctrl+H
Copy            Ctrl+C               files
Copy As         Ctrl+Shift+C
Move            Ctrl+M               Maximize/Minimize   Ctrl+,  (left)
Move As         Ctrl+Shift+M         Panels              Ctrl+.  (right)
SymLink         Ctrl+S
SymLink As      Ctrl+Shift+S         Menu                Ctrl+P
Rename          Ctrl+R               Plugins Menu        Ctrl+[
Delete          DEL                  User Menu           Ctrl+]
Make Dir        Ctrl+D
Refresh         Ctrl+L
Sync Dirs       Ctrl+X
Quit            Ctrl+Q			


Command Line Tricks
~~~~~~~~~~~~~~~~~~~
Ctrl+Enter Copies the selected filenames in the active pane
Ctrl+L     Copies the selected pathnames in the inactive pane
Ctrl+D     Copies the active directory name
Ctrl+O     Copies the inactive directory name
Ctrl+Z     Close output window and change focus to current file list
(Note: Command line shortcuts also work with Alt+<letter>)

If you prefix a command with an 'x', emelFM will open an xterm and execute
the command from there. For example 'x man fopen', will open an xterm with
the manpage for fopen. This is useful for interactive programs that the
emelFM command line can't handle.

If you prefix a command with 'su', emelFM will open an xterm and su to root to
execute the command. For example 'su make install', will open an xterm, prompt
for the root password, and then execute the 'make install' in the current
directory.

If you append an '&' to the end of a command emelFM will not capture the output
of the process.

Typing 'keys' at the command line will list the keyboard shortcuts.
Typing 'clear' at the command line will clear the output field


Drag & Drop
~~~~~~~~~~~
Drag and drop is activated by selecting the files you want to copy/move/link,
and then clicking the middle mouse button and dragging to another location in
either of the directory lists. If you drag to a directory the files will be
copied/moved/linked to that directory, otherwise they will be copied/moved/
linked to the directory of the list. When you release the button, a menu will
prompt you for the operation you want to perform (copy/move/link). I find that
this is most useful for moving files into a subdirectory of the current
directory, since you can avoid changing the other directory. It is also
possible to drag and drop between different instances emelFM and some other
gtk+ apps like Gnome Midnight Commander and GQView.


Action Notes
~~~~~~~~~~~~
Prefixing an action with 'x' will open an xterm to execute the action.
Prefixing an action with 'su' will open an xterm and su to root to execute the
action.
Appending the '&' character to an action will cause emelFM to discard the output
of the command. (By default, emelFM will capture the output and print it to the
output window)

Macros:
%f = The selected filename(s) in the active directory
%F = The full pathname(s) of files selected in inactive directory
%d = The active directory name
%D = The inactive directory name
%{Prompt message} = Prompt for input with the message "Prompt message"

Examples:

  x rpm -qlip %f | less

This opens an xterm and executes an rpm query command and pipes the output
to 'less'. If the output were not piped to 'less', the xterm would exit after
the query finished and the user would not be able to see the results for very
long.

  su rpm -Uvh %f

This opens an xterm and su's to root, prompting for the root password. Then it
executes the RPM install command which would probably fail if done as a normal
user.

  tar xzvf %f -C %D &

This unpacks a tarball from the active directory into the inactive directory.
Because of the '&' at the end, emelFM will *not* capture the output.

  diff -c %f %F > %{Filename for patch:}

This runs the diff command to create a patch between the selected files,
prompting for the filename for the patch.


Other Notes
~~~~~~~~~~~
Shift+Right Click:
Right Clicking on the file listing while holding down the Shift key will
activate the Plugins menu.

Ctrl+Right Click:
Right Clicking on the file listing while holding down the Ctrl key will
activate the User Commands menu.

Right Clicking on the "Up Dir" button will take you to the home directory
Right Clicking on the "<" button will copy the directory to the opposite
directory (Like Sync Dirs)

Typing 'keys' at the command line will list the keyboard shortcuts.
Typing 'clear' at the command line will clear the output field


Credits
~~~~~~~
I would like to thank the following people for their contributions to emelFM:

  * Aurelien Gateau
  * Paul Evans
  * Vaclav Dvorak
  * Konstantin Volckov
  * All users that have sent suggestions, bug reports and compliments


emelFM is essentially just a compilation of some of the features that i have
found most useful in other file managers. An abbreaviated "thank you" list:

  * Henrik Harmsen for FileRunner
  * Pixel for sfm
  * Emil Brink for gentoo
  * GNU for Midnight Commander.
  

Homepage
~~~~~~~~
http://www.pitt.edu/~macst92/emelfm/
http://emelfm.sourceforge.net/


Contact
~~~~~~~
macst92@imap.pitt.edu


