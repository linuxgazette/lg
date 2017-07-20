package Jcd; // -- Listing-7 -- Program.java//   1
                                            //   2
import java.io.*;                           //   3
import java.util.*;                         //   4
import java.awt.*;                          //   5
import java.awt.event.*;                    //   6
                                            //   7
import Jcd.Drive;                           //   8
import Jcd.Monitor;                         //   9
                                            //  10
class Program                               //  11
  extends Form implements Observer {       
                                            //  12
  private abstract class DoAction           //  13
    implements ActionListener {         
    public void actionPerformed(            //  14
      ActionEvent event) {   
      this.invoke();                        //  15
    }                                       //  16
    abstract void invoke();                 //  17
  }                                         //  18
                                            //  19
  private static final int INITIAL_BUTTONS = 20;
  private static final int LISTING_SIZE =26;//  21
  private static final int GRID_SIZE =8;    //  22
                                            //  23
  private static final int ADD_MODE = 0;    //  24
  private static final int DEL_MODE = 1;    //  25
  private static final int PLAY_MODE  = 2;  //  26
  private static final String EDIT_LABELS[] = 
    { "Add ", "Del ", "Play" };             //  27 
                                            //  28
  private SmartDrive cdPlayer;              //  29
                                            //  30
  private TextField programListing =        //  31 
    new TextField(Program.LISTING_SIZE);
                                            //  32
  private Panel trackPanel  = new Panel();  //  33
  private Panel buttonPanel = new Panel();  //  34
                                            //  35
  private Button editButton;                //  36
                                            //  37
  private int mode = ADD_MODE;              //  38
                                            //  39
  public Program(SmartDrive drive)          //  40
  {                                         //  41
    super("Jcd Program");                   //  42
                                            //  43
    int n;                                  //  44
                                            //  45
    cdPlayer = drive;                       //  46
                                            //  47
    programListing.setEditable(false);      //  48
                                            //  49
    addCenter(programListing);              //  50
    addCenter(trackPanel);                  //  51
                                            //  52
    editButton = new Button("Add ");        //  53
    addButton(buttonPanel,                  //  54
              editButton,                   //  55
              new DoAction() {              //  56
                void invoke() {
                 setEditMode(); 
                } 
              });
    addButton(buttonPanel,                  //  57
              new Button("Shuffle"),        //  58
              new DoAction() { void invoke() 
                    {shuffleProgram();} });
    addButton(buttonPanel,                  //  60
              new Button("Reset"),          //  61
              new DoAction() {              //  62
              void invoke() {resetProgram();}});
    addButton(buttonPanel,                  //  63
              new Button("Clear"),          //  64
              new DoAction() { void invoke() 
                    { clearProgram(); } }); //  65
    addButton(buttonPanel,                  //  66
              new Button("Dismiss"),        //  67
              new DoAction() { void invoke()
                    { dismiss(); } });      //  68
                                            //  69
    addCenter(buttonPanel);                 //  70
                                            //  71
    addWindowListener(                      //  72
      // Use anonymous class - save defining 
      // another class
      new WindowAdapter() {                 //  73
        public void windowClosing(WindowEvent e) {
          dismiss();                        //  75
        }                                   //  76
      }                                     //  77
    );                                      //  78
                                            //  79
    n = cdPlayer.monitor.numberOfTracks;    //  80
    updateTrackPanel(n > 0 ? 
      n : Program.INITIAL_BUTTONS);         //  81
                                            //  82
    cdPlayer.monitor.addObserver(this);     //  83
                                            //  84
    pack();                                 //  85
    show();                                 //  86
  }                                         //  87
                                            //  88
  public void update(Observable o, Object arg)
  {                                         //  90
    if (cdPlayer.monitor.cdChanged) {       //  91
      updateTrackPanel(
       cdPlayer.monitor.numberOfTracks);    //  92
    }                                       //  93
  }                                         //  94
                                            //  95
  void addButton(Panel panel, Button button,//  96
                 DoAction action)        
  {                                         //  97
    panel.add(button);                      //  98
    button.addActionListener(action);       //  99
  }                                         // 100
                                            // 101
  void clearProgram() {                     // 102
    cdPlayer.tracksToPlay.clear();          // 103
    displayProgram();                       // 104
  }                                         // 105
                                            // 106
  void dismiss()                            // 107
  {                                         // 108
    setVisible(false);                      // 109
    dispose();                              // 110
  }                                         // 111
                                            // 112
  void displayProgram()                     // 113
  {                                         // 114
    String str =                            // 115
      cdPlayer.monitor.cdChanged ?
        "[]" : cdPlayer.tracksToPlay.toString();
    programListing.setText(str.substring(1, 
                           str.length() - 1));  
  }                                         // 118
                                            // 119
  void pickTrack(int tracknum) {            // 120
    switch (mode) {                         // 121
    case ADD_MODE:                          // 122
      cdPlayer.tracksToPlay.addTrack(tracknum);
      break;                                // 124
    case DEL_MODE:                          // 125
      cdPlayer.tracksToPlay.removeTrack(tracknum);
      break;                                // 127
    case PLAY_MODE:                         // 128
      cdPlayer.tracksToPlay.skipTo(tracknum);
      try {                                 // 130
        cdPlayer.play(tracknum);            // 131
      }                                     // 132
      catch (DriveException except) {       // 133
        System.out.println("Exception " + except);
      }                                     // 135
      break;                                // 136
    }                                       // 137
    displayProgram();                       // 138
  }                                         // 139
                                            // 140
  void resetProgram() {                     // 141
    cdPlayer.tracksToPlay.reset();          // 142
    displayProgram();                       // 143
  }                                         // 144
                                            // 145
  void setEditMode() {                      // 146
    mode++;                                 // 147
    if (mode > PLAY_MODE) mode = ADD_MODE;  // 148
    editButton.setLabel(EDIT_LABELS[mode]); // 149
  }                                         // 150
                                            // 151
  void shuffleProgram()                     // 152
  {                                         // 153
    int n = cdPlayer.monitor.numberOfTracks;// 154
    Vector choices = new Vector(n);         // 155
    Random random = new Random();           // 156
                                            // 157
    cdPlayer.tracksToPlay.clear();          // 158
    // Make a list of all choices.
    for (int i=1; i <= n; i++)              // 159
      choices.addElement(new Integer(i));   // 160
                                            // 161
    // Remove at random until none are left.
    for (int i=1; i <= n; i++) {            // 162
      int which = (int) (random.nextFloat() *
                         choices.size());   // 163
      int track = ((Integer)
        choices.elementAt(which)).intValue(); 
      cdPlayer.tracksToPlay.addTrack(track);// 165
      choices.removeElementAt(which);       // 166
    }                                       // 167
    displayProgram();                       // 168
  }                                         // 169
                                            // 170
  private void updateTrackPanel(int n)      // 171
  {                                         // 172
    int prev_n = trackPanel.getComponentCount();  
    if (n != prev_n) {                      // 174
      Component button[] = 
        trackPanel.getComponents();         // 175
      trackPanel.setLayout(                 // 177
        new GridLayout(n / Program.GRID_SIZE + 1, 
                       Program.GRID_SIZE)); 
      for (int i = n; i < prev_n; i++)      // 178
        trackPanel.remove(button[i]);       // 179
      for (int i = prev_n; i < n; i++) {    // 180
        class TrackAction extends DoAction {// 181
          int track;                        // 182
          public TrackAction(int i) {track=i;} 
          void invoke() {pickTrack(track);} // 184
        }                                   // 185
        addButton(                          // 186
          trackPanel,
          new Button(Integer.toString(i+1)),
          new TrackAction(i + 1));
      }                                     // 189
    }                                       // 190
    displayProgram();                       // 191
    pack();                                 // 192
  }                                         // 193
}                                           // 194
