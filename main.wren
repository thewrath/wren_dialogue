import "graphics" for Canvas, Color, ImageData
import "math" for Vector
import "input" for Keyboard, Mouse

// Utility class to process task each x second
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

// Contract class for a dialog box component.
class DialogComponent {
  
  height {}
  
  isDone {}

  nextStep() {}

  checkSizeConstraints(dialog_size) {}

  draw(dt, position) {}

}

// Display text in DialogBox
class DialogText is DialogComponent {

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
  
  nextStep() {
    _last_letter = _last_letter + 1
    if (!isDone) {
      var current = _buffer.count - 1
      _buffer[current] = _buffer[current] + _text[_last_letter]
    }
  }

  checkSizeConstraints(dialog_size) {

    // Check line break only between words (and if end of text isn't reach)
    if (!isDone && _text[_last_letter] == " ") {

      // Find the next word
      var next_word = ""
      var word_to_check = _text[(_last_letter + 1)..._text.count]
      for (l in word_to_check) {
        if (l == " ") break
        next_word = next_word + l
      }

      // Get area needed to display the text
      var area = Canvas.getPrintArea(_buffer[_buffer.count - 1] + next_word)

      if (area.x > (dialog_size.x - _line_padding.x)) {
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

// Display image in DialogBox
class DialogImage is DialogComponent {

  construct new(author, image) {
    _author = author
    _image = image
    _current_step = 1
    _step = 10
    _scale = 1
    nextStep()
  }

  height { (_image.height*_scale)*(_current_step/_step) }

  isDone { _current_step >= _step }

  nextStep() {
    if (!isDone) {
      _current_step = _current_step + 1
      _region = _image.transform({
        "srcX": 0, "srcY": 0,
        "scaleX": _scale, "scaleY": _scale,
        "srcW": _image.width, "srcH": _image.height*(_current_step/_step),  
      })
    }
  }

  checkSizeConstraints(dialog_size) {
    _scale = 1/(_image.width / dialog_size.x)
  }

  draw(dt, position) {
    _region.draw(position.x, position.y)
  }

}

class DialogBox {
  
  construct new(position, size, dialog_components, speed) {
    _position = position
    _size = size
    _color = Color.white
    _dialog_components = dialog_components
    _current_dialog_component_id = 0

    // Clock to update text
    _clock = Clock.new()
    _clock.each(speed, Fn.new {
      currentComponent.nextStep()
      currentComponent.checkSizeConstraints(_size)
    })

    _skipKeyDown = false
  }

  currentComponent { _dialog_components[_current_dialog_component_id] }

  isLastComponent { !(_current_dialog_component_id < (_dialog_components.count - 1)) }

  nextComponent() {
    if (!isLastComponent) {
      _current_dialog_component_id = _current_dialog_component_id + 1
    }
  }

  isClicked { Mouse.isButtonPressed("left") || Keyboard.isKeyDown("space") }

  update() {
    _clock.update()

    if (isClicked && !_skipKeyDown) {
      if (!currentComponent.isDone) {
        while(!currentComponent.isDone) {
          currentComponent.nextStep()
          currentComponent.checkSizeConstraints(_size)      
        }
      } else {
        nextComponent()
      }

      _skipKeyDown = true
    } else if (!isClicked && _skipKeyDown) {
      _skipKeyDown = false 
    }

    // Auto-resize DialogBox
    if (currentComponent.height > _size.y) {
      _size.y = currentComponent.height
    }
  }

  draw(dt) {
    currentComponent.draw(dt, _position)
    Canvas.rect(
      _position.x,
      _position.y,
      _size.x,
      _size.y,
      _color
    )

    // Draw arrow to go to next component
    if (currentComponent.isDone && !isLastComponent) {
      var arrow_position = Vector.new(_position.x + _size.x - 15, _position.y +  _size.y - 15)
      Canvas.triangle(
        arrow_position.x,
        arrow_position.y,
        arrow_position.x,
        arrow_position.y + 10,
        arrow_position.x + 10,
        arrow_position.y +5, 
        _color
      )
    }   
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
