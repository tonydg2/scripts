# Function to convert decimal numbers to binary strings with fixed bit length
proc dec2bin {num bits} {
    set bin ""
    for {set i [expr {$bits - 1}]} {$i >= 0} {incr i -1} {
        if {[expr {$num & (1 << $i)}]} {
            append bin "1"
        } else {
            append bin "0"
        }
    }
    return $bin
}

# Function to convert decimal numbers to hexadecimal strings with fixed digit length
proc dec2hex {digits num} {
    return [format "%0${digits}X" $num]
}

#--------------------------------------------------------------------------------------------------
# get time custom, same format as xilinx USR_ACCESS TIMESTAMP 
#--------------------------------------------------------------------------------------------------
proc getTime {} {
  # Get the current time
  set now [clock seconds]

  # Extract date and time components and convert to integers
  scan [clock format $now -format %d] %d dayNum
  scan [clock format $now -format %m] %d monthNum
  scan [clock format $now -format %Y] %d yearNum
  scan [clock format $now -format %H] %d hourNum
  scan [clock format $now -format %M] %d minuteNum
  scan [clock format $now -format %S] %d secondNum

  # Adjust the components as per your requirements
  set day    [expr {$dayNum - 1}]        ;# Days from 0 to 30
  set month  [expr {$monthNum - 1}]      ;# Months from 0 to 11
  set year   [expr {$yearNum - 2000}]    ;# Years from 0 to 63
  set hour   $hourNum                    ;# Hours from 0 to 23
  set minute $minuteNum                  ;# Minutes from 0 to 59
  set second $secondNum                  ;# Seconds from 0 to 59

  # Convert each component to binary with fixed bit lengths
  set day_bin    [dec2bin $day 5]
  set month_bin  [dec2bin $month 4]
  set year_bin   [dec2bin $year 6]
  set hour_bin   [dec2bin $hour 5]
  set minute_bin [dec2bin $minute 6]
  set second_bin [dec2bin $second 6]

  # Convert each component to hexadecimal with fixed digit lengths
  set day_hex    [dec2hex 2 $day]    ;# 2 hex digits for day (5 bits)
  set month_hex  [dec2hex 1 $month]  ;# 1 hex digit for month (4 bits)
  set year_hex   [dec2hex 2 $year]   ;# 2 hex digits for year (6 bits)
  set hour_hex   [dec2hex 2 $hour]   ;# 2 hex digits for hour (5 bits)
  set minute_hex [dec2hex 2 $minute] ;# 2 hex digits for minute (6 bits)
  set second_hex [dec2hex 2 $second] ;# 2 hex digits for second (6 bits)

  # Output the formatted result in binary
 #puts "Binary Output:"
 #puts "${day_bin}_${month_bin}_${year_bin}_${hour_bin}_${minute_bin}_${second_bin}"
 #
 ## Output the formatted result in hexadecimal
 #puts "\nHexadecimal Output:"
  return "${day_hex}${month_hex}${year_hex}${hour_hex}${minute_hex}${second_hex}"
}
