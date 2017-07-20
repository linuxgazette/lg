package Jcd; // -- Listing-6 -- Monitor.java//   1
                                            //   2
import java.lang.*;                         //   3
import java.util.*;                         //   4
import Jcd.Drive;                           //   5
                                            //   6
class Monitor 
  extends Observable implements Runnable {  //   7
                                            //   8
  // Updates once a second - calls client   //   9
  // object's update methods so they can 
  // reflect the updates.                   //  10
                                            //  11
  // The following public status info is 
  // available for the client to use.
                                            //  13
  public Drive cdPlayer;                    //  14
  public int status = Drive.STATUS_INVALID; //  15
  public int currentTrack = 0;              //  16
  public int currentIndex = 0;              //  17
  public int currentAddress = 0;            //  18
  public int trackStartAddress = 0;         //  19
  public int trackElapsed = 0;              //  20
                                            //  21
  public boolean cdChanged = false;         //  22
  public boolean trackChanged = false;      //  23
                                            //  24
  public int cdEndAddress = -1;             //  25
  public int numberOfTracks = 0;            //  26
    // Info origin [1], [0] is total for CD.// 27
  public int trackAddress[] = {0};          //  28
  public int trackEndAddress[] = {0};       //  29
  public int trackLength[] = {0};           //  30
                                            //  31
  public String cddbID = "00000000";        //  32
                                            //  33
  protected int lastTrack = 0;              //  34
  protected Thread updateThread = null;     //  35
                                            //  36
  public Monitor(Drive cdPlayer) {          //  37
    this.cdPlayer = cdPlayer;               //  38
  }                                         //  39
                                            //  40
  public void run() {                       //  41
    for (;;) {                              //  42
      int sleep = 1000;                     //  43
      synchronized (cdPlayer) {             //  44
        updateCdInfo();                     //  45
        setChanged();                       //  46
         // Force notify to do its thing.
        notifyObservers();                  //  47
      }                                     //  48
      try {                                 //  49
        Thread.sleep(sleep);                //  50
      }                                     //  51
      catch (InterruptedException e) {      //  52
      }                                     //  53
    }                                       //  54
  }                                         //  55
                                            //  56
  public void start() {                     //  57
                                            //  58
    if (updateThread == null) {             //  59
      System.out.println("Starting thread");//  60
      updateThread = new Thread(this);      //  61
             // Higher priority for console access
      updateThread.setPriority(6);          //  62
      updateThread.start();                 //  63
    }                                       //  64
  }                                         //  65
                                            //  66
  public void stop() {                      //  67
    if (updateThread != null &&             //  68
        updateThread.isAlive()) 
      updateThread.stop();
    updateThread = null;                    //  69
  }                                         //  70
                                            //  71
  protected void updateCdInfo()             //  72
  {                                         //  73
    try {                                   //  74
      cdChanged = false;                    //  75
      trackChanged = false;                 //  76
      status = cdPlayer.status();           //  77
      if (status != Drive.STATUS_INVALID) { //  78
        int cdEnd = cdPlayer.cdEndAddress();//  79
                                            //  80
        if (cdEnd != cdEndAddress) {        //  81
          // Assumes we never get two cd's the  82
          // exact same length in a row! Breaks 83
          // if we do!          
          cdEndAddress = cdEnd;             //  84
          cdChanged = true;                 //  85
          trackChanged = true;              //  86
                                            //  87
          cddbID = cdPlayer.cddbID();       //  88
          numberOfTracks =                  //  89
            cdPlayer.numberOfTracks();   
                                            //  90
          trackAddress= new int[numberOfTracks+1];
          trackEndAddress =                 //  92
            new int[numberOfTracks+1];     
          trackLength = new int[numberOfTracks+1];
                                            //  94
          for (int i=1; i<=numberOfTracks; i++) {
            trackAddress[i] =               //  96
              cdPlayer.trackAddress(i);      
            trackEndAddress[i] =            //  97
              cdPlayer.trackEndAddress(i);  
            trackLength[i] =                //  98
              cdPlayer.trackLength(i);    
          }                                 //  99
          trackAddress[0] =                 // 100
            cdPlayer.trackAddress(Drive.LEAD_OUT);
          trackEndAddress[0] =              // 101
            cdPlayer.trackEndAddress(
              Drive.LEAD_OUT);
          trackLength[0] =                  // 102
            cdPlayer.trackLength(Drive.LEAD_OUT); 
        }                                   // 103
                                            // 104
        currentTrack = cdPlayer.currentTrack();
        if (currentTrack > numberOfTracks) {// 106 
          // Fishy, probably at end of CD.  // 107
          // Prevent subscript out of bounds.
          currentTrack = numberOfTracks;   
        }                                   // 108
        if (currentTrack==0){ // Just in case. 109
          currentTrack = 1;                 // 110
        }                                   // 111
        currentIndex = cdPlayer.currentIndex();
        currentAddress= cdPlayer.currentAddress();
        trackStartAddress =                 // 114  
          cdPlayer.trackAddress(currentTrack);  
        trackElapsed =                      // 115 
          currentAddress - trackStartAddress;
        if (trackElapsed<0) trackElapsed=0; // 116
        if (currentTrack != lastTrack) {    // 117
          trackChanged = true;              // 118
          lastTrack = currentTrack;         // 119
        }                                   // 120
      }                                     // 121
    }                                       // 122
    catch (DriveException e) {              // 123
      System.out.println("Monitor Exception "+e);
    }                                       // 125
  }                                         // 126
}                                           // 127
