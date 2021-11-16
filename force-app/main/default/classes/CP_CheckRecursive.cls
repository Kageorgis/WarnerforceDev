/*========================================================================================================================
* @author: Kalash 
* @date: 13/08/2021
* @description: Checking Recursive.
==========================================================================================================================*/
public Class CP_CheckRecursive{
    public static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}