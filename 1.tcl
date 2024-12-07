proc getGitHash {} {
  if {[catch {exec git rev-parse HEAD}]} {
    puts "([pwd]) NOT A GIT REPO.\nGit hash will be set to FFFFFFFFFFFFFFFF"
    set ghash_msb "FFFFFFFFFFFFFFFF"
  } else {
    set git_hash  [exec git rev-parse HEAD]
    set ghash_msb [string range $git_hash 0 15]
  }
  return [string toupper $ghash_msb]
}
cd ../
set gh [getGitHash]

# set git_hash_top          {"" "git_hash_top_inst"         "../"              }
# set git_hash_bd           {"" "version_bd_inst"           "../"              }
# set git_hash_scripts      {"" "git_hash_scripts_inst"     "./"               }
# set git_hash_click_uart   {"" "version_click_uart_inst"   "../sub/click_uart"}
# set git_hash_click_lcd    {"" "version_click_lcd_inst"    "../sub/click_lcd" }



;# tcl var, module instance, repo path
#array set versionInfo {
#  git_hash_top          git_hash_top_inst         ../                 dummy
#  git_hash_bd           version_bd_inst           ../                 dummy
#  git_hash_scripts      git_hash_scripts_inst     ./                  dummy
#  git_hash_click_uart   version_click_uart_inst   ../sub/click_uart   dummy
#  git_hash_click_lcd    version_click_lcd_inst    ../sub/click_lcd    dummy
#}
#
#puts "\n"
#foreach {var inst vdir dum} [array get versionInfo] {
#    puts "$var $inst $vdir $dum"
#}


set vInfo [list \
  {git_hash_top          git_hash_top_inst         ../              }\
  {git_hash_bd           version_bd_inst           ../              }\
  {git_hash_scripts      git_hash_scripts_inst     ./               }\
  {git_hash_click_uart   version_click_uart_inst   ../sub/click_uart}\
  {git_hash_click_lcd    version_click_lcd_inst    ../sub/click_lcd }
]

set vInfo [list \
  {"" git_hash_top_inst         ../              }\
  {"" version_bd_inst           ../              }\
  {"" git_hash_scripts_inst     ./               }\
  {"" version_click_uart_inst   ../sub/click_uart}\
  {"" version_click_lcd_inst    ../sub/click_lcd }
]

#puts $vInfo
#puts [llength $vInfo]
#
#puts "\n"
#puts [lindex $vInfo 0]
#puts [lindex [lindex $vInfo 0] 0]

#puts "\n"
#
#puts "\n"
#foreach vList $vInfo {
#  foreach vListElem $vList {
#    puts -nonewline $vListElem
#  }
#}
foreach vList $vInfo {
  puts $vList
}

set idx 0;
foreach vList $vInfo {
  set curDir [pwd]
#  cd [lindex $vList 2]
  lset vInfo $idx [lset vList 0 "$idx\abcd"]
  incr idx 
}

puts "\n"
foreach vList $vInfo {
  set val1 *[lindex $vList 1]*
  puts $vList
}

