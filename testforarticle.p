define variable Test as com.amduus.voleso.clsVoleso no-undo.
define variable Comment as com.amduus.voleso.clsVoleso no-undo.
define variable AddOn as com.amduus.voleso.clsVoleso no-undo.
define variable BOM as com.amduus.voleso.clsVoleso no-undo.

 
define variable Counter as integer no-undo.
define variable AddonIter as integer no-undo.
define variable CommentIter as integer no-undo.


Test = new com.amduus.voleso.clsVoleso("/tmp/scott.html").

Test:AssignVar("ThankYouMessage", "Thank you for your order!").
Test:AssignVar("YourCompany", "Amduus Information Works, Inc.").

// Starting our items as a do instead of a for each

bom = new com.amduus.voleso.clsVoleso(Test:GetSection("bom")).

do Counter = 1 to 4:

  if Counter > 1 then bom:NextSection().

   // Set our "Item"

  bom:AssignVar("Item", "Part-" + string(Counter)).

  // Grab comment

  comment = new com.amduus.voleso.clsVoleso(bom:GetSection("comment")).

  do CommentIter = 1 to 2:

    if CommentIter > 1 then comment:NextSection().

    comment:AssignVar("Comment", "Hi there "
                               + string(Counter)
                               + "-"
                               + string(CommentIter)).

  end.

  // Grab Addon

  addon = new com.amduus.voleso.clsVoleso(bom:GetSection("addon")).

  do AddonIter = 1 to 3:

    if AddonIter > 1 then addon:NextSection().

    addon:AssignVar("Description", "whalawhala-" + string(AddonIter)).

    addon:AssignVar("Price", random(1, 99) + .99, "99.99").

  end.

  // Attach it to bom

  bom:ApplySection("comment", comment).
  bom:ApplySection("addon", addon).

  delete object comment.
  delete object addon.

end. // do Counter

 
Test:ApplySection("bom", bom).

Test:DeleteRemainingSections().

Test:HTMLRender("/tmp/scott_rendered.html").