function bin2dec(value)
{
  result=0;
  pow2bit=1;
  while (length(value))
  {
    bitChar = substr(value, length(value));
    if (bitChar == "1")
      result = result + pow2bit;
    pow2bit = pow2bit * 2;
    value = substr(value, 1, length(value)-1)
  }
  return result
}
BEGIN {prev=0;}
{
  if ($1 ~ /^#/)
    next;
  cur = bin2dec($1);
  while (prev<cur)
  {
    print "0,";
    prev = prev+1;
  }
  print $2",\t\t/*"$3"*/"
  prev = prev+1;
}
END { while (prev<64) {print "0,"; prev=prev+1}}
