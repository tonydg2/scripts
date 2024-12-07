


proc curlWordProc {word wfid} {

  puts "$word:"
  puts $wfid "$word:"

  set word [string tolower $word] ;# lower case or fail

  set shellCmd {curl -s https://www.lexico.com/en/definition/}
  set shellCmd2 { | html2text -ascii -nobs -style compact -width 500 }
  append shellCmd $word $shellCmd2
  #puts $shellCmd\n
  set shellResponse [exec sh -c $shellCmd] 

  # this gives everything from first definition up to 'origin'
  set regExpShRsp [regexp -line -nocase -all -- {(^\*\*\*\*{1} .* \*\*\*\*{1})((.|\n)*)(\*\*\*\*{1} Origin \*\*\*\*{1})} $shellResponse a] ;# ((.|\n)*) = any character or newline repeated 0 or more times
  
  if {$regExpShRsp} {
    # now find the definitions
    set regExpShRsp [regexp -inline -line -nocase -all -- {( \* ){1}(.*)} $a] ;# just search for " * ", entire line that follows
    set cntr 0
    foreach x $regExpShRsp {
      if {!($cntr%3 - 2)} {
        puts "  [string trim $x]"
        puts $wfid "  [string trim $x]"
      }
      incr cntr
    }
  # search failed, assume no 'origin' in definition. In this case just grab first def and hope...
  } else {
    puts -nonewline "  *!!*"
    puts -nonewline $wfid "  *!!*"
    set regExpShRsp [regexp -inline -line -nocase -all -- {(^\*\*\*\*{1} .* \*\*\*\*{1})(\n.*)} $shellResponse]
    set guessStrng [lindex $regExpShRsp 2]
    puts " [string trim $guessStrng]"
    puts $wfid "  [string trim $guessStrng]"
  }


  # ***** DONT DELETE THIS!! -- FIX IT!! ******
  # now find any decimal definitions (1.1, etc)
  # ** this works, but does not follow the correct order = 1.1 should follow definition 1, etc.
  #set regExpShRsp [regexp -inline -line -nocase -all -- {([1-9]\. [1-9]\.[1-9]){1}(.*)} $a] ;# will be in the form of "1. 1.1"
  #foreach x $regExpShRsp {
  #  if {!($cntr%3 - 2)} {
  #    puts "  [string trim $x]"
  #    puts $wfid "  [string trim $x]"
  #  }
  #  incr cntr
  #}

  after 1000;# wait ms

}

puts "*********************************************************************************************"
puts "**     Script  START                                                                       **"
puts "*********************************************************************************************\n"

set testLine "this \"is a, test\" (line)"


set rfid [open "Words_210310_081900.txt" r]
#set rfid [open "Words2.txt" r]
set wfid [open "Words2Def_2.txt" w] ;# write file



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

