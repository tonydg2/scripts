

# curl 'https://www.lexico.com/en/definition/arid' | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"


proc curlWordProcOLD {word wfid} {
  #set curlCmd "curl 'https://www.lexico.com/en/definition/"
  #append curlCmd $word "' | html2text -ascii -nobs -style compact -width 500 | grep \"* [1-9]\""
  #puts $curlCmd

  puts "$word:"
  puts $wfid "$word:"

  set word [string tolower $word] ;# lower case or fail

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"}
  append shellCmd $word $shellCmd2
  puts $shellCmd 

  #set shellResponse [exec sh -c $shellCmd]
  #**
  
  # if this catch errors, there was no number in the definition
  if {[catch {exec sh -c $shellCmd} shellResponse]} {
    puts "catch1: $shellResponse"
    exit
  } else {
    puts "catch2: $shellResponse"
    exit
  }

  #set shellResponse [catch {exec sh -c $shellCmd} shellCatch]
  #puts "@@Catch: $shellCatch"

  #**
  puts $shellResponse\n
  puts $wfid $shellResponse\n
  after 1000;# wait ms

}


proc curlWordProc {word wfid} {

  puts "$word:"
  puts $wfid "$word:"

  set word [string tolower $word] ;# lower case or fail

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }
  append shellCmd $word $shellCmd2
  #puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]

  set regExpShRsp [regexp -line -nocase -inline -all  -- {(    \* [1-9]).*} $shellResponse]

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



while {1} {
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


;#*********  TESTING ************************************************************************************************

if {0} {
  puts $testLine
  
  set lineList [regexp -inline -all -- {\S+} $testLine]
  
  puts $lineList
  puts [lindex $lineList 0]
  
  #set lineQuote [regexp {(["'])[^"']*\1} $testLine lq]
  set lineQuote [regexp {"([^"])*"} $testLine lq]
  
  puts $lineQuote
  puts $lq
  set lq [string trim $lq \"]
  set lq [regsub -all {\s+} $lq _]
  puts $lq

}


if {0} {
  set curlCmd "curl 'https://www.lexico.com/en/definition/"
  set curlCmd2 "' | html2text -ascii -nobs -style compact -width 500 | grep \"* \[1-9\]\""

  append curlCmd "arid" $curlCmd2

  #puts $curlCmd

  set def [exec $curlCmd]
  puts $def

}

if {0} {
  set url "https://www.lexico.com/en/definition/"
  set json 


}

if {0} {
  exec /usr/bin/curl -u :pass -X POST https://localhost:55477/raw -d '{"command": "site search $name", "sites": ["$ftp"]}' --insecure

  exec /usr/bin/curl -u :pass -X POST https://localhost:55477/raw -d "{\"command\": \"site search $name\", \"sites\": \[\"$ftp\"\]}" --insecure
}


if {0} {

  
  #set shellCmd {curl -s https://www.lexico.com/en/definition/arid | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"}
  
  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  #set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"}
  #set shellCmd2 { | html2text -ascii -nobs -style compact -width 500  | grep " **** "}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  append shellCmd "fixity" $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  
  puts $shellResponse

  #set wfid [open "tfile.txt" w]
  #puts $wfid $shellResponse
  #close $wfid

  puts "\n*********************************************************************************************************"
  puts "*********************************************************************************************************"
  puts "*********************************************************************************************************\n"


  #set regExpShRsp [regexp -nocase -inline -all -- {\b\*\*\*\*.*\b} $shellResponse]
  #set regExpShRsp [regexp -nocase -inline -all -- {^\*\*\*\*.*} $shellResponse]
  #set regExpShRsp [regexp -line -nocase -inline  -- {.*\*\*\*\* .*} $shellResponse]
  set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]

  #puts $regExpShRsp
  #puts [llength $regExpShRsp]
  puts [lindex $regExpShRsp 2]

  #after 1000;# wait ms

  #set url "https://www.lexico.com/en/definition/arid /| html2text -ascii -nobs -style compact -width 500"
  #exec curl $url


  #set dat2 [exec ]

}

if {0} {
  
  set string1  "***Tcl *** Tutorial\n\
                Next ***** Line\n\
                here is @@ ok\n\
                Random Stuff **** here\n\
                another line ** end\n**** this line ****\n\
                the correct line"


  #regexp -nocase {^\*\*\*.*$} "***Tcl *** Tutorial\nNext Line" a b c  
  #regexp -nocase -line {.*\*\*\*.*} "***Tcl *** Tutorial\nNext ***** Line\nhere is @@ ok\nRandom Stuff **** here\nanother line ** end" a b c  
  #set a [regexp -line -nocase -inline -- {.*\*\*\*\* .*} $string1] 
  set a [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $string1]


  puts "a: $a"
  puts [lindex $a 2]
  #puts "b: $b"
  #puts "c: $c"



}

if {0} {

  #set shellCmd {curl -s https://www.lexico.com/en/definition/arid | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"}
  if {0} {
  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  set word "fixity"

  append shellCmd $word $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  
  #puts $shellResponse


  set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]
  puts $regExpShRsp
  puts -nonewline "$word:"
  puts [lindex $regExpShRsp 2]\n


  after 1000;
  }

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  set word "fixity"

  append shellCmd $word $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  
  #puts $shellResponse
  #puts "\n*********************************************************************************************************"
  #puts "*********************************************************************************************************"
  #puts "*********************************************************************************************************\n"
  puts  "$word:"

  #   grep \"* \[1-9\]\"

  #set regExpShRsp [regexp -line -nocase -inline  -- {(^\*\*\*\* .*)(\n.*)} $shellResponse]

  set regExpShRsp [regexp -line -nocase -inline -all  -- {(    \* [1-9]).*} $shellResponse]

  ;# if {[catch {exec sh -c $shellCmd} shellResponse]} {}

  #if {[catch {regexp -line -nocase -inline -all  -- {(    \* [1-9]).*} $shellResponse} catchResponse]} {
  #  puts "CATCH: $catchResponse"
  #} else {
  #  puts "noCatch"
  #}

  if {$regExpShRsp eq ""} {
    puts "EMPTY"
  }
  
  set regExpShRspLen [llength $regExpShRsp]

  set cntr 0
  foreach n $regExpShRsp {
    if {$cntr%2 - 1} {
      puts $n
    }
    incr cntr
  }

}

if {0} {

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }

  set word "arid"

  append shellCmd $word $shellCmd2

  puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd]
  
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



# curl https://www.lexico.com/en/definition/arid | html2text -ascii -nobs -style compact -width 500 | grep "* [1-9]"
