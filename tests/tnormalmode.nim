import unittest
import ncurses
import moepkg/[editorstatus, gapbuffer, unicodetext, editor, bufferstatus]

include moepkg/normalmode

suite "Normal mode: Move to the right":
  test "Move tow to the right":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'l']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 2)

suite "Normal mode: Move to the left":
  test "Move one to the left":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])
    status.workspace[0].currentMainWindowNode.currentColumn = 2

    status.resize(100, 100)
    status.update

    const key = @[ru'h']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 1)

suite "Normal mode: Move to the down":
  test "Move two to the down":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a", ru"b", ru"c"])

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'j']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 2)

suite "Normal mode: Move to the up":
  test "Move two to the up":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a", ru"b", ru"c"])
    status.workspace[0].currentMainWindowNode.currentLine = 2

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'k']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 0)

suite "Normal mode: Delete current character":
  test "Delete two current character":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'x']
    status.normalCommand(key, 100, 100)
    status.update

    check status.bufStatus[0].buffer[0] == ru"c"
    check status.registers.yankedStr == ru"ab"

suite "Normal mode: Move to last of line":
  test "Move to last of line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    const key = @[ru'$']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 2)

suite "Normal mode: Move to first of line":
  test "Move to first of line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])
    status.workspace[0].currentMainWindowNode.currentColumn = 2

    status.resize(100, 100)
    status.update

    const key = @[ru'0']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 0)

suite "Normal mode: Move to first non blank of line":
  test "Move to first non blank of line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"  abc"])
    status.workspace[0].currentMainWindowNode.currentColumn = 4

    status.resize(100, 100)
    status.update

    const key = @[ru'^']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 2)

suite "Normal mode: Move to first of previous line":
  test "Move to first of previous line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"  abc", ru"def", ru"ghi"])
    status.workspace[0].currentMainWindowNode.currentLine = 2

    status.resize(100, 100)
    status.update

    const key = @[ru'-']
    status.normalCommand(key, 100, 100)
    status.update
    check(status.workspace[0].currentMainWindowNode.currentLine == 1)
    check(status.workspace[0].currentMainWindowNode.currentColumn == 0)

    status.normalCommand(key, 100, 100)
    status.update
    check(status.workspace[0].currentMainWindowNode.currentLine == 0)
    check(status.workspace[0].currentMainWindowNode.currentColumn == 0)

suite "Normal mode: Move to first of next line":
  test "Move to first of next line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc", ru"def"])

    status.resize(100, 100)
    status.update

    const key = @[ru'+']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 1)
    check(status.workspace[0].currentMainWindowNode.currentColumn == 0)

suite "Normal mode: Move to last line":
  test "Move to last line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc", ru"def", ru"ghi"])

    status.resize(100, 100)
    status.update

    const key = @[ru'G']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 2)

suite "Normal mode: Page down":
  test "Page down":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])
    for i in 0 ..< 200: status.bufStatus[0].buffer.insert(ru"a", 0)

    status.settings.smoothScroll = false

    status.resize(100, 100)
    status.update

    const key = @[KEY_NPAGE.toRune]
    status.normalCommand(key, 100, 100)
    status.update

    let
      currentLine = status.workspace[0].currentMainWindowNode.currentLine
      viewHeight = status.workspace[0].currentMainWindowNode.view.height

    check currentLine == viewHeight

suite "Normal mode: Page up":
  test "Page up":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])
    for i in 0 ..< 200: status.bufStatus[0].buffer.insert(ru"a", 0)

    status.settings.smoothScroll = false

    status.resize(100, 100)
    status.update

    block:
      const key = @[KEY_NPAGE.toRune]
      status.normalCommand(key, 100, 100)
    status.update

    block:
      const key = @[KEY_PPAGE.toRune]
      status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 0)

suite "Normal mode: Move to forward word":
  test "Move to forward word":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc def ghi"])

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'w']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 8)

