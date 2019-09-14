/****************************************************************************
** Work Notes:
- fix Copy constructor
****************************************************************************/

#include "kdtree_cpp.h"

using namespace std;

/* PURPOSE:  add descriminator data field information
   RECEIVES: desc_data - a field's worth of descriminator field data to
             be inserted into the descriminator field porton of the 
             record.
   RETURNS:  nothing
   REMARKS:
*/
void CKDTRecord::AddDescriminatorFld(long desc_data)
{  
  m_DescrimFlds.push_back(desc_data);
}

/* PURPOSE:   get current descriminator field and return it's reference
   RECEIVES:  nothing
   RETURNS:   the object in the field
   REMARKS:
*/
const long& CKDTRecord::GetCurrentDescriminatorFld(int nDiscIndex)
{  
  return m_DescrimFlds[nDiscIndex];
}    

/* PURPOSE:  assignment operator for the record data type
   RECEIVES: b - a reference to the list to be assigned
   RETURNS:  this works only with info data that also has an operator=
   REMARKS:
*/
const CKDTRecord& CKDTRecord::operator=(const CKDTRecord& b)
{  
  if(&(*this) != &b)
  {  
    m_DescrimFlds = b.m_DescrimFlds;
  }
  return (*this);
}

bool CKDTRecord::operator==(const CKDTRecord& b)  const
{
  bool bResult = true;

  if(&(*this) != &b)
  {
    for(int i = 0; i < b.m_DescrimFlds.size(); i++)
    {
      if(m_DescrimFlds[i] != b.m_DescrimFlds[i])
      {
        bResult = false;
        break;
      }
    }
  }

  return bResult;
}

bool CKDTRecord::operator<=(const CKDTRecord& b)  const
{
  bool bResult = true;

  if(&(*this) != &b)
  {
    for(int i = 0; i < b.m_DescrimFlds.size(); i++)
    {
      if(m_DescrimFlds[i] > b.m_DescrimFlds[i])
      {
        bResult = false;
        break;
      }
    }
  }

  return bResult;
}

/* PURPOSE:  constructor for the tree node
*/
CKDTreeNode::CKDTreeNode()  
:  m_KDTRecord(),
   m_pLeftNode(NULL),
   m_pRightNode(NULL),
   m_lRefCnt(1)
{}   

/* PURPOSE:  constructor for the k-d binary tree
*/
CKDTree::CKDTree()
:  m_nNumNodes(0),
   m_ptnCurPos(NULL),
   m_pRoot(NULL),
   m_iLevel(0),
   m_iDimmension(0),
   m_iDiscriminator(0)
{}

/* PURPOSE:  destuctor for the k-d binary tree
*/
CKDTree::~CKDTree()
{  
  Free(m_pRoot);
}

/* PURPOSE:   tests whether the k-d binary search tree is empty
   RETURNS:   true - if the k-d binary search tree is empty
              false - if the k-d binary search tree is not empty
*/
bool CKDTree::IsEmpty()
{  
  return (m_pRoot == NULL ? true : false);
}

/* PURPOSE:  returns the number of nodes in the k-d binary tree
   RECEIVES: nothing
   RETURNS:  the number of nodes in the k-d binary tree
*/
unsigned CKDTree::GetNumberOfKDTNodes() const
{  
  return m_nNumNodes;
}

