#!/usr/local/bin/wish
#
# tclvu.tcl      A small Tcl/Tk app that allows the user to view the 
#                contents of a tar or tar+gzip file and optionally
#                view/edit/save a file within the archive.
#
# Copyright (c) 1996 John M. Fisk <fiskjm@ctrvax.vanderbilt.edu>
#
# VERSION:
# $Id: tclvu.tcl,v 1.1.1.1 2002/08/14 22:26:57 dan Exp $


# GLOBAL DEFINITIONS
#
# print command definition
set lprCmd        "lpr"

# tar and tgz 'find' recognition strings
set tarStr "tar archive"
set tgzStr "gzip compressed data"


#######################################################################
# PROCEDURE DEFINITIONS
#######################################################################

proc CreateWindow {} {
#
# creates the top level window and sets the listbox and button bindings
# for these widgets

    global pathname 
    global filename
    global tarType
    global tarStr
    global tgzStr

    # DEFINE WM ATTRIBS
    wm title . "TclVu Tar Archive Viewer"

    # DEFINE FRAMES
    frame .frPath -bd 2 -relief groove
    frame .frFile -bd 2
    frame .frDir  -bd 2 -relief groove
    frame .frBut  -bd 2 -relief sunken
    pack .frPath \
         .frFile \
         .frDir \
         .frBut \
         -side top -fill x -expand false -padx 1m -pady 1m

    # DEFINE PATH ENTRY BOX AND UP BUTTON
    label .frPath.lblPath -text "Path: "
    set PTH [entry .frPath.entPath -width 80 -relief sunken \
        -textvariable pathname]
    bind $PTH <Return> {
        if [file isdirectory $pathname] {
            cd $pathname
            set filename ""
            DirList $pathname
        } else {
            set pathname [pwd]
        }
    }
    button .frPath.btnPathUp -text "Up.." -command {
        if [file isdirectory $pathname] {
            cd ..
            set pathname [pwd]
            DirList $pathname
        } else {
            set pathname [string range $pathname 0 [expr [string last / \
                $pathname] -1]]
            set filename ""
            DirList $pathname
        }
    }
    pack .frPath.lblPath -side left -expand false -padx 1m
    pack .frPath.entPath -side left -expand false -padx 1m -pady 2m
    pack .frPath.btnPathUp -side right -expand false -padx 1m

    # FILE LABEL AND ENTRY BOX
    label .frFile.lblFile -text "File: "
    entry .frFile.entFile -width 32 -textvariable filename -relief flat \
        -foreground red -font 9x15
    pack  .frFile.lblFile \
          .frFile.entFile \
          -side left -expand false -padx 1m -pady 0.25m

    # DIRECTORY LISTBOX
    set LB [listbox .frDir.lbxDir -relief raised -bd 2 -yscrollcommand \
        ".frDir.sbDir set" -width 72 -height 12 -font 8x13]
    scrollbar .frDir.sbDir -command ".frDir.lbxDir yview"

    bind $LB <Double-Button-1> {
        #
        # BIND DOUBLE CLICK IN LISTBOX
        # since we're using a long directory listing, create a tmp
        # list and get the file/dir name from the last item in the list

        # PARSE SELECTION
        foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isdirectory $fname] {
            cd $fname
            set pathname [pwd]
            DirList $pathname
        } elseif [file isfile $fname] {
            if [regexp $tarStr [exec file $fname]] {
                set pathname "$pathname/$fname"
                set tarType tar
                TarList $fname
            } elseif [regexp $tgzStr [exec file $fname]] {
                set pathname "$pathname/$fname"
                set tarType tgz
                TarList $fname
            } else {
            }
        } else {
            if [file isfile $pathname] {
                if [regexp $tarStr [exec file $pathname]] {
                    set tarType tar
                    TarView $pathname [selection get]
                } elseif [regexp $tgzStr [exec file $pathname]] {
                    set tarType tgz
                    TarView $pathname [selection get]
                } else {
                }
            }
        }
    }
    bind $LB <ButtonRelease-1> {
        #
        # BIND SINGLE CLICK IN LISTBOX
        # only set the filename if in directory listing
        # mode; if in tar archive listing mode, leave the
        # archive filename in the File entry box

        foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]
        if [file isdirectory $pathname] {
            if [file isfile $fname] {
                set filename $fname
            } else {
                set filename ""
            }
        }
    }
    bind $LB <ButtonRelease-3> { .frBut.btnSave invoke }
    pack .frDir.sbDir -side right -fill y
    pack .frDir.lbxDir -side left -fill both -expand true

    # COMMAND BUTTONS
    button .frBut.btnView -text "View/Edit..." -command {
        foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isdirectory $fname] {
            cd $fname
            set pathname [pwd]
            DirList $pathname
        } elseif [file isfile $fname] {
            if [regexp $tarStr [exec file $fname]] {
                set pathname "$pathname/$fname"
        set tarType tar
                TarList $fname
            } elseif [regexp $tgzStr [exec file $fname]] {
                set pathname "$pathname/$fname"
        set tarType tgz
                TarList $fname
            } else {
            }
        } else {
            if [file isfile $pathname] {
                if [regexp $tarStr [exec file $pathname]] {
                    set tarType tar
                    TarView $pathname [selection get]
                } elseif [regexp $tgzStr [exec file $pathname]] {
                    set tarType tgz
                    TarView $pathname [selection get]
                } else {
                }
            }
        }
    }
    button .frBut.btnSave -text "Save..." -command {
        if [file isfile $pathname] {
            SaveFile $pathname [selection get]
        }
    }
    button .frBut.btnPrnt -text "Print..." -command {
        if [file isfile $pathname] {
            if [regexp $tarStr [exec file $pathname]] {
                set tarType tar
                PrintFile $pathname [selection get]
            } elseif [regexp $tgzStr [exec file $pathname]] {
                set tarType tgz
                PrintFile $pathname [selection get]
            } else {
            }
        }
    }
    button .frBut.btnQuit -text "Quit" -command { exit }
    pack .frBut.btnView \
         .frBut.btnSave \
         .frBut.btnPrnt \
         .frBut.btnQuit \
         -side left -fill x -expand true -padx 2m -pady 2m
}
# END CreateWindow ----------------------------------------------------


