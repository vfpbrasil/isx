# ISX 
========================================================================================

 BRASIL - FOXBRASIL Members (Alphabetic Order)

    Emerson Santon Reed - emerson_reed@hotmail.com
    Grego - grego@jdk.com.br
    Mauricio Marques (Moshe) - mauricio@moshe.com.br
    Rafael Lippert - rafaellippert@gmail.com

========================================================================================

 This program implements partial IntelliSense in VFP 6-9. To enable
 IntelliSenseX, simply execute this program at any time when using
 Visual FoxPro or put it into your startup program.

 To configure ISX please see the section just below the comment block.

 To stop IntelliSenseX run this program again and pass "QUIT" as a
 parameter. Alternatively, you can simply remove the ON KEY LABEL
 macros for the ALT+I and the "." key.

 Currently only IntelliSense for variable names is implemented. This
 means that whenever you enter "m." in a MODIFY COMMAND window or
 in a Method edit window, you get a list of all variables declared
 in the current procedure. ISX doesn't parse the entire sourcecode
 for memory variables, but only the current procedure or method and
 only those variables listed in a LOCAL, PRIVATE, PUBLIC, LPARAMETER
 and PARAMETER statement.  ALT+I can be used to trigger this list.

 ALT+RIGHTARROW triggers a universal autocomplete function that tries to determine the
 type of what you have entered and offers a list of all possible values.

 Please note that I haven't written this program as an excercise for
 good coding styles <g>, rather as an excercise to see if
 IntelliSense is possible within Visual FoxPro itself. Therefore
 you won't find the Assertions you would otherwise find in my code.

========================================================================================

 Acknowledgements

 Thanks to George Tasker for his really helpful documentation on the
 FoxTools.Fll. You can download his ToolHelp.Hlp file from the
 UniversalThread and the CompuServe MSDEVAPP forum. George also made
 some suggestions to improve this program.

 Also thanks to Ken Levy, who couldn't implement an inline Intelli-
 Sense feature in his SuperCls and thereby convinced me that there
 must be a way to do it, even only for the purpose of doing
 something that Ken Levy couldn't do. <bg>

 Thanks to all the folks that posted me bug reports, especially
 Frank Cazabon. Thanks to Gerry Hughes for correcting the typos in
 my comments.

 Louis D. Zelus added a nifty feature to my version to make ISX
 even more useful. Thanks for that! The code based on his work is
 marked with "LDZ:".

 Sietse Wijnkler added a lot of new cool features: He added the
 ability to distinguish different types that all are triggered by
 a period and the code to display variables, object properties and
 field names. Code based on his work is marked with "SW:".

 Jürgen "wOOdy" Wondzinski pointed out that special characters like
 "ö" are valid variable names and IsAlpha() returns .T. for them.
 Therefore any of these characters is detected by ISX, as well.

 Tamar E. Granor and Peter Steinke, both requested the list DEFINE
 features which is why I finally added it.

 Thanks to Eddy Maue for his contributions:

   Ce qu'ile fait de plus maintenant
    -  Alt-Q pour arrêter Isx
    -  Alt-Q pour redemarrer Isx
    - Ouvre automatiquements :
            -Les tables présentes dans les répertoires courants et de recherches
             (set path to)
            -Les vues présentes dans le projet actif
            -Les query présents dans les répertoires courants et de recherches
             (set path to)
              Petit point à ne pas négliger. Le curseur produit par le fichier
              MyQuery.qpr doit être du même nom que le fichier

 In English:

    - ALT+Q enables/disables ISX
    - files are opened automatically:
        - tables available in the current directory or the search path (SET PATH TO)
        - Views available in the current project
        - Queries available in the current directory or the search path (SET PATH TO)
          Minor, but important restriction: The cursor created by the query program
          must have the same alias as the filename.

 Mike Yearwood added supported for maximized editing windows which caused a lot
 of flickering everytime the popup came up.

 Thanks to all those who pointed out bugs in ISX's releases:

  - Nina Schwanzer
  - Del Lee
  - Pamela Thalacker
  - Christophe Chenavier
  - Aragorn Rockstroh
  - Claude Hebert
  - Jens Kippnich

========================================================================================

 This program has been written in 1999-2005 by Christof Wollenhaupt
 and is placed into Public Domain. You can use the entire
 code or parts of it as you like in any private or commercial
 application. None of the contributors to this programm can be hold
 liable for any damage or problems, using this program may cause.

 If you added a new feature, please let me know. If you want I add
 your feature to my master copy of ISX to let others use your
 feature, as well. Please note that since the entire program is
 placed into Public Domain, this places your code into Public
 Domain, as well. Of course, your contributions are acknlowdeged in
 the comment at the beginning of this file.

========================================================================================

 Known problems:

 - So far ISX has not been tested with different Display appearance
   settings, like wider scrollbars or form borders, large fonts and
   the like. Some values are hardcoded and might be wrong for non-
   standard Windows settings.

 - When you enter a period into a textbox, the cursor is set to the first character of
   the textbox and then the period entered. If SelectOnEntry is true, everything is
   replaced by the period. This is caused by a bug in VFP that makes all ON KEY LABEL
   behave this way. You can disable this behavior by commenting out the lines starting
   with "ON KEY LABEL .". In this case, you must use ALT+I or ALT+RIGHTARROW do expand
   the variable.

========================================================================================
