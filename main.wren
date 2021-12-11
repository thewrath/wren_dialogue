import "graphics" for Canvas, Color
import "math" for Vector

class Clock {

  construct new() {
    _tasks = List.new()
  }

  each(seconds, cb) {
    _tasks.add([System.clock, seconds, cb])
  }

  update() {
    for (task in _tasks) {
      System.print(task)
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
  construct new(text, color) {
    _text = text
    _last_letter = 0
    _buffer = _text[_last_letter] 
    _color = color
  }

  nextLetter() {
    _last_letter = _last_letter + 1
    _buffer = _text[0..._last_letter]
  }

  draw(dt, position) {
    Canvas.print(_buffer, position.x, position.y, _color)
  }
}

class DialogBox {
  
  construct new(position, size, text) {
    _position = position
    _size = size
    _color = Color.white
    _text = text
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
    _dialog_text = DialogText.new("Ceci est un dialogue de test", Color.white)
    _dialog = DialogBox.new(
      Vector.new(50, 50),
      Vector.new(200, 50),
      _dialog_text
    )

    _clock = Clock.new()
    _clock.each(1, Fn.new {
      _dialog_text.nextLetter()
    })
  }
  
  update() {
    _clock.update()
  }
  
  draw(dt) {
    _dialog.draw(dt)
  }
}

var Game = Main.new()
