package Jcd; // -- Listing-1 -- Player.java  //  1
                                             //  2
import java.io.*;                            //  3
import java.util.*;                          //  4
import java.awt.*;                           //  5
import java.awt.event.*;                     //  6
                                             //  7
import Jcd.*;                                //  8
                                             //  9
public class Player                          // 10
  extends Form 
  implements ActionListener { // Main window.
                                             // 11
  SmartDrive cdPlayer; // Hardware interface // 12
  Program program;     // Program tracks to play.
                                             // 14
  Display  display;    // Numeric display    // 15
  Controls controls;   // Push buttons       // 16  
                                             // 17
                       // File-Menu items    // 18
  private MenuItem fileProgramItem  = 
             new MenuItem("Program");        // 19
  private MenuItem fileExitItem     = 
             new MenuItem("Exit");           // 20
                                             // 21
  //                                         // 22
  // 1. Connect to a cdrom device.           // 23
  // 2. Create the interface:                // 24
  //     the display-panel;                  // 25
  //     the control-panel;                  // 26
  // 3. Establish the panel components as    // 27
  //    clients of the monitor.              // 28
                                             // 29
  public static void main(String[] args)     // 30
  {                                          // 31
    Player player =                          // 32
      new Player();  // Create a GUI CD player 
  }                                          // 33
                                             // 34
  public Player()                            // 35
  {                                          // 36
    super("Jcd");                            // 37
                    // Init CDROM hardware   // 38
    String device = "/dev/cdrom";            // 39
    String module = 
      "native/ix86-Linux/Jcd_Drive.so";      // 40
    int flags     = 0;                       // 41
                                             // 42
    cdPlayer= new SmartDrive(device,module,flags); 
                    // Init GUI              // 44
    setResizable(true);                      // 45
    setMenuBar(new MenuBar());               // 46
    getMenuBar().add(createFileMenu());      // 47
    display  = new Display(cdPlayer);        // 48
    controls = new Controls(cdPlayer);       // 49
    addCenter(display);                      // 50
    addCenter(controls);                     // 51
                  // Handle close requests.
    addWindowListener(new DoClose());        // 52
    pack();       // Resize to fit.          // 53
    show();       // Let the user have it!   // 54
                  // Now everyone is ready...// 55
                  // ...start processing events
    cdPlayer.monitor.start();                // 56
  }                                          // 57
                                             // 58
  public void actionPerformed(ActionEvent event)  
  {                                          // 60
    Object source = event.getSource();       // 61
    if (source == fileProgramItem) {         // 62
      if (program == null || !program.isShowing())
        program = new Program(cdPlayer);     // 64
    }                                        // 65
    else if (source == fileExitItem)         // 66
      System.exit(0);                        // 67
  }                                          // 68
                                             // 69
  private Menu createFileMenu()              // 70
  {                                          // 71
    Menu fileMenu = new Menu("File");        // 72
    fileMenu.add(fileProgramItem);           // 73
    fileMenu.addSeparator();                 // 74
    fileMenu.add(fileExitItem);              // 75
    fileProgramItem.addActionListener(this); // 76
    fileExitItem.addActionListener(this);    // 77
    return fileMenu;                         // 78
  }                                          // 79
                                             // 80
  private class DoClose extends WindowAdapter {
    public void windowClosing(WindowEvent e) {
      System.exit(0);                        // 83
    }                                        // 84
  }                                          // 85
}                                            // 86
