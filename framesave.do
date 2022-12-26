/*
function: framesave
usage: framesave new_frame_name: stata-command
source: https://www.elwyndavies.com/stata-tips/save-command-results-to-new-frame-in-stata/
*/

cap program drop framesave
program define framesave

  * Saves the output of the command, e.g. collapse, to a frame

  gettoken left right2 : 0, parse(":")
  if `"`left'"' == ":" {
    local right `"`right2'"'
  }
  else {
   gettoken right3 right : right2, parse(":")
  }

  local 0 : copy local left

  syntax anything

  * Run the command on a copy of the current frame 
  cap frame pwf
  frame copy `=r(currentframe)' `anything', replace
  frame `anything' : `right'
end


