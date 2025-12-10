defmodule BibleEx.Reference do
  @moduledoc """
  Represents a normalized Bible reference.

  A `%BibleEx.Reference{}` ties together book, chapter(s), verse(s), and
  derived metadata such as OSIS code, abbreviation, and the list of
  `BibleEx.Chapter` and `BibleEx.Verse` structs that make up the reference.
  """

  alias BibleEx.Librarian
  alias BibleEx.Chapter
  alias BibleEx.Verse

  @enforce_keys [:book]

  defstruct book: "",
            book_names: %{},
            book_number: nil,
            reference: nil,
            reference_type: nil,
            start_chapter: nil,
            start_chapter_number: nil,
            start_verse: nil,
            start_verse_number: nil,
            end_chapter: nil,
            end_chapter_number: nil,
            end_verse: nil,
            end_verse_number: nil,
            is_valid: false,
            chapters: [],
            verses: [],
            osis: nil,
            abbr: nil,
            short: nil

  @doc ~S"""
  Builds a new `%BibleEx.Reference{}` for a given book and optional range.

  The `book` parameter may be any recognized form for a book name:

    * Full name: `"Genesis"`
    * OSIS code: `"Gen"`
    * Paratext abbreviation: `"GEN"`
    * Short form: `"Gn"`

  Missing chapter or verse boundaries are filled in using `BibleEx.Librarian`,
  defaulting to the full book, chapter, or verse range as appropriate.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "Genesis", start_chapter: 2, start_verse: 3, end_chapter: 4, end_verse: 5)
      iex> ref.book
      "Genesis"
      iex> {ref.start_chapter_number, ref.start_verse_number, ref.end_chapter_number, ref.end_verse_number}
      {2, 3, 4, 5}
      iex> ref.reference_type in [:chapter_range, :verse_range]
      true

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "3 John")
      iex> ref.book
      "3 John"
      iex> {ref.start_chapter_number, ref.start_verse_number}
      {1, 1}
      iex> ref.is_valid
      true

  """
  def new(book: book) do
    new(book: book, start_chapter: nil, start_verse: nil, end_chapter: nil, end_verse: nil)
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a book starting at a given chapter.

  This is a convenience wrapper for `new/1` when only `start_chapter` is known.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "Genesis", start_chapter: 1)
      iex> {ref.book, ref.start_chapter_number, ref.start_verse_number}
      {"Genesis", 1, 1}

  """
  def new(
        book: book,
        start_chapter: start_chapter
      ) do
    new(
      book: book,
      start_chapter: start_chapter,
      start_verse: nil,
      end_chapter: nil,
      end_verse: nil
    )
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a single starting verse.

  This is a convenience wrapper for `new/1` when `book`, `start_chapter`
  and `start_verse` are known but no end boundary is supplied.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "Gen", start_chapter: 1, start_verse: 1)
      iex> ref.reference
      "Genesis 1:1"

  """
  def new(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse
      ) do
    new(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: nil,
      end_verse: nil
    )
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a cross-chapter range without an end verse.

  This form is used when the start verse is known but the range ends at the
  end of `end_chapter`.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "John", start_chapter: 3, start_verse: 16, end_chapter: 4)
      iex> {ref.start_chapter_number, ref.start_verse_number, ref.end_chapter_number}
      {3, 16, 4}

  """
  def new(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter
      ) do
    new(
      book: book,
      start_chapter: start_chapter,
      start_verse: start_verse,
      end_chapter: end_chapter,
      end_verse: nil
    )
  end

  @doc ~S"""
  Builds the most general `%BibleEx.Reference{}` with optional start and end.

  This function:

    * Normalizes the book name using `BibleEx.Librarian.get_book_names/1`.
    * Computes default start and end chapters/verses when omitted.
    * Loads `BibleEx.Chapter` and `BibleEx.Verse` structs for the range.
    * Sets `reference`, `reference_type`, and `is_valid` using `BibleEx.Librarian`.

  Prefer calling the convenience helpers (`chapter/2`, `verse/3`,
  `chapter_range/3`, `verse_range/4`) instead of this function directly
  in most application code.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.new(book: "Romans", start_chapter: 8, start_verse: 28, end_chapter: 8, end_verse: 30)
      iex> ref.reference
      "Romans 8:28-30"
      iex> ref.is_valid
      true

  """
  def new(
        book: book,
        start_chapter: start_chapter,
        start_verse: start_verse,
        end_chapter: end_chapter,
        end_verse: end_verse
      ) do
    bname =
      case Librarian.get_book_names(book: book) do
        book_names = %{
          osis: _osis,
          abbr: _abbr,
          name: _name,
          short: _short
        } ->
          Map.get(book_names, :name, book)

        %{} ->
          book
      end

    sc =
      if !is_nil(start_chapter) do
        Chapter.new(book: bname, chapter_number: start_chapter)
      else
        Chapter.new(book: bname, chapter_number: 1)
      end

    scn =
      if !is_nil(start_chapter) do
        start_chapter
      else
        1
      end

    ec =
      if !is_nil(end_chapter) do
        Chapter.new(book: bname, chapter_number: end_chapter)
      else
        if !is_nil(start_chapter) do
          Chapter.new(book: bname, chapter_number: start_chapter)
        else
          Chapter.new(book: bname, chapter_number: end_chapter)
        end
      end

    ecn =
      if !is_nil(end_chapter) do
        end_chapter
      else
        if !is_nil(start_chapter) do
          scn
        else
          Librarian.get_last_chapter_number(book: bname)
        end
      end

    sv =
      if !is_nil(start_verse) do
        Verse.new(book: bname, chapter_number: start_chapter, verse_number: start_verse)
      else
        Verse.new(book: bname, chapter_number: 1, verse_number: 1)
      end

    svn =
      if !is_nil(start_verse) do
        start_verse
      else
        1
      end

    ev =
      if !is_nil(end_verse) do
        Verse.new(book: bname, chapter_number: scn, verse_number: end_verse)
      else
        if !is_nil(start_verse) do
          Verse.new(book: bname, chapter_number: scn, verse_number: start_verse)
        else
          Librarian.get_last_verse_number(book: bname, chapter: scn)
        end
      end

    evn =
      if !is_nil(end_verse) do
        end_verse
      else
        if !is_nil(start_verse) do
          start_verse
        else
          Librarian.get_last_verse_number(book: bname, chapter: ecn)
        end
      end

    chapters =
      Librarian.get_chapters(
        book: bname,
        start_chapter: scn,
        end_chapter: ecn
      )

    chapter_list =
      scn..ecn
      |> Enum.to_list()

    verse_collection =
      Enum.map(chapter_list, fn x ->
        find_start_verse =
          if !is_nil(svn) and x == Enum.at(chapter_list, 0) do
            svn
          else
            1
          end

        find_last_verse =
          if !is_nil(evn) and x == List.last(chapter_list) do
            evn
          else
            Librarian.get_last_verse_number(book: bname, chapter: x)
          end

        Librarian.get_verses(
          book: bname,
          chapter: x,
          start_verse: find_start_verse,
          end_verse: find_last_verse
        )
      end)

    book_names = Librarian.get_book_names(book: bname)
    osis_book = Map.get(book_names, :osis, nil)
    abbr_book = Map.get(book_names, :abbr, nil)
    short_book = Map.get(book_names, :short, nil)

    %__MODULE__{
      book: bname,
      book_names: book_names,
      book_number: Librarian.find_book_number(book: bname),
      reference:
        Librarian.create_reference_string(
          book: bname,
          start_chapter: start_chapter,
          start_verse: start_verse,
          end_chapter: ecn,
          end_verse: end_verse
        ),
      reference_type:
        Librarian.identify_reference_type(
          book: bname,
          start_chapter: scn,
          start_verse: start_verse,
          end_chapter: ecn,
          end_verse: end_verse
        ),
      start_chapter: sc,
      start_chapter_number: scn,
      end_chapter: ec,
      end_chapter_number: ecn,
      start_verse: sv,
      start_verse_number: svn,
      end_verse: ev,
      end_verse_number: evn,
      is_valid:
        Librarian.verify_reference(
          book: bname,
          start_chapter: scn,
          start_verse: start_verse,
          end_chapter: ecn,
          end_verse: end_verse
        ),
      chapters: chapters,
      verses: List.flatten(verse_collection),
      osis: osis_book,
      abbr: abbr_book,
      short: short_book
    }
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a whole chapter.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.chapter(book: "Genesis", chapter: 1)
      iex> {ref.book, ref.reference_type}
      {"Genesis", :chapter}
      iex> ref.reference
      "Genesis 1"

  """
  def chapter(book: book, chapter: chapter) do
    new(book: book, start_chapter: chapter)
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a single verse.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.verse(book: "Genesis", chapter: 1, verse: 1)
      iex> {ref.book, ref.reference_type}
      {"Genesis", :verse}
      iex> ref.reference
      "Genesis 1:1"

  """
  def verse(book: book, chapter: chapter, verse: verse) do
    new(book: book, start_chapter: chapter, start_verse: verse)
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a chapter range.

  The range spans from `start_chapter` to `end_chapter`, inclusive.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.chapter_range(book: "Genesis", start_chapter: 1, end_chapter: 2)
      iex> ref.reference
      "Genesis 1-2"
      iex> ref.reference_type
      :chapter_range

  """
  def chapter_range(book: book, start_chapter: start_chapter, end_chapter: end_chapter) do
    new(
      book: book,
      start_chapter: start_chapter,
      start_verse: nil,
      end_chapter: end_chapter,
      end_verse: nil
    )
  end

  @doc ~S"""
  Builds a `%BibleEx.Reference{}` for a verse range within a chapter.

  ## Examples

      iex> alias BibleEx.Reference
      iex> ref = Reference.verse_range(book: "Matt", chapter: 2, start_verse: 4, end_verse: 10)
      iex> ref.book
      "Matthew"
      iex> {ref.start_verse_number, ref.end_verse_number}
      {4, 10}
      iex> ref.reference_type
      :verse_range

  """
  def verse_range(book: book, chapter: chapter, start_verse: start_verse, end_verse: end_verse) do
    new(
      book: book,
      start_chapter: chapter,
      start_verse: start_verse,
      end_chapter: nil,
      end_verse: end_verse
    )
  end
end