proc PrintFile { tarfile sfile } {
#
# displays a small dialog box requesting print command

    global tarType
    global lprCmd
    global aFile
    global sFile

    # DEFINE VARs
    set aFile $tarfile
    set sFile $sfile

    # DEFINE TOPLEVEL WINDOW
    toplevel .prt
    wm title .prt "TclVu Printing $sfile"

    # DEFINE FRAMES
    frame .prt.frEnt -relief groove -bd 2
    frame .prt.frBut -relief sunken -bd 2
    pack  .prt.frEnt \
          .prt.frBut \
          -side top -fill x -expand false -padx 2m -pady 2m

    # DEFINE LPR COMMAND ENTRY BOX
    label .prt.frEnt.lbl -text "Enter print command: "
    entry .prt.frEnt.ent -textvariable lprCmd -width 24
    pack  .prt.frEnt.lbl -side left -expand false
    pack  .prt.frEnt.ent -side left -fill x -expand true

    # DEFINE PRINT AND CANCEL BUTTONS
    button .prt.frBut.butPrnt -text "Print" -command {
        if {$tarType == "tar"} {
            eval exec tar -xOf $aFile $sFile | $lprCmd -
            destroy .prt
        } elseif {$tarType == "tgz"} {
            eval exec tar -xzOf $aFile $sFile | $lprCmd -
            destroy .prt
        } else {
        }
    }
    button .prt.frBut.butCncl -text "Cancel" -command { destroy .prt }
    pack .prt.frBut.butPrnt \
         .prt.frBut.butCncl \
         -side left -fill x -expand true -padx 2m -pady 2m
}
# END PrintFile -------------------------------------------------------


