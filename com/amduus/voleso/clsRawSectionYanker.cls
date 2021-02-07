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
/* Copyright 2012,2021 Amduus Information Works, Inc., Scott Auge             */
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

/* $Id: clsRawSectionYanker.cls 55 2011-09-13 17:57:36Z scott_auge $ */
/* $URL: file:///users/scott_auge/svn_rc/repos/trunk/com/amduus/voleso/clsRawSectionYanker.cls $ */

/**************************************************************************/
/* Used for pulling out chunks of the template.  Not really meant to be   */
/* an editor.                                                             */
/**************************************************************************/

class com.amduus.voleso.clsRawSectionYanker:

  define private variable Template as longchar no-undo.

  /**********************************************************************/
  /* Initialize the template by reading it in from a file.              */
  /**********************************************************************/
  
  constructor clsRawSectionYanker (input TemplateFile as character):

    copy-lob from file TemplateFile to Template.

  end. /* Constructor */

  /**********************************************************************/
  /* Initialize the template by giving it a new value.                  */
  /**********************************************************************/

  constructor clsRawSectionYanker (input NewTemplate as longchar):

    Template = NewTemplate.

  end. /* Constructor */

  /**********************************************************************/
  /* Write out what we got.  Used as a debugging tool mostly.           */
  /**********************************************************************/
  
  method public void  WriteTemplate (input TemplateFile as character):

    copy-lob from Template to file TemplateFile.

  end. /* WriteTemplate */
  
  /**********************************************************************/
  /* Generally used for debugging.                                      */
  /**********************************************************************/

  method public void WriteLongToFile (input TemplateFile as character, 
                                      input LongText as longchar):
                                
    copy-lob from LongText to file TemplateFile.
    
  end. /* WriteLong */

  /**********************************************************************/
  /* Yank a section from the template.                                  */
  /* Note this retains the section tags in the data.                    */
  /**********************************************************************/
   
  method public longchar YankSection (input SectionName as character):

    define variable TheSection as longchar no-undo.
    define variable SectionStartOffset as integer no-undo.
    define variable SectionEndOffset as integer no-undo.

    define variable WorkingText as longchar no-undo.

    define variable NextSectionStartOffset as integer no-undo.
    define variable PossibleSectionEndoffset as integer no-undo.

    define variable WalkingOffset as integer no-undo.
    define variable LastWalkingOffset as integer no-undo.
    define variable NeededClosingTags as integer no-undo.

    /* The easy part, find the beginning of the section */

    SectionStartOffset = index (Template, "~{section name=" + SectionName).
    
    /* If no such offset, then return blank line. */

    if SectionStartOffset = 0 then return "".

    /* Work only with text in question, that is, get rid of the beginning */
    /* text we might have enountered before the section since it is use-  */
    /* less to us. */

    WorkingText = substring (Template, SectionStartOffset).

    /* Find the first closing section tag */

    PossibleSectionEndOffset = index (WorkingText, "~{/section~}").

    /* Determine if there is a sub-section between our section and the closing */
    /* section tag.  If not, we have our section.  This is worth computing be- */
    /* cause often we will be working with sections with no sub-sections.      */

    NextSectionStartOffset = index (WorkingText, "~{section name=", 2).

    if NextSectionStartOffset > 0 then
        if NextSectionStartOffset > PossibleSectionEndoffset then
            return substring (WorkingText, 1, PossibleSectionEndOffset + LENGTH ("~{/section~}") - 1).

    /* Now the harder part, we have sub-sections that need to be included. */

    WalkingOffset = 0.
    NeededClosingTags = 0.
    LastWalkingOffset = WalkingOffset.

    do while true:

        /* Move our offset to find tags past our current position */

        WalkingOffset = WalkingOffset + 1.

        /* If we do not encounter a section, then WalkingOffset turns  */
        /* turns to zero.  So we always want the LastWalkingOffset for */
        /* the substring following this search loop. */

        LastWalkingOffset = WalkingOffset.
        WalkingOffset = index (WorkingText, "section", WalkingOffset).

        if WalkingOffset = 0 then leave.

        /* If we encountered a new open tag, then update our count of */
        /* needed closing tags. */

        if WalkingOffset > 1 then
        if substring (WorkingText, WalkingOffset - 1, 1) = "~{" then do:

            NeededClosingTags = NeededClosingTags + 1.

        end. /* if new subsection found */

        /* If we encountered a closing tag, the update our count of */
        /* needed closing tags. */

        if WalkingOffset > 2 then
        if substring (WorkingText, WalkingOffset - 2, 2) = "~{/" then do:
            
            NeededClosingTags = NeededClosingTags - 1.

        end. /* end of a subsection or the section */

        /* if we have our closing tag, we are done! */

        if NeededClosingTags = 0 then do:

            leave.

        end. /* if NeededClosingTags = 0 */

    end. /* do while true */

    /* We have found the boundaries, return the section */

    WalkingOffset = WalkingOffset + 7.
    TheSection = substring (WorkingText, 1, WalkingOffset).
    
    return TheSection.

  end. /* YankSection */
  
  /**********************************************************************/
  /* Yank a section, but without it's outside tagging.                  */
  /**********************************************************************/
  
  method public longchar YankSectionNoDelimiters (input SectionName as character):
  
    define variable S as longchar no-undo.
    define variable Offset as integer no-undo.
    
    S = YankSection (SectionName).
    
    /* The end of S should be "{/section}" so simply trim that off */
    
    S = substring (S, 1, length(S) - 10).
    
    /* The beginning should be {section .... } so look for last } */
    /* and delete all before it. */
    
    S = substring (S, index (S, "~}") + 1).
    
    /* Should be good to go - send it on it's way. */
    
    return S.
  
  end. /* YankSectionNoDelimiters */

end. /* clsRawSectionYanker */

/**************************************************************************/
/* UNIT TESTING CODE                                                      */
/**************************************************************************

****** Check that writing template to file works.

DEF VAR a AS clsRawSectionYanker NO-UNDO.

a = NEW clsRawSectionYanker("c:\tmp\section.txt").

a:WriteTemplate ("c:\tmp\1.txt").

DELETE OBJECT a.

****** Check no sub-sections works

DEF VAR a AS clsRawSectionYanker NO-UNDO.
DEF VAR b AS LONGCHAR NO-UNDO.

a = NEW clsRawSectionYanker("c:\tmp\section.txt").

b = a:YankSection ("1").

COPY-LOB b TO FILE "c:\tmp\2.txt".

DELETE OBJECT a.

****** Data we are working with

Experimental Data
{section name=1}
1
{/section} /* 1 */
Past 1.

{section name=2}
2
  {section name=2.1}
  2.1
  {/section} /* 2.1 */
  past 2.1
{/section} /* 2 */
past 2

3 deep, 2 parallel
{section name=3}
3
  {section name=3.1}
  3.1
    {section name=3.1.1}
    3.1.1
    {/section}
  {/section}
  {section name=3.2}
  3.2
  {/section}
{/section}
Past 3

Testing abutted close section tag
{section name=4}
4
  {section name=4.1}
  4.1
  {/section} /* 4.1 */
  past 4.1{/section} /* 4 */
past 4

**************************************************************************/
                                            
