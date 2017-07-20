package Jcd;   // -- Listing-2 -- Form.java  //  1
                                             //  2
import java.awt.*;                           //  3
                                             //  4
public class Form extends Frame {            //  5
                                             //  6
 // Subclass the AWT GridBagLayout Frame by adding
 // methods to set up placement constraints.     
                                             //  9
  public GridBagLayout layout;               // 10
                                             // 11
  protected Insets formInsets=new Insets(1,1,1,1);
                                             // 13
  public Form(String title)                  // 14
  {                                          // 15
    super(title);                            // 16
    layout = new GridBagLayout();            // 17
    setLayout(layout);                       // 18
  }                                          // 19
                                             // 20
  public Component addCenter(Component comp) // 21
  {                                          // 22
    int fill = GridBagConstraints.NONE;      // 23
    Insets insets = formInsets;              // 24
    GridBagConstraints c=new GridBagConstraints();
    c.gridx = 0;                             // 26
    c.gridy = GridBagConstraints.RELATIVE;   // 27
    c.anchor = GridBagConstraints.CENTER;    // 28
    c.gridwidth = GridBagConstraints.REMAINDER;
    c.fill = fill;                           // 30
    c.insets = insets;                       // 31
    layout.setConstraints(comp, c);          // 32
    return super.add(comp);                  // 33
  }                                          // 34
}                                            // 35
