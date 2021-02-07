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
/* Copyright 2012,2020,2021 Amduus Information Works, Inc., Scott Auge         */
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
/* 2020-12      sauge   Added HTMLRender to a file                        */
/**************************************************************************/


/* $Id: clsVoleso.cls 126 2012-12-20 09:36:10Z scott_auge $ */
/* $URL: file:///users/scott_auge/svn_rc/repos/trunk/com/amduus/voleso/clsVoleso.cls $ */

/*  
TODO: Error handling on non-existant file on constructor
TODO: literal cuz { used in javascript too
*/

class com.amduus.voleso.clsVoleso:

  /* Define the goods in a longchar because HTML pages can be large - especially with */
  /* inserted web pages (due in an update.)                                           */
  
  define public variable HTMLTemplate as longchar no-undo.
  define public variable ShowComments as logical no-undo.
  define public variable ShowTemplateErrors as logical init FALSE no-undo.
  
  define public variable OriginalTemplate as longchar no-undo.
   
  /***********************************************************************************/  
  /* Object should be created with the template file name for which template to work */
  /* with.  Unlike Voleso, we cannot :display(templatefile) because we have no means */
  /* of saving values that are longchar.  So we the Reset() and constructor need the */
  /* file name and we start manipulating as things go on.                            */
  /***********************************************************************************/
  
  constructor public clsVoleso (input TemplateFile as character):
  
    copy-lob from file TemplateFile to HTMLTemplate.
    RemoveSmartyComments().
    OriginalTemplate = HTMLTemplate.    
    
  end. /* constructor */
  
  constructor public clsVoleso (input HTML as longchar):
  
    HTMLTemplate = HTML.
    RemoveSmartyComments().
    OriginalTemplate = HTMLTemplate.    
    
  end. /* constructor */

  /***********************************************************************************/
  /* Once all the variables have been set, this should be called to insert the       */
  /* values and remove comments, etc.                                                */
  /***********************************************************************************/
  
  method public logical FinalProcess():

    DeleteRemainingSections().
    
  end. /* method Process */
  
  /***********************************************************************************/
  /* This is the Voleso->assign() function - however in ABL ASSIGN is a reserved     */
  /* word.                                                                           */
  /* It would be nice if this were a temp table and then we could repeat, but no     */
  /* longchar allowed as a field type in temp tables.                                */
  /***********************************************************************************/
  
  method public logical AssignVar(input Varname as character, input VarValue as longchar):  

    HTMLTemplate = replace (HTMLTemplate, "~{$" + VarName + "~}", VarValue).
    HTMLTemplate = replace (HTMLTemplate, "`" + VarName + "`", VarValue).
    
    return true.
    
  end. /* method AssignVar (character, longchar) */
  
  method public logical AssignVar(input Varname as character, input VarValue as logical):  

    AssignVar(VarName, Logical2String(VarValue)).
    
    return true.
    
  end. /* method AssignVar (character, logical) */  
  
  method public logical AssignVar(input Varname as character, input VarValue as character, input Formatting as character):  

    AssignVar(VarName, string(VarValue, Formatting)).
    
    return true.
    
  end. /* method AssignVar (character, int) */  
  
  method public logical AssignVar(input Varname as character, input VarValue as integer):  

    AssignVar(VarName, string(VarValue)).
    
    return true.
    
  end. /* method AssignVar (character, int) */
  
  method public logical AssignVar(input Varname as character, input VarValue as integer, input Formatting as character):  

    AssignVar(VarName, string(VarValue, Formatting)).
    
    return true.
    
  end. /* method AssignVar (character, integer, formatting) */    
  
  method public logical AssignVar(input Varname as character, input VarValue as date):  

    AssignVar(VarName, string(VarValue)).
    
    return true.
    
  end. /* method AssignVar (character, date) */  
  
  method public logical AssignVar(input Varname as character, input VarValue as date, input Formatting as character):  

    AssignVar(VarName, string(VarValue, Formatting)).
    
    return true.
    
  end. /* method AssignVar (character, date, formatting) */  
  
  method public logical AssignVar(input Varname as character, input VarValue as decimal):  

    AssignVar(VarName, string(VarValue)).
    
    return true.
    
  end. /* method AssignVar (character, decimal) */    
  
  method public logical AssignVar(input Varname as character, input VarValue as decimal, input Formatting as character):  

    AssignVar(VarName, string(VarValue, Formatting)).
    
    return true.
    
  end. /* method AssignVar (character, decimal, formatting) */   
  

  /***********************************************************************************/
  /* Call out to the .p file that can use {&OUT} and spit out the revised HTML.      */
  /* {&OUT} is a shared stream which as of 102b is not useable within a class.       */
  /* This is Voleso->display() but of course, display is a reserved keyword in ABL.  */
  /***********************************************************************************/
 
   
  method public logical HTMLRender(input Destination as character):

    /* Call out to automatic variables that might be out there */
    
    FinalProcess().

    /* Spit it out to a file */

   copy-lob HTMLTemplate to file Destination.

  end. // 

  // How to render to webspeed
  // AnObject:HTMLRender(stream webstream:handle)

  method public logical HTMLRender(input Destination as handle):
    
    define variable SizeOf as integer no-undo.
    define variable Offset as integer no-undo.
    define variable ChunkSize as integer init 14000 no-undo.
    define variable Chunk as character no-undo.
    
    /* Call out to automatic variables that might be out there */
    
    FinalProcess().
    
    /* Spit it out! */
    
    SizeOf = length(HTMLTemplate).
    
    /* If HTML is less than ChunkSize, then we can simply convert to string and put */
    
    if SizeOf < ChunkSize then do:
      put stream-handle Destination unformatted string(HTMLTemplate).
      return true.
    end. /* if SizeOf ... */
    
    /* Otherwise we need to chunk up the longchar into char via ChunkSize and put */
    /* that way.                                                                  */
    
    Offset = 1.
    do while Offset < SizeOf:
      
      Chunk = substring (HTMLTemplate, Offset, ChunkSize).
      put stream-handle Destination unformatted Chunk.
      Offset = Offset + ChunkSize.
      
    end. /* do while */
    
    return true.
    
    /* This is old school.  With 10.2B one can do handles
    run oas/template/toweb.p (HTMLTemplate).
    */
    
  end. /* method Render */
  
  /***********************************************************************************/
  /* Re-use the object with another set of variables and HTML template file.         */
  /***********************************************************************************/
  
  method public logical Reset(input TemplateFile as character):

    copy-lob from file TemplateFile to HTMLTemplate.
    RemoveSmartyComments().
    OriginalTemplate = HTMLTemplate.
  
  end. /* method Reset */
  
  method public logical Reset(input HTML as longchar):

    HTMLTemplate = HTML.
    RemoveSmartyComments().
    OriginalTemplate = HTMLTemplate.
  
  end. /* method Reset */  
  
  /***********************************************************************************/
  /* Voleso comments are {* through *}. This removes these as they don't go out.     */
  /* We could use ExtractSection and ReplaceSection, but these comment sections are  */
  /* pretty straight forward.                                                        */
  /***********************************************************************************/
  
  method private logical RemoveSmartyComments():
  
    define variable TheSection as longchar no-undo.
    define variable NewHTML as longchar no-undo.
    define variable FirstDelimiter as integer no-undo.
    define variable LastDelimiter as integer no-undo.
    
    FirstDelimiter = index(HTMLTemplate, "~{~*").
    do while FirstDelimiter > 0:
      LastDelimiter = index (HTMLTemplate, "~*~}").
      TheSection = substring (HTMLTemplate, FirstDelimiter, LastDelimiter + 2 - FirstDelimiter).
      if TheSection <> "" then
        HTMLTemplate = replace (HTMLTemplate, TheSection, "").
      FirstDelimiter = index(HTMLTemplate, "~{*").
    end. /* do while FirstDelimiter > 0 */
    
    return true.
  
  end. /* method RemoveVolesoComments */
  
  /***********************************************************************************/
  /* After extracting a section like a foreach, this provides a means of removing    */
  /* the Voleso markup.                                                              */
  /* NOTE: We assume anything in { and } is Voleso template markup.                  */
  /***********************************************************************************/
  
  method public longchar RemoveSmartyMarkup (input HTML as longchar):
  
    define variable T as longchar no-undo.
    
    do while index (HTML, "~{") > 0:
      
      T = ExtractSection ("~{", "~}").
      ReplaceSection (HTML, T, "").
      
    end. /* do */
  
    return HTML.
    
  end. /* method RemoveVolesoMarkup */
  
  /***********************************************************************************/
  /* Used for extracting things based on parameters.                                 */
  /* WARNING: THIS IS NOT FOR EMBEDDED GOODS - USE clsRawSectionYanker for sections  */
  /*          with embedded sections!                                                */
  /***********************************************************************************/
  
  method public longchar ExtractSection (input BeginningChars as longchar,
                                         input EndingChars as longchar):
                                         
    define variable StartOffset as integer no-undo.
    define variable EndOffset as integer no-undo.
    define variable T as longchar no-undo.
    define variable ErrorMessage as character no-undo.
    define variable IsASubSection as integer no-undo.
    
    StartOffset = index (HTMLTemplate, BeginningChars).
    
    /* If we have no offset, then nothing to really pull out of there! */
    
    if StartOffset = 0 then do:
      
      if not ShowTemplateErrors then return "".
      
      ErrorMessage = substring (BeginningChars, 40).
      
      message "clsVoleso:ExtractSection tried to find " ErrorMessage 
              " but did not!".
      return "".
      
    end. /* if StartOffset = 0 */
    
    T = substring (HTMLTemplate, StartOffset).
    EndOffset = index (T, EndingChars).

    return substring (T, 1, EndOffset + length(EndingChars)).
  
  end. /* method ExtractSection */                                                  
  
  /***********************************************************************************/
  /* Who knows what will happen with this in the future...                           */ 
  /***********************************************************************************/
  
  method public longchar ReplaceSection (input T as longchar,
                                         input OldSection as longchar,
                                         input NewSection as longchar):
    if OldSection <> "" then                                     
      return replace (T, OldSection, NewSection).                                         
    else
      return T.
                                         
  end. /* method ReplaceSection */                                        
  
  /***********************************************************************************/
  /* Pull out whatever is between the section tags.  This should not include the     */
  /* section tags, but might include other goods.                                    */
  /* TODO: Nested sections                                                           */
  /***********************************************************************************/
  
  method public longchar GetSection (input NameOfSection as character):
  
    define variable S as com.amduus.voleso.clsRawSectionYanker no-undo.
    define variable SectionText as longchar no-undo.
  
    
    S = new com.amduus.voleso.clsRawSectionYanker(HTMLTemplate).
    
    SectionText = S:YankSectionNoDelimiters (NameOfSection).
    
    delete object S.
    
    return SectionText.
    
  end. /* method GetSection */
  
  /***********************************************************************************/
  /* Set the section with whatever is in the replacement text.                       */
  /***********************************************************************************/
  
  method public longchar SetSection (input NameOfSection as character,
                                     input ReplacementHTML as longchar):
    
    define variable S as com.amduus.voleso.clsRawSectionYanker no-undo.
    define variable SectionText as longchar no-undo.
    
    S = new com.amduus.voleso.clsRawSectionYanker(HTMLTemplate).
    
    SectionText = S:YankSection(NameOfSection).
                 
    delete object S.
 
    /* Check if the section actually has anything to set */
    if SectionText <> "" then
      HTMLTemplate = replace (HTMLTemplate, SectionText, ReplacementHTML).
  
  end. /* method SetSection */
  
  /***********************************************************************************/
  /* When the class is an instance of a section, we tag on the original HTML to the  */
  /* HTML template so another "row" can be attached.                                 */
  /***********************************************************************************/
  
  method public logical NextSection ():
  
    HTMLTemplate = HTMLTemplate + OriginalTemplate.
    
    return true.
    
  end. /* method NextSection */
  
  /***********************************************************************************/
  /* I hate this, but seems to be needed done.  When looping with NextSection, if    */
  /* not watching LAST-OF or what have you, we end up with a section template on the */
  /* end.  This lets us take the section template off the back of the HTMLTemplate   */
  /* when we really don't need it anymore.                                           */
  /***********************************************************************************/
  
  method public logical FinishSection ():
  
    if OriginalTemplate <> "" then
      HTMLTemplate = replace(HTMLTemplate, OriginalTemplate, "").
  
    return true.
   
  end. /* method UnnextSection */
  
  /***********************************************************************************/
  /* Accept an instance of this class containing the replacement section goods.  Go  */
  /* and replace the section.                                                        */
  /***********************************************************************************/
  
  method public logical ApplySection (input SectionName as character, 
                                      input SectionObject as com.amduus.voleso.clsVoleso):
                                      
    SetSection (SectionName, SectionObject:HTMLTemplate).  
    
    return true.
                                      
  end. /* method ApplySection */                                      

  /***********************************************************************************/
  /* Handle the include entry.                                                       */
  /* Remember this may be recursive in some templates.  The class does not take care */
  /* of that.                                                                        */
  /***********************************************************************************/
  
  method public longchar IncludeFile (input NameOfInclude as character):
  
    define variable T as longchar no-undo.
    define variable S as longchar no-undo.
    
    copy-lob from file NameOfInclude TO T.
    
    S = ExtractSection ("~{include name=" + NameOfInclude, "~}"). /* Note the space */
    HTMLTemplate = ReplaceSection (HTMLTemplate, S, T).
    
  end. /* method IncludeFile */
  
  /***********************************************************************************/
  /* Automatically include files                                                     */
  /* Watch out for recursive loops!                                                  */
  /* This does NOT eliminate commenting!                                             */
  /***********************************************************************************/
  
  method public logical AutoIncludeFile ():
  
    define variable Offset as integer no-undo.
    define variable EndOffset as integer no-undo.
    define variable HTML as longchar no-undo.
    define variable EmbeddedFileName as character no-undo.
    
    Offset = index (HTMLTemplate, "~{include name="). /* Look for markup */
    
    do while Offset > 0:
      
      HTML = substring (HTMLTemplate, Offset). /* Find start */
      EndOffset = index (HTML, "~}").          /* Find end */
      HTML = substring (HTMLTemplate, Offset, EndOffset).
      
      EmbeddedFileName = replace (HTML, "~{include name=", "").
      EmbeddedFileName = replace (EmbeddedFileName, "~}", "").
      
      IncludeFile(EmbeddedFileName).
    
      Offset = index (HTMLTemplate, "~{include name="). /* Look for the next one! */
    
    end. /* do while */
  
    return true.
    
  end. /* method AutoIncludeFile */
  
  /***********************************************************************************/
  /* Delete a section from the output.                                               */
  /***********************************************************************************/
  
  method public logical DeleteSection (input SectionName as character):
  
    SetSection (SectionName, "").
    
    return true.
    
  end. /* method DeleteSection */
  
  /***********************************************************************************/
  /* Automatically search for section templates and delete them - should be called   */
  /* by HTMLRender() for template clean up?                                          */
  /***********************************************************************************/
	  
  method public logical DeleteRemainingSections ():
  
    define variable SectionName as character no-undo.
	define variable Offset as integer no-undo.
	define variable OffsetStop as integer no-undo.
	
    do while (true):
	
	  /* Determine if there is a section hanging about */
	  
	  Offset = index(HTMLTemplate, "~{section name=").
	  if Offset = 0 then leave.
	  
	  /* Determine it's name and call :DeleteSection */
	  /* If additional arguments added to section, will need to re-write this */
	  
	  Offset = Offset + 14.                            /* Number of chars in "{section name=" */
	  OffsetStop = index(HTMLTemplate, "}", Offset).   /* Find end of name marked by } */ 
	  if OffsetStop = 0 then leave.                    /* Badly formed section name? */
	  SectionName = trim(substring(HTMLTemplate, Offset, OffsetStop - Offset - 1)).
	  DeleteSection (SectionName).
	
	end. /* while */
  
    return true.
	
  end. /* DeleteRemainingSections */
  
  /***********************************************************************************/
  /* Show a section into the output (without the section tags!)                      */
  /***********************************************************************************/
  
  method public logical ShowSection (input SectionName as character):
  
    define variable S as longchar no-undo.
    
    S = GetSection (SectionName).
    SetSection (SectionName, S).
    
    return true.
    
  end. /* method ShowSection */
  
  method private character Logical2String (input V as logical):
  
    case V:

      when ? then return "?".
    
      when no then return "no".
      
      when yes then return "yes".
      
    end. /* case */
  
  end. /* method Logical2String */
  
