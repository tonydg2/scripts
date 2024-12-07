

# curl 'https://www.lexico.com/en/definition/arid' | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"

proc curlWordProc {word wfid} {

  puts "$word:"
  puts $wfid "$word:"

  set word [string tolower $word] ;# lower case or fail

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }
  append shellCmd $word $shellCmd2
  #puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd] ;# puts $shellResponse; puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";

  set regExpShRsp [regexp -line -nocase -inline -all  -- {(    \* [1-9]).*|(    \* [1-9]).[1-9]} $shellResponse]

  if {$regExpShRsp eq ""} {
    set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]
    set defStrg [lindex $regExpShRsp 2]
    puts [string range $defStrg 1 end] ;# remove a newline char
    puts $wfid [string range $defStrg 1 end] ;# remove a newline char
  } else {
    set regExpShRspLen [llength $regExpShRsp]
    set cntr 0
    foreach n $regExpShRsp {
      if {$cntr%2 - 1} {
        puts $n
        puts $wfid $n
      }
      incr cntr
    }
  }

  after 1000;# wait ms

}

puts "*********************************************************************************************"
puts "**     Script  START                                                                       **"
puts "*********************************************************************************************\n"

set testLine "this \"is a, test\" (line)"


#set rfid [open "Words_210310_081900.txt" r]
set rfid [open "Words2.txt" r]
set wfid [open "Words2Def.txt" w] ;# write file



while {0} {
  set line [gets $rfid]
  #puts $line
  
  if {$line eq ""} {puts "\nREMOVE EMPTY LINES FROM TEXT FILE\n";exit}

  # if in quotes, it's a phrase, need to get only phrase and replace spaces with underscores
  set lineQuoteFound [regexp {"([^"])*"} $line lineQuote] ;# search for quotes and get the phrase with qoutes
  if {$lineQuoteFound} {
    set lookupWord $lineQuote
    set lookupWord [string trim $lookupWord \"] ;# remove the quotes
    set lookupWord [regsub -all {\s+} $lookupWord _] ;# replace spaces with underscores
  } else {

    # turn string into a list
    set lineList [regexp -inline -all -- {\S+} $line]

    # 1st word in list
    set lookupWord [lindex $lineList 0]
  }

  # remove non alphanumerics (commas)
  set lookupWordFound [regsub -all {[^\w\.]} $lookupWord "" newlookupWord]
  if {$lookupWordFound} {
    set lookupWord $newlookupWord
  }
  #puts $lookupWord

  if {[eof $rfid]} {
    break
    close $rfid
    close $wfid
  }

  curlWordProc $lookupWord $wfid


}


puts "*********************************************************************************************"
puts "**     Script  END                                                                         **"
puts "*********************************************************************************************"

if {0} {

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  set word "penitent"

  append shellCmd $word $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  puts $shellResponse
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n"
  puts  "$word:"


  set regExpShRsp [regexp -line -nocase -inline -all  -- {(    \* [1-9]).*} $shellResponse]

  if {$regExpShRsp eq ""} {
    set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]
    puts [lindex $regExpShRsp 2]\n
  } else {
    set regExpShRspLen [llength $regExpShRsp]
    set cntr 0
    foreach n $regExpShRsp {
      if {$cntr%2 - 1} {
        puts $n
      }
      incr cntr
    }
  }
}

if {1} {

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  set word "penitent"

  append shellCmd $word $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  puts $shellResponse
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n"
  puts  "$word:"


## need to check for both, a numbered definition, and a non-numbered def.
#
#  set regExpShRsp [regexp -line -nocase -inline -all  -- {(    \* [1-9]).*} $shellResponse]
#  puts "numbered:\n $regExpShRsp\n"
## if numbered def is found, search for decimal numbered (ex. 1.1)
#
#  set regExpShRsp [regexp -line -nocase -inline -all  -- {([1-9].).*} $shellResponse]
#  puts "numbered_dot:\n $regExpShRsp\n"
#
#
#  set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]
#  puts "non-numbered:\n $regExpShRsp\n"

#------------------------------------------------------------------------------------------------------------------
# find all pattern: "**** <word> ****" except when <word> = Origin
#set regExpShRsp [regexp -line -nocase -inline -all  -- {(?!.*(Origin))(^\*\*\*\*{1} [A-Za-z]* \*\*\*\*{1})} $shellResponse]
#puts "$regExpShRsp\n"

# Options: 
#   *           (single star - followed by definition)
#   * 1         (single star, space, number - followed by definition)
#       1. 1.1  (number,dot,space,number,dot,number - followed by def) {ONLY IF above number is present}


set regExpShRsp [regexp -line -nocase -inline -all  -- {(?!.*(Origin))(^\*\*\*\*{1} [A-Za-z]* \*\*\*\*{1})(\n.*)} $shellResponse]
puts "$regExpShRsp\n"

#puts "\n--HERE--\n"
set cntr 0
foreach x $regExpShRsp {
  #puts -nonewline $cntr:
  # divisible by 3, zero indexed (ex. 2,5,8,etc.
  if {!($cntr%3 - 2)} {
    #puts -nonewline $cntr:
    #puts $x
    puts [string trim $x] ;# removes all white space (spaces,tabs,newlines,carriage returns)
  }
  incr cntr
}
#puts \n\n-----\n\n


set regExpShRsp [regexp -line -nocase -inline -all  -- {([1-9]\. [1-9]\.[1-9])(.*)} $shellResponse]
#puts "$regExpShRsp\n"

#puts [llength $regExpShRsp]

#puts "\n--HERE2--\n"

set cntr 0
foreach x $regExpShRsp {
  if {!($cntr%3 - 2)} {
    puts [string trim $x] 
  }
  incr cntr
}


#puts "\n----\n"
#
#
#set cntr 0
#foreach x $regExpShRsp {
#  set rsp2 [regexp -line -nocase -inline -all -- {(?!.*\*\*\*\*{1})(.*\* .*)} $x]
#
#  puts $rsp2\n
#  
#  incr cntr
#}




#set cntr 0
#foreach n $regExpShRsp {
#  puts "$cntr:$n"
#  incr cntr
#}
#
#puts "\n\n----\n\n"
#set cntr 0
#foreach n $regExpShRsp {
#  if {$cntr%2 - 1} {
#    puts $n
#  }
#  incr cntr
#}



}

if {0} {

  set cntr 0
  while {$cntr != 10} {
    if {!($cntr%3 - 2)} {
      puts -nonewline "!"
    }
    puts $cntr
    incr cntr
  }

}  