buttonToPress = { start = true }

function playGame()
  dir = emu.read(0x5, cpu)
  x = emu.read(0x7, cpu)
  y = emu.read(0x8, cpu)  
  
  -- Right
  if dir == 0 then
    dirText = "right"
    if y > 20 then
      if x > 21 then
        buttonToPress = { up = true }
      end
    elseif x > 20 then
      buttonToPress = { down = true }
    end
  end
  
  -- Left
  if dir == 1 then
    dirText = "left"
    if x <= 1 then
      buttonToPress = { down = true }
    end
  end
  
  -- Down
  if dir == 3 then
    dirText = "down"
    if x < 13 then
      buttonToPress = { right = true }
    else
      buttonToPress = { left = true }
    end
  end
  
  -- Up
  if dir == 2 then
    dirText = "up"
    if y <= 1 then
      buttonToPress = { left = true }
    end
  end
  
  emu.drawString(10, 10, "x: " .. x .. ", y:" .. y .. ", dir: " .. dirText, 0xFFFFFF, 0xFF000000, 1)
end

function provideInput()
  emu.setInput(0, buttonToPress)
end

emu.addEventCallback(playGame, emu.eventType.endFrame)
emu.addEventCallback(provideInput, emu.eventType.inputPolled);
emu.displayMessage("Script", "AutoSnake loaded")
