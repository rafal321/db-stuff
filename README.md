
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

y           copy line
dd          cut line
p           paste line, below cursor
----------------------------------------
D    	    del till end of line
DD          del till end of line + follow delete
cc          cell line and enter insert mode
dd    	    cut line
p    	    paste line, under cursor
de    	    delete till next word
di"    	    delete within " "   - no need be within " "
ci"    	    delete within " " , with insert mode
u    	    undo
v    	    highlight + d  to delete, p to paste
----------------------------------------
%s/AAA/BBB/     replace
vi -c "%norm! 150|D" dump.sql
vi -c "set number | %norm! 15|D" dump.sql
cut -c 1-150 big_dump.sql | grep -n "INSERT INTO \`my_table_name\`"

sed -n '8820,8849p' /var/log/messages

> file.yaml                           empty file
cat > file.yaml  <paste> + ctr+d      paste into file
```
### --- VIM END --------

### --- K9S START ------
```
x po
pulse
k9s -c pulse
k9s --readonly
https://k9scli.io/
```
### --- K9S END --------
