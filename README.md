[![Code Climate](https://codeclimate.com/github/kaspernj/tretry/badges/gpa.svg)](https://codeclimate.com/github/kaspernj/tretry)
[![Test Coverage](https://codeclimate.com/github/kaspernj/tretry/badges/coverage.svg)](https://codeclimate.com/github/kaspernj/tretry)
[![Build Status](https://img.shields.io/shippable/540e7b9e3479c5ea8f9ec25b.svg)](https://app.shippable.com/projects/540e7b9e3479c5ea8f9ec25b/builds/latest)

# tretry

## Installation

```ruby
gem 'tretry'
```

## Usage

### Simple retry three times (which is the default)
```ruby
Tretry.try do
  # do something that might randomly fail.
end
```

### Retry with options
```ruby
Tretry.try(tries: 3, timeout: 1.5, errors: [SomeCustomError], wait: 1) do
  # do something.
end
```

## Contributing to tretry
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kasper Johansen. See LICENSE.txt for
further details.