proc SaveFile { tarfile sfile } {
#
# displays a directory browser window from which the selected file
# may be saved or appended to a file

    global tarType
    global dirname
    global aFile
    global sFile
    global sFilename
    global tmpPWD

    # SET VARs
    set dirname [pwd]
    set aFile $tarfile
    set sFile $sfile
    set sFilename "$dirname/"
    set tmpPWD [pwd]

    # DEFINE TOPLEVEL WINDOW
    toplevel .save
    wm title .save "TclVu Saving File: $sfile"

    # DEFINE FRAMES
    frame .save.frLbl -relief groove -bd 2
    frame .save.frLbx -relief groove -bd 2
    frame .save.frEnt -relief flat   -bd 2
    frame .save.frBut -relief sunken -bd 2
    pack  .save.frLbl \
          .save.frLbx \
          .save.frEnt \
          .save.frBut \
          -side top -fill x -expand true -padx 2m -pady 2m

    # DEFINE TOPMOST DIRECTORY LABEL AND BUTTONS
    label .save.frLbl.lblDir -text "Directory: "
    entry .save.frLbl.entDir -textvariable dirname -width 72
    button .save.frLbl.butUp -text "Up.." -command {
        cd ..
        set dirname [pwd]
        set sFilename "$dirname/"
        set dirlist [exec ls -al $dirname]
        .save.frLbx.lbxDir delete 0 end
        foreach i [split $dirlist "\n"] {
            .save.frLbx.lbxDir insert end $i
        }
    }
    pack  .save.frLbl.lblDir \
          .save.frLbl.entDir \
          -side left -fill x -expand true -padx 2m -pady 2m
    pack  .save.frLbl.butUp -side right -expand false -padx 2m -pady 2m

    # DEFINE DIRECTORY ENTRYBOX <RETURN> BINDING
    bind .save.frLbl.entDir <Return> {
        if [file isdirectory $dirname] {
            cd $dirname
            set sFilename "$dirname/"
            set dirlist [exec ls -al $dirname]
            .save.frLbx.lbxDir delete 0 end
            foreach i [split $dirlist "\n"] {
                .save.frLbx.lbxDir insert end $i
            }
        } else {
            set dirname [pwd]
        }
    }

    # DEFINE DIRECTORY LISTBOX AND SCROLLBAR
    listbox .save.frLbx.lbxDir -relief raised -bd 2 -yscrollcommand \
        ".save.frLbx.sbDir set" -width 72 -height 12 -font 8x13
    scrollbar .save.frLbx.sbDir -command ".save.frLbx.lbxDir yview"
    pack .save.frLbx.sbDir -side right -fill y
    pack .save.frLbx.lbxDir -side left -fill x -expand true

    # DEFINE LISTBOX DOUBLE CLICK EVENT
    bind .save.frLbx.lbxDir <Double-Button-1> {
        foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isdirectory $fname] {
            cd $fname
            set dirname [pwd]
            set sFilename "$dirname/"
            set dirlist [exec ls -al $dirname]
            .save.frLbx.lbxDir delete 0 end
            foreach i [split $dirlist "\n"] {
                .save.frLbx.lbxDir insert end $i
            }
        } elseif [file isfile $fname] {
            set sFilename "$dirname/$fname"
        } else {
        }
    }
    # DEFINE LISTBOX SINGLE CLICK EVENT
    bind .save.frLbx.lbxDir <ButtonRelease-1> {
            foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isfile $fname] {
            set sFilename "$dirname/$fname"
        } elseif [file isdirectory $fname] {
            set sFilename "$dirname/"
        } else {
        }
    }

    # GET INITIAL DIRECTORY LISTING
    .save.frLbx.lbxDir delete 0 end
    set dirlist [exec ls -al $dirname]
    foreach i [split $dirlist "\n"] {
        .save.frLbx.lbxDir insert end $i
    }

    # DEFINE FILENAME ENTRY BOX
    label .save.frEnt.lbl -text "Filename: "
    entry .save.frEnt.ent -textvariable sFilename -width 72
    pack  .save.frEnt.lbl -side left -pady 2m
    pack  .save.frEnt.ent -side left -fill x -pady 0.5m

    # DEFINE OPERATION BUTTONS
    # SAVE AS BUTTON
    button .save.frBut.butSave -text "Save As" -command {
        if [file exists $sFilename] {
            set sFilename "$dirname/"
        } else {
            if {$tarType == "tar"} {
                exec tar -xOf $aFile $sFile > $sFilename
            } elseif {$tarType == "tgz"} {
                exec tar -xzOf $aFile $sFile > $sFilename
            } else {
            }
            cd $tmpPWD
            destroy .save
        }
    }
    # APPEND BUTTON
    button .save.frBut.butApnd -text "Append" -command {
        if {![file isfile $sFilename]} {
            set sFilename "$dirname/"
        } else {
            if {$tarType == "tar"} {
                exec tar -xOf $aFile $sFile >> $sFilename
            } elseif {$tarType == "tgz"} {
                exec tar -xzOf $aFile $sFile >> $sFilename
            } else {
            }
            cd $tmpPWD
            destroy .save
        }        
    }
    # QUIT BUTTON
    button .save.frBut.butQuit -text "Quit" -command { cd $tmpPWD; destroy .save }
    pack .save.frBut.butSave \
         .save.frBut.butApnd \
         .save.frBut.butQuit \
         -side left -fill x -expand true -padx 2m -pady 2m
}
# END SaveFile --------------------------------------------------------


