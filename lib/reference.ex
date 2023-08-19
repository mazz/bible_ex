defmodule BibleEx.Reference do
  @moduledoc """
  Is a general Bible reference struct.
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

  @doc """
  Make a new `%Reference{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *start_chapter*: an integer that is the start chapter number
    - *start_verse*: an integer that is the start verse number
    - *end_chapter*: an integer that is the end chapter number
    - *end_verse*: an integer that is the end verse number

  ## Examples
      iex> alias BibleEx.Reference
      iex> genesis_ref = Reference.new(book: "Genesis", start_chapter: 2, start_verse: 3, end_chapter: 4, end_verse: 5)

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

      iex> alias BibleEx.Reference
      iex> Reference.new(book: "3 John")

      %BibleEx.Reference{
        book: "3 John",
        book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
        book_number: 64,
        reference: "3 John",
        reference_type: :chapter,
        start_chapter: %BibleEx.Chapter{
          book: "3 John",
          book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
          reference_type: :chapter,
          reference: "3 John 1",
          chapter_number: 1,
          start_verse_number: 1,
          start_verse: %BibleEx.Verse{
            book: "3 John",
            book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
            book_number: 64,
            reference_type: :verse,
            reference: "3 John 1:1",
            chapter_number: 1,
            verse_number: 1,
            is_valid: true
          },
          end_verse: %BibleEx.Verse{
            book: "3 John",
            book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
            book_number: 64,
            reference_type: :verse,
            reference: "3 John 1:15",
            chapter_number: 1,
            verse_number: 15,
            is_valid: true
          },
          end_verse_number: 15,
          verses: [
            ...
          ],
          is_valid: true
        },
        start_chapter_number: 1,
        start_verse: %BibleEx.Verse{
          book: "3 John",
          book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
          book_number: 64,
          reference_type: :verse,
          reference: "3 John 1:1",
          chapter_number: 1,
          verse_number: 1,
          is_valid: true
        },
        start_verse_number: 1,
        end_chapter: %BibleEx.Chapter{
          book: "3 John",
          book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
          reference_type: :chapter,
          reference: nil,
          chapter_number: nil,
          start_verse_number: 1,
          start_verse: %BibleEx.Verse{
            book: "3 John",
            book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
            book_number: 64,
            reference_type: :verse,
            reference: nil,
            chapter_number: nil,
            verse_number: 1,
            is_valid: false
          },
          end_verse: %BibleEx.Verse{
            book: "3 John",
            book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
            book_number: 64,
            reference_type: :verse,
            reference: "3 John 1:15",
            chapter_number: 1,
            verse_number: 15,
            is_valid: true
          },
          end_verse_number: 15,
          verses: nil,
          is_valid: true
        },
        end_chapter_number: 1,
        end_verse: 15,
        end_verse_number: 15,
        is_valid: true,
        chapters: [
          %BibleEx.Chapter{
            book: "3 John",
            book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
            reference_type: :chapter,
            reference: "3 John 1",
            chapter_number: 1,
            start_verse_number: 1,
            start_verse: %BibleEx.Verse{
              book: "3 John",
              book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
              book_number: 64,
              reference_type: :verse,
              reference: "3 John 1:1",
              chapter_number: 1,
              verse_number: 1,
              is_valid: true
            },
            end_verse: %BibleEx.Verse{
              book: "3 John",
              book_names: %{abbr: "3JO", name: "3 John", osis: "3John", short: "3 Jn"},
              book_number: 64,
              reference_type: :verse,
              reference: "3 John 1:15",
              chapter_number: 1,
              verse_number: 15,
              is_valid: true
            },
            end_verse_number: 15,
            verses: [
              ...
            ],
            is_valid: true
          }
        ],
        verses: [
          ...
        ]
      }

  """

  def new(book: book) do
    new(book: book, start_chapter: nil, start_verse: nil, end_chapter: nil, end_verse: nil)
  end

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
        # if svn is nil then choose 1, else choose svn
        find_start_verse =
          if !is_nil(svn) and x == Enum.at(chapter_list, 0) do
            svn
          else
            1
          end

        # if evn is nil then choose last verse, else choose evn
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
    osis_book = Map.get(Librarian.get_book_names(book: bname), :osis, nil)
    abbr_book = Map.get(Librarian.get_book_names(book: bname), :abbr, nil)
    short_book = Map.get(Librarian.get_book_names(book: bname), :short, nil)

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

  @doc """
  Make a chapter `%Reference{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *chapter*: an integer that is the chapter number

  ## Examples
      iex> alias BibleEx.Reference
      iex> genesis_ref = Reference.chapter(book: "Genesis", chapter: 1)

      %BibleEx.Reference{
        book: "Genesis",
        book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
        book_number: 1,
        reference: "Genesis 1",
        reference_type: :chapter,
        start_chapter: %BibleEx.Chapter{
        ...
        }
      }
  """

  def chapter(book: book, chapter: chapter) do
    new(book: book, start_chapter: chapter)
  end

  @doc """
  Make a verse `%Reference{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *chapter*: an integer that is the chapter number
    - *verse*: an integer that is the verse number

  ## Examples
      iex> alias BibleEx.Reference
      iex> gen_11 = Reference.verse(book: "Genesis", chapter: 1, verse: 1)

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
  """

  def verse(book: book, chapter: chapter, verse: verse) do
    new(book: book, start_chapter: chapter, start_verse: verse)
  end

  @doc """
  Make a chapter_range `%Reference{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *start_chapter*: an integer that is the chapter number
    - *end_chapter*: an integer that is the chapter number

  ## Examples
      iex> alias BibleEx.Reference
      iex> gen_1_to_2 = Reference.verse(book: "Genesis", start_chapter: 1, end_chapter: 2)

      %BibleEx.Reference{
        book: "Genesis",
        book_names: %{abbr: "GEN", name: "Genesis", osis: "Gen", short: "Gn"},
        book_number: 1,
        reference: "Genesis 1-2",
        reference_type: :chapter_range,
        start_chapter: %BibleEx.Chapter{
          ...
        }
        ...
      }
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

  @doc """
  Make a verse_range `%Reference{}` struct.

  ## Parameters

    - *book*: a string that is one of the four possible book name formats
    - `"GEN"` (abbr)
    - `"Genesis"` (name)
    - `"Gen"` (osis)
    - `"Gn"` (short)
    - *start_verse*: an integer that is the start verse number
    - *end_verse*: an integer that is the end verse number

  ## Examples
      iex> alias BibleEx.Reference
      iex> matt2410 = Reference.verse_range(book: "Mat", chapter: 2, start_verse: 4, end_verse: 10)

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
      }
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
