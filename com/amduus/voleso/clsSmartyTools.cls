/**************************************************************************/
/*                                                                        */ 
/*           .-.------------------------------------------.-.             */
/*          ((o))                                            )            */
/*           \U/_______          _____         ______   ____/             */
/*             |                                           |              */
/*             |         #####   #####  ######             |              */
/*             |         #     # #     # #     #           |              */
/*             |         #     # #       #     #           |              */
/*             |         ######   #####  #     #           |              */
/*             |         #     #       # #     #           |              */
/*             |         #     # #     # #     #           |              */
/*             |         ######   #####  ######            |              */
/*             |                                           |              */
/*             |                                           |              */
/*             |                                           |              */
/*             |____    _______    __  ____    _   ___   __|KCK/SGA       */
/*            /A\                                           \             */
/*           ((o))                                           )            */
/*            '-'-------------------------------------------'             */
/*                                                                        */
/*                                                                        */
/* Copyright 2012, Amduus Information Works, Inc., Scott Auge             */
/* All rights reserved.                                                   */
/*                                                                        */
/* Redistribution and use in source and binary forms, with or without     */
/* modification, are permitted provided that the following conditions are */
/* met:                                                                   */
/*                                                                        */
/*   - Redistributions of source code must retain the above copyright     */
/*     notice, this list of conditions and the following disclaimer.      */
/*   - Redistributions in binary form must reproduce the above copyright  */
/*     notice, this list of conditions and the following disclaimer in    */
/*     the documentation and/or other materials provided with the         */
/*     distribution.                                                      */
/*   - Neither the name of the Amduus Information Works, Inc. nor the     */
/*     names of its contributors may be used to endorse or promote        */
/*     products derived from this software without specific prior written */
/*     permission.                                                        */
/*                                                                        */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    */
/* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      */
/* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  */
/* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   */
/* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, */
/* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       */
/* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  */
/* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  */
/* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    */
/* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  */
/* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   */
/*                                                                        */ 
/**************************************************************************/ 

/**************************************************************************/
/*                                                                        */
/*   ________                                                             */
/*   ()_______)                                                           */
/*    \:::::::\        Make your mark on open source, let people know     */
/*     \:::::::\       what you can do, profit on reputation.             */
/*     @:::::::/                                                          */
/*      ~~~~~~~                                                           */
/* ---------------------------------------------------------------------- */
/*  Scott Auge sauge@amduus.com scott_auge@yahoo.com                      */
/*  Amduus Information Works, Inc.                                        */
/*  http://www.amduus.com                                                 */
/*                                                                        */
/*  Initial development                                                   */
/*                                                                        */
/* ---------------------------------------------------------------------- */
/*                                                                        */
/**************************************************************************/




/* Tools to aid with Smarty templates.  A lot of times, things are written */
/* in E4GL with the HTML embedded.  Now there is code that uses the HTML   */
/* as a template.  This can aid in handling those changes.                 */

/* With script lab, see unit test code */

/* $Id: clsSmartyTools.cls 61 2011-10-06 06:57:54Z scott_auge $ */
/* $URL: file:///users/scott_auge/svn_rc/repos/trunk/com/amduus/voleso/clsSmartyTools.cls $ */

