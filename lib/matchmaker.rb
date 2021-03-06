#lib/matchmaker.rb
=begin
Matchmaker, class; Person, helper class

Usage: given item_group_1 and item_group_2, returns a unique stable matching 
of item1 <-> item2 where item1 is from group 1 and item 2 is from group 2

for matching only:
Matchmaker.new(item_group_1, item_group_2).match_couples

to measure stability:
matchmaker = Matchmaker.new
matchmaker.match_couples
matchmaker.stability

Tests contained in: ./spec/matchmaker_spec.rb
9/9 pass

untested: 
- $DEBUG configurable from command line or from Matchmaker.new
  reason:unsure how. unsure if necessary
=end

require 'set'

$DEBUG = false | ARGV[0]

class Person
  def initialize(name)
    @name = name
    @fiance = nil
    @preferences = []
    @proposals = []
  end
  attr_reader :name, :proposals
  attr_accessor :fiance, :preferences
 
  def free
    @fiance = nil
  end
 
  def single?
    @fiance == nil
  end
 
  def engage(person)
    self.fiance = person
    person.fiance = self
  end
  
  def final_choice?(person)
    @preferences.last == person
  end
 
  def better_choice?(person)
    unless @fiance.nil?
      fi_idx = @preferences.index(@fiance)
      new_idx = @preferences.index(person)
      return true if fi_idx.nil?
      return false if new_idx.nil?
      return false if @fiance.final_choice?(self)
      new_idx < fi_idx
    else
      true
    end
  end
 
  def propose_to(person)
    puts "#{self} proposes to #{person}" if $DEBUG
    @proposals << person
    person.respond_to_proposal_from(self)
  end
 
  def respond_to_proposal_from(person)
    if single?
      puts "#{self} accepts proposal from #{person}" if $DEBUG
      engage(person)
    elsif better_choice?(person)
      puts "#{self} dumps #{@fiance} for #{person}" if $DEBUG
      @fiance.free
      engage(person)
    else
      puts "#{self} rejects proposal from #{person}" if $DEBUG
    end
  end
  
  def more_preferable_people
    ( @preferences.partition {|p| better_choice?(p)} ).first
  end
end

class Matchmaker
  def valid_arg(thing)
    return !thing.nil? && thing.respond_to?(:merge)
  end
  
  def initialize(men_prefs, women_prefs, debug = false)
    $DEBUG = debug
    unless valid_arg(men_prefs) && valid_arg(women_prefs)
      @men = nil
      @women = nil
      return
    end
    prefs = men_prefs.merge(women_prefs)
    @men = Hash[
        men_prefs.keys.collect { |name| [name, Person.new(name)]}
        ]
    @women = Hash[
        women_prefs.keys.collect { |name| [name, Person.new(name)]}
        ]
    @men.each {|name, man| man.preferences = @women.values_at(*prefs[name])}
    @women.each {|name, woman| woman.preferences = @men.values_at(*prefs[name])}
    @men, @women = @women, @men if @men.keys.length > @women.keys.length
  end
  
  def match_couples
    return nil if @men.nil? || @women.nil?
    @men.each_value {|man| man.free}
    @women.each_value {|woman| woman.free}
    while m = @men.values.find {|man| man.single?} do
      puts "considering single man #{m}" if $DEBUG
      w = m.preferences.find {|woman| not m.proposals.include?(woman)}
      m.propose_to(w)
    end
    @men.each_value.collect {|man| puts "#{man} + #{man.fiance}"} if $DEBUG
    return Hash.new(@men.each{|k,v| [k,v.fiance]})
  end
  
  def stability
    unstable = Set.new
    @men.each_value do |man|
      woman = man.fiance
      puts "considering #{man} and #{woman}" if $DEBUG
   
      man.more_preferable_people.each do |other_woman|
        if other_woman.more_preferable_people.include?(man)
          puts "an unstable pairing: #{man} and #{other_woman}" if $DEBUG
          unstable << [man, other_woman]
        end
      end
      woman.more_preferable_people.each do |other_man|
        if other_man.more_preferable_people.include?(woman)
          puts "an unstable pairing: #{woman} and #{other_man}" if $DEBUG
          unstable << [other_man, woman]
        end
      end
    end
   
    if unstable.empty?
      return 1.0
    else
      unstable.each do |a,b|
        if $DEBUG
          puts "#{a} is engaged to #{a.fiance} but would prefer #{b}, and #{b} is engaged to #{b.fiance} but would prefer #{a}"
        end
      end
      return (1.0 - unstable.length.to_f / @men.keys.length.to_f)
    end
  end
end