suite "Normal mode: Move to backward word":
  test "Move to backward word":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc def ghi"])
    status.workspace[0].currentMainWindowNode.currentColumn = 8

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 1
    const key = @[ru'b']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 4)

suite "Normal mode: Move to forward end of word":
  test "Move to forward end of word":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc def ghi"])

    status.resize(100, 100)
    status.update

    status.bufStatus[0].cmdLoop = 2
    const key = @[ru'e']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.workspace[0].currentMainWindowNode.currentColumn == 6)

suite "Normal mode: Open blank line below":
  test "Open blank line below":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'o']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].buffer.len == 2)
    check(status.bufStatus[0].buffer[0] == ru"a")
    check(status.bufStatus[0].buffer[1] == ru"")

    check(status.workspace[0].currentMainWindowNode.currentLine == 1)

    check(status.bufStatus[0].mode == Mode.insert)

suite "Normal mode: Open blank line below":
  test "Open blank line below":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'O']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].buffer.len == 2)
    check(status.bufStatus[0].buffer[0] == ru"")
    check(status.bufStatus[0].buffer[1] == ru"a")

    check(status.workspace[0].currentMainWindowNode.currentLine == 0)

    check(status.bufStatus[0].mode == Mode.insert)

suite "Normal mode: Add indent":
  test "Add indent":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'>']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].buffer[0] == ru"  a")

suite "Normal mode: Delete indent":
  test "Normal mode: Delete indent":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"  a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'<']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].buffer[0] == ru"a")

suite "Normal mode: Join line":
  test "Join line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a", ru"b"])

    status.resize(100, 100)
    status.update

    const key = @[ru'J']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].buffer[0] == ru"ab")

suite "Normal mode: Replace mode":
  test "Replace mode":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'R']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].mode == Mode.replace)

suite "Normal mode: Move right and enter insert mode":
  test "Move right and enter insert mode":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a"])

    status.resize(100, 100)
    status.update

    const key = @[ru'a']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].mode == Mode.insert)
    check(status.workspace[0].currentMainWindowNode.currentColumn == 1)

suite "Normal mode: Move last of line and enter insert mode":
  test "Move last of line and enter insert mode":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    const key = @[ru'A']
    status.normalCommand(key, 100, 100)
    status.update

    check(status.bufStatus[0].mode == Mode.insert)
    check(status.workspace[0].currentMainWindowNode.currentColumn == 3)

suite "Normal mode: Repeat last command":
  test "Repeat last command":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    block:
      const key = ru'x'
      let commands = status.isNormalModeCommand(key)
      status.normalCommand(commands, 100, 100)
      status.update

    block:
      const key = @[ru'.']
      status.normalCommand(key, 100, 100)
      status.update

    check(status.bufStatus[0].buffer.len == 1)
    check(status.bufStatus[0].buffer[0].len == 1)

  test "Repeat last command 2":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    block:
      const key = ru'>'
      let commands = status.isNormalModeCommand(key)
      status.normalCommand(commands, 100, 100)
      status.update

    status.workspace[0].currentMainWindowNode.currentColumn = 0

    block:
      const key = ru'x'
      let commands = status.isNormalModeCommand(key)
      status.normalCommand(commands, 100, 100)
      status.update

    block:
      const key = @[ru'.']
      status.normalCommand(key, 100, 100)
      status.update

    check(status.bufStatus[0].buffer.len == 1)
    check(status.bufStatus[0].buffer[0] == ru"abc")

  test "Repeat last command 3":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"abc", ru"def", ru"ghi"])

    status.resize(100, 100)
    status.update

    block:
      const key = ru'j'
      let commands = status.isNormalModeCommand(key)
      status.normalCommand(commands, 100, 100)
      status.update

    block:
      const key = @[ru'.']
      status.normalCommand(key, 100, 100)
      status.update

    check(status.workspace[0].currentMainWindowNode.currentLine == 1)

