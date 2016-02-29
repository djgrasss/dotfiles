#/bin/bash


col=${1:-1}
N=${2:-16}

awk -v N=$N -v col=$col '
function compl_add(a, b,   ara,arb) {
  split(a, ara);split(b, arb);
  return ara[1]+arb[1]" "ara[2]+arb[2];
}
function compl_sub(a, b,   ara,arb) {
  split(a, ara);split(b, arb);
  return ara[1]-arb[1]" "ara[2]-arb[2];
}
function compl_mul(a, b,   ara,arb) {
  split(a, ara);split(b, arb);
  return ara[1]*arb[1]-ara[2]*arb[2]" "ara[1]*arb[2]+ara[2]*arb[1];
}

function calc_pow2(N,    pow)
{
  pow = 0;
  while(N = rshift(N,1)) {
    ++pow;
  };
  return pow;
}

function bit_reverse(n,pow,    i,r)
{
  r = 0;
  pow-=1;
  for(i=pow;i>=0;--i) {
    r = or(r,lshift(and(rshift(n,i),1), pow-i));
  }
  return r;
}

function binary_inversion(N,    tmp,i,j,pow)
{
  pow = calc_pow2(N);
  for(i=0;i<N;++i) {
    j = bit_reverse(i,pow);
    if (i<j) {
      tmp = c[i];
      c[i] = c[j]; 
      c[j] = tmp; 
    }
  } 
}

function fft(start,end,e,     N,N2,k,t,et) {
  N = end - start;
  if (N<2) return;
  N2 = N/2;
  et = e;
  for (k=0;k<N2;++k) {
    t = c[start+k];
    c[start+k] = compl_add(t,c[start+k+N2]);
    c[start+k+N2] = compl_sub(t,c[start+k+N2]);
    if (k>0) {
      c[start+k+N2] = compl_mul(et,c[start+k+N2]);
      et = compl_mul(et,e);
    }
  }
  et = compl_mul(e,e);
  fft(start, start+N2, et);
  fft(start+N2, end, et);
}

function print_fft(N,     N2,i)
{
  N2 = N/2;
  for(i=1;i<=N2;++i) {
    print c[i];
  }
}

BEGIN {
  if (and(N,N-1)!=0) {
    print "Error: Signal width shall be power of two!" > "/dev/stderr";
    exit(1);
  }
  start=0;end=0;
  for(i=0;i<N;++i) a[i]=0;
  PI = atan2(0,-1);
  expN = cos(2*PI/N) " " (-sin(2*PI/N));
  N2 = N/2;

#  for(i=0;i<N2;++i) {c[i]=1}
#  for(i=N2;i<N;++i) {c[i]=0}
#  fft(0,N,expN); 
#  binary_inversion(N);
#  print_fft(N);
#  exit(0); 
}
{
  if (match($0,/^.+$/)) {
    a[end] = $col;
    ++end;
    if (end>start+N) {
      delete a[start];
      start++;
    } 
    for (i=start;i<N+start;++i) {(i<end)?c[i-start] = a[i]:c[i-start] = 0;}
    fft(0,N,expN); 
    binary_inversion(N);
    print_fft(N);
    printf("\n");
    fflush();
  }
}
' -

