*========================================================================================
*
* BRASIL - FOXBRASIL Members (Alphabetic Order)
*
*    Emerson Santon Reed - emerson_reed@hotmail.com
*    Grego - grego@jdk.com.br
*    Mauricio Marques (Moshe) - mauricio@moshe.com.br
*    Rafael Lippert - rafaellippert@gmail.com
*
*========================================================================================
*
* This program implements partial IntelliSense in VFP 6-9. To enable
* IntelliSenseX, simply execute this program at any time when using
* Visual FoxPro or put it into your startup program.
*
* To configure ISX please see the section just below the comment block.
*
* To stop IntelliSenseX run this program again and pass "QUIT" as a
* parameter. Alternatively, you can simply remove the ON KEY LABEL
* macros for the ALT+I and the "." key.
*
* Currently only IntelliSense for variable names is implemented. This
* means that whenever you enter "m." in a MODIFY COMMAND window or
* in a Method edit window, you get a list of all variables declared
* in the current procedure. ISX doesn't parse the entire sourcecode
* for memory variables, but only the current procedure or method and
* only those variables listed in a LOCAL, PRIVATE, PUBLIC, LPARAMETER
* and PARAMETER statement.  ALT+I can be used to trigger this list.
*
* ALT+RIGHTARROW triggers a universal autocomplete function that tries to determine the
* type of what you have entered and offers a list of all possible values.
*
* Please note that I haven't written this program as an excercise for
* good coding styles <g>, rather as an excercise to see if
* IntelliSense is possible within Visual FoxPro itself. Therefore
* you won't find the Assertions you would otherwise find in my code.
*
*========================================================================================
*
* Acknowledgements
*
* Thanks to George Tasker for his really helpful documentation on the
* FoxTools.Fll. You can download his ToolHelp.Hlp file from the
* UniversalThread and the CompuServe MSDEVAPP forum. George also made
* some suggestions to improve this program.
*
* Also thanks to Ken Levy, who couldn't implement an inline Intelli-
* Sense feature in his SuperCls and thereby convinced me that there
* must be a way to do it, even only for the purpose of doing
* something that Ken Levy couldn't do. <bg>
*
* Thanks to all the folks that posted me bug reports, especially
* Frank Cazabon. Thanks to Gerry Hughes for correcting the typos in
* my comments.
*
* Louis D. Zelus added a nifty feature to my version to make ISX
* even more useful. Thanks for that! The code based on his work is
* marked with "LDZ:".
*
* Sietse Wijnkler added a lot of new cool features: He added the
* ability to distinguish different types that all are triggered by
* a period and the code to display variables, object properties and
* field names. Code based on his work is marked with "SW:".
*
* Jürgen "wOOdy" Wondzinski pointed out that special characters like
* "ö" are valid variable names and IsAlpha() returns .T. for them.
* Therefore any of these characters is detected by ISX, as well.
*
* Tamar E. Granor and Peter Steinke, both requested the list DEFINE
* features which is why I finally added it.
*
* Thanks to Eddy Maue for his contributions:
*
*   Ce qu'ile fait de plus maintenant
*    -  Alt-Q pour arrêter Isx
*    -  Alt-Q pour redemarrer Isx
*    - Ouvre automatiquements :
*            -Les tables présentes dans les répertoires courants et de recherches
*             (set path to)
*            -Les vues présentes dans le projet actif
*            -Les query présents dans les répertoires courants et de recherches
*             (set path to)
*              Petit point à ne pas négliger. Le curseur produit par le fichier
*              MyQuery.qpr doit être du même nom que le fichier
*
* In English:
*
*    - ALT+Q enables/disables ISX
*    - files are opened automatically:
*        - tables available in the current directory or the search path (SET PATH TO)
*        - Views available in the current project
*        - Queries available in the current directory or the search path (SET PATH TO)
*          Minor, but important restriction: The cursor created by the query program
*          must have the same alias as the filename.

* Mike Yearwood added supported for maximized editing windows which caused a lot
* of flickering everytime the popup came up.
*
* Thanks to all those who pointed out bugs in ISX's releases:
*
*  - Nina Schwanzer
*  - Del Lee
*  - Pamela Thalacker
*  - Christophe Chenavier
*  - Aragorn Rockstroh
*  - Claude Hebert
*  - Jens Kippnich
*
*========================================================================================
*
* This program has been written in 1999-2005 by Christof Wollenhaupt
* and is placed into Public Domain. You can use the entire
* code or parts of it as you like in any private or commercial
* application. None of the contributors to this programm can be hold
* liable for any damage or problems, using this program may cause.
*
* If you added a new feature, please let me know. If you want I add
* your feature to my master copy of ISX to let others use your
* feature, as well. Please note that since the entire program is
* placed into Public Domain, this places your code into Public
* Domain, as well. Of course, your contributions are acknlowdeged in
* the comment at the beginning of this file.
*
*========================================================================================
*
* Known problems:
*
* - So far ISX has not been tested with different Display appearance
*   settings, like wider scrollbars or form borders, large fonts and
*   the like. Some values are hardcoded and might be wrong for non-
*   standard Windows settings.
*
* - When you enter a period into a textbox, the cursor is set to the first character of
*   the textbox and then the period entered. If SelectOnEntry is true, everything is
*   replaced by the period. This is caused by a bug in VFP that makes all ON KEY LABEL
*   behave this way. You can disable this behavior by commenting out the lines starting
*   with "ON KEY LABEL .". In this case, you must use ALT+I or ALT+RIGHTARROW do expand
*   the variable.
*
*========================================================================================


*========================================================================================
* Configuration.
*
* Over the time I got many enhanced versions of ISX, many of which include new hotkeys.
* To give everyone control over the hotkey assignment and to disable/enable particular
* features, I added the following configuration section. By commenting out a #DEFINE, you
* disable a particular feature. Changing the value changes the hotkey.
*
*========================================================================================

#define expand_variable    alt+i
#define list_all           alt+rightarrow
#define toggle_isx         alt+q
#define dot_activation     .
#define aspas_activation   ['] && Single_Quotes
#define aspasd_activation  ["] && Double_Quotes
#define dp1                [|] && VerticalBar
#define dp2                [[] && Brackets
#define dp3                [(] && Parenthesis
#define dp3b               [)] && Parenthesis
#define back_slash         [\] && Back_Slash
#define enter_key          enter && Back_Slash
#define ctrlenter_key      ctrl+enter && Back_Slash


*========================================================================================
* Main program
*========================================================================================
lparameters tcaction, tcparam, tcparam2

if val(version(4)) < 9
   messagebox('Sorry ISX-BR only runs with VFP 9')
   return






































endif


do case
   case vartype(m.tcaction) == "L"
      installisx()

   case upper(alltrim(m.tcaction)) == "AUTOCOMPLETE"
      push key clear
      autocomplete( m.tcparam, m.tcparam2 )
      pop key

   case upper(alltrim(m.tcaction)) == "QUIT"
      uninstallisx()

endcase

return


*========================================================================================
* Activates the hotkeys.
*========================================================================================
procedure installisx

local lcisxprogram
lcisxprogram = ["] + sys(16,program(-1)-1) + ["]

createisxobject(justpath(lcisxprogram))

#ifdef expand_variable
   on key label expand_variable do &lcisxprogram with "AUTOCOMPLETE", "VAR", ""
#endif
#ifdef dot_activation
   on key label dot_activation do &lcisxprogram with "AUTOCOMPLETE", "VAR,OBJ,TABLE", "."
#endif


* by Rafael - FoxBrasil - Feb/2009
* by Grego - FoxBrasil - Feb/2009
*------------------------------------
if _screen.isx.onkey_single_quotes
   #ifdef aspas_activation
      on key label aspas_activation do &lcisxprogram with "AUTOCOMPLETE", "ASPAS", aspas_activation
   #endif
endif

if _screen.isx.onkey_double_quotes
   #ifdef aspasd_activation
      on key label aspasd_activation do &lcisxprogram with "AUTOCOMPLETE", "ASPASD", aspasd_activation
   #endif
endif

if _screen.isx.onkey_alt_enter
   #ifdef enter_key
      on key label enter_key do &lcisxprogram with "AUTOCOMPLETE", "ENTER", "" && ENTER_KEY
   #endif
endif
if _screen.isx.onkey_alt_enter
   #ifdef ctrlenter_key
      on key label ctrlenter_key do &lcisxprogram with "AUTOCOMPLETE", "CTRL+ENTER", "" && ENTER_KEY
   #endif
endif


if _screen.isx.onkey_verticalbar
   #ifdef dp1
      on key label dp1 do &lcisxprogram with "AUTOCOMPLETE", "DP1", dp1
   #endif
endif

if _screen.isx.onkey_brackets
   #ifdef dp2
      on key label dp2 do &lcisxprogram with "AUTOCOMPLETE", "DP2", dp2
   #endif
endif

if _screen.isx.onkey_parenthesis
   #ifdef dp3
      on key label dp3 do &lcisxprogram with "AUTOCOMPLETE", "DP3", dp3
   #endif
   #ifdef dp3b
      on key label dp3b do &lcisxprogram with "AUTOCOMPLETE", "DP3b", dp3b
   #endif
endif

if _screen.isx.onkey_back_slash
   #ifdef back_slash
      on key label back_slash do &lcisxprogram with "AUTOCOMPLETE", "TABLE", back_slash
   #endif
endif



*--------------------------------------

#ifdef list_all
   on key label list_all do &lcisxprogram with "AUTOCOMPLETE", "", ""
#endif

#ifdef toggle_isx
   on key label toggle_isx do &lcisxprogram with "QUIT"
   wait window nowait [ISX up and running... TOGGLE_ISX to quit]
#else
   wait window nowait "ISX up and running..."
#endif
endproc


*====================================================================
* Deactivates the hotkeys.
*====================================================================
procedure uninstallisx

local lcisxprogram
lcisxprogram = ["] + sys(16,program(-1)-1) + ["]

#ifdef expand_variable
   on key label expand_variable
#endif
#ifdef dot_activation
   on key label dot_activation
#endif
#ifdef list_all
   on key label list_all
#endif

* by Rafael - FoxBrasil - Feb/2009
* by Grego - FoxBrasil - Feb/2009
*---------------------------
#ifdef aspas_activation
   on key label aspas_activation
#endif
#ifdef aspasd_activation
   on key label aspasd_activation
#endif
#ifdef dp1
   on key label dp1
#endif
#ifdef dp2
   on key label dp2
#endif
#ifdef dp3
   on key label dp3
#endif
#ifdef back_slash
   on key label back_slash
#endif
#ifdef enter_key
   on key label enter_key
#endif
#ifdef ctrlenter_key
   on key label ctrlenter_key
#endif

*---------------------------




#ifdef toggle_isx
   on key label toggle_isx do &lcisxprogram
   wait window nowait [ISX terminated... TOGGLE_ISX to restart]
#else
   wait window nowait "ISX terminated..."
#endif

destroyisxobject()

endproc


*========================================================================================
* Provides a generic autocomplete function. AutoComplete checks all content providers
* if they have something to add to the global list and displays the list as a popup
*========================================================================================
procedure autocomplete
lparameters tcproviders, tcinvocation

if vartype(_screen.isx) <> 'O'
   * Where is the Object ? Create Again - By Moshe - FoxBrasil - 05/03/2009
   local lcisxprogram
   lcisxprogram = ["] + sys(16,program(-1)-1) + ["]
   createisxobject(justpath(lcisxprogram))
endif


*--------------------------------------------------------------------------------------
* The list of providers can be limited. This speeds up program execution if one knows
* from the context that only few content providers actually fit.
*--------------------------------------------------------------------------------------
local lcproviders
if empty(m.tcproviders)
   lcproviders = "VAR,DEFINE,TABLE,OBJ"
else
   lcproviders = upper(m.tcproviders)
endif


*-----------------------------------------------------------------
* Make sure, FoxTools.Fll is loaded.
*-----------------------------------------------------------------
if at("FOXTOOLS.FLL",upper(set("Library"))) = 0 .and. at("FOXTOOLS9.FLL",upper(set("Library"))) = 0
   * by Moshe - FoxBrasil - 04/03/2009
   set library to (home()+"FoxTools.Fll") additive
endif




*-----------------------------------------------------------------
* Get the current window and verify that it is a valid window.
*-----------------------------------------------------------------
local lnwhandle
lnwhandle = getcurrentwindow()


_screen.isx.work_remove = 0

