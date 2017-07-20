package Jcd; // -- Listing-5 -- SmartDrive.java   1
                                             //   2
import java.io.*;                            //   3
import java.util.*;                          //   4
import java.awt.*;                           //   5
import Jcd.Drive;                            //   6
import Jcd.Monitor;                          //   7
                                             //   8
class SmartDrive 
  extends Drive implements Observer {        //   9
                                             //  10
  public Monitor monitor;                    //  11
  public TrackList tracksToPlay = null;      //  12
  public int program_pos = 0;                //  13
  public boolean singleMode = false;         //  14
                                             //  15
  public SmartDrive(String device,           //  16
                    String module, int flags)
  {                                          //  17
    super(device, module, flags);            //  18
    setUp();                                 //  19
  }                                          //  20
                                             //  21
  protected void setUp()                     //  22
  {                                          //  23
    monitor = new Monitor(this);             //  24
    monitor.addObserver(this);               //  25
    tracksToPlay = new TrackList(30);        //  26
  }                                          //  27
                                             //  28
  public void setSingleMode(boolean state)   //  29
  {                                          //  30
    singleMode = state;                      //  31
  }                                          //  32
                                             //  33
  public void play(int track)                //  34
    throws DriveException
  {                                          //  35
    if (singleMode) single(track);           //  36
    else super.play(track);                  //  37
  }                                          //  38
                                             //  39
  public boolean startPlaying()              //  40 
    throws DriveException   
  {                                          //  41
    if (status() == Drive.STATUS_PAUSED)     //  42
      resume();                              //  43
    else if (!tracksToPlay.isEmpty()) {      //  44
      if (tracksToPlay.atEnd())              //  45
        tracksToPlay.reset();                //  46
      play(tracksToPlay.nextTrack());        //  47
    }                                        //  48
    else play(1);                            //  49
    return true;                             //  50
  }                                          //  51
                                             //  52
  public boolean next() throws DriveException//  53
  {                                          //  54
    if (tracksToPlay.isEmpty()) {            //  55
      int track = currentTrack();            //  56
      int max = numberOfTracks();            //  57
      if (track >= max) return false;        //  58
      play(track + 1);                       //  59
    }                                        //  60
    else {                                   //  61
      int next = tracksToPlay.nextTrack();   //  62
      if (next <= 0)                         //  63
        return false;                        //  64
      play(next);                            //  65
    }                                        //  66
    return true;                             //  67
  }                                          //  68
                                             //  69
  public boolean prev() throws DriveException//  70
  {                                          //  71
    if (tracksToPlay.isEmpty()) {            //  72
      int track = currentTrack();            //  73
      if (track <= 1) return false;          //  74
      play(track - 1);                       //  75
    }                                        //  76
    else {                                   //  77
      int next = tracksToPlay.prevTrack();   //  78
      if (next <= 0) return false;           //  79
      play(next);                            //  80
    }                                        //  81
    return true;                             //  82
  }                                          //  83
                                             //  84
  public int remaining()                     //  85
  {                                          //  86
    int result = 0;                          //  87
    if (tracksToPlay.isEmpty())              //  88
      result = monitor.cdEndAddress -
                 monitor.currentAddress;     //  89
    else {                                   //  90
      int index = 0;                         //  91
      Enumeration iter = tracksToPlay.elements();
      while (iter.hasMoreElements()) {       //  93
        int track =                          //  94
         ((Integer) iter.nextElement()).intValue();
        if (index >= tracksToPlay.stepNumber() &&
            track < monitor.trackLength.length) {
          result += monitor.trackLength[track];
        }                                    //  98
        index++;                             //  99
      }                                      // 100
      if (!tracksToPlay.atStart() && 
          !tracksToPlay.atEnd()) {           // 101
        result -= (monitor.currentAddress -  // 102
                   monitor.trackStartAddress);
      }                                      // 103
    }                                        // 104
    return result;                           // 105
  }                                          // 106
                                             // 107
  public int togglePause()                   // 108
    throws DriveException
  {                                          // 109
    if (status() == Drive.STATUS_PAUSED) {   // 110
      resume();                              // 111
      return Drive.STATUS_PLAY;              // 112
    }                                        // 113
    pause();                                 // 114
    return Drive.STATUS_PAUSED;              // 115
  }                                          // 116
                                             // 117
  public synchronized void update(Observable o, 
                                  Object arg)// 118
  {                                          // 119
    try {                                    // 120
      if (monitor.status != Drive.STATUS_INVALID) {
        if (monitor.cdChanged)               // 122
          tracksToPlay.clear();              // 123
        else if (monitor.status == 
                 Drive.STATUS_PLAY) {        // 124
          int track= monitor.currentTrack;   // 125
          int tend= monitor.trackEndAddress[track];
          if (monitor.currentAddress >= 
              tend - 210) { // Near end of track?
            // Poll frequently so we don't miss the
            // event.                        // 128
            while (currentAddress() < tend &&// 129
              monitor.status == Drive.STATUS_PLAY
              && currentAddress() != 0) {    // 131
              try { Thread.sleep(100); // 100 msec
              }                              // 133
              catch (InterruptedException e) {
              }                              // 135
            }                                // 136
            if (!tracksToPlay.atStart())     // 137
              programEndOfTrack();           // 138
            else            // Normal play   // 139
              normalEndOfTrack(track);       // 140
          }                                  // 141
        }                                    // 142
      }                                      // 143
    }                                        // 144
    catch (DriveException e) {               // 145
      System.out.println("Exception: " + e); // 146
    }                                        // 147
  }                                          // 148
                                             // 149
  protected void programEndOfTrack()         // 150
  {                                          // 151
    try {                                    // 152
      int next = tracksToPlay.nextTrack();   // 153
      if (tracksToPlay.atEnd()) {            // 154
        stop(); tracksToPlay.reset();       
      }
      else if (singleMode) stop();           // 155
      else play(next);                       // 156
    }                                        // 157
    catch (DriveException e) {               // 158
      System.out.println(                    // 159 
       "Program end of track exception: " + e);
    }                                        // 160
  }                                          // 161
                                             // 162
  protected void normalEndOfTrack(int track) // 163
  {  // If during the track we switched play // 164
     // modes, ensure the correct behaviour occurs.
    try {                                    // 165
      if (singleMode) stop();                // 166
      else if (track < monitor.numberOfTracks)
        play(track + 1);                     // 167
    }                                        // 168
    catch (DriveException e) {               // 169
      System.out.println(
       "Normal-Play end of track exception: " + e);
    }                                        // 171
  }                                          // 172
}                                            // 173
                                             // 174
