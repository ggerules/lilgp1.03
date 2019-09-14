// ggkdtreeDlg.cpp : implementation file
//

#include <iostream>
#include <cstdio>
#include "kdtree_cpp.h"

using namespace std;

int main() 
{
  CKDTree kdt1; // create k-d binary tree number one

  long l1x  = 5; //x
  long l1y  = 5; //y
  long l2x  = 1;
  long l2y  = 1;
  long l3x  = 1;
  long l3y  = 2;
  long l4x  = 4;
  long l4y  = 1;
  long l5x  = 2;
  long l5y  = 1;
  long l6x  = 6;
  long l6y  = 3;
  long l7x  = 4;
  long l7y  = 2;
  long l8x  = 3;
  long l8y  = 5;
  long l9x  = 1;
  long l9y  = 7;
  long l10x = 1;
  long l10y = 6;
  long l11x = 1;
  long l11y = 3;
  long l12x = 2;
  long l12y = 2;
  long l13x = 2;
  long l13y = 3;
  long l14x = 2;
  long l14y = 0;
  long l15x = 0;
  long l15y = 0;
  long l16x = 0;
  long l16y = 1;
  long l17x = 4;
  long l17y = 4;

  long lfnd1x = 1;
  long lfnd1y = 1;
  long lfnd2x = 8;
  long lfnd2y = 8;

  long lrf1x = 2;
  long lrf1y = 2;
  long lrf2x = 5;
  long lrf2y = 5;
  
  CKDTRecord rf1;  
  rf1.AddDescriminatorFld(lfnd1x); 
  rf1.AddDescriminatorFld(lfnd1y); 
  CKDTRecord rf2;  
  rf2.AddDescriminatorFld(lfnd2x); 
  rf2.AddDescriminatorFld(lfnd2y); 

  CKDTRecord r1;  
  r1.AddDescriminatorFld(l1x); 
  r1.AddDescriminatorFld(l1y); 

  CKDTRecord r2;  
  r2.AddDescriminatorFld(l2x); 
  r2.AddDescriminatorFld(l2y); 

  CKDTRecord r3;  
  r3.AddDescriminatorFld(l3x); 
  r3.AddDescriminatorFld(l3y); 

  CKDTRecord r4;  
  r4.AddDescriminatorFld(l4x); 
  r4.AddDescriminatorFld(l4y); 

  CKDTRecord r5;  
  r5.AddDescriminatorFld(l5x); 
  r5.AddDescriminatorFld(l5y); 

  CKDTRecord r6;  
  r6.AddDescriminatorFld(l6x); 
  r6.AddDescriminatorFld(l6y); 

  CKDTRecord r7;  
  r7.AddDescriminatorFld(l7x); 
  r7.AddDescriminatorFld(l7y); 

  CKDTRecord r8;  
  r8.AddDescriminatorFld(l8x); 
  r8.AddDescriminatorFld(l8y); 

  CKDTRecord r9;  
  r9.AddDescriminatorFld(l9x); 
  r9.AddDescriminatorFld(l9y); 

  CKDTRecord r10;  
  r10.AddDescriminatorFld(l10x); 
  r10.AddDescriminatorFld(l10y); 

  CKDTRecord r11;  
  r11.AddDescriminatorFld(l11x); 
  r11.AddDescriminatorFld(l11y); 

  CKDTRecord r12;  
  r12.AddDescriminatorFld(l12x); 
  r12.AddDescriminatorFld(l12y); 

  CKDTRecord r13;  
  r13.AddDescriminatorFld(l13x); 
  r13.AddDescriminatorFld(l13y); 

  CKDTRecord r14;  
  r14.AddDescriminatorFld(l14x); 
  r14.AddDescriminatorFld(l14y); 

  CKDTRecord r15;  
  r15.AddDescriminatorFld(l15x); 
  r15.AddDescriminatorFld(l15y); 

  CKDTRecord r16;  
  r16.AddDescriminatorFld(l16x); 
  r16.AddDescriminatorFld(l16y); 

  CKDTRecord r17;  
  r17.AddDescriminatorFld(l17x); 
  r17.AddDescriminatorFld(l17y); 

  kdt1.Insert(r1); // Insert record one
  kdt1.Insert(r2); // Insert record two
  kdt1.Insert(r3); 
  kdt1.Insert(r4); 
  kdt1.Insert(r5); 
  kdt1.Insert(r6); 
  kdt1.Insert(r7); 
  kdt1.Insert(r8); 
  kdt1.Insert(r9); 
  kdt1.Insert(r10); 
  kdt1.Insert(r11); 
  kdt1.Insert(r12); 
  kdt1.Insert(r13); 
  kdt1.Insert(r14); 
  kdt1.Insert(r15); 
  kdt1.Insert(r16); 
  kdt1.Insert(r17); 

  CKDTreeNode* pKDTreeNode = NULL;
  pKDTreeNode = kdt1.ExactFind(rf1);
  pKDTreeNode = kdt1.ExactFind(rf2);

  CKDTRecord rngfnd1;  
  rngfnd1.AddDescriminatorFld(lrf1x); 
  rngfnd1.AddDescriminatorFld(lrf1y); 
  CKDTRecord rngfnd2;  
  rngfnd2.AddDescriminatorFld(lrf2x); 
  rngfnd2.AddDescriminatorFld(lrf2y); 

  kdt1.ReInitializeVariables();
  kdt1.RangeFind(rngfnd1, rngfnd2, kdt1.GetRootNode(), 0);

  CKDTRecord rFndRecords;

  long lDescFldX = 0;
  long lDescFldY = 0;
  
  for(int i = 0; i < kdt1.m_foundRecords.size(); i++)
  {
    rFndRecords = kdt1.m_foundRecords[i];
    lDescFldX = rFndRecords.m_DescrimFlds[0];
    lDescFldY = rFndRecords.m_DescrimFlds[1];
  }

  kdt1.m_foundRecords.clear();
}