proc DirList { dirname } {
#
# displays a directory listing of the directory specified as 'dirname'
# in the listbox of the main window

    if [file isdirectory $dirname] {

        # CLEAR LISTBOX
        .frDir.lbxDir delete 0 end

        # DISPLAY DIRECTORY LISTING
        set dirlist [exec ls -al $dirname]
        foreach f [split $dirlist "\n"] {
            .frDir.lbxDir insert end $f
        }
    }
}
# END DirList ---------------------------------------------------------


proc TarList { file } {
#
# clears the directory listbox in the main window and displays a listing
# of the files within the selected tar archive.  Note that the global
# variable 'tarType' must be set to either "tar" or "tgz" in order for
# the correct command line options to be specified to tar

    global tarType

    # CLEAR LISTBOX
    .frDir.lbxDir delete 0 end

    # DISPLAY ARCHIVE LISTING
    if { $tarType == "tar" } {
        set tarlist [exec tar -tf $file]
    } elseif { $tarType == "tgz" } {
        set tarlist [exec tar -tzf $file]
    } else {
    }

    foreach i [split $tarlist "\n"] {
        .frDir.lbxDir insert end $i
    }
}
# END TarList ---------------------------------------------------------


proc TarView { tarfile file } {
#
# displays a text viewer/editor in which the specified tar archive file
# may be viewed, edited, saved to disk, or printed

    global fd wd ht 
    global tarType
    global savFilename
    global lprCmd
    global tmpFile

    # DEFINE TOPLEVEL WINDOW
    toplevel .txt
    wm title .txt "TarVu Viewer"

    # DEFINE LOCAL VARs
    set tmpFile /tmp/tclvu.tmp
    set ht 24
    set wd 80
    set savFilename "[pwd]/"

    # DEFINE FRAMES
    frame .txt.frLbl -bd 2 -relief groove
    frame .txt.frTxt -bd 2 -relief groove
    pack  .txt.frLbl \
          .txt.frTxt \
          -side top -fill x -expand true -padx 2m -pady 2m

    # DEFINE FILE LABEL AND BUTTONS
    label .txt.frLbl.lblFile -text "File: $file"
    button .txt.frLbl.butDone -text "Done" -command { destroy .txt }
    button .txt.frLbl.butPrnt -text "Print..." -command { PrintBuffer }
    button .txt.frLbl.butSave -text "Save As..." -command { SaveBuffer }
    button .txt.frLbl.butWide -text "Widen Window" -command {
        set wd [expr $wd + 8]
        .txt.frTxt.text configure -width $wd
    }
    button .txt.frLbl.butLong -text "Lengthen Window" -command {
        set ht [expr $ht + 8]
        .txt.frTxt.text configure -height $ht
    }
    pack  .txt.frLbl.lblFile -side left  -padx 2m -pady 2m
    pack  .txt.frLbl.butDone \
          .txt.frLbl.butPrnt \
          .txt.frLbl.butSave \
          .txt.frLbl.butLong \
          .txt.frLbl.butWide \
          -side right -padx 1m -pady 2m

    # DEFINE TEXT WIDGET AND SB's
    scrollbar .txt.frTxt.sbY -command ".txt.frTxt.text yview" -orient vert
    scrollbar .txt.frTxt.sbX -command ".txt.frTxt.text xview" -orient horiz
    text .txt.frTxt.text -relief raised -width $wd -height $ht -bd 2 \
        -yscrollcommand ".txt.frTxt.sbY set" -font 9x15 -wrap none \
        -xscrollcommand ".txt.frTxt.sbX set"
    pack .txt.frTxt.sbY  -side right  -fill y -expand true
    pack .txt.frTxt.sbX -side bottom -fill x -expand true
    pack .txt.frTxt.text -side left   -fill both -expand true

    # CREATE TMP FILE
    if {$tarType == "tar"} {
        exec tar -xOf $tarfile $file > $tmpFile
    } elseif {$tarType == "tgz"} {
        exec tar -xzOf $tarfile $file > $tmpFile
    } else {
    }

    # DISPLAY TMP FILE
    .txt.frTxt.text delete 1.0 end
    set fd [open $tmpFile]
    while {![eof $fd]} {
        .txt.frTxt.text insert end [read $fd 512]
    }
    close $fd
    exec rm -f $tmpFile
}
# END TarView ---------------------------------------------------------