end. /* class clsVoleso */


/************************** UNIT TEST CODE *************************

Test {* .. *} should happen on load.

define variable S as class com.amduus.voleso.clsVoleso no-undo.

S = new com.amduus.voleso.clsVoleso("oas/template/test1.html").
S:HTMLRender(stream WebStream:handle).

delete object S.

----

Test {include ..} markup

define variable S as class com.amduus.voleso.clsVoleso no-undo.

S = new com.amduus.voleso.clsVoleso("oas/template/test1.html").
S:IncludeFile ("oas/template/testinc.html").
S:HTMLRender(stream WebStream:handle).

delete object S.


----

Test AssignVar markup

define variable S as class com.amduus.voleso.clsVoleso no-undo.

S = new com.amduus.voleso.clsVoleso("oas/template/test1.html").
S:IncludeFile ("oas/template/testinc.html").
S:AssignVar("Value", "Scott").
S:HTMLRender(stream WebStream:handle).

delete object S.

----

Test sections.  Basically pull a section out to T (so Voleso ops can work there)
and then when done, ApplySection back into the original template.

define variable S as class com.amduus.voleso.clsVoleso no-undo.
define variable T as class com.amduus.voleso.clsVoleso no-undo.

define variable i as integer no-undo.

S = new com.amduus.voleso.clsVoleso("oas/template/test1.html").
S:IncludeFile ("oas/template/testinc.html").
S:AssignVar("Value", "Scott").

/* Deal with a section */

T = new com.amduus.voleso.clsVoleso (S:GetSection ("1")).

{&OUT} "Template:".
T:HTMLRender(stream webstream:handle).

do i = 1 to 3:

  T:AssignVar ("Value1", string(i)).
  T:NextSection().

end. /* do */

T:FinishSection().
S:ApplySection("1", T).

delete object T.


S:HTMLRender(stream WebStream:handle).

delete object S.

----

Not show a section and show a section.



define variable S as class com.amduus.voleso.clsVoleso no-undo.

S = new com.amduus.voleso.clsVoleso("oas/template/test2.html").
S:DeleteSection ("DeleteThis").
S:ShowSection ("ShowThis")..
S:AssignVar("Value", "Scott").
S:HTMLRender(stream WebStream:handle).

delete object S.



*********************************************************************/
