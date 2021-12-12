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

  construct new(text, color, line_padding) {
    _text = text
    _last_letter = 0
    _buffer = []
    _buffer.add(_text[_last_letter]) 
    _color = color
    _line_height = Canvas.getPrintArea(_buffer[0]).y
    _line_padding = line_padding
  }

  nextLetter() {
    _last_letter = _last_letter + 1
    if (_last_letter < _text.count) {
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
    if (_last_letter < _text.count && _text[_last_letter] == " ") {
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
  
  construct new(position, size, text, speed) {
    _position = position
    _size = size
    _color = Color.white
    _text = text

    // Clock to update text
    _clock = Clock.new()
    _clock.each(speed, Fn.new {
      _text.nextLetter()
      _text.checkLineBreak(_size)
    })
  }

  update() {
    _clock.update()

    if (Keyboard.isKeyDown("Space")) {
      _text.skip(_size)
    }
  }

  draw(dt) {
    _text.draw(dt, _position)
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
    
    _dialog_text = DialogText.new(
      "This is a really long text dialogue that is here to test line break in DialogBox.",
      Color.white,
      Vector.new(5, 5)
    )
    
    _dialog = DialogBox.new(
      Vector.new(50, 50),
      Vector.new(200, 100),
      _dialog_text,
      0.05 // Speed less is faster
    )
  
  }
  
  update() {
    _dialog.update()
  }
  
  draw(dt) {
    _dialog.draw(dt)
  }
}

var Game = Main.new()
