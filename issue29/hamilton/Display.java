package Jcd; // -- Listing-4 -- Display.java //  1
                                             //  2
import java.util.*;                          //  3
import java.awt.*;                           //  4
import java.awt.event.*;                     //  5
import Jcd.SmartDrive;                       //  6
import Jcd.Monitor;                          //  7
                                             //  8
class Display extends Panel implements Observer {
                                             // 10
  // Independent status display thread.      // 11
                                             // 12
  private TextField trackField = new TextField(2);
  private TextField indexField = new TextField(8);
  private TextField timeField = new TextField(22);
                                             // 16
  private SmartDrive cdPlayer;               // 17
  private String prevText = "";              // 18
                                             // 19
  public Display(SmartDrive drive)           // 20
  {                                          // 21
    setLayout(
        new FlowLayout(FlowLayout.LEFT,5,5));// 22
    indexField.setEditable(false);           // 23
    timeField.setEditable(false);            // 24
                                             // 25
    cdPlayer = drive;                        // 26
    add(trackField);                         // 27
    add(indexField);                         // 28
    add(timeField);                          // 29
                                             // 30
    trackField.addFocusListener(
        new TrackFocusLost());               // 31
    trackField.addKeyListener(
        new TrackKeyPress());                // 32
                                             // 33
    cdPlayer.monitor.addObserver(this);      // 34
  }                                          // 35
                                             // 36
  public void update(Observable obj, Object arg) {
    Monitor mon = (Monitor) obj;             // 38
    if (mon.status != Drive.STATUS_INVALID) {
      int time = (                           // 40
          mon.trackEndAddress[mon.currentTrack] -
          mon.currentAddress) /
            Drive.FRAMES_PER_SECOND;         // 41
      String newTrackText =
        Integer.toString(mon.currentTrack);  // 42
      // Prevent excessive updates - so that
      // the user can edit the field.        // 43
      if (prevText.compareTo(newTrackText) != 0) {
        trackField.setText(newTrackText);    // 45
        prevText = newTrackText;             // 46
      }                                      // 47
      indexField.setText("Index: " +         // 48 
                         mon.currentIndex);  
      timeField.setText("Trk Rem: " +        // 49
                        time/60 + " min " +
                        time%60 + " sec");
    }                                        // 50
  }                                          // 51
                                             // 52
  private class TrackFocusLost               // 53
    extends FocusAdapter {                   // 54
       // removes text entered on focus out.
    public void focusLost(FocusEvent e) {    // 55
       trackField.setText(prevText);
    }
  }                                          // 56
                                             // 57
  private class TrackKeyPress extends KeyAdapter {
                                             // 59
    public void keyPressed(KeyEvent e)       // 60
    {                                        // 61
      if (e.getKeyChar() == '\n') {          // 62
        try {                                // 63
          cdPlayer.play(                     // 64
          Integer.parseInt(trackField.getText()));
        }                                    // 65
        catch (NumberFormatException nx) {   // 66
          System.out.println(
            "Invalid track number: " + nx);  // 67
        }                                    // 68
        catch (DriveException dx) {          // 69
          System.out.println("Exception: " + dx);
        }                                    // 71
      }                                      // 72
    }                                        // 73
  }                                          // 74
                                             // 75
}                                            // 76
