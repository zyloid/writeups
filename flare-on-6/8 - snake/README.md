# Challenge 8 - Snake

The eighth Flare-On challenge archive contains a NES ROM and the following message:

> The Flare team is attempting to pivot to full-time twitch streaming video games instead of reverse engineering computer software all day. We wrote our own classic NES game to stream content that nobody else has seen and watch those subscribers flow in. It turned out to be too hard for us to beat so we gave up. See if you can beat it and capture the internet points that we failed to collect.

This sounds super-exciting! Still being relatively early on in my reverse-engineering career I've seen little outside of x86/x64 - should be a great opportunity to learn something new.

First-off I decide to fire up the ROM in an emulator and see what we're dealing with. Mesen has been recommended to me, so I load up snake.nes and away we go.

<images>

After a few rounds it appears this is indeed Snake. For those who don't know (hah), the object of Snake is to control your roving serpent as it makes its way around the game area, avoding the sides and consuming apples to grow. As you get larger and older, avoiding your own flabby body becomes more and more challenging - likely as a deep metaphor for the inherent futility of our consumer driven society.

Interesting aside - Snake was the the first game I ever played, on my Dad's work Compaq Portable at the age of 3. Unfortunately shortly after discovering Snake I discovered the even more exciting FORMAT C: command, at which point I was banned from said computer forever :( Happy ending though, my parents bought me a 128k Spectrum +2 to break instead and a mis-spent youth began.

Unfortunately due to this being the Age of Technology I have the attention span of a gnat on speed and as such grow bored quickly. Clearly I need to find some way to get to the end of this game and obtain the flag without actually having to play the darn thing. Mesen comes with a handy debugger/disassembler, so let's fire that up and see what we're dealing with:

Okay! So, there's a bunch of 6502 opcodes I'm unfamiliar with and various references to the PPU. Let's find out more about that.

...

Gosh that looks like a lot of effort to learn. Did I mention the attention span thing? Also, it feels like cracking this game is somewhat missing the point of what we've been asked to do - capture internet points by streaming a video of us winning. I want those internet points dammit.

Revisiting Mesen's debugger we appear to have a decent number of toys to play with, including a scripting engine. Maybe...we can just script the snake to play itself? We could build a clever algorithm that hunts down each apple with laser-like precision, always leaving itself just enough room to survive! But that also sounds like a lot of work.

Firstly we need to figure out where the snake is and which way it's going. Fortunately Mesen's natty debugger also contains a live memory viewer. Firing that up and playing the game for a bit allows us to very quickly identify the bytes associated with X position, Y position and direction:

![Mesen Memory Capture](images/MemCapture.png)

Offset | Purpose
------ | -------
0x0004/0x0005 | Direction (0x0 to 0x3)
0x0007 | X coordinate (0x0 to 0x17)
0x0008 | Y coordinate (0x0 to 0x15)

The current direction is stored in the bytes at both 0x0004 and 0x0005, with 0x0005 updating slightly before 0x0004. The X and Y coordinates are stored at 0x0007 and 0x0008 respectively. Armed with this information, we should have enough to build our script.

Firing up Mesen's script window we're presented with a handy sample script which gives us a great starting point, in addition the awesome documentation at https://www.mesen.ca/docs/apireference.html. In order to write our script we'll want to read the current game state and then provide appropriate inputs. Interaction with the emulator is done via callbacks, in this case one on frame completion and one for polling input. 