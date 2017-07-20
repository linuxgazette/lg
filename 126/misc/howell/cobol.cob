      * Sample COBOL program
       IDENTIFICATION DIVISION.
       PROGRAM-ID. Decimal.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  I PIC S9(8) COMP.
       01  J PIC S9(8)V9(2) COMP-3.
       01  WS-OUT-REC.
         10 OUT-I PIC ZZZZZZZ.99.
         10 filler pic x(5) value spaces.
         10 OUT-J PIC ------9.99.
       PROCEDURE DIVISION.
       DISPLAY "Hello World!".

           Move 12.34 to J.
           Display "first Test------- J = ", J.
           Perform Test-Paragraph through Test-Paragraph-Exit
                   varying I from 3 by -1 until I < 1.

           MOVE -2 TO I.
           MOVE 99 TO J.
           Display "second Test------- J = ", J.
           MOVE I to OUT-I.
           MOVE J to OUT-J.
           DISPLAY "I = ", I, " J = ", J.
           display WS-OUT-REC.
           DISPLAY "Still there?".

           COMPUTE J = J / I.
           MOVE I to OUT-I.
           MOVE J to OUT-J.
           DISPLAY "I = ", I, " J = ", J.
           display WS-OUT-REC.
           DISPLAY "Still there?".

           MOVE 0 TO I.
           COMPUTE J = J / I.
           DISPLAY "I = ", I, " J = ", J.
           display WS-OUT-REC.
           DISPLAY "WOW!".
       STOP RUN.

       Test-Paragraph.

           COMPUTE J = J / I.
           MOVE I to OUT-I.
           MOVE J to OUT-J.
           DISPLAY "I = ", I, " J = ", J.
           display WS-OUT-REC.
       Test-Paragraph-Exit.
           EXIT.

