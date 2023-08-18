defmodule BibleEx.Reference do
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
            verses: []

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
      case BibleEx.Librarian.get_book_names(book: book) do
        nil ->
          book

        book_names ->
          Map.get(book_names, :name, book)
      end

    sc =
      if !is_nil(start_chapter) do
        BibleEx.Chapter.new(book: bname, chapter_number: start_chapter)
      else
        BibleEx.Chapter.new(book: bname, chapter_number: 1)
      end

    scn =
      if !is_nil(start_chapter) do
        start_chapter
      else
        1
      end

    ec =
      if !is_nil(end_chapter) do
        BibleEx.Chapter.new(book: bname, chapter_number: end_chapter)
      else
        if !is_nil(start_chapter) do
          BibleEx.Chapter.new(book: bname, chapter_number: start_chapter)
        else
          BibleEx.Chapter.new(book: bname, chapter_number: end_chapter)
        end
      end

    ecn =
      if !is_nil(end_chapter) do
        end_chapter
      else
        if !is_nil(start_chapter) do
          scn
        else
          BibleEx.Librarian.get_last_chapter_number(book: bname)
        end
      end

    sv =
      if !is_nil(start_verse) do
        BibleEx.Verse.new(book: bname, chapter_number: start_chapter, verse_number: start_verse)
      else
        BibleEx.Verse.new(book: bname, chapter_number: 1, verse_number: 1)
      end

    svn =
      if !is_nil(start_verse) do
        start_verse
      else
        1
      end

    ev =
      if !is_nil(end_verse) do
        BibleEx.Verse.new(book: bname, chapter_number: scn, verse_number: end_verse)
      else
        if !is_nil(start_verse) do
          BibleEx.Verse.new(book: bname, chapter_number: scn, verse_number: start_verse)
        else
          BibleEx.Librarian.get_last_verse_number(book: bname, chapter: scn)
        end
      end

    evn =
      if !is_nil(end_verse) do
        end_verse
      else
        if !is_nil(start_verse) do
          start_verse
        else
          BibleEx.Librarian.get_last_verse_number(book: bname, chapter: ecn)
        end
      end

    # dbg(ecn)
    # dbg(ec)
    # dbg(end_chapter)

    chapters =
      BibleEx.Librarian.get_chapters(
        book: bname,
        start_chapter: scn,
        end_chapter: ecn
      )

    # if the reference has a verse range(both start_verse, end_verse, not nil) limit the verses to range
    verses =
      if !is_nil(start_verse) and !is_nil(end_verse) do
        BibleEx.Librarian.get_verses(
          book: bname,
          chapter: start_chapter,
          start_verse: start_verse,
          end_verse: end_verse
        )
      else
        Enum.map(chapters, fn x ->
          BibleEx.Librarian.get_verses(book: bname, chapter: x.chapter_number)
        end)
        |> List.flatten()
      end

    %__MODULE__{
      book: bname,
      book_names: BibleEx.Librarian.get_book_names(book: bname),
      book_number: BibleEx.Librarian.find_book_number(book: bname),
      reference:
        BibleEx.Librarian.create_reference_string(
          book: bname,
          start_chapter: start_chapter,
          start_verse: start_verse,
          end_chapter: ecn,
          end_verse: end_verse
        ),
      reference_type:
        BibleEx.Librarian.identify_reference_type(
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
        BibleEx.Librarian.verify_reference(
          book: bname,
          start_chapter: scn,
          start_verse: start_verse,
          end_chapter: ecn,
          end_verse: end_verse
        ),
      chapters: chapters,
      verses: verses
    }
  end

  def chapter(book: book, chapter: chapter) do
    new(book: book, start_chapter: chapter)
  end

  def verse(book: book, chapter: chapter, verse: verse) do
    new(book: book, start_chapter: chapter, start_verse: verse)
  end

  def chapter_range(book: book, start_chapter: start_chapter, end_chapter: end_chapter) do
    new(
      book: book,
      start_chapter: start_chapter,
      start_verse: nil,
      end_chapter: end_chapter,
      end_verse: nil
    )
  end

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