/* PURPOSE:  inserts record into the k-d binary tree
   RECEIVES: rec - the record to be inserted into the k-d tree
   RETURNS:  nothing
*/
void CKDTree::Insert(CKDTRecord rec)
{  
  CKDTreeNode* pPrev; // pointer to the previous node
  CKDTreeNode* pTreeNode = new CKDTreeNode;
  m_iLevel = 0;
  m_iDimmension = 0;
  m_iDiscriminator = 0;
  pTreeNode->m_KDTRecord = rec; // assign the record to our new node
  pTreeNode->m_pLeftNode = NULL;  // make sure left and right pointers are NULL
  pTreeNode->m_pRightNode = NULL;
  m_iDimmension = pTreeNode->m_KDTRecord.m_DescrimFlds.size();

  m_ptnCurPos = m_pRoot; // resets the tree cursor
  pPrev = m_ptnCurPos; // sets up the previous node pointer
  m_nNumNodes++; // now we have one more node
  if(m_pRoot == NULL)
  {  
    pTreeNode->m_pLeftNode = NULL;
    pTreeNode->m_pRightNode = NULL;
    m_pRoot = pTreeNode; // set up the new root address
  }
  else // position to be inserted has to be in the right or left subtree
  {  
    while(m_pRoot != NULL)
    {  
      pPrev = m_ptnCurPos;
      long ltnX = pTreeNode->m_KDTRecord.m_DescrimFlds[0];
      long ltnY = pTreeNode->m_KDTRecord.m_DescrimFlds[1];
      long lcnX = m_ptnCurPos->m_KDTRecord.m_DescrimFlds[0];
      long lcnY = m_ptnCurPos->m_KDTRecord.m_DescrimFlds[1];

      m_iDiscriminator = m_iLevel % m_iDimmension;
      long ltnCDF = pTreeNode->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator);
      long lcnCDF = m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator);

#if 0
      for(long i = 0; i < m_iDimmension && (m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(i) == pTreeNode->m_KDTRecord.GetCurrentDescriminatorFld(i)); i++ );
      if(i == m_iDimmension)
#endif
      if(m_ptnCurPos->m_KDTRecord == pTreeNode->m_KDTRecord)
        m_ptnCurPos->m_lRefCnt++; // means we have more than one point at the same location
      if(pTreeNode->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator) <= m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator))
      {  
        m_iLevel++;
        m_ptnCurPos = m_ptnCurPos->m_pLeftNode;
        if(m_ptnCurPos == NULL)
        {  
          pPrev->m_pLeftNode = pTreeNode;
          break;
        }
      }
      else
      {  
        m_iLevel++;
        m_ptnCurPos = m_ptnCurPos->m_pRightNode;
        if(m_ptnCurPos == NULL)
        {  
          pPrev->m_pRightNode = pTreeNode;
          break;
        }
      }
    }
  }
}

/* PURPOSE:  tries to find the exact record in the k-d tree
   RECEIVES: recToFind - the record to be found in the k-d tree
   RETURNS:  a pointer to the node containing the record or
             a NULL pointer saying that record was not found
*/
CKDTreeNode* CKDTree::ExactFind(CKDTRecord recToFind)
{
  m_ptnCurPos = NULL;

  m_iLevel = 0;
  m_iDimmension = 0;
  m_iDiscriminator = 0;

  if(m_pRoot)
  {
    m_iDimmension = m_pRoot->m_KDTRecord.m_DescrimFlds.size();

    m_ptnCurPos = m_pRoot;

    while(m_pRoot != NULL)
    {  
      long ltnX = recToFind.m_DescrimFlds[0];
      long ltnY = recToFind.m_DescrimFlds[1];
      long lcnX = m_ptnCurPos->m_KDTRecord.m_DescrimFlds[0];
      long lcnY = m_ptnCurPos->m_KDTRecord.m_DescrimFlds[1];

      m_iDiscriminator = m_iLevel % m_iDimmension;
      long ltnCDF = recToFind.GetCurrentDescriminatorFld(m_iDiscriminator);
      long lcnCDF = m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator);

      long i = 0;
      for(; i < m_iDimmension && (m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(i) == recToFind.GetCurrentDescriminatorFld(i)); i++ );
      if(i == m_iDimmension)
      {
        break; // we have found an exact match!
      }
      if(recToFind.GetCurrentDescriminatorFld(m_iDiscriminator) <= m_ptnCurPos->m_KDTRecord.GetCurrentDescriminatorFld(m_iDiscriminator))
      {  
        m_iLevel++;
        m_ptnCurPos = m_ptnCurPos->m_pLeftNode;
        if(m_ptnCurPos == NULL)
        {  
          break; // it is not in the tree
        }
      }
      else
      {  
        m_iLevel++;
        m_ptnCurPos = m_ptnCurPos->m_pRightNode;
        if(m_ptnCurPos == NULL)
        {  
          break; // it is not in the tree
        }
      }
    }
  }

  return m_ptnCurPos;
}

