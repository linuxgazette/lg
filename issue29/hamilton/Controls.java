package Jcd; // -- Listing-3 -- Controls.java//  1
                                             //  2
import java.io.*;                            //  3
import java.util.*;                          //  4
import java.awt.*;                           //  5
import java.awt.event.*;                     //  6
                                             //  7
import Jcd.SmartDrive;                       //  8
import Jcd.Monitor;                          //  9
                                             // 10
class Controls                               // 11 
  extends Panel 
  implements ActionListener {             
                                             // 12
  // Control panel, buttons: play, stop, eject ...
                                             // 14
  private SmartDrive cdPlayer;               // 15
                                             // 16
  private Button play  = new Button("Play"); // 17
  private Button pause = new Button("Pause");// 18
  private Button stop  = new Button("Stop"); // 19
  private Button next  = new Button("Next"); // 20
  private Button prev  = new Button("Prev"); // 21
  private Button eject = new Button("Eject");// 22
                                             // 23
  public Controls(SmartDrive drive)          // 24
  {                                          // 25
    cdPlayer = drive;                        // 26
    setLayout(new GridLayout(1, 6, 2, 2));   // 27
    add(play); add(stop); add(pause);        // 28
    add(prev); add(next); add(eject);
  }                                          // 29
                                             // 30
  private void add(Button b) {               // 31
    b.addActionListener(this);               // 32
    super.add(b);                            // 33
  }                                          // 34
                                             // 35
  public void actionPerformed(ActionEvent event) {
    try {                                    // 37
      Object source = event.getSource();     // 38
                                             // 39
      if (source == play) cdPlayer.startPlaying(); 
      else if (source == stop)  cdPlayer.stop();
      else if (source == next)  cdPlayer.next();
      else if (source == prev)  cdPlayer.prev();
      else if (source == pause) 
        cdPlayer.togglePause();
      else if (source == eject) cdPlayer.eject();
    }                                        // 45
    catch (DriveException except) {          // 46
      System.out.println("Exception " + except); 
    }                                        // 48
  }                                          // 49
                                             // 50
}                                            // 51
                                             // 52
