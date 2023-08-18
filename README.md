# BibleEx

This is a port of the Dart package https://github.com/joshpetit/reference_parser to Elixir.

An Elixir package that parses strings for bible references. You can parse single references or multiple references from a string in a variety of formats.

Really 99% of what you need to know will be found in 
[Parsing References](#parsing-references)
headers. But if you have more complicated needs this package can handle those!

<!-- toc -->
- [Usage](#usage)
  * [Parsing References](#parsing-references)
  * [Objects and References](#objects-and-references)
    + [Reference](#reference)
    + [Verses](#verses)
    + [Chapters](#chapters)
    + [Books](#books)
  * [Constructing References](#constructing-references)
    + [Invalid References](#invalid-references)
<!-- tocstop -->

# Usage

to include this in your Swift application:
```elixir
import BibleEx
```

## Parsing References
use the `parse_references` function to retrieve a single reference:

```elixir
alias BibleEx.RefParser
refs = RefParser.parse_references("I like Mat 2:4-10 and 1john 3:16")
```
This will return two reference objects, one describing "Matthew 2:4-10" and the other "1 John 3:16"

**Note**: The word 'is' will be parsed as the book of Isaiah.
```
[
  %BibleEx.Reference{
    book: "Matthew",
    book_names: %{abbr: "MAT", name: "Matthew", osis: "Matt", short: "Mt"},
    book_number: 40,
    reference: "Matthew 2:4-10",
    reference_type: :verse_range,
    start_chapter: %BibleEx.Chapter{
      ...
    }
  ...
  },
  %BibleEx.Reference{
  book: "1 John",
  book_names: %{abbr: "1JO", name: "1 John", osis: "1John", short: "1 Jn"},
  book_number: 62,
  reference: "1 John 3:16",
  reference_type: :verse,
  start_chapter: %BibleEx.Chapter{
    ...
  }
  ...
]

```

## Objects and References

### Reference
Reference objects are the broadest kind of reference.
You can directly construct one by following this format:

```elixir
genesis_ref = Reference.new(book: "Genesis", start_chapter: 2, start_verse: 3, end_chapter: 4, end_verse: 5)
```
```
%BibleEx.Reference{
  book: "Genesis",
  book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
  book_number: 1,
  reference: "Genesis 2:3 - 4:5",
  reference_type: :chapter_range,
  start_chapter: %BibleEx.Chapter{
    ...
  }
}
```


Their most important fields are these:
```elixir
genesis_ref.reference # The string representation (osis_reference, short_reference, and abbr also available)
genesis_ref.start_verse_number
genesis_ref.end_verse_number
genesis_ref.start_chapter_number
genesis_ref.end_chapter_number
genesis_ref.reference_type # :verse, :chapter, :verse_range, :chapter_range, :book
```
Based on what is passed in, the constructor will figure out
certain fields. For example, if you were to construct `Reference('James')`
the last chapter and verse numbers in James will be initialized accordingly.

There are many other fields that may prove useful such as 
ones that subdivid the reference, look [here](#other-fun stuff)

-------

### Verses

`Reference` objects have a `start_verse` and `end_verse` field
that return objects of the Verse type.
```elixir
genbook = Reference.new(book: "Genesis")
first_verse = genbook.start_verse;

# same as first_verse above
first = Verse(book: "Genesis", chapter_number: 1, verse_number: 1)

%BibleEx.Verse{
  book: "Genesis",
  book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
  book_number: 1,
  reference_type: :verse,
  reference: "Genesis 1:1",
  chapter_number: 1,
  verse_number: 1,
  is_valid: true
}
```

You can also construct `Reference`s that 'act' like
verses by using the named constructor
```elixir
gen_11 = Reference.verse(book: "Genesis", chapter: 1, verse: 1)

%BibleEx.Reference{
  book: "Genesis",
  book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
  book_number: 1,
  reference: "Genesis 1:1",
  reference_type: :verse,
  start_chapter: %BibleEx.Chapter{
    ...
  }
  ...
}
```

------

### Chapters
```elixir
james5 = RefParser.parse_references("James 5 is a chapter") |> List.first()
```
The `james5` object now holds a `Reference` to "James 5". Despite this, start_verse_number and end_verse_number are initialized to the first and last verses in James 5. 
```elixir
james5.start_verse_number # 1
james5.end_verse_number # 20
james5.reference_type # :chapter
```

The Reference object also has start/end chapter fields
```elixir
james510 = RefParser.parse_references("James 5-10 is cool") |> List.first()
james510.start_chapter_number # 5
james510.end_chapter_number # 10
```

Just like verses you can create chapter objects:

```elixir
john1 = Chapter.new(book: "John", chapter_number: 1)
```
------

### Books
```elixir
ecc = RefParser.parse_references("Ecclesiastes is hard to spell") |> List.first()
ecc.start_chapter_number # 1
ecc.end_chapter_number # 12
ecc.reference_type # :chapter_range
```
Books are the equivalent of a `Reference` object.

## Constructing References

### Verses
```elixir
matt24 = Reference.new(book: "Mat", start_chapter: 2, start_verse: 4)
matt24 = Reference.verse(book: "Mat", chapter: 2, verse: 4)
matt24 = Verse.new(book: "Matt", chapter_number: 2, verse_number: 4)
```

Note that the `verse` object has different fields than a
`Reference` object. Check the API.

### Verse Ranges
```elixir
matt2410 = Reference.new(book: "Mat", start_chapter: 2, start_verse: 4, end_chapter: nil, end_verse: 10)
matt2410 = Reference.verse_range(book: "Mat", chapter: 2, start_verse: 4, end_verse: 10)
```
These are equivalents that create a reference to 'Matthew 2:4-10'.

### Invalid References
All references have an `is_valid` field that says whether this reference
is within the bible.

```elixir
mcd = Reference.new(book: "McDonald", start_chapter: 2, start_verse: 4, end_chapter: 10)
print(mcd.is_valid) # false, as far as I know at least.
```
**Notice that the other fields are still initialized!!** So if needed, make
sure to check that a reference is valid before using it.
```elixir
mcd.reference # "McDonald 2:4-10"
mcd.book # "McDonald"
mcd.start_verse_number # 4
mcd.osis_book # nil, and so will be other formats.
```

The same logic applies to chapters and verse numbers.
```elixir
jude2 = Reference.new(book: "Jude", start_chapter: 2, start_verse: 10)
jude2.is_valid # false (Jude only has one chapter)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bible_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
      {
        :bible_ex,
        git: "https://github.com/mazz/bible_ex.git", branch: "main"
      }
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/bible_ex>.

