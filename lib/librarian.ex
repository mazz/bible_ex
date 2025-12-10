defmodule BibleEx.Librarian do
  @moduledoc """
  Internal helper functions for looking up Bible metadata and validating references.

  This module is used by `BibleEx.Reference` and `BibleEx.RefParser` to:

    * Resolve book names into canonical numbers and name variants.
    * Compute last chapters and verses for a given book.
    * Build lists of `BibleEx.Chapter` and `BibleEx.Verse` structs.
    * Infer reference types and validate that references are in range.
    * Render human-readable reference strings.
  """

  require Logger
  alias BibleEx.BibleData

  @doc ~S"""
  Returns the book number (1–66) for a given book identifier.

  The `book` argument may be:

    * The full lowercased book name, e.g. `"genesis"`.
    * An OSIS identifier, e.g. `"gen"`.
    * A shortened/abbreviated key from `BibleEx.BibleData`.
    * A variant key, e.g. `"mat"` for Matthew.

  If the book cannot be resolved, `nil` is returned.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.find_book_number(book: "Genesis")
      1

      iex> Librarian.find_book_number(book: "rom")
      45

      iex> Librarian.find_book_number(book: "NotABook")
      nil

  """
  def find_book_number(book: book) do
    book_lower = String.downcase(book)

    cond do
      book_lower == "" ->
        nil

      BibleData.books()[book_lower] ->
        BibleData.books()[book_lower]

      BibleData.osis_books()[book_lower] ->
        BibleData.osis_books()[book_lower]

      BibleData.shortened_books()[book_lower] ->
        BibleData.shortened_books()[book_lower]

      BibleData.variants()[book_lower] ->
        BibleData.variants()[book_lower]

      true ->
        nil
    end
  end

  @doc ~S"""
  Returns `true` if the given book string is a recognized Bible book.

  This check uses the canonical, OSIS, and shortened maps in `BibleEx.BibleData`
  and does not attempt to correct misspellings.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.check_book(book: "Genesis")
      true

      iex> Librarian.check_book(book: "Gen")
      true

      iex> Librarian.check_book(book: "NotABook")
      false

  """
  def check_book(book: book) do
    book_lower = String.downcase(book)

    Map.has_key?(BibleData.books(), book_lower) ||
      Map.has_key?(BibleData.osis_books(), book_lower) ||
      Map.has_key?(BibleData.shortened_books(), book_lower)
  end

  @doc ~S"""
  Returns all name variants for a book as a map.

  The result map contains:

    * `:osis` – OSIS identifier (e.g. `"Gen"`)
    * `:abbr` – Paratext-style abbreviation (e.g. `"GEN"`)
    * `:name` – Full book name (e.g. `"Genesis"`)
    * `:short` – Shortened form (e.g. `"Gn"`)

  The `book` argument may be a name/abbreviation string or a 1-based book number.
  If the book cannot be resolved, an empty map is returned.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.get_book_names(book: "Genesis")[:name]
      "Genesis"

      iex> Librarian.get_book_names(book: 45)[:osis]
      "Rom"

      iex> Librarian.get_book_names(book: "NotABook")
      %{}

  """
  def get_book_names(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
        "nil"    -> nil
        "atom"   -> nil
      end

    case found_book do
      nil ->
        %{}

      found_book ->
        list = Enum.at(BibleData.book_names(), found_book - 1)

        %{
          osis: Enum.at(list, 0),
          abbr: Enum.at(list, 1),
          name: Enum.at(list, 2),
          short: Enum.at(list, 3)
        }
    end
  end

  @doc ~S"""
  Returns the last verse number for a given book, or for a specific chapter.

  When only `book` is given, the last verse in the final chapter is returned.
  When `chapter` is given, the last verse in that chapter is returned, or `nil`
  if the chapter is out of range.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.get_last_verse_number(book: "Genesis", chapter: 1) > 0
      true

      iex> Librarian.get_last_verse_number(book: "Revelation")
      v when is_integer(v) and v > 0

      iex> Librarian.get_last_verse_number(book: "Genesis", chapter: 999)
      nil

  """
  def get_last_verse_number(book: book) do
    get_last_verse_number(book: book, chapter: nil)
  end

  def get_last_verse_number(book: book, chapter: chapter) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    case found_book do
      nil ->
        nil

      _found_book_not_nil ->
        found_chapter =
          case chapter do
            nil   -> length(Enum.at(BibleData.last_verse(), found_book - 1))
            found -> found
          end

        if length(Enum.at(BibleData.last_verse(), found_book - 1)) < found_chapter ||
             found_chapter < 1 do
          nil
        else
          verses_in_book = Enum.at(BibleData.last_verse(), found_book - 1)
          Enum.at(verses_in_book, found_chapter - 1)
        end
    end
  end

  @doc ~S"""
  Returns the number of chapters in a book.

  The `book` argument may be a name/abbreviation string or a book number.
  If the book is not recognized, `nil` is returned.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.get_last_chapter_number(book: "Genesis")
      50

      iex> Librarian.get_last_chapter_number(book: "NotABook")
      nil

  """
  def get_last_chapter_number(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      length(Enum.at(BibleData.last_verse(), found_book - 1))
    end
  end

  @doc ~S"""
  Builds a `BibleEx.Verse` struct for the last verse of a book or chapter.

  When only `book` is given, the verse is the last verse of the last chapter.
  When `chapter` is given, the verse is the last verse of that chapter.

  Returns `nil` if the book or chapter cannot be resolved.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> last = Librarian.get_last_verse(book: "Jude")
      iex> {last.chapter_number, last.verse_number}
      {1, v} when v > 0

      iex> Librarian.get_last_verse(book: "NotABook")
      nil

  """
  def get_last_verse(book: book) do
    get_last_verse(book: book, chapter: nil)
  end

  def get_last_verse(book: book, chapter: chapter) do
    book_number =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    book_chapter =
      case chapter do
        nil     -> length(Enum.at(BibleData.last_verse(), book_number - 1))
        chapter -> chapter
      end

    book_names = get_book_names(book: book)

    if is_nil(book_number) do
      nil
    else
      case Map.get(book_names, :name, nil) do
        nil ->
          nil

        book_name ->
          BibleEx.Verse.new(
            book: book_name,
            chapter_number: book_chapter,
            verse_number: get_last_verse_number(book: book_number, chapter: book_chapter)
          )
      end
    end
  end

  @doc ~S"""
  Returns all verses in a chapter as a list of `BibleEx.Verse` structs.

  When only `book` and `chapter` are given, the entire chapter is returned.
  When `start_verse` and/or `end_verse` are given, a subrange of verses is returned.

  Returns `nil` if the book or chapter is invalid, or if the requested range
  is out of bounds (e.g. `start_verse > end_verse`).

  ## Examples

      iex> alias BibleEx.Librarian
      iex> verses = Librarian.get_verses(book: "Genesis", chapter: 1)
      iex> hd(verses).reference
      "Genesis 1:1"

      iex> range = Librarian.get_verses(book: "Genesis", chapter: 1, start_verse: 1, end_verse: 3)
      iex> Enum.map(range, & &1.verse_number)
      [1, 2, 3]

  """
  def get_verses(book: book, chapter: chapter) do
    get_verses(book: book, chapter: chapter, start_verse: nil, end_verse: nil)
  end

  def get_verses(book: book, chapter: chapter, start_verse: start_verse, end_verse: end_verse) do
    book_number =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    if is_nil(book_number) do
      nil
    else
      case chapter do
        nil ->
          nil

        chapter ->
          start_verse =
            if !is_nil(start_verse), do: start_verse, else: 1

          end_verse =
            if !is_nil(end_verse) do
              end_verse
            else
              BibleData.last_verse()
              |> Enum.at(book_number - 1)
              |> Enum.at(chapter - 1)
            end

          case start_verse > end_verse do
            true ->
              nil

            false ->
              case end_verse do
                nil ->
                  nil

                last_verse ->
                  book_names = get_book_names(book: book)

                  case Map.get(book_names, :name, nil) do
                    nil ->
                      nil

                    book_name ->
                      Enum.map(start_verse..last_verse, fn x ->
                        BibleEx.Verse.new(
                          book: book_name,
                          chapter_number: chapter,
                          verse_number: x
                        )
                      end)
                  end
              end
          end
      end
    end
  end

  @doc ~S"""
  Returns a `BibleEx.Chapter` for the last chapter of a book.

  Returns `nil` if the book cannot be resolved.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> ch = Librarian.get_last_chapter(book: "Psalms")
      iex> ch.chapter_number
      150

  """
  def get_last_chapter(book: book) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      book_names = get_book_names(book: book)

      case Map.get(book_names, :name, nil) do
        nil ->
          nil

        book_name ->
          last_chapter = length(Enum.at(BibleData.last_verse(), found_book - 1))
          BibleEx.Chapter.new(book: book_name, chapter_number: last_chapter)
      end
    end
  end

  @doc ~S"""
  Returns a list of `BibleEx.Chapter` structs for a book.

  Supported forms:

    * `get_chapters/1` – all chapters in a book.
    * `get_chapters/2` – a single chapter.
    * `get_chapters/3` – a range of chapters.

  Chapters outside the valid range are clamped to the book's first/last chapter.
  Returns `nil` if the book is invalid.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> chs = Librarian.get_chapters(book: "Genesis")
      iex> length(chs)
      50

      iex> [ch] = Librarian.get_chapters(book: "Genesis", start_chapter: 1)
      iex> ch.chapter_number
      1

      iex> range = Librarian.get_chapters(book: "Genesis", start_chapter: 1, end_chapter: 3)
      iex> Enum.map(range, & &1.chapter_number)
      [1, 2, 3]

  """
  def get_chapters(book: book) do
    get_chapters(book: book, start_chapter: nil, end_chapter: nil)
  end

  def get_chapters(book: book, start_chapter: start_chapter) do
    get_chapters(book: book, start_chapter: start_chapter, end_chapter: nil)
  end

  def get_chapters(book: book, start_chapter: start_chapter, end_chapter: end_chapter) do
    found_book =
      case BibleEx.typeof(book) do
        "binary" -> find_book_number(book: book)
        "number" -> book
      end

    if found_book > BibleData.last_verse() do
      nil
    else
      book_names = get_book_names(book: book)

      if is_nil(found_book) do
        nil
      else
        case Map.get(book_names, :name, nil) do
          nil ->
            nil

          book_name ->
            case start_chapter > end_chapter do
              true ->
                nil

              false ->
                start_chapter =
                  if is_nil(start_chapter), do: 1, else: start_chapter

                end_chapter =
                  if is_nil(end_chapter), do: start_chapter, else: end_chapter

                start_chapter =
                  if start_chapter < 1, do: 1, else: start_chapter

                end_chapter =
                  if end_chapter > length(Enum.at(BibleData.last_verse(), found_book - 1)) do
                    length(Enum.at(BibleData.last_verse(), found_book - 1))
                  else
                    end_chapter
                  end

                Enum.map(start_chapter..end_chapter, fn x ->
                  BibleEx.Chapter.new(book: book_name, chapter_number: x)
                end)
            end
        end
      end
    end
  end

  @doc ~S"""
  Infers the type of a reference (`:book`, `:chapter`, `:verse`, `:chapter_range`, `:verse_range`).

  This set of overloads allows calling with increasing specificity:

    * `identify_reference_type/1` – book only.
    * `identify_reference_type/2` – book and start chapter.
    * `identify_reference_type/3` – book, start chapter, start verse.
    * `identify_reference_type/4` – plus end chapter.
    * `identify_reference_type/5` – plus end verse.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.identify_reference_type(book: "Genesis")
      :book

      iex> Librarian.identify_reference_type(book: "Genesis", start_chapter: 1)
      :chapter

      iex> Librarian.identify_reference_type(book: "Genesis", start_chapter: 1, start_verse: 1)
      :verse

      iex> Librarian.identify_reference_type(book: "Genesis", start_chapter: 1, end_chapter: 2)
      :chapter_range

      iex> Librarian.identify_reference_type(book: "Genesis", start_chapter: 1, start_verse: 1, end_chapter: 1, end_verse: 5)
      :verse_range

  """
  def identify_reference_type(book: book) do
    identify_reference_type(
      book: book,
      start_chapter: nil,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: nil,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      ) do
    identify_reference_type(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: end_chapter,
      end_verse: nil
    )
  end

  def identify_reference_type(
        book: _book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      ) do
    cond do
      is_nil(start_chapter) and is_nil(end_chapter) ->
        if !is_nil(start_verse) do
          if !is_nil(end_verse) do
            :verse_range
          else
            :verse
          end
        else
          :book
        end

      !is_nil(start_chapter) and !is_nil(end_chapter) and start_chapter != end_chapter ->
        :chapter_range

      !is_nil(start_chapter) and (is_nil(end_chapter) or end_chapter == start_chapter) ->
        if !is_nil(start_verse) do
          if !is_nil(end_verse) do
            :verse_range
          else
            :verse
          end
        else
          :chapter
        end

      !is_nil(start_verse) and !is_nil(end_verse) ->
        :verse_range

      !is_nil(start_verse) ->
        :verse

      true ->
        nil
    end
  end

  @doc ~S"""
Validates that a book identifier refers to a real Bible book.

The `book` argument may be a name/abbreviation string or a numeric book
index. Only the book is checked; chapters and verses are not considered
in this arity.

## Examples

    iex> alias BibleEx.Librarian
    iex> Librarian.verify_reference(book: "Genesis")
    true

    iex> Librarian.verify_reference(book: "NotABook")
    false

"""
def verify_reference(book: book) when not is_nil(book) do
  verified = true

  found_book =
    case BibleEx.typeof(book) do
      "binary" -> find_book_number(book: book)
      "number" -> book
    end

  verified =
    if !(found_book > 0 and length(BibleEx.BibleData.last_verse()) >= found_book) do
      false
    else
      verified
    end

  verified
end

@doc ~S"""
Validates a reference consisting of a book and an optional starting chapter.

Checks that:

  * The book exists.
  * The `start_chapter`, if present, is within the book's chapter range.

## Examples

    iex> alias BibleEx.Librarian
    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 1)
    true

    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 999)
    false

"""
def verify_reference(book: book, start_chapter: start_chapter) when not is_nil(book) do
  verified = true

  found_book =
    case BibleEx.typeof(book) do
      "binary" -> find_book_number(book: book)
      "number" -> book
    end

  verified =
    if !(found_book > 0 and length(BibleEx.BibleData.last_verse()) >= found_book) do
      false
    else
      verified
    end

  # if book is not verified at this point, short-circuit
  verified =
    case verified do
      true ->
        if !is_nil(start_chapter) do
          books_last_verse = length(BibleEx.BibleData.last_verse() |> Enum.at(found_book - 1))

          if !(start_chapter > 0 and books_last_verse >= start_chapter) do
            false
          else
            verified
          end
        else
          verified
        end

      false ->
        false
    end

  verified
end

@doc ~S"""
Validates a reference with book, starting chapter, and starting verse.

Checks that:

  * The book exists.
  * The starting chapter exists for that book.
  * The starting verse exists within that chapter.

## Examples

    iex> alias BibleEx.Librarian
    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 1, start_verse: 1)
    true

    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 1, start_verse: 999)
    false

"""
def verify_reference(book: book, start_chapter: start_chapter, start_verse: start_verse)
    when not is_nil(book) do
  verified = true

  found_book =
    case BibleEx.typeof(book) do
      "binary" -> find_book_number(book: book)
      "number" -> book
    end

  verified =
    if !(found_book > 0 and length(BibleEx.BibleData.last_verse()) >= found_book) do
      false
    else
      verified
    end

  # if book is not verified at this point, short-circuit
  verified =
    case verified do
      true ->
        if !is_nil(start_chapter) do
          books_last_verse = length(BibleEx.BibleData.last_verse() |> Enum.at(found_book - 1))

          if !(start_chapter > 0 and books_last_verse >= start_chapter) do
            false
          else
            verified
          end
        else
          verified
        end

      false ->
        false
    end

  # check verse range within the chapter
  verified =
    if is_nil(found_book) do
      false
    else
      case !is_nil(start_verse) do
        true ->
          if !is_nil(start_chapter) do
            books_last_verse_books_start_chapter =
              BibleEx.BibleData.last_verse()
              |> Enum.at(found_book - 1)
              |> Enum.at(start_chapter - 1)

            if !(start_verse > 0 and
                   books_last_verse_books_start_chapter >= start_verse) do
              false
            else
              verified
            end
          else
            false
          end

        false ->
          verified
      end
    end

  verified
end

@doc ~S"""
Validates a reference with book, starting chapter, and ending verse.

This form is used when a verse range is specified in a single chapter
but only the `end_verse` is provided alongside the chapter.

Checks that:

  * The book exists.
  * The chapter exists.
  * The ending verse is within the chapter's verse range.

## Examples

    iex> alias BibleEx.Librarian
    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 1, end_verse: 3)
    true

    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 1, end_verse: 999)
    false

"""
def verify_reference(book: book, start_chapter: start_chapter, end_verse: end_verse)
    when not is_nil(book) do
  verified = true

  found_book =
    case BibleEx.typeof(book) do
      "binary" -> find_book_number(book: book)
      "number" -> book
    end

  verified =
    if !(found_book > 0 and length(BibleEx.BibleData.last_verse()) >= found_book) do
      false
    else
      verified
    end

  # if book is not verified at this point, short-circuit
  verified =
    case verified do
      true ->
        if !is_nil(start_chapter) do
          books_last_verse = length(BibleEx.BibleData.last_verse() |> Enum.at(found_book - 1))

          if !(start_chapter > 0 and books_last_verse >= start_chapter) do
            false
          else
            verified
          end
        else
          verified
        end

      false ->
        false
    end

  verified =
    case !is_nil(end_verse) do
      true ->
        very_last_verse =
          BibleEx.BibleData.last_verse()
          |> Enum.at(found_book - 1)
          |> Enum.at(start_chapter - 1)

        if end_verse <= 0 or very_last_verse < end_verse do
          false
        else
          verified
        end

      false ->
        verified
    end

  verified
end

@doc ~S"""
Validates a fully-specified reference, including optional start and end chapters and verses.

This is the most general form and checks that:

  * The book exists.
  * The start and end chapters are within range and ordered correctly.
  * The start and end verses, if present, are within their chapter ranges and
    ordered correctly relative to each other and the chapter range.

It returns `true` for structurally valid references and `false` otherwise;
it does not check theological or translation-specific constraints.

## Examples

    iex> alias BibleEx.Librarian
    iex> Librarian.verify_reference(book: "John", start_chapter: 3, start_verse: 16, end_chapter: 4, end_verse: 3)
    true

    iex> Librarian.verify_reference(book: "Genesis", start_chapter: 50, start_verse: 1, end_chapter: 49, end_verse: 10)
    false

"""
def verify_reference(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: end_chapter,
      end_verse: end_verse
    )
    when not is_nil(book) do
  verified = true

  found_book =
    case BibleEx.typeof(book) do
      "binary" -> find_book_number(book: book)
      "number" -> book
    end

  verified =
    if !(found_book < 1 or (found_book > 0 and length(BibleEx.BibleData.last_verse()) >= found_book)) do
      false
    else
      verified
    end

  verified =
    if is_nil(found_book) do
      false
    else
      if !is_nil(start_chapter) do
        books_last_verse = length(BibleEx.BibleData.last_verse() |> Enum.at(found_book - 1))

        if !(start_chapter > 0 and books_last_verse >= start_chapter) do
          false
        else
          verified
        end

        if !is_nil(end_chapter) and start_chapter > end_chapter do
          false
        else
          verified
        end
      else
        if !is_nil(end_chapter) or !is_nil(end_verse) do
          false
        else
          verified
        end
      end

      verified =
        case !is_nil(start_verse) do
          true ->
            books_last_verse_books_start_chapter =
              BibleEx.BibleData.last_verse()
              |> Enum.at(found_book - 1)
              |> Enum.at(start_chapter - 1)

            if !(start_verse > 0 and books_last_verse_books_start_chapter >= start_verse) do
              false
            else
              verified
            end

            if !is_nil(end_verse) and !is_nil(start_verse) do
              if start_verse > end_verse do
                false
              else
                verified
              end
            else
              verified
            end

          false ->
            verified
        end

      verified =
        case !is_nil(end_chapter) do
          true ->
            books_last_verse = length(BibleEx.BibleData.last_verse() |> Enum.at(found_book - 1))

            if !(books_last_verse >= end_chapter) do
              false
            else
              verified
            end

          false ->
            verified
        end

      verified =
        case !is_nil(end_verse) do
          true ->
            if is_nil(end_chapter) do
              false
            else
              very_last_verse =
                BibleEx.BibleData.last_verse()
                |> Enum.at(found_book - 1)
                |> Enum.at(end_chapter - 1)

              if end_verse > 0 and very_last_verse >= end_verse do
                verified
              else
                if end_verse < start_verse do
                  false
                else
                  verified
                end
              end
            end

          false ->
            verified
        end

      verified
    end

  verified
end



  @doc ~S"""
  Renders a human-readable reference string from its components.

  This family of functions builds strings such as:

    * `"Genesis 1"`
    * `"Genesis 1:1"`
    * `"John 3:16 - 4:3"`
    * `"Genesis 1-2"`

  Depending on which arguments are provided, the output adjusts to match
  a conventional Bible reference format. If the inputs are not sufficient
  to build a reference (for example, missing book and chapter), `nil` is returned.

  ## Examples

      iex> alias BibleEx.Librarian
      iex> Librarian.create_reference_string(book: "Genesis", start_chapter: 1)
      "Genesis 1"

      iex> Librarian.create_reference_string(book: "Genesis", start_chapter: 1, start_verse: 1)
      "Genesis 1:1"

      iex> Librarian.create_reference_string(book: "John", start_chapter: 3, start_verse: 16, end_chapter: 4, end_verse: 3)
      "John 3:16 - 4:3"

  """
  def create_reference_string(book: _book) do
    nil
  end

  def create_reference_string(book: book, start_chapter: start_chapter) do
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true  -> reference <> book <> " #{start_chapter}"
        false -> reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(book: book, start_chapter: start_chapter, start_verse: start_verse) do
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          reference = reference <> book <> " #{start_chapter}"

          case !is_nil(start_verse) do
            true  -> reference <> ":#{start_verse}"
            false -> reference
          end

        false ->
          reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      ) do
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          reference = reference <> book <> " #{start_chapter}"

          if !is_nil(start_verse) and !is_nil(end_chapter) and end_chapter != start_chapter do
            reference = reference <> ":#{start_verse}"
            reference = reference <> " - #{end_chapter}"

            end_chapter_last_verse = get_last_verse_number(book: book, chapter: end_chapter)

            if !is_nil(end_chapter_last_verse) do
              reference = reference <> ":#{end_chapter_last_verse}"
              reference
            else
              reference
            end
          else
            reference =
              if !is_nil(end_chapter) and end_chapter != start_chapter do
                reference = reference <> "-#{end_chapter}"
                reference
              else
                reference
              end

            reference
          end

        false ->
          reference
      end

    if(reference == "", do: nil, else: reference)
  end

  def create_reference_string(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      ) do
    reference = ""

    reference =
      case !is_nil(book) and !is_nil(start_chapter) do
        true ->
          reference = reference <> book <> " #{start_chapter}"

          if !is_nil(start_verse) and !is_nil(end_chapter) and end_chapter != start_chapter do
            reference = reference <> ":#{start_verse}"
            reference = reference <> " - #{end_chapter}"

            if !is_nil(end_verse) do
              reference = reference <> ":#{end_verse}"
              reference
            else
              end_chapter_last_verse = get_last_verse_number(book: book, chapter: end_chapter)

              if !is_nil(end_chapter_last_verse) do
                reference = reference <> ":#{end_chapter_last_verse}"
                reference
              else
                reference
              end
            end
          else
            reference =
              if !is_nil(end_verse) and is_nil(start_verse) do
                reference = reference <> ":1"
                reference
              else
                if !is_nil(start_verse) do
                  reference = reference <> ":#{start_verse}"
                  reference
                else
                  reference
                end
              end

            reference =
              if !is_nil(end_chapter) do
                reference =
                  if is_nil(start_verse) and is_nil(end_verse) do
                    reference =
                      if start_chapter != end_chapter do
                        reference <> "-#{end_chapter}"
                      else
                        reference
                      end

                    reference
                  else
                    if start_chapter != end_chapter do
                      reference <> " - #{end_chapter}"
                    else
                      reference
                    end

                    reference
                  end

                reference
              else
                reference
              end

            reference =
              if !is_nil(end_verse) do
                reference =
                  if !is_nil(start_verse) do
                    reference <> "-#{end_verse}"
                  else
                    if !is_nil(end_chapter) do
                      reference <> " - #{end_chapter}:#{end_verse}"
                    else
                      reference <> ":#{end_verse}"
                    end
                  end

                reference
              else
                reference
              end

            reference
          end

        false ->
          reference =
            if is_nil(start_chapter) and is_nil(start_verse) do
              book
            else
              reference
            end

          reference
      end

    if(reference == "", do: nil, else: reference)
  end
end
