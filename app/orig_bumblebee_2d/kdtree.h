#ifndef KDTREE_H
#define KDTREE_H

/* PURPOSE: a record in a k-d binary search tree. a record is made up of
            fields.
*/
typedef struct
{
  long* m_DescrimFlds;
} record



#if 0
class CKDTRecord
{  
public:
  CKDTRecord() {} // default constructor
  ~CKDTRecord() {} // default destructor
  void AddDescriminatorFld(long desc_data); // add descriminator field
  const long& GetCurrentDescriminatorFld(int nDiscIndex); // get current descriminator field
  const CKDTRecord& operator=(const CKDTRecord& b);
  bool operator==(const CKDTRecord& b) const;
  bool operator<=(const CKDTRecord& b) const;

  vector< long > m_DescrimFlds; // descriminator data fields
};
#endif

/* PURPOSE: a node in the k-d binary tree
*/
#if 0
class CKDTreeNode
{      
public:
  CKDTreeNode();  // default constructor
  ~CKDTreeNode() {}  // default destructor

  long            m_lRefCnt;     // reference count, the number of copies that have the same point
  CKDTRecord      m_KDTRecord;   // node record data

protected:
  CKDTreeNode*    m_pLeftNode;   // left child pointer
  CKDTreeNode*    m_pRightNode;  // right child pointer
  friend class CKDTree;
};
#endif

/* PURPOSE: a k-d binary tree
*/
#if 0
class CKDTree
{
public:
  void Insert(CKDTRecord rec);
  CKDTreeNode* ExactFind(CKDTRecord recToFind);
  void RangeFind(CKDTRecord recLower, CKDTRecord recUpper, CKDTreeNode* pTreeNode, int iLevel);

  CKDTreeNode* GetRootNode() const { return m_pRoot; }
  unsigned GetNumberOfKDTNodes() const;
  void ReInitializeVariables();

  bool IsEmpty();

  CKDTree();  // constructor for the k-d binary tree
  ~CKDTree(); // destructor for the k-d binary tree
  CKDTree(const CKDTree& b); // Copy constructor
  const CKDTree& operator=(const CKDTree& b);

  vector< CKDTRecord > m_foundRecords; // found records within range search

private:
  void Free(CKDTreeNode* node);
  void Copy(const CKDTree& b);
  void CopyNodes(CKDTreeNode* b);

  int m_iLevel;
  int m_iDimmension;
  int m_iDiscriminator;

  unsigned   m_nNumNodes;     // number of nodes
  CKDTreeNode* m_ptnCurPos;      // a cursor for our k-d tree
  CKDTreeNode* m_pRoot;     // pointer to the root of the k-d tree
};
#endif

#endif