* Moshe - FoxBrasil - 26/Feb/2009
if lnwhandle <> 0
   local lc_left_word
   local lc_left_line
   local lc_last_char
   lc_left_line = getlineleftfromcursor(m.lnwhandle)
   lc_left_word = getwordnum(lc_left_line,getwordcount(lc_left_line))
   lc_left_word = lower(lc_left_word)
   lc_last_char = right(lc_left_line,1)
   
   _screen.isx.Work_left_line = lc_left_line && By Moshe FoxBrasil - 18/04/2010
   _screen.isx.Work_left_word = lc_left_word && By Moshe FoxBrasil - 18/04/2010
   
   _screen.isx.work_insert = '' && By Moshe FoxBrasil - 18/04/2010
   _screen.isx.work_remove = 0  && Reseting Values

   local lc_left_folder
   lc_left_folder = ''

   if tcinvocation = '\'
      local ln_double_point_start
      ln_double_point_start = at(':',lc_left_line)
      if ln_double_point_start = 0
         lc_left_folder = alltrim(lc_left_line)
      else
         lc_left_folder = subst(lc_left_line,ln_double_point_start-1)
      endif

      if empty(lc_last_char) .or. lc_last_char $ '"[' .or. lc_last_char = ['] && by Moshe - FoxBrasil - 17/Abr/2010
         _screen.isx.work_remove = 1
         lc_left_folder          = set('defa') + curdir()
         _screen.isx.work_insert = lc_left_folder
      else
         *
         if left(lc_left_word,1) = '\'
            * Try to search this folder at actual drive && by Moshe - FoxBrasil - 28/Out/2009
            local lc_try_path
            lc_try_path = set('defa')+lc_left_word
            if directory(lc_try_path)
               _screen.isx.work_remove = len(lc_left_word)+1
               lc_left_folder = lc_try_path +'\'
               lc_left_line   = lc_try_path +'\'
               _screen.isx.work_insert = lc_left_folder
            endif
         endif
      endif


      if at(['],lc_left_folder) > 0
         lc_left_folder = substr(lc_left_folder,at(['],lc_left_folder)+1)
      endif
      if at(["],lc_left_folder) > 0
         lc_left_folder = substr(lc_left_folder,at(["],lc_left_folder)+1)
      endif
      if at('[',lc_left_folder) > 0
         lc_left_folder = substr(lc_left_folder,at('[',lc_left_folder)+1)
      endif
      lc_left_folder = alltrim(lc_left_folder)
      *
      do case
         case '\\' $ lc_left_folder
            lc_left_folder = ''
         case at(':',lc_left_folder) = 0
            lc_left_folder = ''
         case !directory(lc_left_folder)
            lc_left_folder = ''
      endcase
   endif
   _screen.isx.work_path = lc_left_folder

   if !empty(lc_left_folder)
      do case
         case 'USE' $ upper(lc_left_line) .or. 'COPY' $ upper(lc_left_line)
            _screen.isx.work_mask = 'dbf'
         case 'MODI' $ upper(lc_left_line) .and. 'FORM' $ upper(lc_left_line)
            _screen.isx.work_mask = 'scx'
         case 'MODI' $ upper(lc_left_line) .and. 'CLAS' $ upper(lc_left_line)
            _screen.isx.work_mask = 'vcx'
         case 'MODI' $ upper(lc_left_line) .and. 'REPO' $ upper(lc_left_line)
            _screen.isx.work_mask = 'frx'
         case 'MODI' $ upper(lc_left_line) .and. 'LABE' $ upper(lc_left_line)
            _screen.isx.work_mask = 'lbx'
         case 'MODI' $ upper(lc_left_line) .and. 'PROJ' $ upper(lc_left_line)
            _screen.isx.work_mask = 'pjx'
         otherwise
            _screen.isx.work_mask = '*'
      endcase
   endif

   local ll_abort
   *
   do case
      case !empty(lc_left_folder)
         ll_abort = .f.
      case lc_left_word == 'm' .or. lc_left_word == 't' .or. lc_left_word == 'f'
         ll_abort = .f.
      case file(lc_left_word+'.dbf') .or. used(lc_left_word)
         ll_abort = .f.
      otherwise
         ll_abort = .t.
   endcase
   *
   if ll_abort and tcinvocation='.'
      on key label .
      keyboard "." plain
      return
   endif
endif



if lnwhandle == 0
   if not empty(m.tcinvocation)
      clear typeahead
      *Keyboard "{Mouse}{Mouse}"+m.tcInvocation PLAIN
      local lc_active_class
      local ln_selstart
      try
         lc_active_class = _screen.activeform.activecontrol.baseclass
         ln_selstart     = _screen.activeform.activecontrol.selstart
      catch
         lc_active_class = ''
      endtry
      *
      if lower(lc_active_class) $ '--textbox--editbox--'
         && by Moshe - FoxBrasil - 19/Feb/2009
         keyboard '{RightArrow}{home}'+replicate('{RightArrow}',ln_selstart) +  m.tcinvocation plain
      else
         keyboard m.tcinvocation plain && Show!!!!
      endif

   else && by Rafael Lippert - FoxBrasil - 13/Mar/2009
      if inlist(lcproviders,'ENTER','CTRL+ENTER')
         keyboard "{"+lcproviders+"}" plain
      endif
   endif
   return
endif




*-----------------------------------------------------------------
* Verify that the current window is indeed an edit window.
*-----------------------------------------------------------------
local lneditsource
lneditsource = geteditsource(m.lnwhandle)

local ln_command_window_number
if lc_left_word == 'm' or (m.lcproviders='ENTER' or m.lcproviders='CTRL+ENTER')
   ln_command_window_number = -1 && Do Not Include m. at Command Window
else
   ln_command_window_number = 0  && Include m. at Command Window
endif



if not inlist( m.lneditsource, ln_command_window_number, 1, 8, 10, 12 ) && by Moshe - FoxBrasil - 26/Feb/2009
   if inlist(lcproviders,"ENTER","CTRL+ENTER")
      keyboard "{"+m.lcproviders+"}" plain
   else
      if  not empty(m.tcinvocation)
         clear typeahead
         *Keyboard "{Mouse}{Mouse}"+m.tcInvocation Plain
         keyboard m.tcinvocation plain
      endif
   endif
   return .f.
endif

*--------------------------------------------------------------------------------------
* Fill an object with details about the current context. We determine what the user
* has entered so far and what's left from that Position.
*--------------------------------------------------------------------------------------
release latabs

local loisx
loisx = createobject("Relation")
loisx.addproperty("nWHandle",m.lnwhandle)
loisx.addproperty("nEditSource",m.lneditsource)
loisx.addproperty("aList[1]")
loisx.addproperty("nCount",0)
loisx.addproperty("cTextLeft",getlineleftfromcursor(m.lnwhandle))
loisx.addproperty("cName","")
loisx.addproperty("cEntity","")
loisx.addproperty("cInvocation",m.tcinvocation)


*--------------------------------------------------------------------------------------
* Determine the part of the name that has been entered so far. This code has been
* kindly provided by Louis D. Zelus.
*--------------------------------------------------------------------------------------
local lcline, lcchar
if empty(m.tcinvocation)
   do while len(m.loisx.ctextleft) > 0
      lcchar = right( m.loisx.ctextleft, 1 )
      if isalpha(m.lcchar) or isdigit(m.lcchar) or m.lcchar == "_"
         loisx.ctextleft = left( m.loisx.ctextleft, len(m.loisx.ctextleft)-1 )
         loisx.cname = m.lcchar + m.loisx.cname
      else
         exit
      endif
   enddo
endif

*--------------------------------------------------------------------------------------
* Determines the name of the entity. This code is courtesy of Sietse Wijnkler.
*--------------------------------------------------------------------------------------
do while len(m.loisx.ctextleft) > 0
   lcchar = right( m.loisx.ctextleft, 1 )
   *   IF ISALPHA(m.lcChar) OR ISDIGIT(m.lcChar) OR m.lcChar == "_" OR m.lcChar == "." OR m.lcChar == ASPAS_ACTIVATION  OR  m.lcChar == ASPASD_ACTIVATION

   if isalpha(m.lcchar) or isdigit(m.lcchar) or m.lcchar == "_" or m.lcchar == "." or m.lcchar == aspas_activation  or  m.lcchar == aspasd_activation  or  m.lcchar==dp1 or  m.lcchar==dp2  or  m.lcchar==dp3
      loisx.ctextleft = left( m.loisx.ctextleft, len(m.loisx.ctextleft)-1 )
      loisx.centity = m.lcchar + m.loisx.centity
   else
      exit
   endif
enddo
if right(loisx.centity,1) == "."
   loisx.centity = left( m.loisx.centity, len(m.loisx.centity)-1 )
endif

*--------------------------------------------------------------------------------------
* This array lists all the providers
*--------------------------------------------------------------------------------------
local laprovider[4,2]
laprovider = ""
laprovider[1,1] = "VAR"
laprovider[1,2] = "CP_Variables"
laprovider[2,1] = "DEFINE"
laprovider[2,2] = "CP_Defines"
laprovider[3,1] = "TABLE"
laprovider[3,2] = "CP_Tables"
laprovider[4,1] = "OBJ"
laprovider[4,2] = "CP_Objects"

*--------------------------------------------------------------------------------------
* Get data from each provider and merge it into the list
*--------------------------------------------------------------------------------------
local laall[1], lnall, larequest[1], lnrequest, lnprovider
lnall = 0
for lnrequest=1 to alines(larequest,chrtran(m.lcproviders,",",chr(13)+chr(10)),.t.)
   for lnprovider=1 to alen(laprovider,1)
      if upper(alltrim(larequest[m.lnRequest])) == laprovider[m.lnProvider,1]
         loisx.ncount = 0
         dimension loisx.alist[1]
         loisx.alist = ""
         &laprovider[m.lnProvider,2](m.loisx)
         if m.loisx.ncount > 0
            dimension laall[m.lnAll+m.loISX.nCount]
            acopy(m.loisx.alist,laall,1,m.loisx.ncount, m.lnall+1)
            lnall = m.lnall + m.loisx.ncount
         endif
      endif
   endfor
endfor




*--------------------------------------------------------------------------------------
* Verify keypress is ENTER or CTRL+ENTER
* By: Rafael Lippert / Created: 14/03/2008 / Updated: 19/03/2008
* Made in Brazil! Foxbrasil
*-------------------------------------------------------------------------------------
local lnlinecount, latext[1], lnstart, lcstring
lnlinha  = getcurrentline( m.lnwhandle )
lcstring = getline(lnwhandle,lnlinha)
lnendposition = getcurrentcol( m.lnwhandle )
lcbeforechar=right(alltrim(left(lcstring,m.lnendposition)),1)
lcafterchar=left(alltrim(right(lcstring,len(lcstring)-m.lnendposition)),1)

if inlist(lcproviders,"ENTER","CTRL+ENTER")
   lnocurrs = mod(occurs(["],lcstring),2)
   if _screen.isx.quote_continue_nextline and at(left(alltrim(lcstring),1),'*&') = 0 and lnocurrs = 0 && Retornou Par - "Aspas abertas e fechadas"
      do case
         case mod(occurs(["],left(lcstring,lnendposition)),2)=1 && Verifica se quantidade de " é impar
            *         MESSAGEBOX('1')
            keyboard '"+;{'+lcproviders+'}{TAB}"' plain
            return
         case lcafterchar="+" and inlist(lcbeforechar,["],[']) and right(trim(lcstring),1)=";"
            *         MESSAGEBOX('2')
            keyboard '{SHIFT+END}{DEL}+;{'+lcproviders+'}'  plain
            _tmp=alltrim(right(lcstring,len(lcstring)-m.lnendposition))
            *         KEYBOARD RIGHT(_TMP,LEN(_TMP)-1) PLAIN
            inserttext( m.lnwhandle,right(_tmp,len(_tmp)-1))
            keyboard "{HOME}{TAB}"
            return
         case lcafterchar="+" and inlist(lcbeforechar,["],['])
            clear typeahead
            *         MESSAGEBOX('3')
            keyboard '{SHIFT+END}{DEL}+;{'+lcproviders+'}'  plain
            _tmp=alltrim(right(lcstring,len(lcstring)-m.lnendposition))
            keyboard strtran(right(_tmp,len(_tmp)-1),chr(10),'') plain
            *         InsertText( m.lnWHandle,CHR(13)+RIGHT(_TMP,LEN(_TMP)))
            keyboard "{HOME}{TAB}" plain
            return
         case inlist(lcbeforechar,"+","-","/","*")
            if left(alltrim(lcstring),1) = '*'
               * Ignore Commented LInes // by Moshe - Foxbrasil - 27/03/2009
               keyboard chr(13) plain
            else
               keyboard ';{'+lcproviders+'}{TAB}' plain
               return
            endif
         case inlist(lcafterchar,["],['])
            keyboard lcafterchar+[+;{]+lcproviders+[}{TAB}]+lcafterchar plain
         case inlist(lcbeforechar,["1],['2])
            keyboard lcafterchar+[+;{]+lcproviders+[}{TAB}]+lcafterchar plain
         otherwise
            *      MESSAGEBOX([{]+lcProviders+[}])
            clear typeahead
            keyboard chr(13) plain
      endcase
   else

      keyboard [{]+lcproviders+[}] plain
      return
   endif
endif

if m.lnall == 0
   if not empty(m.tcinvocation)
      && by Rafael - FoxBrasil - 27/Feb/2009 - updated: 01/april/2009
      *      MESSAGEBOX(tcInvocation)
      do case

            ** Case press 2 times the literals " or '
         case  m.tcinvocation==["] and lcbeforechar=["] and lcafterchar=["]   && By Rafael Lippert - Brasil - 01/04/2009
            clear typeahead
            keyboard '{RIGHTARROW}' plain
         case  m.tcinvocation==['] and lcbeforechar=['] and lcafterchar=[']   &&
            clear typeahead
            keyboard '{RIGHTARROW}' plain
            *******

         case  inlist(m.tcinvocation,aspas_activation,aspasd_activation)
            keyboard m.tcinvocation plain
            if mod(occurs(m.tcinvocation,lcstring)+1,2)=1 && .OR. MOD(OCCURS(ASPASD_ACTIVATION,lcString),2)=0
               keyboard m.tcinvocation plain
               keyboard '{LEFTARROW}'
            endif
         case  m.tcinvocation=='|'  && ||
            keyboard "{Mouse}{Mouse}"+m.tcinvocation+"|" plain

         case  m.tcinvocation==")" and lcbeforechar="(" and lcafterchar=")"   && ||
            clear typeahead
            keyboard '{RIGHTARROW}' plain


         case  m.tcinvocation=='['  && []
            keyboard "{Mouse}{Mouse}"+m.tcinvocation+"]" plain
            keyboard '{LEFTARROW}'

         case  m.tcinvocation=='('  && ()
            clear typeahead
            keyboard "(" plain
            if occurs("(",lcstring)-occurs(")",lcstring)>-1 && By Rafael Lippert - Brasil - 12/03/2009
               keyboard ")" plain
               keyboard '{LEFTARROW}' plain
               keyboard '{ctrl+i}' plain
            endif

         otherwise
            clear typeahead
            keyboard "{Mouse}{Mouse}"+m.tcinvocation plain
      endcase

   endif

else

   *--------------------------------------------------------------------------------------
   * If there's anything in the list, display the popup
   *--------------------------------------------------------------------------------------

   if not empty(m.tcinvocation)
      *   MESSAGEBOX("aqui:"+TRANSFORM(m.tcInvocation))
      inserttext( m.lnwhandle,m.tcinvocation)
   endif
   loisx.ncount = m.lnall
   dimension loisx.alist[loISX.nCount]
   acopy(laall,loisx.alist)
   displaypopup(loisx)

endif




endproc


*========================================================================================
* Determines all include files that fit in the current situation and adds them to the
* list.
*========================================================================================
procedure cp_defines
lparameters toisx

local lofile
if type("_VFP.ActiveProject") == "O"
   for each lofile in _vfp.activeproject.files
      if upper(justext(lofile.name)) == "H"
         readdefines(m.toisx,lofile.name)
      endif
   endfor
else
   readdefines(m.toisx,home()+"FoxPro.H")
endif

endproc


*========================================================================================
* Adds all constants from an include file to the array.
*========================================================================================
procedure readdefines
lparameter toisx, tcfile

*--------------------------------------------------------------------------------------
* File must exist.
*--------------------------------------------------------------------------------------
if not file(m.tcfile)
   return
endif

*--------------------------------------------------------------------------------------
* To increase performance, we cache files if possible.
*--------------------------------------------------------------------------------------
local ladefine[1], lnitem, lncount
if not isincache( "DEFINE", m.toisx, m.tcfile )
   if version(4) >= "07.00"
      lncount = aprocinfo(ladefine,m.tcfile)
   else
      lncount = x6_aprocinfo(@ladefine,m.tcfile)
   endif
   for lnitem=1 to m.lncount
      if ladefine[m.lnItem,3] == "Define"
         toisx.ncount = toisx.ncount + 1
         dimension toisx.alist[toISX.nCount]
         toisx.alist[toISX.nCount] = ladefine[m.lnItem,1]
      endif
   endfor
   addtocache( "DEFINE", m.toisx, m.tcfile )
endif

endproc


*========================================================================================
* The cache is an array in _SCREEN that holds the name of the file, the time stamp, the
* provider ID and the contents of the array.
*========================================================================================
procedure isincache
lparameter tcprovider, toisx, tcfile

if type("_Screen.ISXCache[1,1]") == "U"
   return .f.
endif

local lnline
if version(4) >= "07.00"
   lnline = ascan( _screen.isxcache, m.tcfile+"?"+m.tcprovider, -1, -1, 1, 1+2+4+8 )
else
   local lncurline
   lnline = 0
   for lncurline=1 to alen(_screen.isxcache,1)
      if type(_screen.isxcache[m.lnCurLine]) == "C"
         if upper(m.tcfile+"?"+m.tcprovider) == upper(_screen.isxcache[m.lnCurLine])
            lnline = lncurline
            exit
         endif
      endif
   endfor
endif
if m.lnline == 0
   return .f.
endif

if fdate(m.tcfile,1) # _screen.isxcache[m.lnLine,2]
   return .f.
endif

toisx.ncount = _screen.isxcache[m.lnLine,3]
alines( toisx.alist, _screen.isxcache[m.lnLine,4] )

return .t.


*========================================================================================
* Adds the current entry to the cache.
*========================================================================================
procedure addtocache
lparameter tcprovider, toisx, tcfile

if type("_Screen.ISXCache[1,1]") == "U"
   _screen.addproperty("ISXCache[1,4]")
endif

local lnline
if version(4) >= "07.00"
   lnline = ascan( _screen.isxcache, m.tcfile+"?"+m.tcprovider, -1, -1, 1, 1+2+4+8 )
else
   local lncurline
   lnline = 0
   for lncurline=1 to alen(_screen.isxcache)
      if upper(m.tcfile+"?"+m.tcprovider) == upper(_screen.isxcache[m.lnCurLine])
         lnline = lncurline
         exit
      endif
   endfor
endif
if m.lnline == 0
   lnline = alen(_screen.isxcache,1) + 1
   dimension _screen.isxcache[m.lnLine,Alen(_Screen.ISXCache,2)]
endif

local lnitem
_screen.isxcache[m.lnLine,1] = m.tcfile+"?"+m.tcprovider
_screen.isxcache[m.lnLine,2] = fdate(m.tcfile,1)
_screen.isxcache[m.lnLine,3] = toisx.ncount
_screen.isxcache[m.lnLine,4] = ""
for lnitem=1 to toisx.ncount
   _screen.isxcache[m.lnLine,4] = _screen.isxcache[m.lnLine,4] + ;
      toisx.alist[m.lnItem] + chr(13)+chr(10)
endfor

endproc


*====================================================================
* SW: Fills an array with all PEMs for the objectname typed in
* Returns the number of PEMs. The object has to exist to work
*====================================================================
procedure cp_objects
lparameters toisx

local lnvarcount
if type(toisx.centity) = [O]
   if version(4) >= "07.00"
      if upper(toisx.centity) == "_SCREEN" or upper(toisx.centity) == "_SCREEN"
         return
      endif
   endif
   local lamembers[1]
   try
      toisx.ncount = amembers(lamembers, evaluate(toisx.centity), 1)
      dimension toisx.alist[m.toISX.nCount]
      for m.lncount = 1 to toisx.ncount
         toisx.alist[m.lnCount] = proper(lamembers[m.lnCount,1])
      next
   catch

   endtry

endif

endproc


*====================================================================
* SW: Fills an array with all Fields for the cursor typed in.
* Returns the number of Fields. The cursor has to be open to work
*====================================================================
procedure cp_tables
lparameters toisx

local lncount, lcname,lcerror,lcvaluefield,ln_qtd_dbf, ln_qtd_items
lcname = juststem(toisx.centity)
* November 11, 2004 Modified by Eddy Maue

_screen.isx.work_code_list = .f.   && by Moshe - FoxBrasil - 12/03/2009
_screen.isx.work_force_value = 0   && by Moshe - FoxBrasil - 22/09/2009


do case


   case !empty(_screen.isx.work_path)

      wait window 'Reading Directory '+ _screen.isx.work_path +'...' nowait noclear

      ln_qtd_items = adir(la_tabs,_screen.isx.work_path+'\*.*','HSD')

      if _screen.isx.directory_folders_before_file
         local ln_lop
         * Preparing to Sort...
         for ln_lop = 1 to ln_qtd_items
            if 'D' $ la_tabs[ln_lop,5]
               la_tabs[ln_lop,5] = '1' + la_tabs[ln_lop,1]
            else
               la_tabs[ln_lop,5] = '2' + la_tabs[ln_lop,1]
            endif
         endfor
         *
         asort(la_tabs,5)
      endif


      local ln_list_count
      ln_list_count = 0

      if ln_qtd_items > 0
         toisx.ncount = ln_qtd_items
         dimension toisx.alist[toISX.nCount,5]
         for i=1 to ln_qtd_items
            if left(la_tabs[i,1],1) = '.'
               loop
            endif
            *
            if _screen.isx.work_mask <> '*'
               if lower(justext(la_tabs[i,1])) <> _screen.isx.work_mask .and. at('D',la_tabs[i,5]) = 0
                  loop
               endif
            endif
            *
            ln_list_count = ln_list_count + 1
            do case
               case left(la_tabs[i,5],1) = '1' .and. _screen.isx.directory_folders_before_file
                  toisx.alist[ln_list_count] = la_tabs[i,1] +chr(0)+ 'Folder' +chr(0)+ repl('-',25) + chr(0)+'---------'
               case "D" $ la_tabs[i,5] .and. !_screen.isx.directory_folders_before_file
                  toisx.alist[ln_list_count] = la_tabs[i,1] +chr(0)+ 'Folder' +chr(0)+ repl('-',25) + chr(0)+'---------'
               otherwise
                  if _screen.isx.directory_folders_before_file
                     toisx.alist[ln_list_count] = la_tabs[i,1] +chr(0)+ ltrim(str(la_tabs[i,2],13,0)) +chr(0)+ dtoc(la_tabs[i,3]) +' '+la_tabs[i,4] +chr(0)+ 'File' && By Moshe - FoxBrasil - 18/04/2010
                  else
                     toisx.alist[ln_list_count] = la_tabs[i,1] +chr(0)+ ltrim(str(la_tabs[i,2],13,0)) +chr(0)+ dtoc(la_tabs[i,3]) +' '+la_tabs[i,4] +chr(0)+ la_tabs[i,5] && By Moshe - FoxBrasil - 18/04/2010
                  endif
            endcase
         endfor
         toisx.ncount = ln_list_count
      endif

      wait clear

   case "f." == lower(toisx.centity+".") .and.  _screen.isx.onkey_f_dot && by Moshe - FoxBrasil - 12/03/2009

      _screen.isx.work_code_list = .t.

      local lc_prgfxp_folders
      local lc_current_folder
      lc_prgfxp_folders = set('path')
      lc_current_folder = set('defa')+curdir()
      if at(lower(lc_current_folder),lower(lc_prgfxp_folders)) = 0
         lc_prgfxp_folders = lc_prgfxp_folders +';'+ lc_current_folder
      endif
      *
      if !empty(_screen.isx.f_dot_aditional_path)
         lc_prgfxp_folders = lc_prgfxp_folders +';'+ _screen.isx.f_dot_aditional_path
      endif

      local ln_qtd_fxp
      ln_qtd_fxp = 0

      local ln_lop
      local lc_folder
      local lm_adir_temp[1]
      local ln_qtde_temp
      for ln_lop = 1 to getwordcount(lc_prgfxp_folders,';')
         lc_folder = getwordnum(lc_prgfxp_folders,ln_lop,';')
         *
         if empty(lc_folder)
            loop
         endif
         if right(lc_folder,1) = '\'
            lc_folder = left(lc_folder,len(lc_folder)-1)
         endif
         if !directory(lc_folder)
            loop
         endif
         *
         local ln_lop_type
         for ln_lop_type = 1 to 2
            if ln_lop_type = 1
               if !_screen.isx.f_dot_alow_prg
                  loop
               endif
               ln_qtde_temp = adir(lm_adir_temp,lc_folder+'\*.PRG')
            else
               if !_screen.isx.f_dot_alow_fxp
                  loop
               endif
               ln_qtde_temp = adir(lm_adir_temp,lc_folder+'\*.FXP')
            endif
            *
            if ln_qtde_temp = 0
               loop
            endif
            *
            if vartype(la_tabs) = 'U'
               * 1st Time
               ln_qtd_fxp = ln_qtde_temp
               local la_tabs[ln_qtde_temp,5]
               acopy(lm_adir_temp,la_tabs,1,ln_qtde_temp*5,1)
            else
               * Destination already Exist...
               dimension la_tabs[ln_qtde_temp+LN_qtd_fxp,5]
               acopy(lm_adir_temp,la_tabs,1,ln_qtde_temp*5,(ln_qtd_fxp*5)+1)
               ln_qtd_fxp = ln_qtd_fxp + ln_qtde_temp
            endif
            *
         endfor
         *
      endfor

      local lc_already_listed
      lc_already_listed = ''

      if ln_qtd_fxp > 0
         asort( la_tabs, -1, -1, 0, 1 )

         dimension toisx.alist[LN_qtd_fxp,4]
         for i=1 to ln_qtd_fxp
            if '@' + upper(juststem(la_tabs[i,1])) +'@' $ lc_already_listed
               loop
            endif
            *
            toisx.ncount = toisx.ncount + 1
            toisx.alist[toISX.nCount] = la_tabs[i,1] +"-File-"+ justext(la_tabs[i,1]) +"- "
            lc_already_listed = lc_already_listed + '@' + upper(juststem(la_tabs[i,1])) +'@'
         endfor
      endif



   case "t." == lower(toisx.centity+".") .and.  _screen.isx.onkey_t_dot && by Rafael - FoxBrasil - 16/Feb/2009

      local ln_qtd_dbf
      ln_qtd_dbf=adir(la_tabs,'*.dbf')
      if ln_qtd_dbf>0
         toisx.ncount = ln_qtd_dbf
         dimension toisx.alist[toISX.nCount,4]
         for m.i=1 to ln_qtd_dbf
            toisx.alist[m.i] = juststem(la_tabs[m.i,1])+"-File-DBF- "
            *
            if lower(juststem(la_tabs[m.i,1])) == lower(juststem(dbf()))
               _screen.isx.work_force_value = m.i && by Moshe - FoxBrasil - 22/09/2009
            endif
            *
         endfor
      endif

   case occurs(".",toisx.centity)==0 and !"m." == lower(toisx.centity+".") and ;
         iif(used(m.lcname),.t.,;
         iif(file(m.lcname+".dbf"),opentable(m.lcname),;
         iif(file(m.lcname+".qpr"),execquery(m.lcname),openview(m.lcname))))

      toisx.ncount = fcount(m.lcname)

      _screen.isx.work_table = m.lcname

      dimension toisx.alist[toISX.nCount]

      local lm_matriz_fields[toISX.nCount]
      afields(lm_matriz_fields,m.lcname)

      for m.lncount = 1 to toisx.ncount
         *         toISX.aList[m.lnCount] = PROPER(FIELD(m.lnCount, m.lcName))
         * by Rafael - FoxBrasil - 09/Feb/2009
         lcerror=.f.

         try
            && by Moshe - FoxBrasil - 26/Feb/2009
            local lc_campo_full
            lc_campo_full = m.lcname +'.'+ field(m.lncount, m.lcname)
            *
            lcvaluefield=transform(evaluate(lc_campo_full))+'.'
            if len(lcvaluefield) > 20
               lcvaluefield = left(lcvaluefield,40) +'...'
            endif
         catch
            lcerror=.t.
         endtry

         && by Moshe - FoxBrasil - 18/Feb/2009
         local lc_field_line
         lc_field_line = proper(field(m.lncount, m.lcname))+"-"+typevar(lm_matriz_fields[m.lnCount,2])
         lc_field_line = lc_field_line +" ("+ ltrim(str(lm_matriz_fields[m.lnCount,3],3))
         if lm_matriz_fields[m.lnCount,2] = 'N'
            lc_field_line = lc_field_line +','+ ltrim(str(lm_matriz_fields[m.lnCount,4],2))
         endif
         lc_field_line = lc_field_line +")-Field-"+iif(lcerror,'.',lcvaluefield)
         toisx.alist[m.lnCount] = lc_field_line
      next

endcase



endproc

*====================================================================
* Open the table
* Eddy Maue
* November 11, 2004
*====================================================================
procedure opentable
lparameters lcname

*
* By Moshe - FoxBrasil - 18/04/2010
*
local lc_use_command
if vartype(_screen.isx.use_udf_function) = 'C' .and. !empty(_screen.isx.use_udf_function)
   lc_use_command = 'do '+ _screen.isx.use_udf_function +' with "' + m.lcname +'"'
else
   lc_use_command = [use "]+ m.lcname +[" in 0]
endif
*
try
   &lc_use_command.
endtry
if !used(m.lcname)
   messagebox('Error Opening '+m.lcname+chr(13)+lc_use_command,0+16)
endif

return used(m.lcname)
endproc




*====================================================================
* Open a query
*====================================================================
* Eddy Maue
* November 11, 2004
*====================================================================
procedure execquery
lparameters lcname
do (lcname+".qpr")
return used(lcname)
endproc

*====================================================================
* Open a view
*====================================================================
* Eddy Maue
* November 11, 2004
*====================================================================
procedure openview
lparameters lcname,lcsafety,lcconsol
if type("_vfp.ActiveProject")="U" .or. empty(dbc())
   return .f.
endif
m.lcsafety = "Set Safety "+set("safety")
set safety off
list views to file _view.tmp noconsole
if ":"+alltrim(lower(lcname))+"(" $ strtran(lower(filetostr("_view.tmp"))," ","")
   use (lcname) in 0
endif
&lcsafety
return used(m.lcname)


*========================================================================================
* Displays a popup with all the values from taList, lets the user incrementally approach
* the desired item and inserts it into the editor.
*========================================================================================
procedure displaypopup
lparameter toisx

local lopopupform
if toisx.ncount > 0
   lopopupform = createobject( "isxForm", toisx )
   if vartype(m.lopopupform) == "O"
      lopopupform.show()
   endif
   lopopupform = null
endif
clear class isxform

endproc


*====================================================================
* Determines the source of the window identified by the passed
* WHandle. It returns the following values:
*
* -1     The window is not an edit window
*  0     Command Window
*  1     MODIFY COMMAND window
*  2     MODIFY FILE window
*  8     Menu Designer code window
* 10     Method Edit Window in Class or Form Designer
* 12     MODIFY PROCEDURE window
*
* This procedure uses _EdGetEnv() from the FoxTools.Fll to determine
* the edit source. Passing an invalid handle causes an exception in
* VFP 5 and VFP 3. In VFP 6 this raises an error 2028 (API function
* caused an exception). Therefore we return -1 in this case, too.
*====================================================================
procedure geteditsource
lparameter tnwhandle

local laenv[25], lnsource, lnok, lcerror
lcerror = on( "Error" )
on error lnok = 0

lnok = _edgetenv( m.tnwhandle, @laenv )
on error &lcerror

if m.lnok == 0
   lnsource = -1
   return lnsource
else
   lnsource = laenv[25]
endif
return m.lnsource


*====================================================================
* Returns the WHandle of the current edit window or 0, if no edit
* window is available.
*====================================================================
procedure getcurrentwindow

local lnwindowontop
lnwindowontop = _wontop()
if m.lnwindowontop <= 0
   return 0
endif
if geteditsource( m.lnwindowontop ) == -1
   lnwindowontop = 0
endif

return m.lnwindowontop


*====================================================================
* Returns the current cursor position in the edit window identified
* by the WHandle. On error -1 is returned.
*====================================================================
procedure getfilecursorpos
lparameters tnwhandle

local lncursorpos
lncursorpos = _edgetpos( m.tnwhandle )

return m.lncursorpos


*====================================================================
* Changes the current cursor position in the edit window identified
* by the WHandle.
*====================================================================
procedure setfilecursorpos
lparameter tnwhandle, tnposition

_edsetpos( m.tnwhandle, m.tnposition )

endproc


*====================================================================
* Returns the current line of the edit window identified by the
* WHandle. The line number is zero based. On Error -1 is returned.
*====================================================================
procedure getcurrentline
lparameters tnwhandle

local lncursorpos, lnlineno
lncursorpos = getfilecursorpos( m.tnwhandle )
if lncursorpos < 0
   lnlineno = -1
else
   lnlineno = _edgetlnum( m.tnwhandle, m.lncursorpos )
endif

return m.lnlineno


*====================================================================
* Returns the cursor position within the current line of the edit
* window identified by the WHandle. The cursor position is 0 based.
* On error -1 is returned.
*====================================================================
procedure getcurrentcol
lparameters tnwhandle

local lncursorpos, lnlineno, lncolumn, lnlinestart
lncursorpos = getfilecursorpos( m.tnwhandle )
if m.lncursorpos < 0
   return -1
endif
lnlineno = getcurrentline( m.tnwhandle )
if m.lnlineno < 0
   return -1
endif
lnlinestart = getlinestart( m.tnwhandle, m.lnlineno )
lncolumn = m.lncursorpos - m.lnlinestart

return m.lncolumn


*====================================================================
* Returns the beginning of the specific line in the edit window
* identified by WHandle. Returns -1 on error.
*====================================================================
procedure getlinestart
lparameter tnwhandle, tnlineno

local lnlinestart
lnlinestart = _edgetlpos( m.tnwhandle, m.tnlineno )

return m.lnlinestart


*====================================================================
* Returns the text of the specified line in the edit window
* identified by the WHandle. A terminating carriage return is
* removed. Returns an empty string on error. The line must be zero
* based.
*====================================================================
procedure getline
lparameters tnwhandle, tnline

local lnstartpos, lnendpos, lcstring
lnstartpos = getlinestart( m.tnwhandle, m.tnline )
lnendpos = getlinestart( m.tnwhandle, m.tnline+1 )
if m.lnstartpos == m.lnendpos
   lcstring = ""
else
   lnendpos = m.lnendpos - 1
   lcstring = _edgetstr( m.tnwhandle, m.lnstartpos, m.lnendpos )
   lcstring = chrtran( m.lcstring, chr(13), "" )
endif

return m.lcstring


*====================================================================
* Returns the text in the current line that is to the left of the
* cursor in the edit window identified by the WHandle. Returns "" on
* error.
*====================================================================
procedure getlineleftfromcursor
lparameters tnwhandle

local lncurline, lncurcol, lcline
lncurline = getcurrentline( m.tnwhandle )
if m.lncurline < 0
   return ""
endif
lncurcol = getcurrentcol( m.tnwhandle )
if m.lncurcol < 0
   return ""
endif
if m.lncurcol == 0
   lcline = ""
else
   lcline = getline( m.tnwhandle, m.lncurline )
   lcline = left( m.lcline, m.lncurcol )
endif

return m.lcline


*====================================================================
* Inserts text in the edit window identified by WHandle. The text is
* stored in tcText, the position is optional. tcOptions can contains
* a combination of the following values:
*
*  R   The current selection is replaced
*  B   The cursor is positioned at the beginning of the inserted
*      text.
*  E   (default) The cursor is positioned at the end of the inserted
*      text.
*  H   The inserted text is highlighted.
*====================================================================
procedure inserttext
lparameters tnwhandle, tctext, tnposition, tcoptions

*MESSAGEBOX(tnPosition)
*-----------------------------------------------------------------
* Normalize options
*-----------------------------------------------------------------
local lcoptions
if vartype(m.tcoptions) == "C"
   lcoptions = upper( alltrim(m.tcoptions) )
else
   lcoptions = ""
endif

*-----------------------------------------------------------------
* If a position is passed, Change the current cursor position
* accordingly.
*-----------------------------------------------------------------
if vartype(m.tnposition) == "N"
   setfilecursorpos( m.tnwhandle, m.tnposition )
endif

*-----------------------------------------------------------------
* Insert the Text at the current position. If the "R" option is
* used, delete the current selection.
*-----------------------------------------------------------------
local lnstartposition, lnendposition
if "R" $ m.lcoptions
   _eddelete( m.tnwhandle )
endif
lnstartposition = getfilecursorpos( m.tnwhandle )
_edinsert( m.tnwhandle, tctext, len(tctext) )
lnendposition = getfilecursorpos( m.tnwhandle )

*MESSAGEBOX(_EdGetPos(m.tnWHandle))

* by Rafael - FoxBrasil - 18/Feb/2009


if tctext='.'
   if upper(_edgetstr(m.tnwhandle, m.lnstartposition-1, m.lnendposition-2))='T'
      _edselect( m.tnwhandle, m.lnstartposition-1, m.lnendposition ) && Seleciona um a menos para que quando selecionar a tabela o T. ser apagado
   endif
endif


*-----------------------------------------------------------------
* Set the cursor accordingly. "E" is the default of VFP. We don't
* need any action for that.
*-----------------------------------------------------------------
do case
   case "B" $ m.lcoptions
      setfilecursorpos( m.tnwhandle, m.lnstartposition )
   case "H" $ m.lcoptions
      _edselect( m.tnwhandle, m.lnstartposition, m.lnendposition )

endcase

endproc


*========================================================================================
* Fills an array with all variable declarations in the current procedure of the edit
* window identified by the WHandle. Variable declarations are only searched backward from
* the current position. Returns the number of variables.
*
*! 2004-10Oct-19  ChrisW
*      Added support for variables with non-english characters such as "ö".
*      In VFP 9 the array limitation has been lifted.
*========================================================================================
procedure cp_variables
lparameters toisx

*--------------------------------------------------------------------------------------
* Check if the current entity is a variable
*--------------------------------------------------------------------------------------
local llisvariable
do case
   case upper(toisx.centity)=="M"
      llisvariable = .t.
   case empty(m.toisx.centity)
      if empty(toisx.cinvocation)
         llisvariable = .t.
      else
         llisvariable = .f.
      endif
   otherwise
      llisvariable = .f.
endcase
if not m.llisvariable
   return
endif

*-----------------------------------------------------------------
* Get the current line as a starting point. We start with the line
* before that line.
*-----------------------------------------------------------------
local lnend
lnend = getcurrentline( toisx.nwhandle )
if lnend <= 0
   return
else
   lnend = m.lnend - 1
endif

*-----------------------------------------------------------------
* Because GetLine() is quite slow with large program files, we
* read the entire program up to the line before the current line
* into an array and parse that. Since an array can only contain
* up to 65000 lines, we make sure that we don't read more than
* that into the laText array.
*-----------------------------------------------------------------
local lnlinecount, latext[1], lnstart
if m.lnend >= 65000 and version(4) < "09.00"
   lnstart = m.lnend - 65000
else
   lnstart = 0
endif
lnlinecount = agetlines(m.toisx.nwhandle,@latext,m.lnstart,m.lnend)

*--------------------------------------------------------------------------------------
* Parse all lines backwards for the following keywords: LOCAL,
* PUBLIC, PROCEDURE, FUNCTION. We add all variables in the
* LOCAL and PUBLIC lines and stop parsing when we find PROCEDURE
* or FUNCTION.
*--------------------------------------------------------------------------------------
local lncurrentline, lcline, lnpos, lccommand, lcvalidcmds,lcline2
for lncurrentline = m.lnlinecount to 1 step -1
   lcline = normalizeline( latext[m.lnCurrentLine] )
   lcline2=lcline
   if len(m.lcline) < 4
      loop
   endif
   if version(4) >= "07.00"
      lccommand = getwordnum(m.lcline,2)
   else
      lccommand = x6_getwordnum(m.lcline,2)
   endif
   if m.lccommand == "="
      loop
   endif
   if version(4) >= "07.00"
      lccommand = getwordnum(m.lcline,1)
   else
      lccommand = x6_getwordnum(m.lcline,1)
   endif
   lcvalidcmds = ;
      "LOCAL,PUBLIC,LPARAMETERS,PARAMETERS,PRIVATE,PROCEDURE,FUNCTION,PROTECTED," + ;
      "HIDDEN"
   if not isfoxprocommand(m.lccommand,m.lcvalidcmds)
      loop
   endif
   lnpos = at( " ", m.lcline )
   if m.lnpos == 0 or m.lnpos == len(m.lcline)
      loop
   endif
   lcline = alltrim( substr(m.lcline,m.lnpos) )
   if isfoxprocommand(m.lccommand,"LOCAL")
      if version(4) >= "07.00"
         lccommand = getwordnum(m.lcline,1)
      else
         lccommand = x6_getwordnum(m.lcline,1)
      endif
      if isfoxprocommand(m.lccommand,"ARRAY")
         lnpos = at( " ", m.lcline )
         if m.lnpos == 0 or m.lnpos == len(m.lcline)
            loop
         endif
         lcline = alltrim( substr(m.lcline,m.lnpos) )
      endif
   endif
   if isfoxprocommand( m.lccommand, "PROCEDURE,FUNCTION,PROTECTED,HIDDEN" )
      lnpos = at( "(", m.lcline )
      if m.lnpos == 0 or m.lnpos == len(m.lcline)
         exit
      endif
      lcline = substr(m.lcline,m.lnpos+1)
   endif
   lncurrentline = m.lncurrentline - ;
      cp_variablesadd( m.toisx, m.lcline, m.lncurrentline, @latext,lcline2 )
   if isfoxprocommand( m.lccommand, "PROCEDURE,FUNCTION,PROTECTED,HIDDEN" )
      exit
   endif
endfor

endproc


*========================================================================================
*
*========================================================================================
procedure cp_variablesadd
lparameter toisx, tcline, tncurrentline, isx_tatext , isx_tatext2
alines(lctypevar,isx_tatext2,4,' ') && by Rafael - FoxBrasil - 07/Feb/2009

local lcline, lnlineoffset, lncurrentvar, ladeclarations[1], lccurrentvar, ;
   lnposinvar, lcchar, lnpos,lcvaluevar
lcline = m.tcline
lnlineoffset = 0

do while .t.
   lcline = chrtran( m.lcline, ",", chr(13) )
   for lncurrentvar = 1 to alines( ladeclarations, lcline )
      lccurrentvar = alltrim( ladeclarations[m.lnCurrentVar] )
      if empty( m.lccurrentvar )
         loop
      endif
      if     not isalpha( m.lccurrentvar ) ;
            and not left(m.lccurrentvar,1) == "_"
         loop
      endif
      lnpos = at( " ", m.lccurrentvar )
      if m.lnpos == 0
         lnpos = len( m.lccurrentvar )
      else
         lnpos = m.lnpos - 1
      endif
      * by Rafael - FoxBrasil - 07/Feb/2009
      && Peguei número de caracteres da declaração da variável, diminui pelo lnPos(caracteres do nome), diminui 3 posições, e cheguei ao Type
      lccurrentvartype = right( m.lccurrentvar, len(m.lccurrentvar)-m.lnpos-3 )
      lccurrentvartype =iif(empty(lccurrentvartype),'Undefined',lccurrentvartype)
      **********
      lccurrentvar = left( m.lccurrentvar, m.lnpos )
      if left(lower(m.lccurrentvar),2)=='m.'
         lccurrentvar = substr(m.lccurrentvar,3)
      endif
      for m.lnposinvar = 2 to len(m.lccurrentvar)
         lcchar = substr(m.lccurrentvar,m.lnposinvar,1)
         if not (isalpha(m.lcchar) or isdigit(m.lcchar) or m.lcchar="_")
            lccurrentvar = left( m.lccurrentvar, m.lnposinvar-1 )
            exit
         endif
      endfor
      toisx.ncount = m.toisx.ncount + 1
      dimension toisx.alist[m.toISX.nCount]
      *         toISX.aList[m.toISX.nCount] = m.lcCurrentVar
      && by Rafael - FoxBrasil - 07/Feb/2009
      if type(m.lccurrentvar)<>'U'
         lcvaluevar=transform(evaluate(lccurrentvar))
         if len(lcvaluevar) > 20 && by Moshe - FoxBrasil - 18/Feb/2009
            lcvaluevar = left(lcvaluevar,20)+'...'
         endif
      else
         lcvaluevar=' '
      endif
      toisx.alist[m.toISX.nCount] = m.lccurrentvar+'-'+proper(lccurrentvartype) +'-'+proper(lctypevar)+'-'+lcvaluevar
   endfor
   if right(m.lcline,1) # ";"
      exit
   endif
   lnlineoffset = m.lnlineoffset + 1
   if m.tncurrentline + m.lnlineoffset > alen(isx_tatext,1)
      exit
   endif
   lcline = normalizeline( isx_tatext[m.tnCurrentLine+m.lnLineOffset] )
enddo

return m.lnlineoffset


*========================================================================================
* Returns .T., when the first string is a FoxPro command.
*========================================================================================
procedure isfoxprocommand
lparameter tccommand, tccommandlist

local lalist[1], lnline, llfound

llfound = .f.
for lnline=1 to alines(lalist,chrtran(m.tccommandlist,",",chr(13)+chr(10)))
   if left(upper(lalist[m.lnLine]),len(m.tccommand)) == upper(m.tccommand)
      llfound = .t.
      exit
   endif
endfor

return m.llfound


*====================================================================
* Normalizes a line. This means: All tabs are converted to single
* blanks, leading or trailing blanks are removed. Comments starting
* with && are removed.
*====================================================================
procedure normalizeline
lparameters tcline

local lcline, lnpos
lcline = chrtran( m.tcline, chr(9), " " )
if "&"+"&" $ m.lcline
   lnpos = at( "&"+"&", m.lcline )
   lcline = left( m.lcline, m.lnpos-1 )
endif
lcline = alltrim(m.lcline)

return m.lcline


*====================================================================
* GetKeyLabel takes the parameters passed to the KeyPress event and
* returns the label name that can be used for KEYBOARD or ON KEY
* LABEL, etc.
*====================================================================
procedure getkeylabel
lparameter tnkeycode, tnsac

local lclabel
do case
   case between(m.tnkeycode,33,126)
      lclabel = chr(m.tnkeycode)
   case between(m.tnkeycode,128,255)
      lclabel = chr(m.tnkeycode)
   case m.tnsac == 2 and between(m.tnkeycode,1,26)
      do case
         case m.tnkeycode == 2
            lclabel = "CTRL+RIGHTARROW"
         case m.tnkeycode == 8
            lclabel = ""
         case m.tnkeycode == 10
            lclabel = "CTRL+ENTER"
         case m.tnkeycode == 23
            lclabel = "CTRL+END"
         case m.tnkeycode == 26
            lclabel = "CTRL+LEFTARROW"
         otherwise
            lclabel = "CTRL+" + chr(m.tnkeycode+64)
      endcase
   case m.tnsac == 0 and m.tnkeycode < 0
      lclabel = "F" + alltrim(str(abs(m.tnkeycode)+1))
   case m.tnsac == 0 and m.tnkeycode == 22
      lclabel = "INS"
   case m.tnsac == 1 and m.tnkeycode == 22
      lclabel = "SHIFT+INS"
   case m.tnsac == 0 and m.tnkeycode == 1
      lclabel = "HOME"
   case m.tnsac == 0 and m.tnkeycode == 7
      lclabel = "DEL"
   case m.tnsac == 0 and m.tnkeycode == 28
      lclabel = "F1"
   case m.tnsac == 0 and m.tnkeycode == 6
      lclabel = "END"
   case m.tnsac == 0 and m.tnkeycode == 18
      lclabel = "PGUP"
   case m.tnsac == 0 and m.tnkeycode == 3
      lclabel = "PGDN"
   case m.tnsac == 0 and m.tnkeycode == 5
      lclabel = "UPARROW"
   case m.tnsac == 0 and m.tnkeycode == 28
      lclabel = "F1"
   case m.tnsac == 0 and m.tnkeycode == 24
      lclabel = "DNARROW"
   case m.tnsac == 0 and m.tnkeycode == 4
      lclabel = "RIGHTARROW"
   case m.tnsac == 0 and m.tnkeycode == 19
      lclabel = "LEFTARROW"
   case m.tnsac == 0 and m.tnkeycode == 27
      lclabel = "ESC"
   case m.tnsac == 0 and m.tnkeycode == 13
      lclabel = "ENTER"
   case m.tnsac == 0 and m.tnkeycode == 127
      lclabel = "BACKSPACE"
   case m.tnsac == 0 and m.tnkeycode == 9
      lclabel = "TAB"
   case m.tnsac == 0 and m.tnkeycode == 32
      lclabel = "SPACEBAR"
   case m.tnsac == 1 and m.tnkeycode == 13
      lclabel = "SHIFT+ENTER"
   case m.tnsac == 1 and m.tnkeycode == 127
      lclabel = "SHIFT+BACKSPACE"
   case m.tnsac == 1 and m.tnkeycode == 15
      lclabel = "SHIFT+TAB"
   case m.tnsac == 1 and m.tnkeycode == 32
      lclabel = "SHIFT+SPACEBAR"
   case m.tnsac == 2 and m.tnkeycode == 29
      lclabel = "CTRL+HOME"
   case m.tnsac == 2 and m.tnkeycode == 31
      lclabel = "CTRL+PGUP"
   case m.tnsac == 2 and m.tnkeycode == 30
      lclabel = "CTRL+PGDN"
   case m.tnsac == 2 and m.tnkeycode == 128
      lclabel = "CTRL+BACKSPACE"
   case m.tnsac == 2 and m.tnkeycode == 32
      lclabel = "CTRL+SPACEBAR"
   otherwise
      lclabel = ""
endcase

return m.lclabel


*====================================================================
* Fills an array with all lines between nStart and nEnd.
*====================================================================
procedure agetlines
lparameter tnwhandle, ratext, tnstart, tnend

*-----------------------------------------------------------------
* Copy the text between nStart and nEnd into a string variable.
*-----------------------------------------------------------------
local lnstartpos, lnendpos, lcstring
lnstartpos = getlinestart( m.tnwhandle, m.tnstart )
lnendpos = getlinestart( m.tnwhandle, m.tnend+1 ) - 1
lcstring = _edgetstr( m.tnwhandle, m.lnstartpos, m.lnendpos )

*-----------------------------------------------------------------
* And parse this into an array
*-----------------------------------------------------------------
local lncount
lncount = alines( ratext, m.lcstring )

return m.lncount


*====================================================================
* The FoxTools function _AGetEnv() doesn't return proper font infor-
* mation. Instead it claims that "MS Sans Serif", 8 pt. is the
* current font. This function returns font information for the speci-
* fied window by accessing the GDI.
*====================================================================
procedure wgetfontinfo
lparameter tnwhandle, rcfontname, rnfontsize, rnstyle

*-----------------------------------------------------------------
* In addition to the window handle of this window we also need
* the HWND of the child window that contains the actual editor.
* The GetClientWindow() function retrieves this window handle.
*-----------------------------------------------------------------
local lnhwnd
lnhwnd = getclientwindow( m.tnwhandle )
if m.lnhwnd == 0
   return .f.
endif

*-----------------------------------------------------------------
* Using this HWND we can then get a Device Context.
*-----------------------------------------------------------------
local lnhwnd, lnhdc
declare long GetDC in Win32API long
lnhdc = getdc( m.lnhwnd )
if m.lnhdc == 0
   return .f.
endif

*-----------------------------------------------------------------
* With this device context we can now get an object handle to the
* currently selected font.
*-----------------------------------------------------------------
local lnhfont
declare long GetCurrentObject in Win32API long, long
lnhfont = getcurrentobject( m.lnhdc, 6 )  && OBJ_FONT
if m.lnhfont == 0
   return .f.
endif

*-----------------------------------------------------------------
* The HFONT handle to the current font can be used to obtain more
* detailled information about the selected font. We need to rename
* the API function GetObject(), because it interferes with VFP's
* GETOBJECT() function
*-----------------------------------------------------------------

* by Moshe - FoxBrasil - 17/Abr/2010
* Use command GetObject at a varmem to prevent the Beatify to change to Upper ou Lower Case.
* "GetObject" must be searched at Win32API as typed above.
local lc_getobject_nocaption_change
lc_getobject_nocaption_change = 'GetObject'
declare integer &lc_GetObject_nocaption_change. in Win32API as GDI_GetObject long, integer, string@

local lclogfont
lclogfont = replicate( chr(0), 1024 )
if gdi_getobject( m.lnhfont, 1024, @lclogfont ) == 0
   return .f.
endif

*-----------------------------------------------------------------
* Now to extract the font information from the LOGFONT structure.
*-----------------------------------------------------------------
local lnsize, lcname, lnstyle
lnsize = abs( fromint(left(m.lclogfont,4)) - 2^32 )
lcname = substr( m.lclogfont, 29 )
lcname = left( m.lcname, at(chr(0),m.lcname)-1 )
lnstyle = 0
if fromint(substr(m.lclogfont,17,4)) == 700
   lnstyle = m.lnstyle + 1
endif
if fromint(substr(m.lclogfont,21,4)) # 0
   lnstyle = m.lnstyle + 2
endif

*-----------------------------------------------------------------
* We now have the height of the font in pixels but what we need
* are points.
*-----------------------------------------------------------------
local lnresolution
declare integer GetDeviceCaps in Win32API integer, integer
lnresolution = getdevicecaps( m.lnhdc, 90 ) && LOGPIXELSY
lnsize = m.lnsize / m.lnresolution * 72
lnsize = round( m.lnsize, 0 )

*-----------------------------------------------------------------
* Finally release the device context
*-----------------------------------------------------------------
declare integer ReleaseDC in Win32API long, long
releasedc( m.lnhwnd, m.lnhdc )

*-----------------------------------------------------------------
* And pass the values pack as parameters
*-----------------------------------------------------------------
rcfontname = m.lcname
rnfontsize = m.lnsize
rnstyle = m.lnstyle

return .t.


*====================================================================
* The editor only works on the editor window and you can only get the
* HWND of this window using the Window Handle. For many Windows ope-
* rations, however, you need the HWND of the child window that con-
* tains the actual editor area. This function returns the HWND of
* this window. It's not that easy, because Method snippet windows
* actually have two child windows, one for the text editor and one
* with the method and object dropdown combos.
*====================================================================
procedure getclientwindow
lparameter tnwhandle

*-----------------------------------------------------------------
* Convert the Window Handle into a HWND
*-----------------------------------------------------------------
local lnhwnd
lnhwnd = _whtohwnd( m.tnwhandle )

*-----------------------------------------------------------------
* FindWindowEx returns all child windows of a given parent window.
* We use it to find a child of the edit window that doesn't have
* another child window, because method edit windows have a second
* which we can identify since it has another child window.
*-----------------------------------------------------------------
local lnchild
declare integer FindWindowEx in Win32API ;
   integer, integer, string, string
lnchild = 0
do while .t.
   lnchild = findwindowex( m.lnhwnd, m.lnchild, null, null )
   if m.lnchild == 0
      exit
   endif
   if findwindowex( m.lnchild, 0, null, null ) == 0
      exit
   endif
enddo

return m.lnchild


*====================================================================
* Returns the position of the text cursor (caret) in _SCREEN coordi-
* nates. If the window identified by the passed window handle doesn't
* have the focus, or the position can't be determined, this function
* returns .F.
*====================================================================
procedure getcaretposition
lparameter tnwhandle, rntop, rnleft

*-----------------------------------------------------------------
* Check whether this window has got the focus.
*-----------------------------------------------------------------
declare integer GetFocus in Win32API
if getfocus() # _whtohwnd( m.tnwhandle )
   return .f.
endif

*-----------------------------------------------------------------
* Determine the cursor position. This position is relative to the
** OK
* client area of the editing subwindow of the actual editing win-
* dow.
*-----------------------------------------------------------------
local lnleft, lntop, lcpoint
declare integer GetCaretPos in Win32API string@
lcpoint = space(8)
if getcaretpos( @lcpoint ) == 0
   lnleft = mcol(3)
   lntop = mrow(3)
else
   lnleft = asc(left(m.lcpoint,1))+256*asc(substr(m.lcpoint,2,1))
   lntop = asc(substr(m.lcpoint,5,1))+256*asc(substr(m.lcpoint,6,1))
endif

*-----------------------------------------------------------------
* To convert this postion to _SCREEN coordinates, we have to
* determine the position of the client window relative to the
* desktop window and correlate this with the absolute position of
* the _SCREEN window. Hence, we need first the HWNDs of both
* windows.
*-----------------------------------------------------------------
local lnchild, lnscreen
declare integer GetParent in Win32API integer
lnchild = getclientwindow( m.tnwhandle )
if m.lnchild == 0
   return .f.
endif
lnscreen = getparent( _whtohwnd(m.tnwhandle) )
if m.lnscreen == 0
   return .f.
endif

*-----------------------------------------------------------------
* Now we can determine the position of both windows.
*-----------------------------------------------------------------
local lnchildtop, lnchildleft, lnscreentop, lnscreenleft, lcrect
lcrect = replicate( chr(0), 16 )
declare integer GetWindowRect in Win32API long, string@
getwindowrect( m.lnchild, @lcrect )
lnchildleft = fromint( left(m.lcrect,4) )
lnchildtop = fromint( substr(m.lcrect,5,4) )
getwindowrect( m.lnscreen, @lcrect )
lnscreenleft = fromint( left(m.lcrect,4) )
lnscreentop = fromint( substr(m.lcrect,5,4) )

*-----------------------------------------------------------------
* Now combine the position of the edit window and the cursor
* position.
*-----------------------------------------------------------------
rnleft = m.lnleft + m.lnchildleft - m.lnscreenleft
rntop = m.lntop + m.lnchildtop - m.lnscreentop

endproc


procedure fromint
parameter tcstring
private nvalue, nt
nvalue =0
for nt = 1 to len(tcstring)
   nvalue = nvalue + asc(substr(tcstring,nt,1))*256^(nt-1)
endfor
return nvalue


*====================================================================
* The following class displays a popup window at the current cursor
* position and lets the user continue to type.
*
* The characters a-z, A-Z, 0-9 and _ are inserted into the active
* edit window as the user types. The previous position is saved in
* order to restore the text if necessary.
*
* ESC terminates the popup and doesn't change the text.
*
* TAB inserts the current selection and terminates the popup.
*
* SPACEBAR inserts the current selection, adds a blank and terminates
* the popup.
*
* Any other key terminates the popup and is repeated so it is handled
* properly by VFP. If the user enters the first character that
* doesn't match an item in the list, or entered a full item where
* none exists that has the same name, but additional characters, the
* list is terminated as well.
*
*====================================================================
define class isxform as form

   alwaysontop = .t.
   windowtype = 1
   titlebar = 0
   borderstyle = 0

   nwhandle = 0
   ncurrentpos = 0
   csearchstring = ""
   cvarstring = ""
   dimension aitems[1,2]
   lscrolled = .f.
   *Mike Yearwood - these support reducing screen caption flicker
   cscreencaption = ""
   cwindowcaption = ""
   lmaximized = .f.

   add object isxlist as listbox with ;
      columncount = 4, ;
      columnlines = .t., ;
      incrementalsearch = .t.,;
      specialeffect=1,;
      top=20,;
      left=10

   procedure load
   this.lmaximized = wmaximum()
   if this.lmaximized
      this.cwindowcaption = lower(wtitle())
      *WAIT WINDOW LOWER(WTITLE())
      this.cscreencaption = _screen.caption
   endif
   return dodefault()
   endproc

   procedure show
   *====================================================================
   * Mike Yearwood
   * When the edit window is maximized, the screen caption reads
   * currentedit.prg * - current vfp system window caption
   * When this window goes active, the screen caption changes
   * which causes a flicker. To stop that flicker, set the screen
   * caption to what it was before.
   *====================================================================

   if this.lmaximized
      _screen.caption = this.cwindowcaption + " * - " + this.cscreencaption
   endif

   this.borderstyle = 3
   this.isxlist.anchor = 15

   endproc

   procedure destroy
   *Mike Yearwood
   *Prevent screen caption flicker.
   if this.lmaximized
      _screen.caption = this.cscreencaption
   endif
   endproc


   procedure resize && By Moshe - FoxBrasil - 05/03/2009

   local ln_coef
   ln_coef = this.isxlist.width / _screen.isx.work_width

   local lc_columnwidths
   lc_columnwidths = ;
      ltrim(str(_screen.isx.work_column1 * ln_coef,4)) +','+ ;
      ltrim(str(_screen.isx.work_column2 * ln_coef,4)) +','+ ;
      ltrim(str(_screen.isx.work_column3 * ln_coef,4)) +','+ ;
      ltrim(str(_screen.isx.work_column4 * ln_coef,4))

   this.isxlist.columnwidths = lc_columnwidths

   this.isxlist.refresh()

   endproc


   *====================================================================
   * When the form is initialized, we have to determine its position
   * and get a handle to the current edit window. Pass an array to this
   * form that contains all possible values the user can enter.
   *====================================================================
   procedure init
   lparameter toisx
   with this

      *-----------------------------------------------------------------
      * Get the handle for the current window.
      *-----------------------------------------------------------------
      .nwhandle = toisx.nwhandle
      .ncurrentpos = getfilecursorpos( .nwhandle )


      *-----------------------------------------------------------------
      * Copy the array and sort it case-insensitive
      *-----------------------------------------------------------------
      local lavalues[1], lnvalue
      if version(4) >= "07.00"
         if _screen.isx.table_sort_fields .and. empty(_screen.isx.work_path)
            asort( toisx.alist, -1, -1, 0, 1 )
         endif
      else
         dimension lavalues[toISX.nCount,2]
         for lnvalue = 1 to toisx.ncount
            lavalues[m.lnValue,1] = upper(toisx.alist[m.lnValue])
            lavalues[m.lnValue,2] = m.lnvalue
         endfor
         asort( lavalues, 1 )
      endif


      * Moshe - FoxBrasil - 04/Mar/2009
      if '-field-' $ lower(toisx.alist[1])
         if _screen.isx.table_repl_commands
            toisx.ncount = toisx.ncount +1
            dimension toisx.alist [toISX.nCount]
            ains(toisx.alist,1)
            toisx.alist[1] = '<repl>-*-*-*'
         endif
         *
         if _screen.isx.table_struc_commands
            toisx.ncount = toisx.ncount +1
            dimension toisx.alist [toISX.nCount]
            ains(toisx.alist,1)
            toisx.alist[1] = '<struc>-*-*-*'
         endif
         *
      endif

      * Moshe - FoxBrasil - 05/Mar/2009
      if !empty(_screen.isx.work_path)
         toisx.ncount = toisx.ncount +2
         dimension toisx.alist [toISX.nCount]
         ains(toisx.alist,1)
         toisx.alist[1] = 'Adir() Function'+chr(0)+'*'+chr(0)+'*'+chr(0)+'*'
         ains(toisx.alist,1)
         toisx.alist[1] = 'Adir()'+chr(0)+'*'+chr(0)+'*'+chr(0)+'*'
      endif


      *--------------------------------------------------------------------------------------
      * Fill the listbox with all possible values.
      *--------------------------------------------------------------------------------------
      local lcvalue, lnwidth, lnmaxwidth, lnvalue, lcvarstring, lnavgcharwidth
      local lnwidthvar, lnmaxwidthvar,llvarvalue,llvartype,lnvarmais && by Rafael - FoxBrasil - 07/Feb/2009
      lnmaxwidth = 0
      lnvarmais=-30
      llvarvalue = .f.
      llvartype = .f.
      lnmaxwidthvar = 0
      lcvarstring = ""
      dimension .aitems[toISX.nCount,4]
      dimension lcvarstringr[4] && by Moshe - FoxBrasil - 04/03/2009
      lnavgcharwidth = fontmetric(6,.isxlist.fontname,.isxlist.fontsize)
      for lnvalue = 1 to toisx.ncount
         if version(4) >= "07.00"
            lcvalue = toisx.alist[m.lnValue]
         else
            lcvalue = toisx.alist[laValues[m.lnValue,2]]
         endif

         && by Moshe - FoxBrasil - 05/Mar/2009
         if empty(_screen.isx.work_path )
            alines(lcvarstringr,lcvalue,4,'-')
         else
            alines(lcvarstringr,lcvalue,4,chr(0))
         endif

         .aitems[m.lnValue,1] = lcvarstringr[1] && m.lcValue && Upper(m.lcValue)
         .aitems[m.lnValue,2] = lcvarstringr[3]
         .aitems[m.lnValue,3] = alltrim(lcvarstringr[2]) && Add New Column - Rafael - FoxBrasil - 07/Feb/2009
         try
            .aitems[m.lnValue,4] = lcvarstringr[4]          && Add New Column - Rafael - FoxBrasil - 07/Feb/2009
            if !empty(lcvarstringr[4])
               llvarvalue = .t.
            endif
         catch
            .aitems[m.lnValue,4] = '' && by Moshe - FoxBrasil - 04/03/2009
            llvarvalue = .t.
         endtry
         if lcvarstringr[2]<>'Undefined'
            llvartype = .t.
         endif
         ********************************************
         lcvarstring = m.lcvarstring + ":" + padr(upper(m.lcvalue),128)
         lnwidth = txtwidth(alltrim(lcvalue),.isxlist.fontname,.isxlist.fontsize) * m.lnavgcharwidth
         lnmaxwidth = max( m.lnmaxwidth, m.lnwidth )
         *MESSAGEBOX(lcVarStringR[1])
         lnwidthvar = txtwidth(alltrim(lcvarstringr[1]),.isxlist.fontname,.isxlist.fontsize) * m.lnavgcharwidth

         lnmaxwidthvar = max( m.lnmaxwidthvar, m.lnwidthvar )
      endfor
      if llvarvalue
         lnvarmais=lnvarmais+60
      endif
      if llvartype
         lnvarmais=lnvarmais+55
      endif
      .cvarstring = m.lcvarstring
      lnmaxwidth = m.lnmaxwidth + lnvarmais && IIF(llVarValue,100,30)

      with .isxlist
         if empty(_screen.isx.work_path)
            .columnwidths = alltrim(str(m.lnmaxwidthvar+5   ))+",40,"+iif(llvartype,'80',iif(llvarvalue,'16','0'))+','+iif(llvarvalue,'300','0')
         else
            .columnwidths = alltrim(str(m.lnmaxwidthvar+5   ))+",120,70,20" && By Moshe - FoxBrasil - 18/04/2010
         endif
         .rowsource = "Thisform.aItems"
         .rowsourcetype = 5


         .requery()

         .value = _screen.isx.work_force_value && by Moshe - FoxBrasil - 22/09/2009

         if !llvarvalue
            lnmaxwidth = lnmaxwidth * 1.15  && by Moshe - FoxBrasil - 04/Mar/2009
         endif
         .move( 0, 0, m.lnmaxwidth, 205 ) && by Moshe - FoxBrasil - 26/Feb/2009



         && By Moshe - FoxBrasil - 05/03/2009
         _screen.isx.work_column1 = val(getwordnum(this.isxlist.columnwidths,1,','))
         _screen.isx.work_column2 = val(getwordnum(this.isxlist.columnwidths,2,','))
         _screen.isx.work_column3 = val(getwordnum(this.isxlist.columnwidths,3,','))
         _screen.isx.work_column4 = val(getwordnum(this.isxlist.columnwidths,4,','))
         _screen.isx.work_width   = .width


         if .listcount < 11
            .height = .listcount*16 + 8
         endif
      endwith
      .width = m.lnmaxwidth+3
      .height = .isxlist.height+3 && Shadow Effect - Rafael - FoxBrasil - 07/Feb/2009

      wait clear


      *-----------------------------------------------------------------
      * The original version of the following few code blocks has been
      * kindly provided by Louis D. Zelus. I've modified it to match the
      * rest of the code here. The purpose is to simulate a behavior
      * in VB. If the variable is inserted via ALT+I, everything already
      * typed is used to position the list and if the already entered
      * parts are sufficient to uniquely identify the variablem it's
      * inserted without displaying the popup at all. All blocks based
      * on his code start with LDZ.
      *-----------------------------------------------------------------

      *-----------------------------------------------------------------
      * LDZ: If a variable name has been entered, we highlight it in the
      * edit window.
      *-----------------------------------------------------------------
      local lnstartpos, lnendpos, lcinput
      lcinput = toisx.cname
      if len(m.lcinput) > 0
         lnendpos = getfilecursorpos( .nwhandle )
         lnstartpos = m.lnendpos - len(m.lcinput)
         _edselect( .nwhandle, m.lnstartpos, m.lnendpos )
      endif

      *-----------------------------------------------------------------
      * LDZ: Try to find this variable name in the list of variables we
      * assembled above. If we find it, we select this entry and save
      * what has been entered so far.
      *-----------------------------------------------------------------
      local lnindex
      if len(m.lcinput) > 0
         lnindex = at( ":"+upper(m.lcinput), .cvarstring )
         if m.lnindex == 0
            .isxlist.listindex = 0
         else
            .isxlist.listindex = (m.lnindex/129) + 1
         endif
         .csearchstring = m.lcinput
      endif

      *-----------------------------------------------------------------
      * LDZ: If there's no second instance of this start, accept it
      * immediately without displaying the popup. The full variable name
      * is inserted with the proper case at the current position
      * replacing the selection.
      *-----------------------------------------------------------------
      if len(m.lcinput) > 0
         if at( ":"+upper(m.lcinput), .cvarstring, 2 ) == 0 ;
               and not m.lnindex == 0
            inserttext( .nwhandle, "", , "R" )
            inserttext( .nwhandle, .isxlist.list[.isxList.ListIndex,2] )
            return .f.
         endif
      endif

      *-----------------------------------------------------------------
      * Determine the cursor position in _SCREEN coordinates
      *-----------------------------------------------------------------
      local lnleft, lntop
      if not getcaretposition( .nwhandle, @lntop, @lnleft )
         return .f.
      endif

      *-----------------------------------------------------------------
      * As we position the popup BELOW the current line, we need to
      * know the height of this line in pixels.
      *-----------------------------------------------------------------
      local lnlineheight, lnavgcharwidth, lcfontname, lnfontsize
      if not wgetfontinfo( .nwhandle, @lcfontname, @lnfontsize )
         return .f.
      endif
      lnlineheight = fontmetric( 1, m.lcfontname, m.lnfontsize )
      lnavgcharwidth = fontmetric(6,m.lcfontname,m.lnfontsize)

      *-----------------------------------------------------------------
      * We make sure that the popup doesn't move below the VFP window to
      * keep it visible all the time. If it doesn't fit into the area
      * below the cursor, we move it upwards.
      *-----------------------------------------------------------------
      if m.lntop + .height + m.lnlineheight > _screen.height
         lntop = m.lntop - .height
      else
         lntop = m.lntop + m.lnlineheight
      endif
      .top = m.lntop

      *------------------------------------------------------------------
      * As for the height of the VFP window, we do the same for the
      * width. If the popup won't fit into the VFP _Screen, we flip
      * it horizontally.
      *------------------------------------------------------------------
      if m.lnleft + .width + lnavgcharwidth > _screen.width
         lnleft = m.lnleft - .width
      else
         lnleft = m.lnleft + lnavgcharwidth
      endif

      if lnleft < 0
         lnleft = 0  && By Moshe - FoxBrasil - 20/09/2009
      endif

      .left = m.lnleft
   endwith
   endproc


   *========================================================================================
   * If we don't hide the popup before releasing it, the focus might not go back to the
   * edit window. This happens when we have a Data Session window docked on one side and
   * a code editing window maximized. In this case the focus switches to the datasession
   * window and Aliases listbox disappears.
   *========================================================================================
   procedure release
   this.hide()
   endproc


   procedure isxlist.keypress
   lparameter tnkeycode, tnsac
   with this

      *-----------------------------------------------------------------
      * If the Up or Down Arrow has been pressed, we do nothing, but
      * remember that the user scrolled in the list, because this acti-
      * vates the enter key.
      *-----------------------------------------------------------------
      local llscrolled
      if m.tnsac == 0 and inlist( m.tnkeycode, 5, 24 ,3 ,18, 1, 6) && by Moshe - FoxBrasil - 26/Feb/2009
         .parent.lscrolled = .t.
         return
      endif
      llscrolled = .parent.lscrolled
      .parent.lscrolled = .f.

      *-----------------------------------------------------------------
      * Determines whether a name qualifier has been entered.
      *-----------------------------------------------------------------
      local llqualifier
      llqualifier = .f.
      if m.tnsac == 0 and between(m.tnkeycode,asc("a"),asc("z"))
         llqualifier = .t.
      endif
      if m.tnsac == 0 and between(m.tnkeycode,asc("A"),asc("Z"))
         llqualifier = .t.
      endif
      if m.tnsac == 0 and between(m.tnkeycode,asc("0"),asc("9"))
         llqualifier = .t.
      endif
      if m.tnsac == 1 and m.tnkeycode == asc("_")
         llqualifier = .t.
      endif

      *-----------------------------------------------------------------
      * If a qualifier has been entered, we insert the character into
      * the current edit window. We also perform an incremental search
      * on the Text being inserted.
      *-----------------------------------------------------------------
      local lcsearch, lnindex
      if m.llqualifier
         lcsearch = .parent.csearchstring + chr(m.tnkeycode)
      endif

      *-----------------------------------------------------------------
      * BACKSPACE deletes the last character.
      *-----------------------------------------------------------------
      if m.tnsac == 0 and m.tnkeycode == 127
         if len(.parent.csearchstring) > 0
            lcsearch = .parent.csearchstring
            lcsearch = left( m.lcsearch, len(m.lcsearch)-1 )
            llqualifier = .t.
         endif
      endif

      *-----------------------------------------------------------------
      * Now that we handled BACKSPACE, we can update the variable name
      * in the edit window.
      *-----------------------------------------------------------------
      if m.llqualifier
         inserttext( .parent.nwhandle, m.lcsearch, , "RH" )
         lnindex = at( ":"+upper(m.lcsearch), .parent.cvarstring )
         if m.lnindex == 0
            .listindex = 0
         else
            .listindex = (m.lnindex/129) + 1
         endif
         .parent.csearchstring = m.lcsearch
         nodefault
         return
      endif




      *-----------------------------------------------------------------
      * The following flags determine how to procede.
      *-----------------------------------------------------------------
      local lctexttoinsert, llresendkey, llclearinput
      lctexttoinsert = ""
      llresendkey = .t.
      llclearinput = .f.

      do case


            *-----------------------------------------------------------------
            * If TAB OR ENTER has been pressed, insert the current selection and
            * release the popup
            *-----------------------------------------------------------------
            * By Moshe - FoxBrasil - 05/Mar/2009
         case m.tnsac == 0 .and. (m.tnkeycode == 9 .or. m.tnkeycode == 13) .and. .listindex > 0
            lctexttoinsert = .list[.ListIndex,1] && Now is the First Column to be added - Rafael - FoxBrasil - 07/Feb/2009
            llresendkey = .f.
            llclearinput = .t.


            *-----------------------------------------------------------------
            * Several keys insert the current selection plus the typed
            * character and release the popup. These are usually keys that
            * directly follow a variable name.
            *-----------------------------------------------------------------
         case m.tnkeycode = 92 .and. !empty(_screen.isx.work_path) .and. .listindex > 0
            lctexttoinsert = .list[.ListIndex,1] && Now is the First Column to be added - Rafael - FoxBrasil - 07/Feb/2009
            llclearinput = .t.

            *-----------------------------------------------------------------
            * If ESC has been pressed, the text is unselected.
            *-----------------------------------------------------------------


         case inlist(m.tnkeycode, ;
               asc(" "), asc(")"), asc("["), asc("."), asc("="), ;
               asc("+"), asc("-"), asc("*"), asc("/"), asc("%"), ;
               asc(","), asc("]"), asc("(") ;
               ) and .listindex > 0
            lctexttoinsert = .list[.ListIndex,1] && Now is the First Column to be added - Rafael - FoxBrasil - 07/Feb/2009
            llclearinput = .t.

            *-----------------------------------------------------------------
            * If ESC has been pressed, the text is unselected.
            *-----------------------------------------------------------------
         case m.tnsac == 0 and m.tnkeycode == 27
            llresendkey = .f.

            *-----------------------------------------------------------------
            * terminate the popup for any other key and leave the text.
            *-----------------------------------------------------------------
         otherwise
      endcase

      *-----------------------------------------------------------------
      * If the currently entered Text should be deleted, insert an empty
      * string using the replace option. Insert text afterwards.
      *-----------------------------------------------------------------
      if m.llclearinput
         inserttext( .parent.nwhandle, "", , "R" )
      else
         setfilecursorpos( ;
            .parent.nwhandle, ;
            .parent.ncurrentpos + len(.parent.csearchstring) ;
            )
      endif


      && by Moshe - FoxBrasil - 18/Feb/2009
      local ll_changed_replace
      ll_changed_replace = .f.

      local ln_remove
      if vartype(_screen.isx.work_table) = 'C' .and. !empty(_screen.isx.work_table)
         ln_remove = len(_screen.isx.work_table) + 1
      else
         ln_remove = 0
      endif


      *
      if not empty( m.lctexttoinsert )
         *
         local lc_texto_esq
         lc_texto_esq = getlineleftfromcursor( .parent.nwhandle)
         *
         do case
            case _screen.isx.work_code_list
               *w
               *               lnEndPos = GetFileCursorPos(.Parent.nWHandle )
               *               lnStartPos = m.lnEndPos - 2
               *               _EdSelect( .Parent.nWHandle, m.lnStartPos, m.lnEndPos )
               *               InsertText( .Parent.nWHandle,' ')
               *
               if left(lower(alltrim(_screen.isx.Work_left_line)),4) == 'modi' && Moshe - FoxBrasil - 18/04/2010
                  keyboard '{backspace}{backspace}'+ juststem(m.lctexttoinsert)
               else
                  keyboard '{backspace}{backspace}'+ juststem(m.lctexttoinsert) +'(' plain
               endif
               *               *
               *               InsertText( .Parent.nWHandle,lc_repl_text)

               llresendkey = .f.
               *
            case left(m.lctexttoinsert,6) == 'Adir()'
               *
               local lc_text
               lc_text = chr(13)

               local ll_adir_function
               local ll_adir_full
               local ll_adir_names
               do case
                  case 'Adir() Function' $ lctexttoinsert
                     ll_adir_function = .t.
                  case 'Adir() Names' $ lctexttoinsert
                     ll_adir_names = .t.
               endcase


               local ln_files
               local lm_files[1]
               local ln_lop

               acopy(this.parent.aitems,lm_files)
               ln_files = alen(lm_files)/5
               
               local ln_max_name_len
               ln_max_name_len = 0
               for ln_lop = 1 to ln_files
                  ln_max_name_len = max(ln_max_name_len,len(_screen.isx.work_path + '\'+ lm_files[ln_lop,1]))
               endfor

               for ln_lop = 1 to ln_files
                  if left(lm_files[ln_lop,1] ,1) = '.' .or. 'adir()' $ lower(lm_files[ln_lop,1])
                     loop
                  endif
                  *
                  if ll_adir_function
                     lc_text = lc_text + [MyFunct(']
                  endif
                  *
                  lc_text = lc_text + padr(_screen.isx.work_path + lm_files[ln_lop,1] ,ln_max_name_len)
                  *  
                  if ll_adir_function
                     * by Moshe - FoxBrasil - 18/04/2010
                     * Adir() Columns 2 and 3 changed by Rafael. So, let's change column order here...
                     * Numeric and Date columns was previous converted by Rafael to String
                     lc_text = lc_text + [',]
                     if 'folder' $ lower(lm_files[ln_lop,3])
                        lc_text = lc_text + padl('0',13) +[ , ''] 
                        lc_text = lc_text + space(19) +[ , '] 
                        lc_text = lc_text + [D....')]
                     else
                        lc_text = lc_text + padl(lm_files[ln_lop,3],13) +[ , '] 
                        lc_text = lc_text + lm_files[ln_lop,2] +[' , '] 
                        lc_text = lc_text + lm_files[ln_lop,4]+ [')]
                     endif
                  endif
                  *
                  lc_text = lc_text + chr(13)
                  *
               endfor

               inserttext( .parent.nwhandle,lc_text)
               *
            case left(m.lctexttoinsert,6) == '<repl>'
               *
               local lm_campos[1]
               afields(lm_campos,_screen.isx.work_table)
               *
               local lc_repl_text
               lc_repl_text = chr(13)+'sele '+ _screen.isx.work_table +chr(13)

               lc_repl_text = lc_repl_text + _screen.isx.table_replace_before_string

               local ln_lop
               for ln_lop = 1 to fcount(_screen.isx.work_table)
                  lc_repl_text = lc_repl_text + 'repl '+ padr(lm_campos(ln_lop,1),10) +' with &'+'& '
                  lc_repl_text = lc_repl_text + typevar(lm_campos(ln_lop,2))
                  lc_repl_text = lc_repl_text + ' ('+ ltrim(str(lm_campos(ln_lop,3)))
                  if lm_campos(ln_lop,2) = 'N'
                     lc_repl_text = lc_repl_text + ','+ ltrim(str(lm_campos(ln_lop,4)))
                  endif
                  lc_repl_text = lc_repl_text + ')'+chr(13)
               endfor
               *
               lc_repl_text = lc_repl_text + _screen.isx.table_replace_after_string
               *
               if ln_remove > 0
                  lnendpos = getfilecursorpos(.parent.nwhandle )
                  lnstartpos = m.lnendpos - ln_remove
                  _edselect( .parent.nwhandle, m.lnstartpos, m.lnendpos )
                  inserttext( .parent.nwhandle,' ')
               endif
               *
               keyboard '{del}' plain
               ll_changed_replace = .t.
               *
               inserttext( .parent.nwhandle,lc_repl_text)
               *
            case left(m.lctexttoinsert,7) == '<struc>'
               *
               local lc_ex_alias
               lc_ex_alias = alias()
               *
               sele (_screen.isx.work_table)
               local lc_ind_file
               lc_ind_file = isx_ind_file()
               *
               if empty(lc_ex_alias)
                  sele 0
               else
                  sele (lc_ex_alias)
               endif
               *
               if ln_remove > 0
                  lnendpos = getfilecursorpos(.parent.nwhandle )
                  lnstartpos = m.lnendpos - ln_remove
                  _edselect( .parent.nwhandle, m.lnstartpos, m.lnendpos )
                  inserttext( .parent.nwhandle,' ')
               endif
               *
               keyboard '{del}' plain
               ll_changed_replace = .t.
               *
               inserttext(.parent.nwhandle,filetostr(lc_ind_file)+replicate(chr(13),4))
               *
            otherwise
               *
               if at('repl',lower(lc_texto_esq)) > 0 .and. at('with',lower(lc_texto_esq)) = 0 .and. !file(m.lctexttoinsert+'.dbf') .and. !used(m.lctexttoinsert)
                  * Replace sem With. 1o.Parâmetro
                  if _screen.isx.table_replace_remove_tablename_before_with
                     keyboard replicate('{backspace}',ln_remove)  + m.lctexttoinsert + ' with ' plain
                  else
                     keyboard m.lctexttoinsert + ' with ' plain
                  endif
                  ll_changed_replace = .t.
               else
                  * _screen.isx.Work_Insert
                  if !empty(_screen.isx.work_insert)
                     *
                     if len(_screen.isx.work_insert) = 2 .and. right(_screen.isx.work_insert,1) = ':'
                        lctexttoinsert = '\' + lctexttoinsert && by Moshe - FoxBrasil - 18/04/2010
                     endif
                     *
                     * Select the last Slash to be removed
                     lnendpos = getfilecursorpos(.parent.nwhandle)

                     *  by Moshe - FoxBrasil - 28/10/2009
                     if ln_remove = 0
                        lnstartpos = m.lnendpos - 1
                     else
                        lnstartpos = m.lnendpos - (ln_remove+1)  && by Moshe - FoxBrasil - 18/10/2009
                     endif
                     _edselect( .parent.nwhandle, m.lnstartpos, m.lnendpos )
                     *
                     m.lctexttoinsert = _screen.isx.work_insert + m.lctexttoinsert

                     _screen.isx.work_insert = ''
                  endif
                  *
                  inserttext( .parent.nwhandle, m.lctexttoinsert )
               endif
               *
         endcase
         *
      endif

      *-----------------------------------------------------------------
      * Close the form.
      *-----------------------------------------------------------------
      nodefault
      thisform.release()

      *-----------------------------------------------------------------
      * And repeat the keystroke if necessary
      *-----------------------------------------------------------------
      local lckey
      if m.llresendkey .and. !ll_changed_replace      && by Moshe - FoxBrasil - 18/Feb/2009
         lckey = getkeylabel( m.tnkeycode, m.tnsac )

         if not empty(m.lckey)
            clear typeahead
            if len(m.lckey) == 1
               keyboard m.lckey
            else
               keyboard "{"+m.lckey+"}"
            endif
         endif
      endif

   endwith
   endproc


   *====================================================================
   * Double-clicking is the same as TAB.
   *====================================================================
   procedure isxlist.dblclick

   clear typeahead
   keyboard "{Tab}" plain

   endproc


enddefine



*========================================================================================
* VFP 6: Returns a specific word in a string
*========================================================================================
function x6_getwordnum
lparameter tcstring, tnword, tcdelimiter

local lcstring, lcdelimiter, lnword, lawords[1], lnfound, lcword

if vartype(m.tcdelimiter) == "C"
   lcdelimiter = m.tcdelimiter
else
   lcdelimiter = chr(9)+chr(32)
endif
lcstring = chrtran(m.tcstring,m.lcdelimiter,replicate(chr(13),len(m.lcdelimiter)))
lnfound = 0
lcword = ""
for lnword = 1 to alines(lawords,m.lcstring)
   if not empty(lawords[m.lnWord])
      lnfound = lnfound + 1
      if m.lnfound == m.tnword
         lcword = lawords[m.lnWord]
         exit
      endif
   endif
endfor

return m.lcword


*========================================================================================
* VFP 6: Returns a list of all defines
*========================================================================================
procedure x6_aprocinfo
lparameter taarray, tcfile

local lalines[1], lnline, lnfound

lnfound = 0
for lnline = 1 to alines(lalines,filetostr(m.tcfile))
   if upper(x6_getwordnum(lalines[m.lnLine],1)) == "#DEFINE"
      lnfound = lnfound + 1
      dimension taarray[m.lnFound,3]
      taarray[m.lnFound,1] = x6_getwordnum(lalines[m.lnLine],2)
      taarray[m.lnFound,3] = "Define"
   endif
endfor

return m.lnfound




*========================================================================================
* Identifica o Type retornando por extenso
* by Rafael - FoxBrasil - 09/Feb/2009
* by Moshe - FoxBrasil - 04/Mar/2009
*========================================================================================
function typevar

parameters tctype1
do case
   case tctype1='C'
      return 'Char'
   case tctype1='I'
      return 'Int'
   case tctype1='N'
      return 'Num'
   case tctype1='L'
      return 'Logic'
   case tctype1='D'
      return 'Date'
   case tctype1='T'
      return 'DTime'
   case tctype1='M'
      return 'Memo'
   case tctype1='G'
      return 'General'
   otherwise
      return 'Undefined'
endcase
endfunc













*------------------------------------------------------------
function isx_ind_file

local lc_ind_file
lc_ind_file = strtran(dbf(),'.'+justext(dbf()),".IND")

list struc to (lc_ind_file) noconsole

local lc_texto1
local lc_texto2
lc_texto1 = filetostr(lc_ind_file)
lc_texto2 = chr(13)+chr(10) + 'Sele '+ alias() +chr(13)+chr(10)+chr(13)+chr(10)

local ln_lop
for ln_lop = 1 to 255
   if empty(tag(ln_lop))
      if ln_lop = 1
         lc_texto2 = lc_texto2 + "* This table does not have Index." +chr(13)+chr(10)
      endif
      exit
   endif
   *
   lc_texto2 = lc_texto2 + "Set Order To "+ padr(tag(ln_lop),10)
   lc_texto2 = lc_texto2 + " &"+"& "+ key(ln_lop)
   if primary(ln_lop)
      lc_texto2 = lc_texto2 + " (PRIMARY KEY)"
   endif
   lc_texto2 = lc_texto2 + chr(13)+chr(10)
endfor

if !empty(tag(1))
   lc_texto2 = lc_texto2 + chr(13)+chr(10)
   lc_texto2 = lc_texto2 + 'Set Key To Exp1' +chr(13)+chr(10)
   lc_texto2 = lc_texto2 + 'Set Key To Range Exp1, Exp2' +chr(13)+chr(10)
endif

lc_texto2 = lc_texto2 + chr(13)+chr(10)
lc_texto2 = lc_texto2 + '*!*    ' + alias() + '.<repl>    &' + '& Use ISX Replace ?!' +chr(13)+chr(10)

set memowidth to 10000
for ln_lop = 1 to memlines(lc_texto1)
   lc_texto2 = lc_texto2 + '*!*    '+ mline(lc_texto1,ln_lop) + chr(13)+chr(10)
endfor

lc_texto2 = lc_texto2 + chr(13)+chr(10) +'*!*   '+ replicate('-',60)+ chr(13)+chr(10)
for ln_lop = 1 to fcount()
   lc_texto2 = lc_texto2 + '*!*   '+ padr(field(ln_lop),10) + ' , '+ chr(13)+chr(10)
endfor
lc_texto2 = lc_texto2 + chr(13)+chr(10) + chr(13)+chr(10)

strtofile(lc_texto2,lc_ind_file)

return(lc_ind_file)













* By Emerson Santon Reed - 2009-03-04
function createisxobject
lparameters lcpath

wait window 'UnFreeze - BugFix' timeout 0.01 && By Moshe - FoxBrasil - 04/03/2009

local loisx, lcisxconfigfile, lcisxconfigscript
loisx = createobject("Empty")
addproperty(loisx,'OnKey_F_DOT',.t.)
addproperty(loisx,'OnKey_T_DOT',.t.)
addproperty(loisx,'OnKey_Alt_Enter',.t.)
addproperty(loisx,'OnKey_Single_Quotes',.t.)
addproperty(loisx,'OnKey_Double_Quotes',.t.)
addproperty(loisx,'OnKey_Parenthesis',.t.)
addproperty(loisx,'OnKey_Brackets',.t.)
addproperty(loisx,'OnKey_VerticalBar',.t.)
addproperty(loisx,'OnKey_Back_Slash',.t.)
addproperty(loisx,'Quote_Continue_NextLine',.t.)
addproperty(loisx,'Table_Sort_Fields',.t.)
addproperty(loisx,'Table_Repl_Commands',.t.)
addproperty(loisx,'Table_Struc_Commands',.t.)
addproperty(loisx,'Table_Replace_Remove_TableName_Before_With',.f.)
addproperty(loisx,'Table_Replace_Before_String','')
addproperty(loisx,'Table_Replace_After_String','')
addproperty(loisx,'Use_UDF_Function','')
addproperty(loisx,'F_DOT_Aditional_Path','')
addproperty(loisx,'F_DOT_Alow_PRG',.t.)
addproperty(loisx,'F_DOT_Alow_FXP',.t.)
addproperty(loisx,'Directory_Folders_Before_File',.f.)
addproperty(loisx,'Work_Force_Value',0)
addproperty(loisx,'Work_Insert','')
addproperty(loisx,'Work_Mask','')
addproperty(loisx,'Work_Path','')
addproperty(loisx,'Work_Remove',0)
addproperty(loisx,'Work_Table','')
addproperty(loisx,'Work_Column1',0)
addproperty(loisx,'Work_Column2',0)
addproperty(loisx,'Work_Column3',0)
addproperty(loisx,'Work_Column4',0)
addproperty(loisx,'Work_Width',0)
addproperty(loisx,'Work_Code_List',.f.)
addproperty(loisx,'Work_left_line','')
addproperty(loisx,'Work_left_word','')
if not pemstatus(_screen,"ISX",5)
   addproperty(_screen,"ISX",null)
endif
_screen.isx = loisx
loisx = null
*
* Restore the user settings
lcisxconfigfile = addbs(lcpath) + "ISXConfig.prg"
if file(lcisxconfigfile)
   lcisxconfigscript = filetostr(lcisxconfigfile)
   execscript(lcisxconfigscript)
endif
*
endfunc

function destroyisxobject
if pemstatus(_screen,"ISX",5)
   _screen.isx = null
endif
endfunc





function focus_functions

local lc_focus


* Don't use empty lines inside Text/Endtext
text to lc_focus noshow
ARR_average() : Returns the average of all numeric elements contained in an array.
ARR_Create() : Creates an array of given dimensions.
ARR_Dimensions() : Determines the dimensions of an array (rows and cols).
ARR_elements() : Total number of elements in an array.
ARR_columns() : Number of columns in an array.
ARR_IsArray() : Determines if a variable is an array.
ARR_max() : Returns the biggest numeric value of all elements contained in an array.
ARR_min() : Returns the smallest numeric value of all elements contained in an array.
ARR_rows() : Number of rows in an array.
ARR_LastVersion() : Returns the file stamp of ARR_*() functions.
BMP_bits() : Number of bits per pixel.
BMP_colors() : Number of colors in the bitmap file.
BMP_header() : Reads a bitmap file header.
BMP_height() : Returns bitmap height.
BMP_isbmp() : Tests whether a file is a bitmap file.
BMP_LastVersion() : Returns the file stamp of BMP functions.
BMP_width() : Returns bitmap width.
CD_bayope() : Opens the door and ejects CD media (if possible).
CD_bayclo() : Retracts the tray and closes the door bay (if possible).
CD_caneje() : Can CD audio device eject the media?
CD_canpla() : Can CD audio device play the media?
CD_close() : Closes CD device.
CD_command() : Sends a MCI command string to the CD device open with CD_open().
CD_curpos() : Returns the current position.
CD_curtra() : Returns the current track.
CD_end() : Moves to the end of audio data on the disc.
CD_home() : Moves to the start of audio data on the disc.
CD_iscd() : Is a CD-ROM attached to the computer?
CD_LastError() : Determines the last error that occurred within the CD_*() functions.
CD_LastVersion() : Returns the file stamp of CD_*() functions.
CD_loff() : Disables output to the left audio channel.
CD_lon() : Enables output to the left audio channel.
CD_MediaPresent() : Returns .T. if a disc is inserted in the drive.
CD_mode() : Returns a value indicating the current mode of the device.
CD_msf() : Sets the current time format to MSF (minutes, seconds, frames).
CD_ms() : Sets the current time format to MS (milliseconds).
CD_off() : Disables audio output (mute).
CD_on() : Enables audio output (unmute).
CD_open() : Opens CD device.
CD_pause() : Pauses playing.
CD_play() : Plays CD tracks.
CD_ready() : Determines whether the CD is ready.
CD_resume() : Resumes playback.
CD_roff() : Disables output to the right audio channel.
CD_ron() : Enables output to the right audio channel.
CD_seek() : Moves to the specified position.
CD_start() : Positions the disc at the starting position.
CD_stop() : Stops playback.
CD_time() : Returns the current time format.
CD_tmsf() : Sets the current time format to TMSF.
CD_totlen() : Returns the total length of disc.
CD_tottra() : Returns the number of tracks on the disc.
CD_tralen() : Returns the length of a given track.
CD_trapos() : Returns the starting position of a given track.
CLP_CountFormats() : Counts the number of different data formats available in the clipboard.
CLP_empty() : Clears the Windows clipboard.
CLP_GetText() : Gets text from Windows clipboard.
CLP_IsFormatAvailable() : Determines whether the clipboard contains data in the specified format.
CLP_LastVersion() : Returns the file stamp of CLP functions.
CLP_SetText() : sets text into the Windows clipboard.
COM_BuildCommDCB() : Fills the internal DCB structure of one of the COM handles of FOCUS with the specified values.
COM_close() : to be continued.
COM_LastVersion() : Returns the file stamp of COM functions.
COM_open() : to be continued.
COM_read() : to be continued.
COM_SetCommState() : Configures a communications device according to the specifications found in the FOCUS internal DCB.
COM_write() : to be continued.
CUR_LastVersion() : Returns the file stamp of CUR functions.
CUR_load() : Creates a cursor based on data contained in a file.
DAT_bom() : Beginning of the month.
DAT_boy() : Beginning of the year.
DAT_ctot() : Character to datetime string.
DAT_DateTime() : Current date and time (char YYYY-MM-DD  hh:mm:ss).
DAT_day() : Returns the numeric day-of-the-month for a given date.
DAT_doy() : Returns the day-of-the-year of a given date.
DAT_eom() : End of the month.
DAT_eoy() : End of the year.
DAT_Easter() : Determines the exact date of Easter.
DAT_IsLeap() : Is this a leap year?
DAT_jtod() : Julian date to date.
DAT_LastVersion() : Returns the file stamp of DAT functions.
DAT_month() : Returns the number of the month for a given date.
DAT_num() : Converts a date into a number (Julian date).
DAT_NumberOfDays() : Returns the number of days in a month.
DAT_stod() : Transforms a YYYYMMDD date string into a FoxPro date (opposite to DTOS()).
DAT_year() : Returns the year from the specified date.
DAT_ymd() : Splits a date into its basic components.
DBF_append() : Appends a new record or a series of records.
DBF_bot() : Is the table at begin of file?
DBF_commit() : Flushes current record to disk.
DBF_empty() : Is it an empty table?
DBF_eot() : Is the table at end of file?
DBF_exclu() : Table open exclusively?
DBF_GoBottom() : Go to the bottom of a given work area.
DBF_GoTop() : Go to the top of a given work area.
DBF_flockd() : Table locked or open exclusively?
DBF_LastVersion() : Returns the file stamp of DBF functions.
DBF_lock() : Locks a file or a record.
DBF_readon() : Table open without write access?
DBF_reccnt() : Number of records.
DBF_replac() : Replaces a field with a value.
DBF_rlockd() : Current record locked, table locked or table open exclusively?
DBF_seek() : Performs a SEEK.
DBF_Skip() : Skips a specified number of records in a given work area.
DBF_status() : Retrieves the status of a DBF.
DDA_Aliases() : Returns all the aliases that are known for a specified FOCUS.FLL function.
DDA_Argc() : Number of arguments that a specified function of FOCUS.FLL expects.
DDA_Argv() : Argument types that a specified function of FOCUS.FLL expects.
DDA_count() : Returns the number of Visual FoxPro commands, and evaluations performed by the FOCUS.FLL interpreter engine.
DDA_CloseLog() : Closes the DDA log file.
DDA_error() : Last operation internal error code.
DDA_Evaluate() : Evaluates an expression.
DDA_ExecFuncPtr() : Executes the code that is pointed to by the internal execution pointer.
DDA_Execute() : Executes a command line.
DDA_ExecuteFile() : Executes a set of commands contained in a file.
DDA_ExecuteSnapIn() : Executes a snap-in file.
DDA_ExtendedError() : Last operation Visual FoxPro error code.
DDA_ExtendedErrorMessage() : Last operation Visual FoxPro error message.
DDA_GetLog() : Gets the log file in which commands that couldn’t be executed are logged.
DDA_GetStop() : Retrieves the current Error Handler routine.
DDA_FuncPtr() : Returns a function pointer to a specified function contained in FOCUS.FLL
DDA_IsFunction() : Returns .T. if a specified function exists in FOCUS.FLL.
DDA_LastVersion() : Returns the file stamp of DDA functions.
DDA_ResetCounter() : Resets the internal DDA counter to 0.
DDA_SetExecPtr() : Assigns the internal execution pointer to a given value.
DDA_SetLog() : Sets the log file in which commands that couldn’t be executed are logged by the FOCUS engine.
DDA_SetStop() : Customizes the Error Handler routine that must be used when execution errors occur.
DDA_Stop() : Sets the strategy that FOCUS.FLL has to follow whenever there is a execution error.
DLG_color() : Selects a color.
DLG_font() : Selects a font.
DLG_LastVersion() : Returns the file stamp of DLG functions.
DLG_open() : Open File Dialog Box.
DLG_save() : Presents the Save File Dialog Box.
EDI_AutoIndent() : Auto indent flag.
EDI_Backup() : Backup flag.
EDI_Close() : Closes a file.
EDI_Cut() : Copies the selected portion of the file to the clipboard and deletes it from the editing window.
EDI_Delete() : Deletes the selected portion of the file.
EDI_FileName() : Determines the name of the file that is currently edited.
EDI_Dirty() : Determines whether the file has been changed.
EDI_GetLineNum() : Returns the line number a given offset belongs to.
EDI_GetLinePos() : Returns the offset of the first character of the specified line in the file in the specified editing window.
EDI_GetPos() : Returns the current offset position.
EDI_GroupUndo() : Groups/ungroups undo selection.
EDI_Insert() : Inserts a string in the editing window.
EDI_LastVersion() : Returns the file stamp of EDI functions.
EDI_Open() : Opens a file for editing.
EDI_Paste() : Copies the contents of the clipboard into the file in the specified editing window.
EDI_PosInView() : Determines whether a given position is visible in the current view of the editing window.
EDI_Redo() : Redoes the last action.
EDI_Save() : Saves a file.
EDI_Select() : Selects the range between two offsets.
EDI_SetPos() : Moves the insertion point to the specified offset.
EDI_StatusBar() : Reports line and column position on the Visual FoxPro statusbar.
EDI_Undo() : Undoes the last action.
EVE_CustomizeEventCommand() : Customizes the command associated to a given event.
EVE_End() : Ends event processing.
EVE_GetIdleSince() : Gets the last time when an event did occur that postponed the inactivity in a program.
EVE_LastError() : Last error encountered in EVE functions.
EVE_LastVersion() : Returns the file stamp of EVE functions.
EVE_OnIdleCommand() : Gets/Sets the idle command.
EVE_OnIdleInterval() : Gets/Sets the idle interval.
EVE_ResetIdleSince() : Resets the last event.
EVE_SetUserDefinedAtNullCommand() : Sets a command to be launched at firts null event.
EVE_Start() : Starts event processing.
FDB_Append() : Appends a series of records to a FDB file.
FDB_Create() : Creates a FDB file.
FDB_LastVersion() : Returns the file stamp of FDB functions.
FIL_AreFileAPIsANSI() : Determines whether a set of Win32 file functions is using the ANSI or OEM character set code page.
FIL_BrowseForComputer() : Displays a dialog box that enables the user to select a computer.
FIL_BrowseForFolder() : Displays a dialog box that enables the user to select a shell folder.
FIL_BrowseForPrinter() : Displays a dialog box that enables the user to select a printer.
FIL_Canonicalize() : Canonicalizes a path.
FIL_chdir() : Change Directory service.
FIL_ClearArchived() : Clears the Archive attribute of a file.
FIL_ClearCompressed() : Clears the Compressed attribute of a file.
FIL_ClearHidden() : Clears the Hidden attribute of a file.
FIL_ClearNormal() : Clears the Normal attribute of a file.
FIL_ClearReadOnly() : Clears the Read-Only attribute of a file.
FIL_ClearSystem() : Clears the System attribute of a file.
FIL_ClearTmp() : Clears the Temporary attribute of a file.
FIL_close() : Closes a file.
FIL_commit() : Flushes a file’s data buffer to disk.
FIL_Common() : Compares two paths to determine if they share a common prefix.
FIL_comp() : Reports if two files are the same.
FIL_CompareTime() : Compares time and date stamps of two files.
FIL_copy() : Copies a file.
FIL_copyTimes() : Determines how many times the callback function of FIL_copy() will be called.
FIL_count() : Returns the number of files and directories that match a particular specification.
FIL_create() : Creates a file.
FIL_CreateHardLink() : Establishes an NTFS hard link between an existing file and a new file. An NTFS hard link is similar to a POSIX hard link.
FIL_crypt() : Encrypts a file.
FIL_decrypt() : Decrypts a file encrypted with FIL_crypt().
FIL_del() : Deletes file or directory.
FIL_DeleteAll() : Deletes all file.
FIL_drive() : Returns the drive letter from a complete path.
FIL_exenam() : Returns the executable file name.
FIL_expand() : Expands a file.
FIL_Explore() : Explores a specified folder.
FIL_ext() : Returns the three letter extension from a complete path.
FIL_first() : Gets first instance of a filename that matches a given file specification.
FIL_FlushAll() : Flushes all streams; clears all buffers.
FIL_FndExe() : Find executable associated with a given filename.
FIL_FullName() : Returns the full path to a specified file.
FIL_gdate() : Gets file date stamp.
FIL_get() : Open File Dialog Box.
FIL_getatt() : Gets file attribute.
FIL_GetFolderLocation() : Obtains special folder location.
FIL_gets() : Gets a string from a file.
FIL_GetStdin() : Reads a number of characters from the standard input (stdin).
FIL_GetTempFileName() : Creates a name for a temporary file.
FIL_GetUniversalName() : Returns the Universal Name of a mapped resource.
FIL_gtime() : Gets file time stamp.
FIL_hleft() : Number of files that can still be open simultaneously.
FIL_iatime() : Last access to file,
FIL_ictime() : File creation time,
FIL_imtime() : Last file modification time.
FIL_ImmediateCopy() : Copies a file.
FIL_info() : Obtains general information about a file.
FIL_IsArchived() : Is the given file an archived file?
FIL_isbof() : Is given file at BOF position?
FIL_IsCompressed() : Is the given file a compressed file?
FIL_IsDirectory() : Tests whether a file is marked with a directory flag.
FIL_isEOF() : Is given file at EOF position?
FIL_IsFile() : Determines if the specified file exists.
FIL_IsHidden() : Is the given file hidden?
FIL_isize() : Gets file size.
FIL_IsNormal() : Is the given file a normal file?
FIL_IsReadOnly() : Is the given file read only?
FIL_IsShared() : Is the given directory shared?
FIL_IsShortcut() : Is a given file object a shortcut?
FIL_IsSystem() : Is the given file a system file?
FIL_IsTmp() : Is the given file a temporary file?
FIL_isUNC() : Determines if the string is a valid UNC (universal naming convention) for a server and share path.
FIL_LastVersion() : Returns the file stamp of FIL functions.
FIL_len() : Determines the length of an open file.
FIL_LenCompressed() : Obtains the compressed size, in bytes, of a specified file.
FIL_mkdir() : Creates a directory
FIL_name() : Returns the file name from a complete path.
FIL_next() : Gets next instance of a filename that matches a given file specification (see FIL_first()).
FIL_now() : Returns a file name in the YYYYMMDDHHmmSSXXXXXXXXXX format.
FIL_open() : Opens a file in a given mode.
FIL_OpenFile() : Attempts to open a file in SHARED mode. The file is closed upon exit of the function.
FIL_owner() : Finds the owner of a given file.
FIL_path() : Returns the pathname from a complete path.
FIL_puts() : Writes a string plus a carriage return line feed pair to a file.
FIL_PutStdout() : Outputs a string to the standard output device (stdout).
FIL_read() : Returns a specified number of bytes.
FIL_ReadAllSections() : Reads all the sections of any INI file.
FIL_ReadSub() : Reads a number of bytes from as specific location in a file.
FIL_ReadWININIAllSections() : Reads all the sections of the WIN.INI file.
FIL_reaini() : Reads a character string from an .INI file.
FIL_rename() : Renames a given file.
FIL_rendir() : Renames a given file or directory.
FIL_rmdir() : Removes a directory.
FIL_save() : Save File Dialog Box.
FIL_sdate() : Sets file date stamp.
FIL_sectio() : Reads .INI section.
FIL_seek() : Moves the file pointer to a new position.
FIL_SetArchived() : Sets the Archive attribute of a file.
FIL_setatt() : Sets file attribute.
FIL_SetCompressed() : Sets the Compressed attribute of a file.
FIL_sethan() : Allocates file handles to the current process.
FIL_SetHidden() : Sets the Hidden attribute of a file.
FIL_SetNormal() : Sets the Normal attribute of a file.
FIL_SetCompression() : Compresses a file.
FIL_SetOpenStrategy() : Determines how the low-level functions of FOCUS will access files.
FIL_SetReadOnly() : Sets the Read-Only attribute of a file.
FIL_SetSystem() : Sets the System attribute of a file.
FIL_SetTmp() : Sets the Temporary attribute of a file.
FIL_ShortName() : Obtains the short name equivalent of a filename.
FIL_size() : Determines the length of a file.
FIL_slices() : Cuts a file into several slices of a given size.
FIL_split() : Splits full filename into their basic components.
FIL_stime() : Sets file time stamp.
FIL_StringToFile() : Writes a string to a file.
FIL_tell() : Determines the current location of a file pointer.
FIL_tree() : Returns a tree of directories.
FIL_type() : Returns the type of the specified file.
FIL_unzip() : Decompresses a file.
FIL_where() : Searches for the target file in a set of directories.
FIL_wipe() : File wiping.
FIL_wreain() : Reads a character string from WIN.INI file.
FIL_wriini() : Copies a character string into a .INI file.
FIL_write() : Writes a character string to a file.
FIL_wsecti() : Reads WIN.INI section.
FIL_wwriin() : Copies a character string into the WIN.INI file.
FIL_zip() : Compresses a file.
FIL_zipLastError() : Last error encountered while in FIL_zip()/FIL_unzip().
FTP_CloseAllSessions() : Closes all active FTP sessions.
FTP_CloseSession() : Closes a FTP session for a given site.
FTP_CreateDirectory() : Creates a new directory on the FTP site.
FTP_DeleteFile() : Deletes a file stored on the FTP site.
FTP_GetCurrentDirectory() : Retrieves the current directory for the specified FTP session.
FTP_GetFile() : Retrieves a file from the FTP site and stores it locally.
FTP_FindFirstFile() : Searches the specified directory of the given FTP session.
FTP_FindNextFile() : Searches for additional files.
FTP_HandlesCount() : Returns the maximum number of FTP handles.
FTP_LastError() : Last error encountered in FTP functions.
FTP_LastVersion() : Returns the file stamp of FTP functions.
FTP_MaxHandle() : Returns the highest possible FTP handle.
FTP_MinHandle() : Returns the lowest possible FTP handle.
FTP_OpenSession() : Opens an FTP session for a given site.
FTP_PutFile() : Stores a file on the FTP site.
FTP_RemoveDirectory() : Removes the specified directory on the FTP site.
FTP_RenameFile() : Renames a file or directory stored on the FTP site.
FTP_SetCurrentDirectory() : Changes to a different working directory on the FTP site.
GDI_CreateEllipticRegion() : Creates an elliptical region.
GDI_CreatePolygonalRegion() : Creates a region based on a polygon.
GDI_DeleteRegion() : Frees a region and all its associated internal GDI objects.
GDI_CombineRegions() : Creates a rectangular region.
GDI_CreateRectangleRegion() : Creates a rectangular region.
GDI_Ellipse() : Draws an ellipse.
GDI_LastVersion() : Returns the file stamp of GDI functions. GRA_LastVersion() : Returns the file stamp of GRA functions.
GDI_Rectangle() : Draws a rectangle.
GDI_RoundRectangle() : Draws a round rectangle.
GDI_ScreenToClient() : Converts the screen coordinates of a specified point on the screen to client-area coordinates.
GDI_ClientToScreen () : Converts the client-area coordinates of a specified point to screen coordinates.
GDI_Arc() : Draws an elliptical arc.
GDI_ArcTo() : Draws an elliptical arc.
GDI_CreateSolidBrush() : Creates a brush that has the specified hatch pattern and color.
GDI_chord() : Draws a chord.
GDI_circle() : Draws a circle
GRA_line() : Draws a line.
GDI_SetPixel() : Draws a pixel.
GRA_carve() : Draws a box with carving effect.
HTML_CodeToEntity() : converts HTML code values to HTML entities (e.g. "&#160;" is converted to "&nbsp;").
HTML_Decode() : decodes an HTML encoded string.
HTML_Encode() : applies HTML encoding to the specified text string.
HTML_EntityToCode() : converts HTML entities to HTML code values (e.g. "&nbsp;" is converted to "&#160;").
HTML_LastVersion() : Returns the file stamp of HTML functions.
HTTP_AttemptConnect() : Attempts to make a connection to the Internet.
HTTP_CanonicalizeURL() : Canonicalizes a URL, which includes converting unsafe characters and spaces into escape sequences.
HTTP_CrackURL() : Cracks a URL into a domain and path.
HTTP_CombineURL() : Combines a base and a relative URL into a single URL.
HTTP_DecodeQueryString() : Decodes the QUERY_STRING of a URL request.
HTTP_GetCodeText() : Returns a descriptive text corresponding to a given HTTP responde code.
HTTP_GetDefaultBrowser() : Returns the default browser application that will be invoked for *.htm files.
HTTP_GetURL() : Retrieves URL as a string.
HTTP_GetURL2() : Retrieves URL as a string.
HTTP_InternetDial() : Initiates a connection to the Internet using a modem.
HTTP_IsURL() : Returns status information about a URL.
HTTP_LastError() : Last error encountered in HTTP functions.
HTTP_LastGetURLTime() : Returns the time the last HTTP_GetURL() operation in milliseconds.
HTTP_LastVersion() : Returns the file stamp of HTTP functions.
HTTP_PostURL() : Gets URL and posts information.
HTTP_SetCallback() : Gets/Sets a callback function for the HTTP_GetURL*() functions.
HTTP_SetURLTimeout() : Gets/Sets the timeout value used in HTTP functions.
HTTP_URLDecode() : Decodes a URL.
HTTP_URLEncode() : Encodes a URL.
GetPrivateProfileString() : Reads a character string from an .INI file.
GetPrivateProfileSection() : Reads .INI section.
GetProfileSection() : Reads WIN.INI section.
GetProfileString() : Reads a character string from the WIN.INI file.
WritePrivateProfileString() : Copies a character string into a .INI file.
WriteProfileString() : Copies a character string into the WIN.INI file.
IP_GetAddress() : Returns the IP address of the PC.
IP_GetIP() : Returns the IP address corresponding to a given domain name.
P_LastError() : Determines the last error that occurred within the IP_*() functions.
IP_LastVersion() : Returns the file stamp of IP functions.
IP_ping() : Pings to an IP address
KEY_CodePage() : Retrieves the OEM code-page identifier for the system.
KEY_fast() : Sets the keyboard tick speed to its max.
KEY_fmax() : Returns the number of function keys on the keyboard.
KEY_GetLayoutName() : Retrieves the name of the active keyboard layout.
KEY_HookF12() : Captures the F12 key.
KEY_HookF12Proc() : Customizes the command to be executed when the F12 key is pressed.
KEY_HookPrtScr() : Captures the PrintScreen key.
KEY_HookPrtScrProc() : Customizes the command to be executed when the PrintScreen key is pressed.
KEY_iscaps() : returns the current status of the CapsLock key.
KEY_IsShift() : Determines whether a shift key (left or right) is down.
KEY_IsLShift() : Determines whether the left shift key is down.
KEY_IsRShift() : Determines whether the right shift key is down.
KEY_IsCtrl() : Determines whether a control key (left or right) is down.
KEY_IsLCtrl() : Determines whether the left control key is down.
KEY_IsRCtrl() : Determines whether the right control key is down.
KEY_IsAlt() : Determines whether a alt key (left or right) is down.
KEY_IsLAlt() : Determines whether the left alt key is down.
KEY_IsRAlt() : Determines whether the right altl key is down.
KEY_isins() : Returns the current status of the Ins key.
KEY_isnum() : Returns the current status of the NumLock key.
KEY_IsScrl() : Returns the current status of the ScrollLock key.
KEY_LastVersion() : Returns the file stamp of KEY functions.
KEY_norm() : Sets the keyboard tick speed to its normal cruise.
KEY_SetCap() : Sets the current status of the CapsLock key.
KEY_SetNum() : Sets the current status of the NumLock key.
KEY_SetScr() : Sets the current status of the ScrollLock key.
KEY_slow() : Sets the keyboard tick speed to its slowest speed.
KEY_type() : Retrieves information about the current keyboard.
KEY_UnHookF12() : Releases the capture of the PrintScreen key.
KEY_UnHookPrtScr() : Releases the capture of the PrintScreen key.
KNL_major() : Returns the major version number of KERNEL.DLL.
KNL_minor() : Returns the minor version number of KERNEL.DLL.
KNL_vers() : Returns the version number of KERNEL.DLL.
LNG_LastVersion() : Returns the file stamp of LNG functions.
LNG_MakeLangID() : constructs a language ID from a primary language ID and a sublanguage ID.
LNG_set() : Gets/sets the internal language code
LOC_EnumSystemLocales() : Enumerates the locales that are installed on a system.
LOC_GetLocaleSetting() : Returns a locale setting
LOC_GetSystemLocales() : Gets the locales that were enumerated via the LOC_EnumSystemLocales() function.
LOC_GetUserDefaultLanguage() : Retrieves the user default language identifier.
LOC_GetUserPrimaryLanguage() : Extracts a primary language identifier from a language identifier.
LOC_GetUserSubLanguage() : Extracts a sublanguage identifier from a language identifier.
LOC_LastVersion() : Returns the file stamp of LOC functions.
LOG_Append() : Appends a line of text to a log file.
LOG_Close() : Closes a log file.
LOG_FindFirstLog() : Finds the first available log handle.
LOG_LastError() : Determines the last error that occurred within the LOG_*() functions.
LOG_LastVersion() : Returns the file stamp of LOG functions.
LOG_Set() : Sets a log file.
LOG_Successful() : Returns the string that is used to declare that the last operation has been successfully executed.
LZH_encode() : Compresses a file using the LZH algorithm.
LZH_decode() : Uncompresses a file using the LZH algorithm.
Sending a message : MAPISendMail()
Sending a document : MAPISendDocuments()
Reading a message : MAPIReadMail()
Next message : MAPIFindNext()
MAPI_IsMAPI() : Determines whether MAPI is installed.
MCI_device() : Retrieves the device identifier corresponding to the name of an open device.
MCI_error() : Gets last MCI command error string.
MCI_IsRiff() : Is a given file in the RIFF format?
MCI_IsWave() : Is a given file in the WAVE format?
MCI_LastVersion() : Returns the file stamp of MCI functions.
MCI_send() : Sends a command to MCI devices.
MET_CmToInch() : Cm to inches.
MET_FeetToInch() : Feet to inches.
MET_FeetToMeters() : Feet to meters.
MET_FeetToMile() : Feet to miles.
MET_FeetToYard() : Feet to yards.
MET_InchToCm() : Inches to cm.
MET_InchToFeet() : Inches to feet.
MET_InchToMile() : Inches to miles.
MET_InchToYard() : Inches to yards.
MET_KmToMile() : Km to mile.
MET_LastVersion() : Returns the file stamp of MET functions.
MET_MetersToFeet() : Meters to feet.
MET_MileToKm() : Miles to km.
MET_MileToFeet() : Miles to feet.
MET_MileToInch() : Miles to inches.
MET_MileToYard() : Miles to yards.
MET_MToYard() : Meters to yards.
MET_YardToFeet() : Yards to feet.
MET_YardToInch() : Yards to inches.
MET_YardToM() : Yards to meters.
MET_YardToMile() : Yards to mile.
MIS_Aliases() : Returns all the aliases that are known for a specified FOCUS.FLL function.
MIS_AllFunctions() : Returns all the function and aliases that are known in FOCUS.FLL.
MIS_Argc() : Number of arguments that a specified function of FOCUS.FLL expects.
MIS_Argv() : Argument types that a specified function of FOCUS.FLL expects.
MIS_BodyMassIndex() : Calculates the body mass index.
MIS_credits() : Returns the credits of FOCUS.FLL.
MIS_DocVers() : Returns the version of the FOCUS documentation.
MIS_Error() : Generates a Visual FoxPro error.
MIS_ErrorInfo() : Visual FoxPro error message associated with the error.
MIS_ExecFuncPtr() : Executes the code that is pointed to by the internal execution pointer.
MIS_false() : Always returns a logical .F..
MIS_FuncPtr() : Returns a function pointer to a specified function contained in FOCUS.FLL.
MIS_GetCommonSlot() : Gets/Sets the contents of a shared memory slot.
MIS_GetFocusUsage() : Gets the usage count of FOCUS.FLL.
MIS_IsFunction() : Returns .T. if a specified function exists in FOCUS.FLL.
MIS_knlmajor() : Returns the major version number of KERNEL.DLL.
MIS_knlminor() : Returns the minor version number of KERNEL.DLL.
MIS_knlvers() : Returns the version number of KERNEL.DLL.
MIS_LastVersion() : Returns the file stamp of MIS functions.
MIS_major() : Returns the major version number of FOCUS.FLL.
MIS_minor() : Returns the minor version number of FOCUS.FLL.
MIS_nothin() : Does not do anything !
MIS_OnlineDocVers() : Returns the version of the FOCUS online documentation.
MIS_OutputDebugString() : Sends a string to the debugger for the current application.
MIS_NumberOfFunctions() : Number of functions included in FOCUS.FLL.
MIS_SetExecPtr() : Assigns the internal execution pointer to a given value.
MIS_true() : Always returns a logical .T.
MIS_vers() : returns the version number of FOCUS.FLL.
MNU_AddItem() : Adds an item to a menu created with MNU_Make().
MNU_AddMenu() : Attach a submenu to a menu.
MNU_create() : Creates a context menu at the position of the mouse.
MNU_Destroy() : Destroys an internal menu structure created with MNU_Make().
MNU_Make() : Creates an internal menu structure suitable for context menus.
MNU_Play() : Plays a menu created by MNU_Make().
MOU_ClipCursor() : Restricts the cursor to the specified area.
MOU_FreeClipCursor() : Clears a previously set cursor clipping region.
MOU_isdown() : Is the left mouse button down?
MOU_isLeftMouseDown() : Is the left mouse button down?
MOU_isLeftMouseUp() : Is the left mouse button up?
MOU_isMiddleMouseDown() : Is the middle mouse button down?
MOU_isMiddleMouseUp() : Is the middle mouse button up?
MOU_isRightMouseDown() : Is the right mouse button down?
MOU_isRightMouseUp() : Is the right mouse button up?
MOU_LastVersion() : Returns the file stamp of MOU functions.
MOU_LeftDown() : Simulates a left button down.
MOU_LeftUp() : Simulates a left button up.
MOU_MiddleDown() : Simulates a middle button down.
MOU_MiddleUp() : Simulates a middle button up.
MOU_RightDown() : Simulates a right button down.
MOU_RightUp() : Simulates a right button up.
MOU_Swap() : Swap mouse buttons.
MQ_close() : Closes the current queue.
MQ_connect() : Connects to the Queue Manager.
MQ_disconnect() : Disconnects from the Queue Manager.
MQ_open() : Opens a Queue.
MSG_Broadcast() : Sends a message to all recipients of the Post Office.
MSG_BytesSent() : Total number of bytes sent with the current Post Office.
MSG_count() : Counts the number of unread messages for a given recipient.
MSG_CreateAccount() : Creates an account in the current Post Office.
MSG_CreatePostOffice() : Creates a Post Office.
MSG_DeleteAccount() : Deletes an account in the current Post Office.
MSG_DeleteUnread() : Deletes all pending messages of an account.
MSG_GetAllAccounts() : Gets all accounts that are defined in the current Post Office.
MSG_GetDir() : Returns the mailbox directory of a given recipient (absolute path).
MSG_GetSep() : Returns the separator that is used internally by FOCUS.FLL to tokenize a message.
MSG_GetSubDir() : Returns the mailbox directory of a given recipient (relative path).
MSG_IsAccount() : Determines if the specified account is known bt the current Post Office.
MSG_IsPostOfficeAccessible() : Determines whether the Post Office can be contacted or not.
MSG_LastError() : Returns a string indicating the last error in Messaging functions.
MSG_LastVersion() : Returns the file stamp of MSG functions.
MSG_MessagesRead() : Returns the number of messages the specified recipient has already read.
MSG_MessagesReceived() : Returns the number of messages the specified recipient has received in total.
MSG_MessagesSent() : Returns the number of messages a specified originator has sent.
MSG_PO() : Gets the Post Office location.
MSG_POFile() : Gets the Post Office settings file.
MSG_PostOffice() : Gets/Sets the Post office location and settings file.
MSG_Read() : Reads the least recent message of a given recipient.
MSG_Send() : Sends a message.
MSG_SetPONotification() : Sets a directory notification on a specified directory.
MSG_Successful() : Returns the string that is used to declare that the last operation has been successfully executed.
MSG_TotalMessagesSent() : Returns the total number of messages sent through the current Post Office.
MTH_atan() : Returns a Double specifying the arctangent of a number.
MTH_combinations() : Computes the number of unordered combinations of n on x
MTH_CylinderVolume() : Computes the volume of the cylinder of radius r and height h.
MTH_distance() : computes the distance between 2 points
MTH_Factorial() : Computes the factorial product of a number.
MTH_Fibonacci() : Given a number of calculation loops, calculate the next Fibonacci number.
MTH_LastVersion() : Returns the file stamp of MTH functions.
MTH_origin() : détermine l'origine à l'ordonnée d'une droite passant par deux points.
MTH_pente() : détermine la pente d'une droite passant par deux points.
MTH_permutations() : Computes the number of ordered permutations of n on x
MTH_SphereSurface() : Computes surface of a sphere.
MTH_SphereVolume() : Computes volume of a sphere.
MTH_TriangleSurface() : Computes surface of a triangle.
NET_CancelConnection() : Breaks an existing network connection.
NET_ConnectionDialog() : Presents a dialog box to establish a new network connection.
NET_DisconnectDialog() : Presents a dialog box to cancel a network connection.
NET_EnumConnections() : Enumerates the network connections.
NET_EthernetAddress() : Obtains the Ethernet address of the network card.
NET_GetComputerName() : Retrieves the computer name of the current system.
NET_GetHostName() : Returns the standard host name for the local machine.
NET_GetUserName() : Returns the user name attached to the local machine.
NET_InternetTime() : Returns the Atomic clock date/time with 1sec accuracy.
NET_LastError() : Last error encountered in NET functions.
NET_LastVersion() : Returns the file stamp of NET functions.
NET_level() : Sets up the user level.
NET_max() : Maximum number of software users that can log in simultaneously.
NET_mode() :?????????
NET_proc() : Customizes the command to be executed by dedicated network timer.
NET_SetComputerName() : Sets the computer name to be used the next time the system is restarted.
NET_setnet() : Must the network be setting up.
NET_timset() : Sets a timer dedicated to network attention.
NET_timkil() : Kills the dedicated network timer.
NET_timkil() : Kills the dedicated network timer.NET_userno() : User number.
NOT_Frequency() : Adjusts the frequency of the internal timer of FOCUS.FLL.
NOT_HandlesCount() : Returns the maximum number of notification handles.
NOT_HandlesFree() : Returns the number of free notification handles.
NOT_info() : Returns notification information.
NOT_IsTimer() : Is the internal timer of FOCUS.FLL active?
NOT_Kill() : Kills a notification.
NOT_KillTimer() : Kills the internal timer of FOCUS.FLL.
NOT_LastError() : Returns an error string indicating the nature of the last error encountered.
NOT_LastVersion() : Returns the file stamp of NOT functions.
NOT_MaxHandle() : Returns the highest possible notification handle.
NOT_MinHandle() : Returns the lowest possible notification handle.
NOT_RestoreAll() : Restores all notifications saved with NOT_SaveAll().
NOT_Resume() : Resumes a notification.
NOT_ResumeAll() : Resumes all notifications.
NOT_SaveAll() : Saves all notifications in a character string.
NOT_Set() : Sets a notification.
NOT_Strategy() : Establishes the strategy used to respond to directory notification.
NOT_Successful() : Returns the string that is used to declare that the last operation has been successfully executed.
NOT_Suspend() : Suspends a notification.
NOT_SuspendAll() : Suspends all notifications.
NOT_ZapAll() : Discards all notifications.
NTE_ClearEventLog() : Clears a given event log.
NTE_CloseEventLog() : Closes a read handle to the specified event log.
NTE_OpenEventLog() : Opens an event log.
NUM_Base() : Converts the digits of a given integer argument to a string, by taking into account a given radix.
NUM_between() : Determines if a number is between 2 others.
NUM_BinHi() : Returns the high byte value of a number.
NUM_BinLow() : Returns the low byte value of a number.
NUM_gcd() : Euclid's implementation of the greatest common divisor of two integers.
NUM_GetNextPrime() : Get the next prime number.
NUM_GetPrevPrime() : Get the previous prime number.
NUM_hexa() : Hexadecimal equivalent of an integer.
NUM_htoi() : Integer equivalent of an hexadecimal number.
NUM_InitRandom() : Initializes internal buffers and values for random numbers generation.
NUM_int_max() : Get the highest value of an integer.
NUM_int_min() : Get the lowest value of an integer.
NUM_IsPrime() : Is a number a prime number?
NUM_LastVersion() : Returns the file stamp of NUM functions.
NUM_long_max() : Get the highest value of a long.
NUM_long_min() : Get the lowest value of a long.
NUM_octal() : Octal equivalent to an integer number.
NUM_Radix() : Reverse function of NUM_Base().
NUM_RandomDouble() : Generates a random float in the range 0 to 1.
NUM_RandomInt() : Generates a random integer.
NUM_UniversalID() : Generates a unique identifier that is supposed to be unique in space and unique in time.
OBJ_AddProperty() : Adds a property to an object at Run-Time.
OBJ_LastVersion() : Returns the file stamp of OBJ functions.
PRN_color() : Color printer to render color or monochrome output
PRN_copies() : Number of copies printed if the device supports multiple-page copies
PRN_device() : Device name
PRN_dialog() : Displays a dialog box to setup application printer
PRN_driver() : Printer driver version number
PRN_drv() : Printer driver name.
PRN_duplex() : Double-sided printing.
PRN_EnumPrinters() : Enumerates available printers.
PRN_extra() : Size of the optional dmDriverData member for device-specific data
PRN_fields() : Set of flags that indicate which members of the DEVMODE structure have been initialized.
PRN_GetDefaultPrinter() : Gets the default printer.
PRN_GetDrvInfo() : Retrieves driver data for the specified printer.
PRN_GetJobs() : List all printing jobs for a given printer.
PRN_GetPrnData() : Retrieves information about a specified printer
PRN_LastVersion() : Returns the file stamp of PRN functions.
PRN_name() : Device name/printer name
PRN_orient() : Paper orientation
PRN_paperL() : Paper length, in tenths of a millimeter
PRN_paperS() : Paper size
PRN_paperW() : Paper width, in tenths of a millimeter
PRN_port() : Port connection
PRN_qualit() : Printer resolution
PRN_resolu() : Printer resolution (y-resolution)
PRN_scale() : Factor by which the printed output is to be scaled
PRN_SetDefaultPrinter() : Sets the default printer.
PRN_SetPrnData() : Sets information in a given printer
PRN_size() : Size of the DEVMODE structure
PRN_source() : Default bin from which the paper is fed
PRN_spec() : Version number of the DEVMODE structure
PRN_TTopt() : How should TrueType fonts be printed?
REG_CreateKey() : Creates a key in the Windows registry.
REG_CreateValue() : Creates a value in the Windows registry.
REG_DeleteKey() : Deletes a key in the Windows registry.
REG_DeleteValue() : Deletes a value in the Windows registry.
REG_EnumKeyEx() : Enumerates all subkeys of a given key of the Windows registry.
REG_LastVersion() : Returns the file stamp of REG functions.
REG_QueryValue() : Gets data from the Registry.
RG_Compile() : Compiles a pattern that will be used in subsequent calls to RG_Execute().
RG_Execute() : Performs a regular expression search.
RG_Match() : match of the whole last regular expression.
SCR_BitmapHeight() : Height of bitmaps contained in title bar.
SCR_BitmapWidth() : Width of bitmaps contained in title bar.
SCR_ColorBlender() : Blends color between 2 colors.
SCR_ColorDepth() : Determines screen color depth
SCR_cols() : Displays width in pixels
SCR_EnumDisplaySettings() : Retrieves information about one of the graphics modes for a display device.
SCR_GetDMMember() : Retrieves a member of the internal DEVMODE structure that is populated after a call to SCR_EnumDisplaySettings().
SCR_GetFullScreenDimensions() : Determines the usable dimensions of the Windows desktop.
SCR_GetScreenDimensions() : Determines the usable dimensions of the Windows desktop.
SCR_LastVersion() : Returns the file stamp of SCR functions.
SCR_MinimumDragHeight() : Minimum tracking height of a window.
SCR_MinimumDragWidth() : Minimum tracking width of a window.
SCR_RefreshDisplay() : Refreshes the entire display.
SCR_ResetDisplaySettings() : Returns to the default mode display.
SCR_roloc() : Reverses color attribute
SHE_AddIcon() : Adds an icon in the System Tray of Windows.
SHE_CopyFile() : Copies multiple source files from one location to another.
SHE_DeleteAllTrayIcons() : Removes all icons set with SHE_AddIcon().
SHE_DeleteIcon() : Removes an icon from the System Tray of Windows.
SHE_GetDllVersion() : Obtains version information from the shell32.dll.
SHE_GetIconCount() : Get the number of icons found in an executable, or .DLL.
SHE_IconsFree() : Determines how many icons can still be placed in the System Tray of Windows.
SHE_IsActiveDesktopInstalled() : Checks for the Active Desktop.
SHE_LastError() : Returns the last error that occurred in the SHE_*() functions.
SHE_LastVersion() : Returns the file stamp of SHE functions.
SHE_QueryRecycleBin() : Determines the number of deleted items in the recycle bin of a specific drive.
SHE_PathAddBackslash() : Adds a backslash to the end of a path.
SHE_PathCompact() : Truncates a path to fit within a certain number of characters by replacing path components with ellipses.
SHE_PathIsRelative() : Searches a path and determines if it is relative.
SHE_PathIsRoot() : Parses a path to determine if it is a directory root.
SHE_PathIsUNC() : Determines if the string is a valid UNC (universal naming convention) for a server and share path.
SHE_PathIsUNCServer() : Determines if a string is a valid UNC for a server path only.
SHE_PathIsUNCServerShare() : Determines if a string is a valid UNC share path, \\server\share.
SHE_PathIsURL() : Tests a given string to determine if it conforms to a valid URL format.
SHE_PathRemoveBackslash() : Removes the trailing backslash from a given path.
SIZ_bool() : Size of a bool.
SIZ_char() : Size of a char.
SIZ_double() : Size of a double.
SIZ_dword() : Size of a DWORD.
SIZ_enum() : Size of an enum.
SIZ_float() : Size of a float.
SIZ_int() : Size of an integer.
SIZ_int8() : Size of a 8-bit integer.
SIZ_int16() : Size of a 16-bit integer.
SIZ_int32() : Size of a 32-bit integer.
SIZ_int64() : Size of a 64-bit integer.
SIZ_handle() : Size of a handle.
SIZ_hwnd() : Size of a window handle (HWND).
SIZ_LastVersion() : Returns the file stamp of the SIZ functions.
SIZ_long() : Size of a long.
SIZ_longdouble() : Size of a long double.
SIZ_short() : Size of a short.
SIZ_tchar() : Size of a TCHAR.
SIZ_uint() : Size of an unsigned integer.
SIZ_wchar() : Size of a WCHAR.
SIZ_whandle() : Size of a window handle (WHANDLE)
SND_AppEvent() : Plays a waveform identified by an entry in the registry.
SND_asterisk() : Plays a waveform identified by an entry in the registry (iconasterisk)
SND_error() : Plays a waveform identified by an entry in the registry (iconhand)
SND_exclamation() : Plays a waveform identified by an entry in the registry (iconexclamation)
SND_LastVersion() : Returns the file stamp of SND functions.
SND_OK() : Plays a waveform identified by an entry in the registry (iconok)
SND_play() : Plays a waveform sound specified by a filename.
SND_repeat() : Repeats the last waveform that was played.
SND_Standard() : Standard beep using the computer speaker.
SND_Stop() : Stops playing any wave file.
SND_vers() : Returns the FOCUS Sound version.
SPI_GetBeep() : Determines whether the warning beeper is on.
SPI_GetBorder() : Retrieves the border multiplier factor that determines the width of a window's sizing border.
SPI_GetDoubleClickHeight() : Height in pixels of the double-click rectangle.
SPI_GetDoubleClickTime() : Retrieves the current double-click time for the mouse.
SPI_GetDoubleClickWidth() : Width in pixels of the double-click rectangle.
SPI_GetFastTaskSwitch() : Is Alt-Tab enabled?
SPI_GetGrid() : Retrieves the current granularity value of the desktop sizing grid.
SPI_GetIconTitleWrap() : Determines whether icon-title wrapping is enabled.
SPI_GetKeyboardDelay() : Retrieves the keyboard repeat-delay setting.
SPI_GetKeyboardSpeed() : Retrieves the keyboard repeat-speed setting.
SPI_GetLastError() : Returns the last error encountered when using SPI_*() functions.
SPI_GetMenuDropAlignment() : Determines whether pop-up menus are left-aligned or right-aligned, relative to the corresponding menu-bar item.
SPI_GetScreenReader() : Determines whether a screen reviewer utility is running.
SPI_GetScreenSaveActive() : Determines whether screen saving is enabled.
SPI_GetScreenSaveTimeout() : Gets the screen saver time-out value.
SPI_GetShowSounds() : Determines whether the Show Sounds accessibility flag is on or off.
SPI_GetWorkArea() : Retrieves the size of the working area.
SPI_LastVersion() : Returns the file stamp of SPI functions.
SPI_SetBorder() : Sets the border multiplier factor that determines the width of a window's sizing border.
SPI_SetBeep() : Turns the warning beeper on or off.
SPI_SetDoubleClickHeight() : Height in pixels of the double-click rectangle.
SPI_GetDoubleClickTime() : Sets the current double-click time for the mouse.
SPI_SetDoubleClickWidth() : Width in pixels of the double-click rectangle.
SPI_SetFastTaskSwitch() : Enables or disables Alt-Tab.
SPI_SetGrid() : Sets the granularity of the desktop sizing grid.
SPI_SetIconHorizontalSpacing() : Sets the width of an icon cell.
SPI_SetIconTitleWrap() : Enables or disables icon-title wrapping.
SPI_SetIconVeriticalSpacing() : Sets the height of an icon cell.
SPI_SetKeyboardDelay() : Sets the keyboard repeat-delay setting.
SPI_SetKeyboardSpeed() : Sets the keyboard repeat-speed setting.
SPI_SetMenuDropAlignment() : Sets the alignment value of pop-up menus.
SPI_SetMouseButtonSwap() : Swaps or restores the meaning of the left and right mouse buttons.
SPI_SetScreenSaveActive() : Sets the state of the screen saver.
SPI_SetScreenSaveTimeout() : Sets the screen saver time-out value.
SPI_SetWallpaper() : Sets the Windows wallpaper.
SPI_SetWorkArea() : Retrieves the size of the working area.
SPI_Successful() : Returns the string that is used to declare that the last operation has been successfully executed.
STR_addcod() : Adds an ASCII code to each character of a string.
STR_AllChars() : Returns all the characters found in a string in a sorted manner.
STR_ascii() : Forms a number based on each character value.
STR_ascii2() : Forms a number based on each character value multiplied by its position.
STR_Ascii2Ebcdic() : Converts a string to its EBCDIC equivalent.
STR_AtLine() : Determines the number of the line a given position belongs to.
STR_balanc() : Finds position where a given character is balanced with another.
STR_char() : Extracts the rest of a string.
STR_chrcnt() : Counts occurrences of a character in a string.
STR_chrswa() : Swaps one character with another within a string.
STR_comma() : Formats a string that only contains digits.
STR_CompareStrings() : Compares two character strings, using the current User Locale as the basis for the comparison.
STR_Compare() : Compares two character strings, and reports where they differ.
STR_ConvertA2B() : Converts a character string based on an internal conversion table.
STR_ConvertB2A() : Reverses the conversion set by the STR_ConvertA2B() function.
STR_cpbrk() : Finds the 1st occurrence in a string of any character from another string. String result.
STR_Decode64() : Decodes a base 64 encoded string.
STR_dionly() : Keeps digits only.
STR_Ebcdic2Ascii() : Converts a string to its ASCII equivalent.
STR_Encode64() : Encodes a string in base 64.
STR_encrypt() : Encrypts a string.
STR_end() : Does a string end with a given value?
STR_exclude() : Excludes characters that are in a string.
STR_find() : Finds an occurrence of a substring in a string (two times faster than AT()).
STR_FindBackward() : Finds an occurrence of a substring in a string (two times faster than RAT()) starting from the end of the string.
STR_first() : Finds the first character that is not a space.
STR_FormatByteSize() : Converts a numeric value into a string that represents the number expressed as a size value in bytes, kilobytes, megabytes, or gigabytes, depending on the size.
STR_getoff() : Gets the internal offset position.
STR_GeneratePassword() : Generates a random password.
STR_hexa() : Hexadecimal equivalent of a string.
STR_htos() : Original string corresponding to an hexadecimal string.
STR_IsAlpha() : Determines if a given string contains only alpha characters.
STR_IsAlphaNumeric() : Determines if a given string contains only alphanumeric characters.
STR_IsPunct() : Determines if a given string contains only punctuation marks.
STR_IsSpace() : Determines if a given string contains only spaces.
STR_IsGraph() : Determines if a given string contains only graph characters.
STR_IsPrint() : Determines if a given string contains only graph characters.
STR_IsCharAlpha() : Determines if a given character is an alpha character.
STR_IsCharAlphaNumeric() : Determines if a given character is an alphanumeric character.
STR_IsCharDigit() : Is a given character a digit?
STR_IsCharGraph() : Is a given character printable while not being a space?
STR_IsCharLower() : Determines if a given character of a specified string is a lowercase character.
STR_IsCharPrint() : Is a given character printable?
STR_IsCharPunct() : Is a given character a punctuation character?
STR_IsCharSpace() : Is a given character a white space character?
STR_IsCharUpper() : Determines if a given character of a specified string is an uppercase character.
STR_IsCharXDigit() : Determines if a given character of the specified string is a hexadecimal digit.
STR_IsDigit() : Determines if characters of the specified string are digits.
STR_IsDigitOrDecimalSeparator() : Determines if characters of the specified string are digits or decimal separator (".").
STR_IsInSet() : Determines if characters of the specified string belongs to a set of characters.
STR_IsNumber() : Determines if a string forms a number.
STR_IsLower() : Determines if characters of the specified string are lowercase characters.
STR_IsUpper() : Determines if characters of the specified string are uppercase characters.
STR_IsValidCreditCard() : Determines whether a credit card number is correct or not.
STR_IsXDigit() : Determines if characters of the specified string are hexadecimal digits.
STR_keep() : Keeps specified characters from a string.
STR_KeepConsonants() : Keeps the consonants of a string.
STR_KeepVowels() : Keeps the vowels of a string.
STR_last() : Finds the last character that is not a space.
STR_LastVersion() : Returns the file stamp of STR functions.
STR_Left() : Returns a specified number of characters from a character expression, starting with the leftmost character.
STR_Length() : Determines the length of a string.
STR_Like() : Strings comparison with wildcards.
STR_LikeCase() : Indicates whether STR_Like() should be case sensitive or not (Get/Set function).
STR_LikeGetToken() : Returns the last token specified when using STR_Like().
STR_LTrim() : Returns the specified character expression with leading blanks removed.
STR_mirror() : Reverses a string.
STR_MixUp() : Mix up a string.
STR_n() : Extracts the nth character of a string.
STR_nparam() : Extracts the nth parameter of a string.
STR_npbrk() : Finds the 1st occurrence in a string of any character from another string. Numeric result.
STR_nset() : Set first n characters of string to specified character.
STR_ntoken() : Extracts a given token from a string.
STR_null() : Returns a null string (empty string).
STR_numtok() : Determines the number of tokens in a string.
STR_occu() : Determines position of nth occurrence of a character in a string.
STR_peek() : Returns the ASCII code of a given character in a string.
STR_poke() : Poke a character at given position in string.
STR_Proper() : Returns a string capitalized appropriately for proper names.
STR_raw() : Forms a string of characters comprised between a given ASCII range.
STR_reduce() : Reduces consecutive occurrences of the same character to only 1 occurrence.
STR_relin() : Run Encoding Length algorithm (In).
STR_relout() : Run Encoding Length algorithm (Out).
STR_Replace() : Replaces a substring with another in a string.
STR_ResetLikeCharConversions() : Resets the conversion table for STR_Like().
STR_Right() : Returns a specified number of characters from a character expression, starting with the rightmost character.
STR_RTrim() : Returns the specified character expression with trailing blanks (or other character) removed.
STR_SetCharConversion() : Gets/sets a new character conversion for STR_ConvertA2B() and STR_ConvertB2A().
STR_SetConvTable() : Sets a conversion table for STR_ConvertA2B() and STR_ConvertB2A().
STR_SetLikeCharConversion() : Gets/sets a new character conversion for STR_Like().
STR_setoff() : Sets the internal offset position of token functions.
STR_setsep() : Gets/sets the internal separator for token based functions.
STR_shl() : Shifts-Left a string by a given number of bits.
STR_shr() : Shifts-Right a string by a given number of bits.
STR_sort() : Sorts all the characters in a string.
STR_soundex() : Returns a phonetic key reprsenting a name.
STR_start() : Does a string start with a given value?
STR_strip() : Strips characters in a given range from a character string.
STR_strtok() : Extracts a token from a string.
STR_TillNull() : Returns a string up to the first null character.
STR_tokfin() : Did we process the entire string?
STR_tokini() : Initializes internal counters for token processing.
STR_toknex() : Gets the next token.
STR_tokpos() : Determines the starting position of a given token.
STR_TrimLeft() : Trims off x characters from the left of a string.
STR_TrimRight() : Trims off x characters from the right of a string.
SYS_ACLineStatus() : AC power status.
SYS_AllocConsole() : Allocates a new console to the current program (EXE).
SYS_avaclu() : Gets the number of available clusters on disk.
SYS_BatteryFlag() : Battery charge status.
SYS_BatteryFullLifeTime() : Number of seconds of battery life when at full charge.
SYS_BatteryLifePercent() : Percentage of full battery charge remaining.
SYS_BatteryLifeTime() : Number of seconds of battery life remaining.
SYS_Broadcast() : Broadcasts a WIN.INI change to all applications.
SYS_bytsec() : Gets the number of bytes per sector on given disk
SYS_ConfigurePort() : Displays the port-configuration dialog box for a port.
SYS_CreateMutex() : Creates a named mutex object.
SYS_curdri() : Obtains the current drive.
SYS_DeleteMutex() : Releases mutex object.
SYS_displa() : Returns the display driver which is used by Windows.
SYS_DoesDriveExist() : Finds out if given drive exists in the system.
SYS_DoesSupportCompression() : Does the file system support file-based compression.
SYS_dosmaj() : Returns DOS major version number.
SYS_dosmin() : Returns DOS minor version number.
SYS_dristr() : Returns a string with all drives.
SYS_DriveType() : Returns the drive type.
SYS_dsksiz() : Returns the total capacity in bytes of a specified disk drive.
SYS_dskspa() : Returns the number of available bytes on a given disk drive
SYS_EnumDeviceDrivers() : List of active device drivers in the system
SYS_errhan() : Custom Windows error handling
SYS_exenam() : Returns the executable file name
SYS_ExitProcess() : Ends a process and all of its threads.
SYS_ExitWindows() : Either logs off, shuts down, or shuts down and restarts the system.
SYS_FatalExit() : Displays a message box and terminates the application.
SYS_FileSystemName() : File system installed on a given drive.
SYS_FormatDrive() : Presents the standard dialog box of Windows to format a drive.
SYS_FreeConsole() : Frees the current console (if any).
SYS_FreeLibrary() : Unloads a 32-bit DLL previously loaded with SYS_LoadLibrary().
SYS_GetBinaryType() : Determines the type of an executable.
SYS_GetCaretBlinkTime() : Returns the elapsed time, in milliseconds, required to invert the caret's pixels.
SYS_GetCaretPosX() : Caret's position, in client coordinates.
SYS_GetCaretPosY() : Caret's position, in client coordinates.
SYS_GetCommandLine() : Command-line string for the current process.
SYS_GetConsoleHWND() : Returns the Windows handle of the current console.
SYS_GetConsoleTitle() : Gets the title of the current console.
SYS_GetCurrentDirectory() : Returns current directory.
SYS_GetDllVersion() : Obtains version information from any DLL.
SYS_GetEnvironmentStrings() : Retrieves the whole environment block of the current process.
SYS_GetEnvironmentVariable() : Retrieves the value of the specified variable from the environment block of the calling process.
SYS_GetHInstance() : Retrieves the handle of the application instance that handles the main FoxPro window.
SYS_GetLocalTime() : Gets the local time.
SYS_GetNumDrives() : Finds out how many drives exist in the system.
SYS_GetStdHandle() : Gets the handle of a standard handle.
SYS_GetSysColor() : Retrieves the current color of the specified display element.
SYS_GetSystemMetrics() : Retrieves various system metrics and system configuration settings.
SYS_GetThreadLocale() : Returns the calling thread's current locale.
SYS_GetTickCount() : Retrieves the number of milliseconds that have elapsed since Windows was started.
SYS_GetTimeZoneInformation() : Retrieves the current time-zone parameters
SYS_GetTmpPath() : Gets the Windows temporary path.
SYS_GlobalMemoryStatus() : Retrieves information about current available memory.
SYS_HideCaret() : Removes the caret from the screen.
SYS_inp() : input a byte from a port.
SYS_iscd() : Is the given drive a CD-ROM?
SYS_IsCompressed() : Determines if the specified volume is a compressed volume.
SYS_isDMA() : Is a DMA installed
SYS_IsDriveReady() : Is a given drive ready?
SYS_IsFileCaseSensitive() : Does the system distinct between upper and lower case filenames?
SYS_IsFileCasePreserved() : Does the system preserve cases?
SYS_isfixe() : Is the given drive a fixed drive?
SYS_IsFlop() : Is the given drive a floppy drive? (is disk removable?)
SYS_IsGame() : Is a game adapter present?
SYS_IsLoaded() : Determines if a process (EXE) or library (DLL) is loaded.
SYS_IsMath() : Is Math coprocessor present?
SYS_IsModem() : Is a modem present?
SYS_IsMutex() : Does a given mutex object exist.
SYS_isNT() : Is the application running under Windows NT?
SYS_ispen() : Is it a pen computing prepared machine?
SYS_isram() : Is the given drive a RAM disk?
SYS_isremo() : Is the given drive a remote drive?
SYS_IsService() : Determines if a given service existson a given machine.
SYS_IsUnicodeOnDisk() : Does the file system support Unicode in filenames as they appear on disk?
SYS_IsValidLocale() : Validity test to a locale identifier.
SYS_JoyStickCaps() : Determines if the capabilities of a joystick can be queried.
SYS_JoyStickEnumDevs() : Returns the number of joysticks the joystick driver supports.
SYS_KillProcess() : Kills a given task.
SYS_LastError() : Gets system functions last error.
SYS_LastVersion() : Returns the file stamp of SYS functions.
SYS_LoadLibrary() : Attempts to load a 32-bit DLL.
SYS_LookupDomain() : Returns the first domain on which a specified user is defined.
SYS_MakeDrive() : From a number, it returns a drive letter.
SYS_MaxApplAddress() : Returns the highest memory address accessible to applications and dynamic-link libraries (DLLs).
SYS_MaxFileLength() : Obtains maximum filename length for a given disk.
SYS_MediaType() : Determines the media type.
SYS_MinApplAddress() : Returns the lowest memory address accessible to applications and dynamic-link libraries (DLLs).
SYS_MinimumDragHeight() : Minimum tracking height of a window.
SYS_MinimumDragWidth() : Minimum tracking width of a window.
SYS_ModuleHandle() : Returns a module handle for a specified module.
SYS_ModuleName() : Retrieves the full path and filename for the executable file containing the specified module.
SYS_mouse() : Returns the mouse driver which is used by Windows.
SYS_networ() : Returns the network driver which is used by Windows.
SYS_numflo() : Floppy disk count.
SYS_numprn() : Number of printers.
SYS_os() : Get OS infos.
SYS_OSLastError() : Returns an error string from the Operating System about the last operation.
SYS_outp() : output a byte to a port.
SYS_P3Serial() : Pentium III serial number.
SYS_PageSize() : Specifies the page size and the granularity of page protection and commitment.
SYS_Processes() : List of active tasks in the system
SYS_ProcessesId() : List of IDs of all active tasks
SYS_ProcessorArchitecture() : Specifies the system's processor architecture.
SYS_ProcessorMask() : Returns a mask representing the set of processors configured into the system.
SYS_RealExecutableName() : Gets the name of the executable.
SYS_RemoteShutdown() : Initiates a shutdown and optional restart of the specified computer.
SYS_secclu() : Gets the number of sectors per cluster on given disk.
SYS_SendMessage() : Sends a specified message to a window (or windows).
SYS_SetCaretBlinkTime() : Sets the caret blink time to the specified number of milliseconds.
SYS_SetCaretPos() : Sets caret's position, in client coordinates.
SYS_SetConsoleTitle() : Sets the title of the current console.
SYS_setdri() : Sets current drive.
SYS_SetEnvironmentVariable() : Sets the value of an environment variable for the current process.
SYS_SetErrorMode() : Controls whether the system will handle the specified types of serious errors, or whether the process will handle them.
SYS_SetFileAPIsToANSI() : Causes a set of Win32 file functions to use the ANSI character set code page.
SYS_SetFileAPIsToOEM() : Causes a set of Win32 file functions to use the OEM character set code page.
SYS_SetLocalTime() : Gets the local time.
SYS_setvol() : Sets a new volume label for a given disk.
SYS_ShellAbout() : Displays a Shell About dialog box.
SYS_ShellExecute() : Opens, explores or prints a specified file.
SYS_ShellExecuteEx() : Opens, explores or prints a specified file.
SYS_ShowCaret() : Makes the caret visible on the screen at the caret's current position.
SYS_sleep() : Suspends the execution of the current thread for a specified interval.
SYS_SplitTime() : Splits the current local time into its base components.
SYS_StartService() : Starts a Windows NT Service.
SYS_StopService() : Stops a Windows NT Service.
SYS_swap() : Returns the name of the Windows swap file.
SYS_sysdir() : Obtains the pathname of the Windows system directory.
SYS_tasks() : List of active tasks in the system.
SYS_totclu() : Gets the total number of clusters on given disk.
SYS_video() : Initial video mode.
SYS_volume() : Obtains volume information for a given disk.
SYS_VolumeName() : Obtains volume name for a given disk.
SYS_VolumeSerial() : Obtains volume serial number for a given disk.
SYS_winBuild() : Returns the build number of the operating system.
SYS_windir() : Obtains the pathname of the Windows directory.
SYS_WinExec() : Runs a specified application.
SYS_WinExecEx() : Runs a specified process.
SYS_winmaj() : Returns Windows major version number.
SYS_winmin() : Returns Windows minor version number.
SYS_WriteConsole() : Writes a string to the current console.
TIM_ctime() : Converts a time value retrieved via TIM_time() as a character string.
TIM_FormatMilli() : Transforms a number of milliseconds in HH:MM:SS.mmm.
TIM_FormatTimeInterval() : Converts a time interval, specified in milliseconds, to a string.
TIM_GetNumberOfDays() : Computes the days difference between two dates.
TIM_gmt() : Converts a time value retrieved via TIM_time() to an Universal Time Coordinated (UTC).
TIM_LastVersion() : Returns the file stamp of Time functions.
TIM_localt() : Converts a time value retrieved via TIM_time() to a local time string.
TIM_MakeSeconds() : Computes the number of seconds from a time string.
TIM_MakeTime() : Computes a time value from a date.
TIM_Minus() : Substract time strings.
TIM_Plus() : Adds time strings.
TIM_SetFormat() : Customizes the internal string buffer that TIM_UserTime() will use.
TIM_SetSystemTime() : Sets the system time to an Universal Coordinated Time (UTC).
TIM_SplitMilli() : Splits a number of millseconds into its basic components (HH:MM:SS.mmm).
TIM_ticks() : Returns the number of milliseconds since Windows was started.
TIM_time() : Gets the current time (UTC format).
TIM_Times() : time string multiplication.
TIM_UserTime() : Gets a formatted string expressing a DateTime value.
TIM_kill() : Kills the global timer.
TIM_proc() : Customizes the command to be executed by the global timer.
TIM_set() : Sets the global timer.
TMR_Create() : Creates a timer.
TMR_Destroy() : Destroys a timer.
TMR_HandlesCount() : Returns the maximum number of handles.
TMR_HandlesFree() : Returns the number of free timer handles.
TMR_info() : Returns timer information.
TMR_LastError() : Returns an error string indicating the nature of the last error encountered.
TMR_LastVersion() : Returns the file stamp of TMR functions.
TMR_MaxHandle() : Returns the highest possible handle.
TMR_MinHandle() : Returns the lowest possible handle.
TMR_Resume() : Resumes a timer.
TMR_Suspend() : Suspends a timer.
TRA_getlog() : Retrieves the name of the tracing log file.
TRA_LastVersion() : Returns the file stamp of TRA functions.
TRA_log() : Logs a string in the tracing log file.
TRA_setlog() : Sets the name of the tracing log file.
VER_alpha() : Gets/sets the alpha flag.
VER_author() : Gets/sets the author name.
VER_beta() : Gets/sets the beta flag.
VER_cargo() : Gets/sets the cargo member. You can write whatever information you’d like to.
VER_cpyrig() : Gets/sets the application copyrights.
VER_counte() : Gets/sets the application counter.
VER_company() : Gets/sets the Company member.
VER_date() : Gets/sets the date field.
VER_demo() : Gets/sets the demo flag.
VER_FinalRelease() : Gets/sets the Final Release flag.
VER_GetFileVersionInfo() : Determines executable version information.
VER_ini() : Gets/sets the INI file field.
VER_init() : Initializes C structure members.
VER_LastVersion() : Returns the file stamp of VER functions.
VER_major() : Gets/sets the major version number.
VER_minor() : Gets/sets the minor version number.
VER_name() : Gets/sets the application name.
VER_prerel() : Gets/sets the pre-release flag.
VER_Release() : Gets/sets the Release flag.
VER_ReleaseCandidate() : Gets/sets the Release Candidate flag.
VER_Revision() : Gets/sets the revision number.
VID_close() : Closes the AVI device.
VID_end() : Sets the AVI to the end position.
VID_home() : Sets the AVI to the start position.
VID_LastError() : Determines the last error that occurred within the CD_*() functions.
VID_LastVersion() : Returns the file stamp of VID functions.
VID_loff() : Sets the AVI audio left off.
VID_lon() : Sets the AVI audio left on.
VID_off() : Sets the AVI audio off.
VID_on() : Sets the AVI audio on.
VID_open() : Opens the AVI device.
VID_play() : Plays the AVI device.
VID_pause() : Pauses the AVI device.
VID_ron() : Sets the AVI audio right on.
WHOIS_LastError() : Last error encountered in WHOIS functions.
WHOIS_LastVersion() : Returns the file stamp of WHOIS functions.
WHOIS_whois() : Queries a central repository for information regarding users, hosts, company addresses, and phone numbers.
WIN_bottom() : Window bottom border position in pixels.
WIN_ClearOval() : Deletes an elliptical region created with WIN_MakeOval().
WIN_Destroy() : Destroys the specified window.
WIN_DestroyIcon() : Destroys a given icon.
WIN_dialog() : Displays a dialog box that is the specified color scheme and contains the specified body text and button text.
WIN_DrawAnimatedRects() : Draws a wire-frame rectangle and animates it to indicate the opening of an icon or the minimizing or maximizing of a window.
WIN_DrawEdge() : Draws one or more edges of rectangle
WIN_DrawIcon() : Draws a given icon.
WIN_EnumChildren() : Enumerates the child windows that belong to the specified parent window.
WIN_EnumWindows() : Enumerates all top-level windows on the screen.
WIN_Flash() : Flashes the specified window once.
WIN_GetActiveWindow() : Retrieves window handle (HWND) of the current window.
WIN_GetChildren() : Retrieves all child window handles obtained by a call to WIN_EnumChildren().
WIN_GetClassName() : Retrieves the name of the class to which the specified window belongs.
WIN_GetClientArea() : Retrieves the dimensions of the bounding rectangle of the specified window.
WIN_GetExStyle() : Retrieves the extended window styles.
WIN_GetForegroundWindow() : Returns a handle to the foreground window (the window with which the user is currently working).
WIN_GetHandle() : Retrieves a handle to the top-level window corresponding to the passed parameter.
WIN_GetHInstance() : Retrieves the handle of the application instance that handles a given window.
WIN_GetHwndParent() : Retrieves the handle of the parent window, if any.
WIN_GetIcon() : Extracts a given icon from an executable or DLL.
WIN_getPort() : Returns the WHANDLE of the window that is currently selected for user output.
WIN_GetStyle() : Retrieves the window style.
WIN_GetWindowDC() : Retrieves the device context (DC) for the entire window, including title bar, menus, and scroll bars.
WIN_GetWindows() : Retrieves all window handles obtained by a call to WIN_EnumWindows().
WIN_GetWindowText() : Determines a window's title bar.
WIN_GetWndProc() : Retrieves the address of the window procedure, or a handle representing the address of the window procedure.
WIN_handle() : Window handle (WHANDLE).
WIN_height() : Window height in pixels
WIN_hwnd() : Returns the Windows HWND of a given window.
WIN_IsWindow() : Determines whether the specified window handle identifies an existing window.
WIN_IsWindowEnabled() : Determines whether the specified window is enabled for mouse and keyboard input.
WIN_IsWindowUnicode() : Determines whether the specified window is a native Unicode window.
WIN_IsWindowVisible() : Determines whether the specified window is visible or not.
WIN_LastVersion() : Returns the file stamp of WIN functions.
WIN_left() : Window left border position in pixels.
WIN_Lock() : Disables or re-enables drawing in the specified window.
WIN_main() : Desktop window handle (WHANDLE).
WIN_MakeOval() : Creates an elliptical region and attach it to a form.
WIN_MsgBox() : Creates, displays, and operates a message box.
WIN_raised() : Draws a raised edge of rectangle.
WIN_ReleaseDC() : Releases a device context (DC), freeing it for use by other applications.
WIN_right() : Window right border position in pixels.
WIN_Select() : Brings the specified window to the active position on the screen.
WIN_SetActiveWindow() : Redirects Windows output to the window asociated with this handle (HWND).
WIN_SetFocus() : Sets the keyboard focus to the specified window.
WIN_SetFocusS() : Shows a window and bring it on top.
WIN_SetForegroundWindow() : Puts the thread that created the specified window into the foreground and activates the window.
WIN_SetParent() : Changes the parent window of the specified child window.
WIN_setPort() : Changes the user output window to be the specified window.
WIN_sunken() : Draws a sunken edge of rectangle.
WIN_top() : Window top border position in pixels.
WIN_width() : Window width in pixels.
WIN_WHandleToHwnd() : Returns the Windows HWND of the specified WHANDLE.
MEM_Compress() : Compresses a string.
MEM_Decompress() : Decompresses a string compressed with MEM_Compress().
ZIP_Compress() : Compresses a set of files into a ZIP archive.
ZIP_Expand() : Expands all files contained in a ZIP archive.
ZIP_LastError() : Determines the last error that occurred within the ZIP_*() functions.
ZIP_LastVersion() : Returns the source file stamp of ZIP functions.
ZIP_List() : List all files contained in a ZIP archive.
ZIP_SetCallback() : Gets/Sets a callback function for the ZIP_Compress(), ZIP_Expand() and ZIP_List() functions.
ZIP_SetSubdirs() : Gets/Sets the subdirectory flag as used in ZIP_Compress().
ENDTEXT
* Don't use empty line insides Text/Endtext


return(lc_focus)







function vfp_comands

local lc_vfp


* Don't use empty lines inside Text/Endtext
text to lc_vfp noshow
ABS( ) Function
ACLASS( ) Function
ACOPY( ) Function
ACOS( ) Function
ADATABASES( ) Function
ADBOBJECTS( ) Function
ADDBS( ) Function
ADDPROPERTY( ) Function
ADEL( ) Function
ADIR( ) Function
ADLLS( ) Function
ADOCKSTATE( ) Function
AELEMENT( ) Function
AERROR( ) Function
AEVENTS( ) Function
AFIELDS( ) Function
AFONT( ) Function
AGETCLASS( ) Function
AGETFILEVERSION( ) Function
AINS( ) Function
AINSTANCE( ) Function
ALANGUAGE( ) Function
ALEN( ) Function
ALIAS( ) Function
ALINES( ) Function
ALLTRIM( ) Function
AMEMBERS( ) Function
AMOUSEOBJ( ) Function
ANETRESOURCES( ) Function
APRINTERS( ) Function
APROCINFO( ) Function
ASC( ) Function
ASCAN( ) Function
ASELOBJ( ) Function
ASESSIONS( ) Function
ASIN( ) Function
ASORT( ) Function
ASQLHANDLES( ) Function
ASTACKINFO( ) Function
ASUBSCRIPT( ) Function
AT( ) Function
AT_C( ) Function
ATAGINFO( ) Function
ATAN( ) Function
ATC( ) Function
ATCC( ) Function
ATCLINE( ) Function
ATLINE( ) Function
ATN2( ) Function
AUSED( ) Function
AVCXCLASSES( ) Function
BAR( ) Function
BARCOUNT( ) Function
BARPROMPT( ) Function
BETWEEN( ) Function
BINDEVENT( ) Function
BINTOC( ) Function
BITAND( ) Function
BITCLEAR( ) Function
BITLSHIFT( ) Function
BITNOT( ) Function
BITOR( ) Function
BITRSHIFT( ) Function
BITSET( ) Function
BITTEST( ) Function
BITXOR( ) Function
BOF( ) Function
CANDIDATE( ) Function
CAPSLOCK( ) Function
CAST( ) Function
CDOW( ) Function
CDX( ) Function
CEILING( ) Function
CHR( ) Function
CHRSAW( ) Function
CHRTRAN( ) Function
CHRTRANC( ) Function
CLEARRESULTSET( ) Function
CMONTH( ) Function
CNTBAR( ) Function
CNTPAD( ) Function
COL( ) Function
COM Functions
COMARRAY( ) Function
COMCLASSINFO( ) Function
COMPOBJ( ) Function
COMPROP( ) Function
COMRETURNERROR( ) Function
COS( ) Function
CPCONVERT( ) Function
CPCURRENT( ) Function
CPDBF( ) Function
CREATEBINARY( ) Function
CREATEOBJECT( ) Function
CREATEOBJECTEX( ) Function
CREATEOFFLINE( ) Function
CTOBIN( ) Function
CTOD( ) Function
CTOT( ) Function
CURDIR( ) Function
CURSORGETPROP( ) Function
CURSORSETPROP( ) Function
CURSORTOXML( ) Function
CURVAL( ) Function
DATE( ) Function
DATETIME( ) Function
DAY( ) Function
DBC( ) Function
DBF( ) Function
DBGETPROP( ) Function
DBSETPROP( ) Function
DBUSED( ) Function
DDE Functions
DDEAbortTrans( ) Function
DDEAdvise( ) Function
DDEEnabled( ) Function
DDEExecute( ) Function
DDEInitiate( ) Function
DDELastError( ) Function
DDEPoke( ) Function
DDERequest( ) Function
DDESetOption( ) Function
DDESetService( ) Function
DDESetTopic( ) Function
DDETerminate( ) Function
DEFAULTEXT( ) Function
DELETED( ) Function
DESCENDING( ) Function
DIFFERENCE( ) Function
DIRECTORY( ) Function
DISKSPACE( ) Function
DisplayPath( ) Function
DMY( ) Function
DODEFAULT( ) Function
DOW( ) Function
DRIVETYPE( ) Function
DROPOFFLINE( ) Function
DTOC( ) Function
DTOR( ) Function
DTOS( ) Function
DTOT( ) Function
EDITSOURCE( ) Function
EMPTY( ) Function
EOF( ) Function
ERROR( ) Function
EVALUATE( ) Function
EVENTHANDLER( ) Function
EVL( ) Function
EXECSCRIPT( ) Function
EXP( ) Function
FCHSIZE( ) Function
FCLOSE( ) Function
FCOUNT( ) Function
FCREATE( ) Function
FDATE( ) Function
FEOF( ) Function
FERROR( ) Function
FFLUSH( ) Function
FGETS( ) Function
FIELD( ) Function
FILE( ) Function
FILETOSTR( ) Function
FILTER( ) Function
FKLABEL( ) Function
FKMAX( ) Function
FLDLIST( ) Function
FLOCK( ) Function
FLOOR( ) Function
FONTMETRIC( ) Function
FOPEN( ) Function
FOR( ) Function
FORCEEXT( ) Function
FORCEPATH( ) Function
FOUND( ) Function
FPUTS( ) Function
FREAD( ) Function
FSEEK( ) Function
FSIZE( ) Function
FTIME( ) Function
FULLPATH( ) Function
FUNCTION Command
FV( ) Function
FWRITE( ) Function
GETAUTOINCVALUE( ) Function
GETBAR( ) Function
GETCOLOR( ) Function
GETCP( ) Function
GETDIR( ) Function
GETENV( ) Function
GETFILE( ) Function
GETFLDSTATE( ) Function
GETFONT( ) Function
GETINTERFACE( ) Function
GETNEXTMODIFIED( ) Function
GETOBJECT( ) Function
GETPAD( ) Function
GETPEM( ) Function
GETPICT( ) Function
GETPRINTER( ) Function
GETRESULTSET( ) Function
GETWORDCOUNT( ) Function
GETWORDNUM( ) Function
GETCURSORADAPTER( ) Function
GOMONTH( ) Function
HEADER( ) Function
HOME( ) Function
HOUR( ) Function
ICASE( ) Function
IDXCOLLATE( ) Function
IIF( ) Function
IMESTATUS( ) Function
INDBC( ) Function
INDEXSEEK( ) Function
INKEY( ) Function
INLIST( ) Function
INPUTBOX( ) Function
INSMODE( ) Function
INT( ) Function
ISALPHA( ) Function
ISBLANK( ) Function
ISCOLOR( ) Function
ISDIGIT( ) Function
ISEXCLUSIVE( ) Function
ISFLOCKED( ) Function
ISLEADBYTE( ) Function
ISLOWER( ) Function
ISMEMOFETCHED( ) Function
ISMOUSE( ) Function
ISNULL( ) Function
ISPEN( ) Function
ISREADONLY( ) Function
ISRLOCKED( ) Function
ISTRANSACTABLE( ) Function
ISUPPER( ) Function
JUSTDRIVE( ) Function
JUSTEXT( ) Function
JUSTFNAME( ) Function
JUSTPATH( ) Function
JUSTSTEM( ) Function
KEY( ) Function
KEYMATCH( ) Function
LASTKEY( ) Function
LEFT( ) Function
LEFTC( ) Function
LEN( ) Function
LENC( ) Function
LIKE( ) Function
LIKEC( ) Function
LINENO( ) Function
LOADPICTURE( ) Function
LOCFILE( ) Function
LOCK( ) Function
LOG( ) Function
LOG10( ) Function
LOOKUP( ) Function
LOWER( ) Function
LTRIM( ) Function
LUPDATE( ) Function
MAKETRANSACTABLE( ) Function
MAX( ) Function
MCOL( ) Function
MDOWN( ) Function
MDX( ) Function
MDY( ) Function
MEMLINES( ) Function
MEMORY( ) Function
MENU( ) Function
MESSAGE( ) Function
MESSAGEBOX( ) Function
MIN( ) Function
MINUTE( ) Function
MLINE( ) Function
MOD( ) Function
MONTH( ) Function
MRKBAR( ) Function
MRKPAD( ) Function
MROW( ) Function
MTON( ) Function
MWINDOW( ) Function
NDX( ) Function
NEWOBJECT( ) Function
NORMALIZE( ) Function
NTOM( ) Function
NUMLOCK( ) Function
NVL( ) Function
OBJNUM( ) Function
OBJTOCLIENT( ) Function
OBJVAR( ) Function
OCCURS( ) Function
OEMTOANSI( ) Function
OLDVAL( ) Function
ON( ) Function
ORDER( ) Function
OS( ) Function
PAD( ) Function
PADL( ) | PADR( ) | PADC( ) Functions
PARAMETERS( ) Function
PAYMENT( ) Function
PCOL( ) Function
PCOUNT( ) Function
PEMSTATUS( ) Function
PI( ) Function
POPUP( ) Function
PRIMARY( ) Function
PRINTSTATUS( ) Function
PRMBAR( ) Function
PRMPAD( ) Function
PROGRAM( ) Function
PROMPT( ) Function
PROPER( ) Function
PROW( ) Function
PRTINFO( ) Function
PUTFILE( ) Function
PV( ) Function
QUARTER( ) Function
RAISEEVENT( ) Function
RAND( ) Function
RAT( ) Function
RATC( ) Function
RATLINE( ) Function
RDLEVEL( ) Function
READKEY( ) Function
RECCOUNT( ) Function
RECNO( ) Function
RECSIZE( ) Function
REFRESH( ) Function
RELATION( ) Function
REPLICATE( ) Function
REQUERY( ) Function
RGB( ) Function
RGBSCHEME( ) Function
RIGHT( ) Function
RIGHTC( ) Function
RLOCK( ) Function
ROUND( ) Function
ROW( ) Function
RTOD( ) Function
RTRIM( ) Function
SAVEPICTURE( ) Function
SCHEME( ) Function
SCOLS( ) Function
SEC( ) Function
SECONDS( ) Function
SEEK( ) Function
SELECT( ) Function
SET( ) Function
SETFLDSTATE( ) Function
SETRESULTSET( ) Function
SIGN( ) Function
SIN( ) Function
SKPBAR( ) Function
SKPPAD( ) Function
SOUNDEX( ) Function
SPACE( ) Function
SQLCANCEL( ) Function
SQLCOLUMNS( ) Function
SQLCOMMIT( ) Function
SQLCONNECT( ) Function
SQLDISCONNECT( ) Function
SQLEXEC( ) Function
SQLGETPROP( ) Function
SQLIDLEDISCONNECT( ) Function
SQLMORERESULTS( ) Function
SQLPREPARE( ) Function
SQLROLLBACK( ) Function
SQLSETPROP( ) Function
SQLSTRINGCONNECT( ) Function
SQLTABLES( ) Function
SQRT( ) Function
SROWS( ) Function
STR( ) Function
STRCONV( ) Function
STREXTRACT( ) Function
STRTOFILE( ) Function
STRTRAN( ) Function
STUFF( ) Function
STUFFC( ) Function
SUBSTR( ) Function
SUBSTRC( ) Function
SYS( ) Functions Overview
SYSMETRIC( ) Function
TABLEREVERT( ) Function
TABLEUPDATE( ) Function
TAG( ) Function
TAGCOUNT( ) Function
TAGNO( ) Function
TAN( ) Function
TARGET( ) Function
TEXTMERGE( ) Function
TIME( ) Function
TRANSFORM( ) Function
TRIM( ) Function
TTOC( ) Function
TTOD( ) Function
TXNLEVEL( ) Function
TXTWIDTH( ) Function
TYPE( ) Function
UNBINDEVENTS( ) Function
UNIQUE( ) Function
UPDATED( ) Function
UPPER( ) Function
USED( ) Function
VAL( ) Function
VARREAD( ) Function
VARTYPE( ) Function
VERSION( ) Function
WBORDER( ) Function
WCHILD( ) Function
WCOLS( ) Function
WDOCKABLE( ) Function
WEEK( ) Function
WEXIST( ) Function
WFONT( ) Function
WLAST( ) Function
WLCOL( ) Function
WLROW( ) Function
WMAXIMUM( ) Function
WMINIMUM( ) Function
WONTOP( ) Function
WOUTPUT( ) Function
WPARENT( ) Function
WREAD( ) Function
WROWS( ) Function
WTITLE( ) Function
WVISIBLE( ) Function
XMLTOCURSOR( ) Function
XMLUPDATEGRAM( ) Function
YEAR( ) Function
& Command
&& Command
* Command
= Command
? | ?? Command
??? Command
@ ... BOX Command
@ ... CLASS Command
@ ... CLEAR Command
@ ... EDIT - Edit Boxes Command
@ ... FILL Command
@ ... GET - Check Boxes Command
@ ... GET - Combo Boxes Command
@ ... GET - Command Buttons Command
@ ... GET - List Boxes Command
@ ... GET - Option Buttons Command
@ ... GET - Spinners Command
@ ... GET - Text Boxes Command
@ ... GET - Transparent Buttons Command
@ ... MENU Command
@ ... PROMPT Command
@ ... SAY - Pictures & OLE Objects Command
@ ... SAY Command
@ ... SCROLL Command
@ ... TO Command
\ | \\ Command
ACTIVATE MENU Command
ACTIVATE POPUP Command
ACTIVATE SCREEN Command
ACTIVATE WINDOW Command
ADD CLASS Command
ADD TABLE Command
ALTER TABLE - SQL Command
APPEND Command
APPEND FROM ARRAY Command
APPEND FROM Command
APPEND GENERAL Command
APPEND MEMO Command
APPEND PROCEDURES Command
ASSERT Command
ASSIST Command
AVERAGE Command
BEGIN TRANSACTION Command
BLANK Command
BROWSE Command
BUILD APP Command
BUILD DLL Command
BUILD EXE Command
BUILD MTDLL Command
BUILD PROJECT Command
CALCULATE Command
CALL Command
CANCEL Command
CD | CHDIR Command
CHANGE Command
CLEAR Commands
CLOSE Commands
CLOSE MEMO Command
COMPILE Command
CONTINUE Command
COPY FILE Command
COPY INDEXES Command
COPY MEMO Command
COPY PROCEDURES Command
COPY STRUCTURE Command
COPY STRUCTURE EXTENDED Command
COPY TAG Command
COPY TO ARRAY Command
COPY TO Command
COUNT Command
CREATE CLASS Command
CREATE CLASSLIB Command
CREATE COLOR SET Command
CREATE Command
CREATE CONNECTION Command
CREATE CURSOR - SQL Command
CREATE DATABASE Command
CREATE FORM Command
CREATE FROM Command
CREATE LABEL Command
CREATE MENU Command
CREATE PROJECT Command
CREATE QUERY Command
CREATE REPORT - Quick Report Command
CREATE REPORT Command
CREATE SCREEN - Quick Screen Command
CREATE SCREEN Command
CREATE SQL VIEW Command
CREATE TABLE - SQL Command
CREATE TRIGGER Command
CREATE VIEW Command
DEACTIVATE MENU Command
DEACTIVATE POPUP Command
DEACTIVATE WINDOW Command
DEBUG Command
DEBUGOUT Command
DECLARE - DLL Command
DECLARE Command
DEFINE BAR Command
DEFINE BOX Command
DEFINE CLASS Command
DEFINE MENU Command
DEFINE PAD Command
DEFINE POPUP Command
DEFINE WINDOW Command
DELETE - SQL Command
DELETE Command
DELETE CONNECTION Command
DELETE DATABASE Command
DELETE FILE Command
DELETE TAG Command
DELETE TRIGGER Command
DELETE VIEW Command
DIMENSION Command
DIR or DIRECTORY Command
DISPLAY Command
DISPLAY CONNECTIONS Command
DISPLAY DATABASE Command
DISPLAY DLLS Command
DISPLAY FILES Command
DISPLAY MEMORY Command
DISPLAY OBJECTS Command
DISPLAY PROCEDURES Command
DISPLAY STATUS Command
DISPLAY STRUCTURE Command
DISPLAY TABLES Command
DISPLAY VIEWS Command
DO CASE ... ENDCASE Command
DO Command
DO FORM Command
DO WHILE ... ENDDO Command
DOCK Command
DOEVENTS Command
DROP TABLE Command
DROP VIEW Command
EDIT Command
EJECT Command
EJECT PAGE Command
END TRANSACTION Command
ERASE Command
ERROR Command
EXIT Command
EXPORT Command
EXTERNAL Command
FIND Command (Visual FoxPro)
FLUSH Command
FOR EACH ... ENDFOR Command
FOR ... ENDFOR Command
FREE TABLE Command
FUNCTION Command
GATHER Command
GETEXPR Command
GO | GOTO Command
HELP Command
HIDE MENU Command
HIDE POPUP Command
HIDE WINDOW Command
IF ... ENDIF Command
IMPORT Command
INDEX Command
INPUT Command
INSERT - SQL Command
INSERT Command
JOIN Command
KEYBOARD Command
LABEL Command
LIST Commands
LIST CONNECTIONS Command
LIST DATABASE Command
LIST DLLS Command
LIST OBJECTS Command
LIST PROCEDURES Command
LIST TABLES Command
LIST VIEWS Command
LOAD Command
LOCAL Command
LOCATE Command
LOOP Command
LPARAMETERS Command
MD | MKDIR Command
MENU Command
MENU TO Command
MODIFY CLASS Command
MODIFY COMMAND Command
MODIFY CONNECTION Command
MODIFY DATABASE Command
MODIFY FILE Command
MODIFY FORM Command
MODIFY GENERAL Command
MODIFY LABEL Command
MODIFY MEMO Command
MODIFY MENU Command
MODIFY PROCEDURE Command
MODIFY PROJECT Command
MODIFY QUERY Command
MODIFY REPORT Command
MODIFY SCREEN Command
MODIFY STRUCTURE Command
MODIFY VIEW Command
MODIFY WINDOW Command
MOUSE Command
MOVE POPUP Command
MOVE WINDOW Command
NOTE Command
ON BAR Command
ON ERROR Command
ON ESCAPE Command
ON EXIT BAR Command
ON EXIT MENU Command
ON EXIT PAD Command
ON EXIT POPUP Command
ON KEY = Command
ON KEY Command
ON KEY LABEL Command
ON PAD Command
ON PAGE Command
ON READERROR Command
ON SELECTION BAR Command
ON SELECTION MENU Command
ON SELECTION PAD Command
ON SELECTION POPUP Command
ON SHUTDOWN Command
OPEN DATABASE Command
PACK Command
PACK DATABASE Command
PARAMETERS Command
PLAY MACRO Command
POP KEY Command
POP MENU Command
POP POPUP Command
PRINTJOB ... ENDPRINTJOB Command
PRIVATE Command
PROCEDURE Command
PUBLIC Command
PUSH KEY Command
PUSH MENU Command
PUSH POPUP Command
QUIT Command
RD | RMDIR Command
READ Command
READ EVENTS Command
READ MENU Command
RECALL Command
REINDEX Command
RELEASE BAR Command
RELEASE CLASSLIB Command
RELEASE Command
RELEASE LIBRARY Command
RELEASE MENUS Command
RELEASE PAD Command
RELEASE POPUPS Command
RELEASE PROCEDURE Command
RELEASE WINDOWS Command
REMOVE CLASS Command
REMOVE TABLE Command
RENAME CLASS Command
RENAME Command
RENAME CONNECTION Command
RENAME TABLE Command
RENAME VIEW Command
REPLACE Command (Visual FoxPro)
REPLACE FROM ARRAY Command
REPORT FORM Command
RESTORE FROM Command
RESTORE MACROS Command
RESTORE SCREEN Command
RESTORE WINDOW Command
RESUME Command
RETRY Command
RETURN Command
ROLLBACK Command
RUN | ! Command
SAVE MACROS Command
SAVE SCREEN Command
SAVE TO Command
SAVE WINDOWS Command
SCAN ... ENDSCAN Command
SCATTER Command
SCROLL Command
SEEK Command
SELECT - SQL Command
SELECT Command
SET ALTERNATE Command
SET ANSI Command
SET ASSERTS Command
SET AUTOINCERROR Command
SET AUTOSAVE Command
SET BELL Command
SET BLOCKSIZE Command
SET BORDER Command
SET BROWSEIME Command
SET BRSTATUS Command
SET CARRY Command
SET CENTURY Command
SET CLASSLIB Command
SET CLEAR Command
SET CLOCK Command
SET COLLATE Command
SET COLOR OF Command
SET COLOR OF SCHEME Command
SET COLOR SET Command
SET COLOR TO Command
SET Command Overview
SET COMPATIBLE Command
SET CONFIRM Command
SET CONSOLE Command
SET COVERAGE Command
SET CPCOMPILE Command
SET CPDIALOG Command
SET CURRENCY Command
SET CURSOR Command
SET DATABASE Command
SET DATASESSION Command
SET DATE Command
SET DEBUG Command
SET DEBUGOUT Command
SET DECIMALS Command
SET DEFAULT Command
SET DELETED Command
SET DELIMITERS Command
SET DEVELOPMENT Command
SET DEVICE Command
SET DISPLAY Command
SET DOHISTORY Command
SET ECHO Command
SET ENGINEBEHAVIOR Command
SET ESCAPE Command
SET EVENTLIST Command
SET EVENTTRACKING Command
SET EXACT Command
SET EXCLUSIVE Command
SET FDOW Command
SET FIELDS Command
SET FILTER Command
SET FIXED Command
SET FORMAT Command
SET FULLPATH Command
SET FUNCTION Command
SET FWEEK Command
SET HEADINGS Command
SET HELP Command
SET HOURS Command
SET INDEX Command
SET INTENSITY Command
SET KEY Command
SET KEYCOMP Command
SET LIBRARY Command
SET LOCK Command
SET LOGERRORS Command
SET MACKEY Command
SET MARGIN Command
SET MARK OF Command
SET MARK TO Command
SET MEMOWIDTH Command
SET MESSAGE Command
SET MULTILOCKS Command
SET NEAR Command
SET NOCPTRANS Command
SET NOTIFY Command
SET NULL Command
SET NULLDISPLAY Command
SET ODOMETER Command
SET OLEOBJECT Command
SET OPTIMIZE Command
SET ORDER Command
SET PALETTE Command
SET PATH Command
SET PDSETUP Command
SET POINT Command
SET PRINTER Command
SET PROCEDURE Command
SET READBORDER Command
SET REFRESH Command
SET RELATION Command
SET RELATION OFF Command
SET REPROCESS Command
SET RESOURCE Command
SET SAFETY Command
SET SECONDS Command
SET SEPARATOR Command
SET SKIP Command
SET SKIP OF Command
SET SPACE Command
SET STATUS BAR Command
SET STATUS Command
SET STEP Command
SET STRICTDATE Command
SET SYSFORMATS Command
SET SYSMENU Command
SET TABLEVALIDATE Command
SET TALK Command
SET TEXTMERGE Command
SET TEXTMERGE DELIMITERS Command
SET TOPIC Command
SET TOPIC ID Command
SET TRBETWEEN Command
SET TYPEAHEAD Command
SET UDFPARMS Command
SET UNIQUE Command
SET VIEW Command
SET WINDOW OF MEMO Command
SHOW GET Command
SHOW GETS Command
SHOW MENU Command
SHOW OBJECT Command
SHOW POPUP Command
SHOW WINDOW Command
SIZE POPUP Command
SIZE WINDOW Command
SKIP Command
SORT Command
STORE Command
SUM Command
SUSPEND Command
SYS(2001) - SET ... Command Status
TEXT ... ENDTEXT Command
TOTAL Command
TRY...CATCH...FINALLY Command
TYPE Command
UNLOCK Command
UPDATE - SQL Command
UPDATE Command
USE Command
VALIDATE DATABASE Command
WAIT Command
WITH ... ENDWITH Command
ZAP Command
ZOOM WINDOW Command
#DEFINE ... #UNDEF Preprocessor Directive
#IF ... #ENDIF Preprocessor Directive
#IFDEF | #IFNDEF ... #ENDIF Preprocessor Directive
#INCLUDE Preprocessor Directive
#INSERT Preprocessor Directive
#NAME Preprocessor Directive
ENDTEXT
* Don't use empty line insides Text/Endtext


return(lc_vfp)


