/* Description    :   Class implements iterator of task wrapper. Used to set pagination.
   Author         :   Prachi Gadewar
   Emp ID         :   489635
*  Date           :   11 – Sep- 2015
*  
*  =============================================================================================  
*                                     Change History
* =============================================================================================
*  Author                               Date                                       Comment
*                                                                                   CHO1
*            
*  
*/

global class  WB_CustomTaskIterable implements Iterator<list<WB_TaskWrapper>>
{ 
   list<WB_TaskWrapper> InnerList{get; set;}
   list<WB_TaskWrapper> ListRequested{get; set;}

   Integer i {get; set;} 
   public Integer setPageSize {get; set;} 

   public WB_CustomTaskIterable(List<WB_TaskWrapper> listAllTask)
   {
       InnerList = new list<WB_TaskWrapper>(); 
       ListRequested = new list<WB_TaskWrapper>();     
       InnerList = listAllTask;
       setPageSize = 10;
       i = 0; 
   }   

   global boolean hasNext(){ 
       if(i >= InnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   global boolean hasPrevious(){ 
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }   

   global list<WB_TaskWrapper> next(){      
       ListRequested = new list<WB_TaskWrapper>(); 
       integer startNumber;
       integer size = InnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
                      
           for(integer start = startNumber; start < i; start++)
           {
               ListRequested.add(InnerList[start]);
           }
       } 
       return ListRequested;
   } 
   
   global list<WB_TaskWrapper> previous(){      
       ListRequested = new list<WB_TaskWrapper>(); 
       system.debug('i value is previous before =====' + i);
       integer size = InnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           ListRequested.add(InnerList[start]);
       } 
       return ListRequested;
   }   
}