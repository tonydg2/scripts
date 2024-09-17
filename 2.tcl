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
set day    [expr {$dayNum - 1}]        ;# Days from 0 to 30 (5 bits)
set month  [expr {$monthNum - 1}]      ;# Months from 0 to 11 (4 bits)
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

# Combine components into a 32-bit value (masks and shifts)
set dayShift    [expr {($day    & 0x1F) << 27}]   # Mask 5 bits for day and shift left by 27
set monthShift  [expr {($month  & 0xF)  << 23}]   # Mask 4 bits for month and shift left by 23
set yearShift   [expr {($year   & 0x3F) << 17}]   # Mask 6 bits for year and shift left by 17
set hourShift   [expr {($hour   & 0x1F) << 12}]   # Mask 5 bits for hour and shift left by 12
set minuteShift [expr {($minute & 0x3F) << 6}]    # Mask 6 bits for minute and shift left by 6
set secondShift [expr {($second & 0x3F)}]         # Mask 6 bits for second (no shift)

# Combine all the shifted values into a final 32-bit value
set finalValue [expr {
    $dayShift |
    $monthShift |
    $yearShift |
    $hourShift |
    $minuteShift |
    $secondShift
}]

# Output the combined 32-bit hexadecimal value
puts "Combined 32-bit Hexadecimal Value:"
puts [format "%08X" $finalValue]
