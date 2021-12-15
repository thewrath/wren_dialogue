import "graphics" for Canvas, Color
import "math" for Vector
import "input" for Keyboard

class Clock {

  construct new() {
    _tasks = List.new()
  }

  each(seconds, cb) {
    _tasks.add([System.clock, seconds, cb])
  }

  update() {
    for (task in _tasks) {
      var last = task[0]
      var seconds = task[1]
      var cb = task[2]
      var now = System.clock

      if (now - last >= seconds) {
        task[0] = now
        cb.call()
      }
    }
  }
}

class DialogText {

  construct new(author, text) {
    _author = author
    _text = text
    _last_letter = 0
    _buffer = []
    _buffer.add(_text[_last_letter]) 
    _color = Color.white
    _line_height = Canvas.getPrintArea(_buffer[0]).y
    _line_padding = Vector.new(5, 5)
  }

  height { _line_height*(_buffer.count+1) + _line_padding.y*(_buffer.count+1) }

  isDone { !(_last_letter < _text.count) }
  
  nextLetter() {
    _last_letter = _last_letter + 1
    if (!isDone) {
      var current = _buffer.count - 1
      _buffer[current] = _buffer[current] + _text[_last_letter]
    }
  }

  skip(dialog_area) {
    while(_last_letter != _text.count) {
      nextLetter()
      checkLineBreak(dialog_area)
    }   
  }

  checkLineBreak(dialog_area) {
    // check line break only between words (and if end of text isn't reach)
    if (!isDone && _text[_last_letter] == " ") {
      var next_word = ""
      var word_to_check = _text[(_last_letter + 1)..._text.count]
      for (l in word_to_check) {
        if (l == " ") break
        next_word = next_word + l
      }

      // Get area needed to display the text
      var area = Canvas.getPrintArea(_buffer[_buffer.count - 1] + next_word)

      if (area.x > (dialog_area.x - _line_padding.x)) {
        _buffer.add("")
      }
    }
  }

  draw(dt, position) {
    for (l in 0..._buffer.count) {
      Canvas.print(
        _buffer[l],
        position.x + _line_padding.x,
        position.y + (_line_height * l) + (_line_padding.y * (l+1)),
        _color
      )
    }
  }
}

class DialogBox {
  
  construct new(position, size, textes, speed) {
    _position = position
    _size = size
    _color = Color.white
    _textes = textes
    _currentTextId = 0

    // Clock to update text
    _clock = Clock.new()
    _clock.each(speed, Fn.new {
      currentText.nextLetter()
      currentText.checkLineBreak(_size)
    })

    _skipKeyDown = false
  }

  currentText { _textes[_currentTextId] }

  isDone { _currentTextId >= _textes.count - 1 && currentText.isDone }

  nextText() {
    if (_currentTextId < (_textes.count - 1)) {
      _currentTextId = _currentTextId + 1
    }
  }

  update() {
    _clock.update()

    if (Keyboard.isKeyDown("Space") && !_skipKeyDown) {
      if (!currentText.isDone) {
        currentText.skip(_size)
      } else {
        nextText()
      }

      _skipKeyDown = true
    } else if (!Keyboard.isKeyDown("Space") && _skipKeyDown) {
      _skipKeyDown = false 
    }

    // Auto-resize dialog box
    if (currentText.height > _size.y) {
      _size.y = currentText.height
    }
  }

  draw(dt) {
    currentText.draw(dt, _position)
    Canvas.rect(
      _position.x,
      _position.y,
      _size.x,
      _size.y,
      _color
    )    
  }

}

class Main {
  
  construct new() {}
  
  init() {
    
    _dialog = DialogBox.new(
      Vector.new(50, 50),
      Vector.new(200, 25),
      [
        DialogText.new("Player", "Hello."),
        DialogText.new("Player", "This is a really long text dialogue that is here to test line break in DialogBox."),
        DialogText.new("Pnj", "This is the next part ..."),
        DialogText.new("Player", "and this is the final part."),
      ],
      0.05 // Speed less is faster
    )
  
  }
  
  update() {
    _dialog.update()
  }
  
  draw(dt) {
    Canvas.cls()
    _dialog.draw(dt)
  }
}

var Game = Main.new()
