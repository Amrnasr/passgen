
# The wordlist is a modified version of the diceware list:
# http://world.std.com/~reinhold/diceware.wordlist.asc
# Commands for re-generating it are in the Makefile.
WORDLIST = ARGV[0]

print <<-eos
/*
 * THIS FILE IS GENERATED BY generate_wordlist.rb. DO NOT MODIFY IT DIRECTLY!
 */

#ifndef WORDLIST_H
#define WORDLIST_H

/* 
 * Each item in this array represents one word in the wordlist. The first byte
 * of each entry is the length of the word, followed by the word characters,
 * followed by padding with 'Z' to make all entries equal length.
 */

eos

File.open(WORDLIST, 'r') do |wl|
  lines = wl.readlines.map { |l| l.strip }
  max_word_length = lines.map { |l| l.length }.max

  puts "#define WORDLIST_WORD_COUNT #{lines.count}"
  puts "#define WORDLIST_MAX_LENGTH #{max_word_length}"
  puts ""

  # Start the big wordlist array.
  puts "const unsigned char words[WORDLIST_WORD_COUNT][WORDLIST_MAX_LENGTH+1] = {"

  lines.each do |line|
    # The length has to be represented in an unsigned char.
    if line.length > 255
      puts "A line is too long!"
      exit(1)
    end

    # Start the word array with a byte for the length (without padding).
    print "    { %3d," % [line.length]

    # Pad the word with 'Z' until it's as long as the longest word.
    line = line.ljust(max_word_length, "Z")

    # Print the rest of the word's bytes.
    line.each_byte do |c|
      print " %3d, " % [c]
    end

    # Close the word array.
    puts "},"
  end

  # End the big wordlist array.
  puts "};"
end

puts ""
puts "#endif"
