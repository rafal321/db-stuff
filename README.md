
### --- VIM START ------
```

gg          -> top of file
G           -> bottom of file
Ctrl-u      -> Scroll up half a page.
Ctrl-d      -> down half a page.
ctrl-b      -> page up
ctrl-f      -> page down

w    	    move to next word    
b    	    move to prev word
0    	    move to beg of line    
$    	    move to end of line

/           -> Find a word
----------------------------------------
D    	    del till end of line
dd    	    cut line
p    	    paste line, under cursor
de    	    delete till next word
di"    	    delete within " "   - no need be within " "
ci"    	    delete within " " , with insert mode
u    	    undo
v    	    highlight + d  to delete
----------------------------------------
%s/AAA/BBB/     replace
vi -c "%norm! 150|D" dump.sql
vi -c "set number | %norm! 15|D" dump.sql
cut -c 1-150 big_dump.sql | grep -n "INSERT INTO \`my_table_name\`"

sed -n '8820,8849p' /var/log/messages
```
### --- VIM END --------

### --- K9S START ------
```
x po
pulse
k9s -c pulse

https://k9scli.io/
```
### --- K9S END --------