proc PrintBuffer {} {
#
# displays a small dialog box allowing the user to input the print 
# command.  It then prints the contents of the current edit buffer
# of the TarView window

    global tmpFile
    global lprCmd
    
    # SET VAR's
    set tmpFile /tmp/tclvu.tmp

    # DEFINE TOPLEVEL WINDOW
    toplevel .prtbuf
    wm title .prtbuf "TclVu Printing Edit Buffer"

    # DEFINE FRAMES
    frame .prtbuf.frEnt -relief groove -bd 2
    frame .prtbuf.frBut -relief sunken -bd 2
    pack  .prtbuf.frEnt \
          .prtbuf.frBut \
          -side top -fill x -expand false -padx 2m -pady 2m

    # DEFINE LPR COMMAND ENTRY BOX
    label .prtbuf.frEnt.lbl -text "Enter print command: "
    entry .prtbuf.frEnt.ent -textvariable lprCmd -width 24
    pack  .prtbuf.frEnt.lbl -side left -expand false
    pack  .prtbuf.frEnt.ent -side left -fill x -expand true

    # DEFINE PRINT AND CANCEL BUTTONS
    button .prtbuf.frBut.butPrnt -text "Print" -command {

        # CREATE TMP FILE OF CURRENT BUFFER
        set fd [open $tmpFile w]
        puts $fd [.txt.frTxt.text get 1.0 end]
        close $fd

        # PRINT THEN DELETE TMP FILE
        eval exec $lprCmd $tmpFile
        exec rm -f $tmpFile

        # CLOSE DIALOG WINDOW
        destroy .prtbuf
    }
    button .prtbuf.frBut.butCncl -text "Cancel" -command { destroy .prtbuf }
    pack .prtbuf.frBut.butPrnt \
         .prtbuf.frBut.butCncl \
         -side left -fill x -expand true -padx 2m -pady 2m
}
# END PrintBuffer -----------------------------------------------------


