# save_the_cat
First attempt on ML language for the course Programming Languages I of ECE at NTUA

Let's suppose we have an N x M map of a basement. In some coordinates of the basement there are broken pipes that threaten to flood the whole basement with water. Also, in a certain spot there is a cat, Arjumand, which hates water. 

As an input, we have a 2-D basement map consisting of blocks. Each of the blocks contain one of the following symbols
"A" For the initial position of Arjumand.
"W" For each broken water pipe.
"." (dot) For each initially blank block.
"X" (obstacle) A block where neither Arjumand nor water can reach.

Each time moment, the water coming out of the broken pipes spreads to the neighbour blocks (up, down, right, left), if those are not an obstacle "X", resulting in a map that floods. The water moves with pace of 1 block per time unit.
Arjumand can also move to the neighbour blocks with pace of 1 block per time unit.

Having this in mind, 
What is the latest time moment that we can save Arjumand and
In which block of the map should we place Arjumand to save her?

The answer to the seconds question is a String that describes the series of movements that Arjumant should to in order to go to the corresponding block from where we will save her.
Theh possible movements are represented by the symbols:
"R" Move a block right on the map.
"L" Move a block left on the map..
"U" Move a block up on the map.
"D" Move a block right on the map.

The input of the program is read from a .txt file consisting of N lines each of which contains M symbols. That is the file that represent the map.

Here are four examples of .txt input files
a1.txt
A...
....

a2.txt
...W..
.A.XX.
XX.X..
.....X

a3.txt
........
.X.X....
AX.X....
.XWXXX..
.XX...X.
....X...

a4.txt
WX..XX....W
.X..X..XW..
.X.........
...XX......
XXX.WX.....
..X.....XXX
...XXX..XW.
..A..X.X...

The output of the program is supposed to be the following:
On the first line, the latest time moment on which we can save Arjumand is printed. If Arjumand is safe and we can save him any time, the output would be "infinity". In any other case the first line will contain exactly one number.
On the seconds line, the String that corresponds to the series of movement of Arjumand in printed. If the String is empty, the output would be "stay". If there are different solutions to save Arjumand with in the same time frame, we choose the one with the coordinates (firstly considering the lines and then the columns). If there are a lot of different series of movements we choose the smallest one and between movements series with the same length we chose the lexicography smaller.

The output for each of those inputs would be:
- savethecat "a1.txt";
infinity
stay
val it = () : unit

- savethecat "a2.txt";
5
RDDLL
val it = () : unit

- savethecat "a3.txt";
15
DDDRRRURR
val it = () : unit

- savethecat "a4.txt";
infinity
LLUU
val it = () : unit

As an example also, the analysis of the program for the a2.txt would be:
...W..  ..WWW.  .WWWWW  WWWWWW  WWWWWW  WWWWWW
.A.XX.  ..AXX.  ..WXX.  .WWXXW  WWWXXW  WWWXXW
XX.X..  XX.X..  XXAX..  XXWX..  XXWX.W  XXWXWW
.....X  .....X  .....X  ..A..X  .AW..X  AWWW.X
t=0      t=1     t=2     t=3     t=4     t=5
 R        D       D       L       L