/* PURPOSE:  tries to find a range of records in the k-d tree
   RECEIVES: CKDTRecord recLower - the lower bound of the k-d rectangle
             CKDTRecord recUpper - the upper bound of the k-d rectangle
             CKDTreeNode* pTreeNode - a pointer to the current node for comparison in the k-d tree
   RETURNS:  nothing out of this function.  but if it finds a something
             within the bounded rectangle it will add the record to the found list.
*/
void CKDTree::RangeFind(CKDTRecord recLower, CKDTRecord recUpper, CKDTreeNode* pTreeNode, int iLevel)
{
  if(pTreeNode == NULL)
    return;

  // is recLower less than equal current record
  if( recLower.GetCurrentDescriminatorFld(iLevel) <= pTreeNode->m_KDTRecord.GetCurrentDescriminatorFld(iLevel))
    RangeFind(recLower, recUpper, pTreeNode->m_pLeftNode, ((iLevel+1) % m_iDimmension));

  if((recLower <= pTreeNode->m_KDTRecord) && (pTreeNode->m_KDTRecord <= recUpper))
    m_foundRecords.push_back(pTreeNode->m_KDTRecord);

  // is recUpper greater than current record
  if( recUpper.GetCurrentDescriminatorFld(iLevel) > pTreeNode->m_KDTRecord.GetCurrentDescriminatorFld(iLevel))
    RangeFind(recLower, recUpper, pTreeNode->m_pRightNode, ((iLevel+1) % m_iDimmension));

  return;
}

void CKDTree::ReInitializeVariables()
{
  m_iLevel = 0;
  m_iDiscriminator = 0;

  if(m_pRoot == NULL)
    m_iDimmension = 0;
  else
    m_iDimmension = m_pRoot->m_KDTRecord.m_DescrimFlds.size();
}

/* PURPOSE:  deletes the k-d binary tree from memory
*/
void CKDTree::Free(CKDTreeNode* node)
{  
  if(node != NULL)
  {  
    Free(node->m_pLeftNode);
    Free(node->m_pRightNode);
    delete node;
  }
}

/* PURPOSE: copies k-d Binary Tree b to a
   RECEIVES: b - a reference to the k-d binary tree
   RETURNS:  a Copy of the k-d binary tree
*/
void CKDTree::Copy(const CKDTree& b)
{  
  CopyNodes(b.m_pRoot);
}

/* PURPOSE:  copies the nodes of the k-d Binary Tree from b to a
             (remember (*this) (*this) is a)
   RECEIVES: b - pointer to the b k-d Binary Tree nodes
   RETURNS:  a Copy of the k-d Binary Tree b nodes as the implicit argument
   REMARKS:  this routine basically appends the b Tree nodes to the implict
             argument.
*/
void CKDTree::CopyNodes(CKDTreeNode* b)
{  
#if 0 
  if(b != NULL)
  {  
    Insert(b->_info);
    CopyNodes(b->m_pLeftNode);
    CopyNodes(b->m_pRightNode);
  }                    
#endif
}

/* PURPOSE:  Copy constructor
   RECEIVES:  b - a reference to the k-d binary tree to be assigned
*/
CKDTree::CKDTree(const CKDTree& b)
{  
  Copy(b);
}

/* PURPOSE:  the assignment operator for this class
   RECEIVES:  b - a reference to the k-d binary tree to be assigned
   REMARKS:   this works only with info data that also has an operator=
*/
const CKDTree& CKDTree::operator=(const CKDTree& b)
{  
  if(&(*this) != &b)
  {  
    Free(m_pRoot);
    Copy(b);
  }
  return (*this);
}

