
#include <string.h>


void* memcpy(void* dest, const void *src, size_t n)
{
  char* d=(char*)dest;
  char* s=(char*)src;
  while(n--)
  {
    *d = *s;
    d++;
    s++;
  }
  return dest;
}


int memcmp(const void* s1, const void* s2, size_t n)
{
  unsigned char* s1_c = (unsigned char*)s1;
  unsigned char* s2_c = (unsigned char*)s2;
  while (n--)
  {
    if ((*s1_c) != (*s2_c)) return ((*s1_c) - (*s2_c));
    s1_c++;
    s2_c++;
  }
  return 0;
}


void* memset(void *s, int c, size_t n)
{
  unsigned char* sc = (unsigned char*)s;
  while (n--)
  {
    *sc = c;
    sc++;
  }
  return s;
}


char* strcpy(char* dest, const char* src)
{
  char* tmp=dest;
  while (*src)
  {
     *dest = *src;
     dest++;
     src++;
  }
  *dest = *src;
  return tmp;
}


char* strncpy(char* dest, const char* src, size_t n)
{
  char* tmp=dest;
  while ((*src) && n)
  {
     *dest = *src;
     dest++;
     src++;
     n--;
  }
  if (n)
    *dest = *src;
  return tmp;
}


size_t strlen(const char* txt)
{
  size_t count = 0;
  while (*txt)
  {
     count++;
     txt++;
  }
  return count+1;
}


int strncmp(const char* s1, const char* s2, size_t n)
{
  int ret;
  while (n)
  {
    ret = *s1 - *s2;
    if (ret) {
      /* found a difference */
      return ret;
    } else {
      /* no difference, check for end */
      if (*s1 == 0) return 0;
    }
    s1++;
    s2++;
    n--;
  }
  return ret;
}


int strcmp(const char* s1, const char* s2)
{
  int ret=0;
  while (1)
  {
    ret = *s1 - *s2;
    if (ret) return ret;  // found a difference.
    if (*s1 == 0) return 0;    // both the same then - are they both null?
    s1++;
    s2++;
  }
  return ret;
}

