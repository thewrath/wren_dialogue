# Dialogue System using Wren and Dome

Little dialogue system to test [Wren](https://wren.io) programming language and [Dome](https://domeengine.com) graphic library.

![Alt Text](https://raw.githubusercontent.com/thewrath/wren_dialogue/main/res/example.gif)

Todo : 
- [x] Autowrap
- [x] Multiple text in dialog (to form a dialog)
- [x] Spacebar to display all text
- [x] Auto resize in height
- [x] Display image in DialogBox
- [ ] Display next at bottom of DialogBox

How to use :

DialogBox work insead of Dome Engine.  


```wren
class Main {
  
  construct new() {}
  
  init() {
    
    _dialog = DialogBox.new(
      Vector.new(50, 50),
      Vector.new(200, 25),
      [
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

```