class com.amduus.voleso.clsSmartyTools:

  define variable CRLF as character no-undo.
  
  constructor clsSmartyTools ():
  
    CRLF = chr(13) + chr(10). /* Most editors on UNIX and Windows know what to do with this */
    
  end. /* constructor */

  /************************************************************************************/
  /* Take a file, read it, convert, and write out                                     */
  /************************************************************************************/
    
  method public longchar FileToABL (input FileName as character, input VarName as character):
  
    define variable HTML as longchar no-undo.
    
    copy-lob from file FileName to HTML.
    
    return ToABL(VarName, HTML).
    
  end. /* method FileToABL */
 
  /************************************************************************************/
  /* This tool takes e4gl code and converts to an computable expression.  It is meant */
  /* for pure HTML with `` entries.  Be careful, easy to blow your code line limit.   */
  /* TODO: When ` at end of line, + shows up, so be careful.                          */
  /************************************************************************************/
  
  method public longchar ToABL(input VarName as character, input HTML as longchar):
  
    define variable WorkingHTML as longchar no-undo.
    
    WorkingHTML = HTML.
    
    /* Convert OS's EOL to internal representation */
    
    WorkingHTML = ToABLEOL(WorkingHTML).
    
    /* The following is meant to quote the entire HTML portion and make it a string */
    
    WorkingHTML = replace (WorkingHTML, "~"", "~~~"").  /* Replace " with ~" for use in computaable */
    WorkingHTML = replace (WorkingHTML, "~'", "~~~'").  /* Replace ' with ~' for use in computable */
    
    /* Put a " at the beginning of all lines */
    
    WorkingHTML = "~"" + WorkingHTML.
    WorkingHTML = replace (WorkingHTML, "~n", "~n~"").
    
    /* Put a " + at the end of all lines */
    
    WorkingHTML = replace (WorkingHTML, "~n", "~" +~n").
    WorkingHTML = WorkingHTML + "~"".
  
    /* E4GL ` */
    
    WorkingHTML = E4GLBackTicToABL(WorkingHTML).
    
    /* Add the variable name and assignment */
    
    WorkingHTML = Varname + " = ~n" + WorkingHTML + ".".        
    
    return WorkingHTML.
  
  end. /* method ToABL */
  
  /************************************************************************************/
  /* Switching ` to " + or + " in HTML                                                */
  /* This technique is painful in ABL compared to C but works                         */
  /************************************************************************************/
  
  method public longchar E4GLBackTicToABL (input H as longchar):
  
    define variable C as character no-undo.
    define variable WorkingH as longchar no-undo.
    define variable SizeOf as integer no-undo.
    define variable Offset as integer no-undo.
    define variable IsOpenTic as logical no-undo.
    
    SizeOf = length (H).
    IsOpenTic = false.
    
    do Offset = 1 TO SizeOf:
      
      C = substring (H, Offset, 1).
      
      if C <> "`" then do:
        WorkingH = WorkingH + C.
        next.
      end.
      
      if IsOpenTic then do:
        IsOpenTic = false.
        WorkingH = WorkingH + " + ~"".
        next.
      end.
      
      IsOpenTic = true.
      WorkingH = WorkingH + "~" + ".
      
    end. /* do */
  
    return WorkingH.
    
  end. /* method E4GLBackTicToABL */
  
  /************************************************************************************/
  /* Editing files on different machines sometimes end up with screwy eol. Clean up   */
  /* to what ever Progress is running on.                                             */
  /************************************************************************************/
  
  method public longchar ToABLEOL (input H as longchar):
  
    define variable CRLF as character no-undo.
    define variable LF as character no-undo.
    define variable CR as character no-undo.
    
    CR = CHR(13).
    LF = CHR(10).
    CRLF = CR + LF.
    
    /* Windows? */
    
    if index (H,CRLF) > 0 then return replace (H, CRLF, "~n").
      
    /* UNIX and OSX v10+?*/
 
     return replace (H, LF, "~n").
  
  end. /* method ToABLEOL */
  
  
  /************************************************************************************/
  /* FindAssignVar for use with webspeed Scripting Lab                                */
  /* Need random string file name for multi-users!                                    */
  /************************************************************************************/

   method public character FindAssignVar (input InputFileName as character,
                                          input Prefix as character):
                                    
     define variable OutputText as character no-undo.
     define variable LCOutputText as longchar no-undo.
     define variable TempFile as character no-undo.
     
     TempFile = if OPSYS = "UNIX" then "/tmp/findassign.txt" else "c:\tmp\findassign.txt".
     
     FindAssignVar (input InputFileName,
                    input TempFile,
                    input Prefix).
                    
     copy-lob from file TempFile to LCOutputText.
     
     OutputText = LCOutputText.
     
     return OutputText.
     
   end. /* method FindAssignVar () */        
  
  /************************************************************************************/
  /* Within HTML, there is often a {$ .. } and ` ... ` that show substitution points. */
  /* This code automatically finds them and creates a file for cutting and pasting    */
  /* from with prefix:assignvar() calls to speed creating such things in complex      */
  /* HTML.                                                                            */
  /************************************************************************************/
  
  method public void FindAssignVar (input InputFileName as character,
                                    input OutputFileName as character, 
                                    input Prefix as character):
                                    
    define variable FileContents as longchar no-undo.
    define variable ABLText as longchar no-undo.
    
    define variable QuoteStartOffset as integer no-undo.
    define variable QuoteEndOffset as integer init 0 no-undo.
    
    define variable VariableName as character no-undo.
    
    copy-lob from file InputFileName to FileContents.
    
    /* Warn this is automated code */
    
    ABLText = "/* Generated by " + program-name(1) + " from file " + InputFileName + " */" + CRLF + CRLF.
    
    /* Go through looking for `` delimited items */
    
    do while true:
    
      QuoteStartOffset = index (FileContents, "`", QuoteEndOffset + 1).
    
      if QuoteStartOffset = 0 then leave. /* Nothing left to find */
        
      QuoteEndOffset = index (FileContents, "`", QuoteStartOffset + 1).
    
      if QuoteEndOffset = 0 then leave. /* Shouldn't happen in good quotes */

      VariableName = substring (FileContents, QuoteStartOffset + 1, QuoteEndOffset - QuoteStartOffset - 1).
      
      ABLText = ABLText + CRLF
              + Prefix + ":AssignVar (~"" + VariableName + "~", " + VariableName + ")."
              .
                
    
    end. /* do while loop */
    
    /* Go through looking for {$ .. } delimited items */
    
    do while true:
    
      QuoteStartOffset = index (FileContents, "~{$", QuoteEndOffset + 2).
    
      if QuoteStartOffset = 0 then leave. /* Nothing left to find */
        
      QuoteEndOffset = index (FileContents, "~}", QuoteStartOffset + 1).
    
      if QuoteEndOffset = 0 then leave. /* Shouldn't happen in good quotes */

      VariableName = substring (FileContents, QuoteStartOffset + 2, QuoteEndOffset - QuoteStartOffset - 2).
    
      ABLText = ABLText + CRLF
              + Prefix + ":AssignVar (~"" +  VariableName + "~", " + VariableName + ")."
              .
                
    
    end. /* do while loop */
    
    /* Send it out */
    
    copy-lob from ABLText to file OutputFileName.
                                    
  end. /* method FindAssignVar */                                    
  

end. /* class clsSmartyTools */






/******** UNIT TEST CODE

/* Use of the tools in the webspeed scripting lab */

def var a as class oas.template.clsSmartyTools no-undo.

a = new oas.template.clsSmartyTools().

{&OUT} "<pre>".
{&OUT} html-encode(string(a:FileToABL("c:/tmp/test.html", "Var"))).
{&OUT} "</pre>".

delete object a.



/* Test FindAssignVar - to disk */


def var a as class com.amduus.voleso.clsSmartyTools no-undo.

a = new com.amduus.voleso.clsSmartyTools().

a:FindAssignVar ("c:\tmp\t\olshistoD.htm", "c:\tmp\t\olshistoD.vars.htm", "S"). 


delete object a.

/* Test FindAssignVar - to script lab */


def var a as class com.amduus.voleso.clsSmartyTools no-undo.
def var ProgrammingText as character no-undo.

a = new com.amduus.voleso.clsSmartyTools().

ProgrammingText = a:FindAssignVar ("c:\tmp\t\olshistoD.htm", "S"). 

{&OUT} "<pre>" ProgrammingText "</pre>".

delete object a.

*************************/