proc SaveBuffer {} {
#
# displays a directory browser window from which the current editing buffer
# may be saved or appended to a file

    global dirname
    global sFilename
    global tmpPWD

    # SET VARs
    set dirname [pwd]
    set sFilename "$dirname/"
    set tmpPWD [pwd]

    # DEFINE TOPLEVEL WINDOW
    toplevel .savbuf
    wm title .savbuf "TclVu Saving Editing Buffer"

    # DEFINE FRAMES
    frame .savbuf.frLbl -relief groove -bd 2
    frame .savbuf.frLbx -relief groove -bd 2
    frame .savbuf.frEnt -relief flat   -bd 2
    frame .savbuf.frBut -relief sunken -bd 2
    pack  .savbuf.frLbl \
          .savbuf.frLbx \
          .savbuf.frEnt \
          .savbuf.frBut \
          -side top -fill x -expand true -padx 2m -pady 2m

    # DEFINE TOPMOST DIRECTORY LABEL AND BUTTONS
    label .savbuf.frLbl.lblDir -text "Directory: "
    entry .savbuf.frLbl.entDir -textvariable dirname -width 72
    button .savbuf.frLbl.butUp -text "Up.." -command {
        cd ..
        set dirname [pwd]
        set sFilename "$dirname/"
        set dirlist [exec ls -al $dirname]
        .savbuf.frLbx.lbxDir delete 0 end
        foreach i [split $dirlist "\n"] {
            .savbuf.frLbx.lbxDir insert end $i
        }
    }
    pack  .savbuf.frLbl.lblDir \
          .savbuf.frLbl.entDir \
          -side left -fill x -expand true -padx 2m -pady 2m
    pack  .savbuf.frLbl.butUp -side right -expand false -padx 2m -pady 2m

    # DEFINE DIRECTORY ENTRYBOX <RETURN> BINDING
    bind .savbuf.frLbl.entDir <Return> {
        if [file isdirectory $dirname] {
            cd $dirname
            set sFilename "$dirname/"
            set dirlist [exec ls -al $dirname]
            .savbuf.frLbx.lbxDir delete 0 end
            foreach i [split $dirlist "\n"] {
                .savbuf.frLbx.lbxDir insert end $i
            }
        } else {
            set dirname [pwd]
        }
    }

    # DEFINE DIRECTORY LISTBOX AND SCROLLBAR
    listbox .savbuf.frLbx.lbxDir -relief raised -bd 2 -yscrollcommand \
        ".savbuf.frLbx.sbDir set" -width 72 -height 12 -font 8x13
    scrollbar .savbuf.frLbx.sbDir -command ".savbuf.frLbx.lbxDir yview"
    pack .savbuf.frLbx.sbDir -side right -fill y
    pack .savbuf.frLbx.lbxDir -side left -fill x -expand true

    # DEFINE LISTBOX DOUBLE CLICK EVENT
    bind .savbuf.frLbx.lbxDir <Double-Button-1> {
        foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isdirectory $fname] {
            cd $fname
            set dirname [pwd]
            set sFilename "$dirname/"
            set dirlist [exec ls -al $dirname]
            .savbuf.frLbx.lbxDir delete 0 end
            foreach i [split $dirlist "\n"] {
                .savbuf.frLbx.lbxDir insert end $i
            }
        } elseif [file isfile $fname] {
            set sFilename "$dirname/$fname"
        } else {
        }
    }
    # DEFINE LISTBOX SINGLE CLICK EVENT
    bind .savbuf.frLbx.lbxDir <ButtonRelease-1> {
            foreach i [split [selection get] \ ] {
            lappend lst $i
        }
        set fname [lindex $lst [expr [llength $lst] -1]]

        if [file isfile $fname] {
            set sFilename "$dirname/$fname"
        } elseif [file isdirectory $fname] {
            set sFilename "$dirname/"
        } else {
        }
    }

    # GET INITIAL DIRECTORY LISTING
    .savbuf.frLbx.lbxDir delete 0 end
    set dirlist [exec ls -al $dirname]
    foreach i [split $dirlist "\n"] {
        .savbuf.frLbx.lbxDir insert end $i
    }

    # DEFINE FILENAME ENTRY BOX
    label .savbuf.frEnt.lbl -text "Filename: "
    entry .savbuf.frEnt.ent -textvariable sFilename -width 72
    pack  .savbuf.frEnt.lbl -side left -pady 2m
    pack  .savbuf.frEnt.ent -side left -fill x -pady 0.5m

    # DEFINE OPERATION BUTTONS
    # SAVE AS BUTTON
    button .savbuf.frBut.butSave -text "Save As" -command {
        if [file exists $sFilename] {
            set sFilename "$dirname/"
        } else {
            set fd [open $sFilename w]
            puts $fd [.txt.frTxt.text get 1.0 end]
            close $fd
            cd $tmpPWD
            destroy .savbuf
        }
    }
    # APPEND BUTTON
    button .savbuf.frBut.butApnd -text "Append" -command {
        if {![file isfile $sFilename]} {
            set sFilename "$dirname/"
        } else {
            set fd [open $sFilename a+]
            puts $fd [.txt.frTxt.text get 1.0 end]
            close $fd
            cd $tmpPWD
            destroy .savbuf
        }        
    }
    # QUIT BUTTON
    button .savbuf.frBut.butQuit -text "Quit" -command {
        cd $tmpPWD 
        destroy .savbuf
    }
    pack .savbuf.frBut.butSave \
         .savbuf.frBut.butApnd \
         .savbuf.frBut.butQuit \
         -side left -fill x -expand true -padx 2m -pady 2m
}
# END SaveBuffer ------------------------------------------------------


#######################################################################
# END PROCEDURE DEFINITIONS 
#######################################################################

# MAIN PROGRAM
CreateWindow
set pathname [pwd]
DirList $pathname