class TrackList extends Vector {             // 175

   // Gone past last track.                  // 176
  protected boolean at_end = false;
  protected Integer current = null;          // 177
                                             // 178
  TrackList(int initial_n) {                 // 179
    super(initial_n);
  } 
  public synchronized void addTrack(int t) { // 181
    addElement(new Integer(t)); 
  }
                                             // 182
  public synchronized void removeTrack(int t)// 183
  {                                          // 184
    for (int pos = size() - 1; pos >= 0; pos--) {
      Integer elem = (Integer) (elementAt(pos));
      if (elem.intValue() == t) { // Found   // 187
        removeElement(elem);                 // 188
        if (elem==current) // Select a new current
          current = (Integer) ((pos>=size()) ? 
            lastElement() : elementAt(pos)); // 190
      }                                      // 191
    }                                        // 192
  }                                          // 193
                                             // 194
  public synchronized int stepNumber()       // 195
  {         // Program step number           // 196
    return (current != null) ? 
           indexOf((Object) current) : 0 ;   // 197
  }                                          // 198
                                             // 199
  public synchronized int currentTrack()     // 200
  {                                          // 201
    return 
     (current != null) ? current.intValue() : 0 ;
  }                                          // 203
                                             // 204
  public synchronized int nextTrack()        // 205
  {    // Advance along the list by one.     // 206
    if (size() == 0) return 0;               // 207
    if (current == null)                     // 208
      current = (Integer) firstElement();    // 209
    else {                                   // 210
      int pos= indexOf((Object) current) + 1;// 211
      at_end= pos == size(); //Finished last track?
      current = (Integer) (at_end ? 
        lastElement() : elementAt(pos));     // 213
    }                                        // 214
    return current.intValue();               // 215
  }                                          // 216
                                             // 217
  public synchronized int prevTrack()        // 218
  {                                          // 219
    if (current != null) {                   // 220
      int pos= indexOf((Object) current) - 1;// 221
      current = (Integer) ((pos<0) ?
        firstElement() : elementAt(pos));    // 222
      return current.intValue();             // 223
    }                                        // 224
    return 0;                                // 225
  }                                          // 226
                                             // 227
  public boolean atStart()                   // 228
    { return current == null ; }
  public boolean atEnd() { return at_end; }  // 229
                                             // 230
  public void skipTo(int track)              // 231
  {                                          // 232
    if (size() > 0) {                        // 233
      while (!atEnd())                       // 234
        if (nextTrack() == track && !atEnd())
          return;
      reset();   // Wrap around to the start // 235
      while (!atEnd())                       // 236
        if (nextTrack() == track) 
          return;
      current = (Integer) lastElement();     // 237
    }                                        // 238
  }                                          // 239
                                             // 240
  public synchronized void clear()           // 241
    { reset(); removeAllElements(); }  
  public synchronized void reset()           // 242
    { current = null; at_end = false; }
}                                            // 243
