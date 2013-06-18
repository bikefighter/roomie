require 'roomie/not_solvable'

module Roomie
  class Solve
    attr_reader :matches

    def initialize *people_prefs
      @people_prefs = *people_prefs
      @group_size = @people_prefs.size
      @best_proposals = Array.new(@group_size)

      if phase_one
        return @matches = @people_prefs.flatten
      else
        until @people_prefs.all? {|p| p.count == 1}
          phase_two 
        end
        return @matches = @people_prefs.flatten
      end
    end

    def match_pairs
      pairs = []
      @matches.each_with_index do |match, person|
        pair = [person, match].sort
        pairs << pair unless pairs.include? pair
      end
      pairs
    end

    def phase_one
      puts "----PHASE ONE INITIATED----" if $DEBUG
      @group_size.times do |i|
        propose(i)
      end
      phase1_reduce
      
      print_prefs if $DEBUG
      print_proposals if $DEBUG

      if @people_prefs.all? {|p| p.count == 1}
        return true
      else
        return false
      end
    end

    def phase_two
      puts "----PHASE TWO INITIATED----" if $DEBUG
      cycle = find_cycle
      puts "Cycle to remove: #{cycle}" if $DEBUG
      cycle.each do |pair|
        cross_off(*pair)
      end
      puts "@best_proposals: #{@best_proposals}" if $DEBUG
      print_proposals
      print_prefs
      sent_proposals.each_with_index do |proposed_to, i|
        if proposed_to == nil
          propose(i)
        end
      end
      raise Roomie::NotSolvable, 'Problem has no solution' if @people_prefs.any? {|p| p.length == 0} 
      print_proposals

    end

    def propose(proposer)
      desired = @people_prefs[proposer][0]
      puts "Proposal: #{proposer} => #{desired}" if $DEBUG

      if @people_prefs[desired].index(proposer) == nil

        puts "Declined: #{proposer} is no longer on #{desired}'s list" if $DEBUG
        @people_prefs[proposer].shift
        propose(proposer)

      elsif @best_proposals[desired] != nil
        # someone has propsed to this person already
        puts "Existing: #{@best_proposals[desired]} ?> #{desired}" if $DEBUG
        previous_suiter = @best_proposals[desired]
        
        if @people_prefs[desired].index(proposer) < @people_prefs[desired].index(previous_suiter)
          puts "Accepted: #{desired} prefers new proposal from #{proposer}." if $DEBUG
          @best_proposals[desired] = proposer
          @people_prefs[previous_suiter].delete(desired)
          propose(previous_suiter)
        else
          puts "Declined: #{desired} prefers #{previous_suiter}." if $DEBUG
          @people_prefs[proposer].delete(desired)
          raise Roomie::NotSolvable, 'Problem has no solution' if @people_prefs[proposer].length == 0
          propose(proposer)
        end

      else
        # no outstanding proposals...propose
        puts "Accepted: #{desired} accepted." if $DEBUG
        @best_proposals[desired] = proposer
      end
    end

    # Irving's Corollary 1.3 i && ii
    def phase1_reduce
      removed_all = []

      # 1.3i - remove any that match 1.3i
      @best_proposals.each_with_index do |p,i|
        slice_point = @people_prefs[i].index(p) + 1
        removed_from_i = @people_prefs[i].slice!(slice_point, @people_prefs[i].count)
        removed_all << removed_from_i
      end

      # 1.3ii - remove user i from the list of those he had removed above
      removed_all.each_with_index do |list,i|
        list.each do |ignored_user|
          @people_prefs[ignored_user].delete(i)
        end
      end

      @people_prefs
    end

    def cross_off(proposer,recipient)
      puts "@best_proposals will have #{proposer} deleted" if $DEBUG
      proposal_to_remove = @best_proposals.index(proposer)
      @best_proposals[proposal_to_remove] = nil
      @people_prefs[proposer].delete(recipient)
      @people_prefs[recipient].delete(proposer)
      @people_prefs
    end

    # start the recursive cycle_crawl method
    def find_cycle
      first = @people_prefs.index{|i| i.size > 1}
      cycle_crawl(first)
    end

    # Looking for a pattern in the proposals.
    def cycle_crawl(person, ps=[], qs=[])
      puts "cycle crawl with (#{person}, #{ps}, #{qs})"
      second_choice = @people_prefs[person][1]
      puts "second_choice: #{second_choice}"
      if ps.include?(person) && qs.include?(second_choice)
        puts "ps: #{ps} << #{person}"
        puts "qs: #{qs} << #{second_choice}"
        ps = ps.slice(ps.index(person), ps.size)
        ps.rotate!
        qs = qs.slice(qs.index(second_choice), qs.size)
        output = ps.zip(qs)
        return output
      else
        ps << person
        qs << second_choice

        person_next = @people_prefs[second_choice].last
        puts "person_next: #{person_next}"
        
        return cycle_crawl(person_next, ps, qs)
      end
    end

    # pretty print the main preference array
    def print_prefs
      puts "____________"
      puts "Reduced Sets"
      @people_prefs.each_with_index do |prefs, i|
        puts "#{i}| #{prefs.join(' ')} "
      end
      puts "____________"
    end

    # pretty print the current proposals
    def print_proposals
      puts "____________"
      puts "Proposals"
      sent_proposals.each_with_index do |proposed, i|
        puts "#{i} => #{proposed}"
      end
      puts "____________"
    end

    # not used
    def invert_array(array)
      inverted = Array.new(array.length)
      array.each_with_index do |e, i|
        inverted[e] = i
      end
      inverted
    end

    # inverts the array of who proposals are received from
    # to who (index) has sent a proposal to whom (value)
    def sent_proposals
      reversed_matches = Array.new(@group_size)
      @best_proposals.each_with_index do |e, i|
        reversed_matches[e] = i if e
      end
      reversed_matches
    end

  end
end