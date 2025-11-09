# rubocop-method-name-get-prefix

A RuboCop extension that flags methods with `get_` prefix that take arguments, suggesting more idiomatic Ruby naming conventions like `*_for` or `find_*` patterns.

## Installation

Add this gem to your Gemfile:

```ruby
gem 'rubocop-method-name-get-prefix', require: false
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rubocop-method-name-get-prefix
```

## Usage

Add this to your `.rubocop.yml`:

```yaml
require:
  - rubocop-method-name-get-prefix
```

Now you can run `rubocop` and it will automatically load the cop.

## What it does

This cop flags methods that:

- Start with `get_` prefix
- Take one or more arguments

It suggests renaming them to use more idiomatic Ruby patterns:

- `*_for` pattern (e.g., `get_user(id)` → `user_for(id)`)
- `find_*` pattern (e.g., `get_user(id)` → `find_user(id)`)

### Examples

**Bad:**

```ruby
def get_user(id)
  User.find(id)
end

def get_db_line_item(order_id, line_item_id)
  # ...
end
```

**Good:**

```ruby
def user_for(id)
  # some additional checks or logic ....
  SpecializedUserClass.find(id)
end

def db_line_item_for(order_id, line_item_id)
  # ...
end

# Or using find_ pattern
def find_user(id)
  SpecializedUserClass.find(id)
end
```

## Exclusions

The cop automatically excludes:

1. **Accessor methods** - Methods without arguments are handled by `Naming/AccessorMethodName`

   ```ruby
   def get_user
     @user
   end
   ```

2. **HTTP GET requests** - Methods that make HTTP GET requests are excluded:

   ```ruby
   def get_user(id)
     connection.get("/users/#{id}")
   end

   def get_checkout(id)
     request = Net::HTTP::Get.new(uri)
     http.request(request)
   end
   ```

3. **API client methods** - Methods in API client files that call `get()` are excluded:
   ```ruby
   # In a file matching *client*.rb, *api_client*.rb, *controller*.rb, etc.
   def get_user(id)
     get("/users/#{id}")
   end
   ```

## Auto-correction

The cop supports auto-correction. Run:

```bash
# Auto-correct a specific file
rubocop --autocorrect path/to/file.rb

# Auto-correct all files (with -A for unsafe corrections)
rubocop -A

# Auto-correct only this cop
rubocop --only Naming/MethodNameGetPrefix --autocorrect
```

**Note:** Auto-correction only renames method definitions, not call sites. After auto-correcting, you'll need to update any calls to the renamed method.

## Configuration

The cop can be configured in your `.rubocop.yml`:

```yaml
Naming/MethodNameGetPrefix:
  Enabled: true
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NewAlexandria/rubocop-method-name-get-prefix.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).
