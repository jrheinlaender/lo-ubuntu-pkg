BEGIN {
  s = "";
}

/^(Build-Depends|Depends|Replaces|Provides|Conflicts|Recommends|Suggests):/ {
  if (s != "") {
    print s;
  }
  s = $0;
  next;
}

s != "" && /^ / {
  s = sprintf("%s%s", s, $0);
  next;
}

s != "" && /^[^ ]/ {
  print s; s = ""; next;
}

{
  print;
}
