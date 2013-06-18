# Roomie

Solves the stable roommate problem. <https://en.wikipedia.org/wiki/Stable_roommates_problem>

## Installation

Add this line to your application's Gemfile:

    gem 'roomie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roomie

## Usage

    require 'roomie'

### Roomie::Solve
Takes an array of roommates as their preferences in arrays.

    r = Roomie::Solve.new([2,3,1,5,4],[5,4,3,0,2],[1,3,4,0,5],[4,1,2,5,0],[2,0,1,3,5],[4,0,2,3,1])

In this scenario, the first `[2,3,1,5,4]` represents the first (0) person, and 
their preferences. Here person0 prefers person2, then person3, etc.

    # 0: 2,3,1,5,4
    # 1: 5,4,3,0,2
    # 2: 1,3,4,0,5
    # 3: 4,1,2,5,0
    # 4: 2,0,1,3,5
    # 5: 4,0,2,3,1

After creating a new Roomie::Solve, the following results are available.

    r.matches       #=> [5, 3, 4, 1, 2, 0]
    r.matched_pairs #=> [[0, 5], [1, 3], [2, 4]]

The results can be read as:
- 0 matched with 5
- 1 matched with 3
- 2 matched with 4
- 3 matched with 1
- 4 matched with 2
- 5 matched with 0

Sometimes a stable matching is not possible, and a `NotSolvable` exception
will be raised.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