suite "Normal mode: Delete the line from current line to last line":
  test "Delete the line from current line to last line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a", ru"b", ru"c", ru"d"])
    status.workspace[0].currentMainWindowNode.currentLine = 1

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'G']
    status.normalCommand(commands, 100, 100)
    status.update

    let buffer = status.bufStatus[0].buffer
    check buffer.len == 1 and buffer[0] == ru"a"

    check status.registers.yankedLines == @[ru"b", ru"c", ru"d"]

suite "Normal mode: Delete the line from first line to current line":
  test "Delete the line from first line to current line":
    var status = initEditorStatus()
    status.addNewBuffer
    status.bufStatus[0].buffer = initGapBuffer(@[ru"a", ru"b", ru"c", ru"d"])
    status.workspace[0].currentMainWindowNode.currentLine = 2

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'g', ru'g']
    status.normalCommand(commands, 100, 100)
    status.update

    let buffer = status.bufStatus[0].buffer
    check buffer.len == 1 and buffer[0] == ru"d"

    check status.registers.yankedLines == @[ru"a", ru"b", ru"c"]

suite "Normal mode: Delete inside paren and enter insert mode":
  test "Delete inside double quotes and enter insert mode (ci\" command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru """abc "def" "ghi""""])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'"']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru """abc "" "ghi""""
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside double quotes and enter insert mode (ci' command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc 'def' 'ghi'"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'\'']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc '' 'ghi'"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside curly brackets and enter insert mode (ci{ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc {def} {ghi}"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'{']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc {} {ghi}"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside round brackets and enter insert mode (ci( command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc (def) (ghi)"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'(']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc () (ghi)"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside square brackets and enter insert mode (ci[ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc [def] [ghi]"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'[']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc [] [ghi]"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

suite "Normal mode: Delete current word and enter insert mode":
  test "Delete current word and enter insert mode (ciw command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc def"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'w']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "def"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentColumn == 0

    check status.registers.yankedStr == ru"abc "

  test "Delete current word and enter insert mode when empty line (ciw command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"abc"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'i', ru'w']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru""
    check currentBufStatus.buffer[1] == ru"abc"
    check currentBufStatus.mode == Mode.insert

    check currentMainWindowNode.currentLine == 0
    check currentMainWindowNode.currentColumn == 0

suite "Normal mode: Delete inside paren":
  test "Delete inside double quotes and enter insert mode (di\" command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru """abc "def" "ghi""""])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'"']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru """abc "" "ghi""""

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside double quotes (di' command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc 'def' 'ghi'"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'\'']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc '' 'ghi'"

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside curly brackets (di{ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc {def} {ghi}"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'{']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc {} {ghi}"

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside round brackets (di( command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc (def) (ghi)"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'(']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc () (ghi)"

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

  test "Delete inside square brackets (di[ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc [def] [ghi]"])
    currentMainWindowNode.currentColumn = 6

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'[']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "abc [] [ghi]"

    check currentMainWindowNode.currentColumn == 5

    check status.registers.yankedStr == ru"def"

suite "Normal mode: Delete current word":
  test "Delete current word and (diw command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru "abc def"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'w']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru "def"

    check currentMainWindowNode.currentColumn == 0

    check status.registers.yankedStr == ru"abc "

  test "Delete current word when empty line (diw command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"abc"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'i', ru'w']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru""
    check currentBufStatus.buffer[1] == ru"abc"

    check currentMainWindowNode.currentLine == 0
    check currentMainWindowNode.currentColumn == 0

suite "Normal mode: Delete current character and enter insert mode":
  test "Delete current character and enter insert mode (s command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    let commands = @[ru's']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru"bc"
    check currentBufStatus.mode == Mode.insert

    check status.registers.yankedStr == ru"a"

  test "Delete current character and enter insert mode when empty line (s command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"", ru""])
    currentMainWindowNode.currentLine = 1

    status.resize(100, 100)
    status.update

    let commands = @[ru's']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer.len == 3
    for i in  0 ..< currentBufStatus.buffer.len:
      check currentBufStatus.buffer[i] == ru""

    check currentBufStatus.mode == Mode.insert

  test "Delete 3 characters and enter insert mode(3s command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcdef"])
    currentMainWindowNode.currentLine = 1

    status.resize(100, 100)
    status.update

    currentBufStatus.cmdLoop = 3
    let commands = @[ru's']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru"def"
    check currentBufStatus.mode == Mode.insert

    check status.registers.yankedStr == ru"abc"

  test "Delete current character and enter insert mode (cu command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abc"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'l']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru"bc"
    check currentBufStatus.mode == Mode.insert

  test "Delete current character and enter insert mode when empty line (s command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"", ru""])
    currentMainWindowNode.currentLine = 1

    status.resize(100, 100)
    status.update

    let commands = @[ru'c', ru'l']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer.len == 3
    for i in  0 ..< currentBufStatus.buffer.len:
      check currentBufStatus.buffer[i] == ru""

    check currentBufStatus.mode == Mode.insert

suite "Normal mode: Yank lines":
  test "Yank to the previous blank line (y{ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(
      @[ru"abc", ru"", ru"def", ru"ghi", ru"", ru"jkl"])
    currentMainWindowNode.currentLine = 4

    status.resize(100, 100)
    status.update

    let commands = @[ru'y', ru'{']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines.len == 4
    check status.registers.yankedLines == @[ru "", ru"def", ru"ghi", ru""]

  test "Yank to the first line (y{ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abc", ru"def", ru""])
    currentMainWindowNode.currentLine = 2

    status.resize(100, 100)
    status.update

    let commands = @[ru'y', ru'{']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines.len == 3
    check status.registers.yankedLines == @[ru "abc", ru"def", ru""]

  test "Yank to the next blank line (y} command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"abc", ru"def", ru""])

    status.resize(100, 100)
    status.update

    let commands = @[ru'y', ru'}']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines.len == 4
    check status.registers.yankedLines == @[ru"", ru "abc", ru"def", ru""]

  test "Yank to the last line (y} command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"", ru"abc", ru"def"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'y', ru'}']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines.len == 3
    check status.registers.yankedLines == @[ru"", ru "abc", ru"def"]

  test "Yank a line (yy command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(
      @[ru"abc", ru"def", ru"ghi"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'y', ru'y']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines == @[ru "abc"]

  test "Yank a line (Y command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(
      @[ru"abc", ru"def", ru"ghi"])

    status.resize(100, 100)
    status.update

    let commands = @[ru'Y']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedLines == @[ru "abc"]

suite "Normal mode: Delete the characters from current column to end of line":
  test "Delete 5 characters (d$ command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcdefgh"])
    currentMainWindowNode.currentColumn = 3

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'$']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru"abc"

    check status.registers.yankedStr == ru"defgh"

suite "Normal mode: delete from the beginning of the line to current column":
  test "Delete 5 characters (d0 command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcdefgh"])
    currentMainWindowNode.currentColumn = 5

    status.resize(100, 100)
    status.update

    let commands = @[ru'd', ru'0']
    status.normalCommand(commands, 100, 100)
    status.update

    check currentBufStatus.buffer[0] == ru"fgh"

    check status.registers.yankedStr == ru"abcde"

suite "Normal mode: Yank string":
  test "yank character (yl command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcdefgh"])

    let commands = @[ru'y', ru'l']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedStr == ru"a"

  test "yank 3 characters (3yl command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcde"])

    currentBufStatus.cmdLoop = 3
    let commands = @[ru'y', ru'l']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedStr == ru"abc"

  test "yank 5 characters (10yl command)":
    var status = initEditorStatus()
    status.addNewBuffer
    currentBufStatus.buffer = initGapBuffer(@[ru"abcde"])

    currentBufStatus.cmdLoop = 10
    let commands = @[ru'y', ru'l']
    status.normalCommand(commands, 100, 100)
    status.update

    check status.registers.yankedStr == ru"abcde"
