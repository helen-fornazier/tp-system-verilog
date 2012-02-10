#include <my_includes.h>

#define FREQ 100

static inline int copro_add(int x, int y)
{
  int resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x00"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}

static inline int copro_sub(int x, int y)
{
  int resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x01"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}

static inline int copro_mult(int x, int y)
{
  int resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x02"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}


static inline float float_mult(float x, float y)
{
  float resultat;
  asm volatile("user %[dest],%[src1],%[src2],0x02"
                 :[dest] "=r" (resultat)
                 :[src1] "r" (x),
                 [src2] "r" (y)
                 ) ;
  return resultat;
}


int main()
{
   float a = 3.0;
   float b = 4.0;
   float c;
   c = float_mult(a,b);
   a = float_mult(b,c);
   b = float_mult(a,c);
    return 0;
}

