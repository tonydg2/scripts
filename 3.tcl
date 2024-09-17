#!/usr/bin/env tclsh

# Function to convert decimal numbers to hexadecimal strings with fixed digit length
proc dec2hex {digits num} {
    return [format "%0${digits}X" $num]
}

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
set day    [expr {$dayNum}]            ;# Days from 0 to 30 (5 bits)
set month  [expr {$monthNum}]          ;# Months from 0 to 11 (4 bits)
set year   [expr {$yearNum - 2000}]    ;# Years from 0 to 63 (6 bits)
set hour   $hourNum                    ;# Hours from 0 to 23 (5 bits)
set minute $minuteNum                  ;# Minutes from 0 to 59 (6 bits)
set second $secondNum                  ;# Seconds from 0 to 59 (6 bits)

# Ensure all values are within their expected ranges
foreach {var maxVal} {
    day    30
    month  11
    year   63
    hour   23
    minute 59
    second 59
} {
    if {[set $var] > $maxVal || [set $var] < 0} {
        error "$var is out of range (0-$maxVal)"
    }
}

# Calculate the final 32-bit value by shifting and masking components
set finalValue [expr {
    ((($day & 0x1F)    << 27) |
    (($month  & 0xF)   << 23) |
    (($year   & 0x3F)  << 17) |
    (($hour   & 0x1F)  << 12) |
    (($minute & 0x3F)  << 6)  |
    ($second  & 0x3F))
}]

# Output the combined 32-bit hexadecimal value
puts "Combined 32-bit Hexadecimal Value:"
puts [format "%08X" $finalValue]
