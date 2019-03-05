import re

c = input()
b=0
pattern1 = "[4-6]{1}[0-9]{3}\-[0-9]{4}\-[0-9]{4}\-[0-9]{4}|[4-6]{1}[0-9]{15}|(\d)\1{3}"
m=re.match(pattern1,c)
if m:
    print("valid")
else:
    print("invalid")
    

